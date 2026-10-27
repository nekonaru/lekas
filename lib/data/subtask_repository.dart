import 'package:drift/drift.dart';
import 'database.dart';

class SubtaskRepository {
  final AppDatabase db;
  SubtaskRepository(this.db);

  Stream<List<Subtask>> watchSubtasks(String taskId) {
    return (db.select(db.subtasks)
          ..where((t) => t.taskId.equals(taskId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<List<Subtask>> getSubtasks(String taskId) async {
    return (db.select(db.subtasks)
          ..where((t) => t.taskId.equals(taskId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<void> insertSubtask(Subtask subtask) async {
    await db.into(db.subtasks).insert(subtask);
  }

  Future<void> updateSubtask(Subtask subtask) async {
    await db.update(db.subtasks).replace(subtask);
  }

  Future<void> toggleSubtask(String id, bool done) async {
    // Column update only: replace() here would blank taskId and title.
    await (db.update(db.subtasks)..where((t) => t.id.equals(id))).write(
      SubtasksCompanion(
        done: Value(done),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> deleteSubtask(String id) async {
    await (db.update(db.subtasks)..where((t) => t.id.equals(id))).write(
      SubtasksCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
