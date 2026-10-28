import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../data/database.dart';
import '../data/models.dart';
import 'package:drift/drift.dart';

/// Thrown when a backup file cannot be trusted. The message is shown to
/// the user, and the import never touches the existing database.
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Roots an imported `file` attachment may never point into.
///
/// The attachment screen shares whatever path a row names, so a hostile
/// backup could plant `/data/user/0/<pkg>/databases/lekas.sqlite` next to a
/// plausible task and have the share sheet hand the database to whichever
/// app the user picks. A path under these prefixes is always app private:
/// no file picker on earth hands one out, so a backup carrying one is
/// either hostile or taken from a dead install and useless here anyway.
const List<String> kUntrustedAttachmentPrefixes = [
  '/data/data/',
  '/data/user/',
  '/data/misc/',
];

/// Whether an imported attachment row may be kept (design section 7.6).
///
/// `file` rows must stay outside app private storage, and `link` rows must
/// really be http links; the schema itself accepts any string, so the
/// import is the last place that can refuse them.
bool isSafeImportedAttachment(
  Attachment row, {
  List<String> blockedPrefixes = kUntrustedAttachmentPrefixes,
}) {
  if (row.kind == 'link') {
    return row.pathOrUrl.startsWith('http://') ||
        row.pathOrUrl.startsWith('https://');
  }
  for (final prefix in blockedPrefixes) {
    if (row.pathOrUrl.startsWith(prefix)) return false;
  }
  return true;
}

class BackupService {
  final AppDatabase db;
  BackupService(this.db);

  static const String backupVersion = '1.0';

  /// Files above this are refused before a single byte is parsed, so a
  /// corrupt or hostile file cannot exhaust memory while decoding.
  static const int maxBackupBytes = 50 * 1024 * 1024;

