import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'database.dart';

/// Free tags such as `#kelompok` or `#revisi` (design section 5.9). The name
/// is stored normalized so `#Revisi` and `revisi` are the same tag.
String normalizeTagName(String raw) {
  final cleaned = raw.trim().replaceFirst(RegExp(r'^#+'), '');
  return cleaned.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

class TagRepository {
  final AppDatabase db;
  TagRepository(this.db);

  Stream<List<Tag>> watchTags() {
    return (db.select(db.tags)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<Tag>> getTags() async {
    return (db.select(db.tags)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Every tag of one task, in name order.
  Future<List<Tag>> tagsForTask(String taskId) async {
    final query = db.select(db.tags).join([
      innerJoin(db.taskTags, db.taskTags.tagId.equalsExp(db.tags.id)),
    ])
      ..where(db.taskTags.taskId.equals(taskId));
    final rows = await query.get();
    return [for (final row in rows) row.readTable(db.tags)]
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Tags of many tasks in one pass, keyed by task id (design section 5.9:
  /// cards and filters both show tags).
  Future<Map<String, List<String>>> tagsForTasks(
    Iterable<String> taskIds,
  ) async {
    final ids = taskIds.toSet();
    final result = <String, List<String>>{for (final id in ids) id: []};
    if (ids.isEmpty) return result;
    final query = db.select(db.taskTags).join([
      innerJoin(db.tags, db.tags.id.equalsExp(db.taskTags.tagId)),
    ])
      ..where(db.taskTags.taskId.isIn(ids));
    final rows = await query.get();
    for (final row in rows) {
      final link = row.readTable(db.taskTags);
      final tag = row.readTable(db.tags);
      result[link.taskId]?.add(tag.name);
    }
    for (final names in result.values) {
      names.sort();
    }
    return result;
  }

  /// Returns the tag with that name, creating it when missing.
  Future<Tag> ensureTag(String rawName) async {
    final name = normalizeTagName(rawName);
    final existing = await (db.select(db.tags)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) return existing;
    final tag = Tag(id: const Uuid().v4(), name: name);
    await db.into(db.tags).insert(tag, mode: InsertMode.insertOrIgnore);
    return (await (db.select(db.tags)..where((t) => t.name.equals(name)))
        .getSingle());
  }

  /// Replaces the whole tag set of a task (design section 5.9).
  Future<void> setTaskTags(String taskId, List<String> rawNames) async {
    final wanted = <String>{
      for (final raw in rawNames)
        if (normalizeTagName(raw).isNotEmpty) normalizeTagName(raw),
    };
    final tagIds = <String>[];
    for (final name in wanted) {
      tagIds.add((await ensureTag(name)).id);
    }
    await (db.delete(db.taskTags)..where((t) => t.taskId.equals(taskId))).go();
    for (final tagId in tagIds) {
      await db.into(db.taskTags).insert(
            TaskTag(taskId: taskId, tagId: tagId),
            mode: InsertMode.insertOrIgnore,
          );
    }
    await pruneEmptyTags();
  }

  /// Drops tags that no task carries any more, so the list stays clean.
  Future<void> pruneEmptyTags() async {
    final used = (await db.select(db.taskTags).get())
        .map((link) => link.tagId)
        .toSet();
    await (db.delete(db.tags)..where((t) => t.id.isNotIn(used))).go();
  }
}
