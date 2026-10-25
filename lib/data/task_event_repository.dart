import 'package:drift/drift.dart';
import 'database.dart';
import 'models.dart';

class TaskEventRepository {
  final AppDatabase db;
  TaskEventRepository(this.db);

  Stream<List<TaskEvent>> watchTaskEvents(String taskId) {
    return db.select(db.taskEvents)..where(db.taskEvents.taskId.equals(taskId)).watch();
  }

  Future<List<TaskEvent>> getTaskEvents(String taskId) async {
    return db.select(db.taskEvents)..where(db.taskEvents.taskId.equals(taskId)).get();
  }

  Future<void> insertTaskEvent(TaskEvent event) async {
    await db.into(db.taskEvents).insert(event);
  }
}