  /// Exports all data to a JSON file.
  Future<File> exportToJson() async {
    final data = <String, dynamic>{};
    data['version'] = backupVersion;
    data['exportedAt'] = DateTime.now().millisecondsSinceEpoch;

    // Export all tables
    data['spaces'] = (await db.select(db.spaces).get()).map((e) => e.toJson()).toList();
    data['space_aliases'] = (await db.select(db.spaceAliases).get()).map((e) => e.toJson()).toList();
    data['space_meta'] = (await db.select(db.spaceMeta).get()).map((e) => e.toJson()).toList();
    data['tasks'] = (await db.select(db.tasks).get()).map((e) => e.toJson()).toList();
    data['subtasks'] = (await db.select(db.subtasks).get()).map((e) => e.toJson()).toList();
    data['class_slots'] = (await db.select(db.classSlots).get()).map((e) => e.toJson()).toList();
    data['tags'] = (await db.select(db.tags).get()).map((e) => e.toJson()).toList();
    data['task_tags'] = (await db.select(db.taskTags).get()).map((e) => e.toJson()).toList();
    data['attachments'] = (await db.select(db.attachments).get()).map((e) => e.toJson()).toList();
    data['reminders'] = (await db.select(db.reminders).get()).map((e) => e.toJson()).toList();
    data['task_events'] = (await db.select(db.taskEvents).get()).map((e) => e.toJson()).toList();
    data['focus_sessions'] = (await db.select(db.focusSessions).get()).map((e) => e.toJson()).toList();
    data['task_templates'] = (await db.select(db.taskTemplates).get()).map((e) => e.toJson()).toList();
    data['parser_prefs'] = (await db.select(db.parserPrefs).get()).map((e) => e.toJson()).toList();
    data['settings'] = (await db.select(db.settings).get()).map((e) => e.toJson()).toList();
    data['task_deps'] = (await db.select(db.taskDeps).get()).map((e) => e.toJson()).toList();
    data['class_exceptions'] = (await db.select(db.classExceptions).get()).map((e) => e.toJson()).toList();
    data['space_items'] = (await db.select(db.spaceItems).get()).map((e) => e.toJson()).toList();
    data['quick_links'] = (await db.select(db.quickLinks).get()).map((e) => e.toJson()).toList();
    data['class_notes'] = (await db.select(db.classNotes).get()).map((e) => e.toJson()).toList();
    data['diagnostics'] = (await db.select(db.diagnostics).get()).map((e) => e.toJson()).toList();
    data['grade_components'] = (await db.select(db.gradeComponents).get()).map((e) => e.toJson()).toList();
    data['saved_filters'] = (await db.select(db.savedFilters).get()).map((e) => e.toJson()).toList();
    data['attendance'] = (await db.select(db.attendance).get()).map((e) => e.toJson()).toList();

    // Compact encoding: a backup is machine data, and indentation roughly
    // doubles the size of a large database.
    final jsonString = jsonEncode(data);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/lekas_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);
    // Remembered for the weekly summary card about the last backup.
    await db.into(db.settings).insertOnConflictUpdate(Setting(
      key: 'last_backup_at',
      value: '${DateTime.now().millisecondsSinceEpoch}',
    ));
    return file;
  }

  /// Imports data from a JSON file. Mode is 'replace' or 'merge'.
  ///
  /// The whole file is decoded and type checked first, and the write runs
  /// in a single transaction, so a bad file leaves the current data alone.
  Future<Map<String, int>> importFromJson(File file, {String mode = 'replace'}) async {
    final size = await file.length();
    if (size > maxBackupBytes) {
      throw BackupFormatException(
        'Backup is larger than ${maxBackupBytes ~/ (1024 * 1024)} MB.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(await file.readAsString());
    } on FormatException catch (e) {
      throw BackupFormatException('Backup is not valid JSON: ${e.message}');
    } on FileSystemException {
      throw BackupFormatException('The backup file could not be read.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw BackupFormatException('The backup root is not a JSON object.');
    }
    final data = decoded;

    final version = data['version'];
    if (version is! String || version.isEmpty) {
      throw BackupFormatException('The backup has no valid version field.');
    }

    // Decode every row before anything is deleted.
    final spaces = _decode<Space>(data, 'spaces', Space.fromJson);
    final aliases = _decode<SpaceAliase>(data, 'space_aliases', SpaceAliase.fromJson);
    final spaceMeta = _decode<SpaceMetaData>(data, 'space_meta', SpaceMetaData.fromJson);
    final tasks = _decode<Task>(data, 'tasks', Task.fromJson);
    final subtasks = _decode<Subtask>(data, 'subtasks', Subtask.fromJson);
    final slots = _decode<ClassSlot>(data, 'class_slots', ClassSlot.fromJson);
    // A class slot only makes sense on one weekday of a real lesson hour;
    // an imported row outside that range made the schedule screen index
    // past the end of its weekday list and shifted the quiet hour window.
    slots.removeWhere((row) =>
        row.weekday < 1 ||
        row.weekday > 7 ||
        row.startMin < 0 ||
        row.endMin > 24 * 60 ||
        row.startMin >= row.endMin);
    final tags = _decode<Tag>(data, 'tags', Tag.fromJson);
    final taskTags = _decode<TaskTag>(data, 'task_tags', TaskTag.fromJson);
    final attachments = _decode<Attachment>(data, 'attachments', Attachment.fromJson);
    // A row only says where a file was; the attachment screen reads that
    // path and shares the file, so the import drops rows that point into
    // app private storage or claim to be links they are not.
    attachments.removeWhere((row) => !isSafeImportedAttachment(row));
    final reminders = _decode<Reminder>(data, 'reminders', Reminder.fromJson);
    final events = _decode<TaskEvent>(data, 'task_events', TaskEvent.fromJson);
    final sessions = _decode<FocusSession>(data, 'focus_sessions', FocusSession.fromJson);
    final templates = _decode<TaskTemplate>(data, 'task_templates', TaskTemplate.fromJson);
    final parserPrefs = _decode<ParserPref>(data, 'parser_prefs', ParserPref.fromJson);
    final settings = _decode<Setting>(data, 'settings', Setting.fromJson);
    final deps = _decode<TaskDep>(data, 'task_deps', TaskDep.fromJson);
    final exceptions = _decode<ClassException>(data, 'class_exceptions', ClassException.fromJson);
    final items = _decode<SpaceItem>(data, 'space_items', SpaceItem.fromJson);
    final quickLinks = _decode<QuickLink>(data, 'quick_links', QuickLink.fromJson);
    final classNotes = _decode<ClassNote>(data, 'class_notes', ClassNote.fromJson);
    final diagnostics = _decode<Diagnostic>(data, 'diagnostics', Diagnostic.fromJson);
    final grades = _decode<GradeComponent>(data, 'grade_components', GradeComponent.fromJson);
    final filters = _decode<SavedFilter>(data, 'saved_filters', SavedFilter.fromJson);
    final attendance = _decode<AttendanceData>(data, 'attendance', AttendanceData.fromJson);

    final stats = <String, int>{};
    void count(String key, List<dynamic> rows) {
      if (data.containsKey(key)) stats[key] = rows.length;
    }

    count('spaces', spaces);
    count('space_aliases', aliases);
    count('space_meta', spaceMeta);
    count('tasks', tasks);
    count('subtasks', subtasks);
    count('class_slots', slots);
    count('tags', tags);
    count('task_tags', taskTags);
    count('attachments', attachments);
    count('reminders', reminders);
    count('task_events', events);
    count('focus_sessions', sessions);
    count('task_templates', templates);
    count('parser_prefs', parserPrefs);
    count('settings', settings);
    count('task_deps', deps);
    count('class_exceptions', exceptions);
    count('space_items', items);
    count('quick_links', quickLinks);
    count('class_notes', classNotes);
    count('diagnostics', diagnostics);
    count('grade_components', grades);
    count('saved_filters', filters);
    count('attendance', attendance);

    Future<void> putAll<D>(List<D> rows, Future<void> Function(D) write) async {
      for (final row in rows) {
        await write(row);
      }
    }

    await db.transaction(() async {
      if (mode == 'replace') {
        // Children first: delete everything this app owns.
        await db.delete(db.savedFilters).go();
        await db.delete(db.attendance).go();
        await db.delete(db.gradeComponents).go();
        await db.delete(db.diagnostics).go();
        await db.delete(db.classNotes).go();
        await db.delete(db.quickLinks).go();
        await db.delete(db.spaceItems).go();
        await db.delete(db.classExceptions).go();
        await db.delete(db.taskDeps).go();
        await db.delete(db.settings).go();
        await db.delete(db.parserPrefs).go();
        await db.delete(db.taskTemplates).go();
        await db.delete(db.focusSessions).go();
        await db.delete(db.taskEvents).go();
        await db.delete(db.reminders).go();
        await db.delete(db.attachments).go();
        await db.delete(db.taskTags).go();
        await db.delete(db.tags).go();
        await db.delete(db.classSlots).go();
        await db.delete(db.subtasks).go();
        await db.delete(db.tasks).go();
        await db.delete(db.spaceMeta).go();
        await db.delete(db.spaceAliases).go();
        await db.delete(db.spaces).go();
      }

      await putAll(spaces, (row) => db.into(db.spaces).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(aliases, (row) => db.into(db.spaceAliases).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(spaceMeta, (row) => db.into(db.spaceMeta).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(tasks, (row) => db.into(db.tasks).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(subtasks, (row) => db.into(db.subtasks).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(slots, (row) => db.into(db.classSlots).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(tags, (row) => db.into(db.tags).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(taskTags, (row) => db.into(db.taskTags).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(attachments, (row) => db.into(db.attachments).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(reminders, (row) => db.into(db.reminders).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(events, (row) => db.into(db.taskEvents).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(sessions, (row) => db.into(db.focusSessions).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(templates, (row) => db.into(db.taskTemplates).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(parserPrefs, (row) => db.into(db.parserPrefs).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(settings, (row) => db.into(db.settings).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(deps, (row) => db.into(db.taskDeps).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(exceptions, (row) => db.into(db.classExceptions).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(items, (row) => db.into(db.spaceItems).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(quickLinks, (row) => db.into(db.quickLinks).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(classNotes, (row) => db.into(db.classNotes).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(diagnostics, (row) => db.into(db.diagnostics).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(grades, (row) => db.into(db.gradeComponents).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(filters, (row) => db.into(db.savedFilters).insert(row, mode: InsertMode.insertOrReplace));
      await putAll(attendance, (row) => db.into(db.attendance).insert(row, mode: InsertMode.insertOrReplace));
    });

    return stats;
  }

  /// Reads one table out of a backup and checks every row, or throws
  /// [BackupFormatException] naming the table and the row at fault.
  List<D> _decode<D>(
    Map<String, dynamic> data,
    String key,
    D Function(Map<String, dynamic> json) fromJson,
  ) {
    final raw = data[key];
    if (raw == null) return <D>[];
    if (raw is! List) {
      throw BackupFormatException('Key "$key" must be a list of objects.');
    }

    final rows = <D>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is! Map) {
        throw BackupFormatException('Row $i of "$key" is not a JSON object.');
      }
      final json = item.map((dynamic k, dynamic v) => MapEntry(k.toString(), v));
      try {
        rows.add(fromJson(json));
      } catch (e) {
        throw BackupFormatException('Row $i of "$key" is not usable: $e');
      }
    }
    return rows;
  }

  /// Picks the folder used for automatic backups (Storage Access Framework).
  Future<String?> pickBackupFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    return result;
  }
}
