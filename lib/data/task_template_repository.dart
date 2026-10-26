import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'database.dart';

/// The subtask list of a template is stored as a JSON array of titles, so a
/// template stays readable in backups and independent of the subtasks table.
String encodeSubtaskTitles(List<String> titles) => jsonEncode(titles);

/// Reads back what [encodeSubtaskTitles] wrote. Also accepts an array of
/// objects with a `title` key, so an older backup still loads.
List<String> decodeSubtaskTitles(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final item in decoded)
        if (item is String && item.isNotEmpty)
          item
        else if (item is Map && item['title'] is String)
          item['title'] as String,
    ];
  } on FormatException {
    return const [];
  }
}

class TaskTemplateRepository {
  final AppDatabase db;
  TaskTemplateRepository(this.db);

  Stream<List<TaskTemplate>> watchTaskTemplates() {
    return db.select(db.taskTemplates).watch();
  }

  Future<List<TaskTemplate>> getTaskTemplates() async {
    return db.select(db.taskTemplates).get();
  }

  Future<void> insertTaskTemplate(TaskTemplate template) async {
    await db.into(db.taskTemplates).insert(template);
  }

  Future<void> updateTaskTemplate(TaskTemplate template) async {
    await db.update(db.taskTemplates).replace(template);
  }

  Future<void> deleteTaskTemplate(String id) async {
    await (db.delete(db.taskTemplates)..where((t) => t.id.equals(id))).go();
  }

  /// Saves a task as a reusable template: name, type, estimate and the
  /// titles of its subtasks (design section 5.9).
  Future<TaskTemplate> saveFromTask(
    Task task,
    String name,
    List<String> subtaskTitles,
  ) async {
    final template = TaskTemplate(
      id: const Uuid().v4(),
      name: name,
      type: task.type,
      estimateMinutes: task.estimateMinutes,
      subtasksJson: encodeSubtaskTitles(subtaskTitles),
    );
    await insertTaskTemplate(template);
    return template;
  }
}
