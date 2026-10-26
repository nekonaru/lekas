import 'package:drift/drift.dart';
import 'database.dart';

class TaskEventRepository {
  final AppDatabase db;
  TaskEventRepository(this.db);

  Stream<List<TaskEvent>> watchTaskEvents(String taskId) {
    return (db.select(db.taskEvents)
          ..where((t) => t.taskId.equals(taskId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<TaskEvent>> getTaskEvents(String taskId) async {
    return (db.select(db.taskEvents)
          ..where((t) => t.taskId.equals(taskId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> insertTaskEvent(TaskEvent event) async {
    await db.into(db.taskEvents).insert(event);
  }
}
