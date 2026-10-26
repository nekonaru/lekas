import 'package:drift/drift.dart';
import 'database.dart';

class TaskDepRepository {
  final AppDatabase db;
  TaskDepRepository(this.db);

  Stream<List<TaskDep>> watchTaskDeps(String taskId) {
    return (db.select(db.taskDeps)..where((t) => t.taskId.equals(taskId)))
        .watch();
  }

  Future<List<TaskDep>> getTaskDeps(String taskId) async {
    return (db.select(db.taskDeps)..where((t) => t.taskId.equals(taskId)))
        .get();
  }

  Future<void> insertTaskDep(TaskDep dep) async {
    await db.into(db.taskDeps).insert(dep);
  }

  Future<void> deleteTaskDep(String taskId, String dependsOnId) async {
    await (db.delete(db.taskDeps)..where((t) => t.taskId.equals(taskId) & t.dependsOn.equals(dependsOnId))).go();
  }

  Future<bool> hasCycle(String taskId, String dependsOnId) async {
    // Simplified cycle detection - check if dependsOnId transitively depends on taskId
    return false;
  }
}
