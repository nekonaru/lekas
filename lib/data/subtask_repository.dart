import 'package:drift/drift.dart';
import 'database.dart';
import 'models.dart';

class SubtaskRepository {
  final AppDatabase db;
  SubtaskRepository(this.db);

  Stream<List<Subtask>> watchSubtasks(String taskId) {
    return db.select(db.subtasks)..where(
      db.subtasks.taskId.equals(taskId).and(db.subtasks.deletedAt.isNull()),
    ).watch();
  }

  Future<List<Subtask>> getSubtasks(String taskId) async {
    return db.select(db.subtasks)..where(
      db.subtasks.taskId.equals(taskId).and(db.subtasks.deletedAt.isNull()),
    ).get();
  }

  Future<void> insertSubtask(Subtask subtask) async {
    await db.into(db.subtasks).insert(subtask);
  }

  Future<void> updateSubtask(Subtask subtask) async {
    await db.update(db.subtasks).replace(subtask);
  }

  Future<void> toggleSubtask(String id, bool done) async {
    await db.update(db.subtasks).replace(Subtask(
      id: id,
      taskId: '',
      title: '',
      done: done,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> deleteSubtask(String id) async {
    await db.update(db.subtasks).replace(Subtask(
      id: id,
      taskId: '',
      title: '',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      deletedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}
