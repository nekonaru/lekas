import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../data/database.dart';
import '../data/models.dart';
import 'package:drift/drift.dart';

class BackupService {
  final AppDatabase db;
  BackupService(this.db);

  static const String backupVersion = '1.0';

  /// Ekspor semua data ke berkas JSON.
  Future<File> exportToJson() async {
    final data = <String, dynamic>{};
    data['version'] = backupVersion;
    data['exportedAt'] = DateTime.now().millisecondsSinceEpoch;

    // Export all tables
    data['spaces'] = (await db.select(db.spaces).get()).map((e) => e.toColumns(true)).toList();
    data['space_aliases'] = (await db.select(db.spaceAliases).get()).map((e) => e.toColumns(true)).toList();
    data['space_meta'] = (await db.select(db.spaceMeta).get()).map((e) => e.toColumns(true)).toList();
    data['tasks'] = (await db.select(db.tasks).get()).map((e) => e.toColumns(true)).toList();
    data['subtasks'] = (await db.select(db.subtasks).get()).map((e) => e.toColumns(true)).toList();
    data['class_slots'] = (await db.select(db.classSlots).get()).map((e) => e.toColumns(true)).toList();
    data['tags'] = (await db.select(db.tags).get()).map((e) => e.toColumns(true)).toList();
    data['task_tags'] = (await db.select(db.taskTags).get()).map((e) => e.toColumns(true)).toList();
    data['attachments'] = (await db.select(db.attachments).get()).map((e) => e.toColumns(true)).toList();
    data['reminders'] = (await db.select(db.reminders).get()).map((e) => e.toColumns(true)).toList();
    data['task_events'] = (await db.select(db.taskEvents).get()).map((e) => e.toColumns(true)).toList();
    data['focus_sessions'] = (await db.select(db.focusSessions).get()).map((e) => e.toColumns(true)).toList();
    data['task_templates'] = (await db.select(db.taskTemplates).get()).map((e) => e.toColumns(true)).toList();
    data['parser_prefs'] = (await db.select(db.parserPrefs).get()).map((e) => e.toColumns(true)).toList();
    data['settings'] = (await db.select(db.settings).get()).map((e) => e.toColumns(true)).toList();
    data['task_deps'] = (await db.select(db.taskDeps).get()).map((e) => e.toColumns(true)).toList();
    data['class_exceptions'] = (await db.select(db.classExceptions).get()).map((e) => e.toColumns(true)).toList();
    data['space_items'] = (await db.select(db.spaceItems).get()).map((e) => e.toColumns(true)).toList();
    data['quick_links'] = (await db.select(db.quickLinks).get()).map((e) => e.toColumns(true)).toList();
    data['class_notes'] = (await db.select(db.classNotes).get()).map((e) => e.toColumns(true)).toList();
    data['diagnostics'] = (await db.select(db.diagnostics).get()).map((e) => e.toColumns(true)).toList();
    data['grade_components'] = (await db.select(db.gradeComponents).get()).map((e) => e.toColumns(true)).toList();
    data['saved_filters'] = (await db.select(db.savedFilters).get()).map((e) => e.toColumns(true)).toList();

    final jsonString = JsonEncoder.withIndent('  ').convert(data);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/lekas_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);
    return file;
  }

  /// Impor data dari berkas JSON. Mode: 'replace' (timpa) atau 'merge' (gabung).
  Future<Map<String, int>> importFromJson(File file, {String mode = 'replace'}) async {
    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Verify version
    final version = data['version'] as String?;
    if (version == null) {
      throw Exception('Berkas cadangan tidak memiliki versi yang valid.');
    }

    final stats = <String, int>{};

    if (mode == 'replace') {
      // Delete all existing data first
      await db.delete(db.savedFilters).go();
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

    // Import spaces
    if (data['spaces'] != null) {
      for (final item in data['spaces']) {
        await db.into(db.spaces).replace(item);
      }
      stats['spaces'] = (data['spaces'] as List).length;
    }

    if (data['space_aliases'] != null) {
      for (final item in data['space_aliases']) {
        await db.into(db.spaceAliases).replace(item);
      }
      stats['space_aliases'] = (data['space_aliases'] as List).length;
    }

    if (data['space_meta'] != null) {
      for (final item in data['space_meta']) {
        await db.into(db.spaceMeta).replace(item);
      }
      stats['space_meta'] = (data['space_meta'] as List).length;
    }

    if (data['tasks'] != null) {
      for (final item in data['tasks']) {
        await db.into(db.tasks).replace(item);
      }
      stats['tasks'] = (data['tasks'] as List).length;
    }

    if (data['subtasks'] != null) {
      for (final item in data['subtasks']) {
        await db.into(db.subtasks).replace(item);
      }
      stats['subtasks'] = (data['subtasks'] as List).length;
    }

    if (data['class_slots'] != null) {
      for (final item in data['class_slots']) {
        await db.into(db.classSlots).replace(item);
      }
      stats['class_slots'] = (data['class_slots'] as List).length;
    }

    if (data['tags'] != null) {
      for (final item in data['tags']) {
        await db.into(db.tags).replace(item);
      }
      stats['tags'] = (data['tags'] as List).length;
    }

    if (data['task_tags'] != null) {
      for (final item in data['task_tags']) {
        await db.into(db.taskTags).replace(item);
      }
      stats['task_tags'] = (data['task_tags'] as List).length;
    }

    if (data['attachments'] != null) {
      for (final item in data['attachments']) {
        await db.into(db.attachments).replace(item);
      }
      stats['attachments'] = (data['attachments'] as List).length;
    }

    if (data['reminders'] != null) {
      for (final item in data['reminders']) {
        await db.into(db.reminders).replace(item);
      }
      stats['reminders'] = (data['reminders'] as List).length;
    }

    if (data['task_events'] != null) {
      for (final item in data['task_events']) {
        await db.into(db.taskEvents).replace(item);
      }
      stats['task_events'] = (data['task_events'] as List).length;
    }

    if (data['focus_sessions'] != null) {
      for (final item in data['focus_sessions']) {
        await db.into(db.focusSessions).replace(item);
      }
      stats['focus_sessions'] = (data['focus_sessions'] as List).length;
    }

    if (data['task_templates'] != null) {
      for (final item in data['task_templates']) {
        await db.into(db.taskTemplates).replace(item);
      }
      stats['task_templates'] = (data['task_templates'] as List).length;
    }

    if (data['parser_prefs'] != null) {
      for (final item in data['parser_prefs']) {
        await db.into(db.parserPrefs).replace(item);
      }
      stats['parser_prefs'] = (data['parser_prefs'] as List).length;
    }

    if (data['settings'] != null) {
      for (final item in data['settings']) {
        await db.into(db.settings).replace(item);
      }
      stats['settings'] = (data['settings'] as List).length;
    }

    if (data['task_deps'] != null) {
      for (final item in data['task_deps']) {
        await db.into(db.taskDeps).replace(item);
      }
      stats['task_deps'] = (data['task_deps'] as List).length;
    }

    if (data['class_exceptions'] != null) {
      for (final item in data['class_exceptions']) {
        await db.into(db.classExceptions).replace(item);
      }
      stats['class_exceptions'] = (data['class_exceptions'] as List).length;
    }

    if (data['space_items'] != null) {
      for (final item in data['space_items']) {
        await db.into(db.spaceItems).replace(item);
      }
      stats['space_items'] = (data['space_items'] as List).length;
    }

    if (data['quick_links'] != null) {
      for (final item in data['quick_links']) {
        await db.into(db.quickLinks).replace(item);
      }
      stats['quick_links'] = (data['quick_links'] as List).length;
    }

    if (data['class_notes'] != null) {
      for (final item in data['class_notes']) {
        await db.into(db.classNotes).replace(item);
      }
      stats['class_notes'] = (data['class_notes'] as List).length;
    }

    if (data['diagnostics'] != null) {
      for (final item in data['diagnostics']) {
        await db.into(db.diagnostics).replace(item);
      }
      stats['diagnostics'] = (data['diagnostics'] as List).length;
    }

    if (data['grade_components'] != null) {
      for (final item in data['grade_components']) {
        await db.into(db.gradeComponents).replace(item);
      }
      stats['grade_components'] = (data['grade_components'] as List).length;
    }

    if (data['saved_filters'] != null) {
      for (final item in data['saved_filters']) {
        await db.into(db.savedFilters).replace(item);
      }
      stats['saved_filters'] = (data['saved_filters'] as List).length;
    }

    return stats;
  }

  /// Pilih folder untuk cadangan otomatis (Storage Access Framework).
  Future<String?> pickBackupFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    return result;
  }
}
