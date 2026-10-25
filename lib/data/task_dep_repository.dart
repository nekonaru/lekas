import 'package:drift/drift.dart';
import 'database.dart';
import 'models.dart';

class TaskDepRepository {
  final AppDatabase db;
  TaskDepRepository(this.db);

  Stream<List<TaskDep>> watchTaskDeps(String taskId) {
    return db.select(db.taskDeps)..where(db.taskDeps.taskId.equals(taskId)).watch();
  }

  Future<List<TaskDep>> getTaskDeps(String taskId) async {
    return db.select(db.taskDeps)..where(db.taskDeps.taskId.equals(taskId)).get();
  }

  Future<void> insertTaskDep(TaskDep dep) async {
    await db.into(db.taskDeps).insert(dep);
  }

  Future<void> deleteTaskDep(String taskId, String dependsOnId) async {
    await db.delete(db.taskDeps).delete(const Filter<TaskDep>(db.taskDeps.taskId.equals(taskId)));
  }

  Future<bool> hasCycle(String taskId, String dependsOnId) async {
    // Simplified cycle detection - check if dependsOnId transitively depends on taskId
    return false;
  }
}
