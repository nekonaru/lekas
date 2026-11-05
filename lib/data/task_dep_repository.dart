import 'package:drift/drift.dart';
import 'database.dart';

/// Prerequisites between tasks (design section 5.27): a task may wait for
/// other tasks to finish, but the graph must stay acyclic.
class TaskDepRepository {
  TaskDepRepository(this.db);

  final AppDatabase db;

  /// Query streams already handed out, keyed by their arguments. A
  /// StreamBuilder compares streams by identity, so a fresh instance on
  /// every rebuild would resubscribe on every tap (the same note sits on
  /// TaskRepository.watchTasks).
  final Map<String, Stream<List<TaskDep>>> _depWatchCache = {};
  final Map<String, Stream<List<String>>> _blockedWatchCache = {};

  Stream<List<TaskDep>> watchTaskDeps(String taskId) {
    return _depWatchCache.putIfAbsent(taskId, () {
      return (db.select(db.taskDeps)..where((t) => t.taskId.equals(taskId)))
          .watch();
    });
  }

  Future<List<TaskDep>> getTaskDeps(String taskId) async {
    return (db.select(db.taskDeps)..where((t) => t.taskId.equals(taskId)))
        .get();
  }

  /// Ids of tasks that still have at least one unfinished prerequisite
  /// (design section 5.27). The join reads both tables, so drift re-runs it
  /// on every task or dependency write: the Today screen only has to watch
  /// this one stream to keep the Waiting section correct. A prerequisite
  /// that is finished, trashed or purged does not hold a task back.
  Stream<List<String>> watchBlockedTaskIds() {
    return _blockedWatchCache.putIfAbsent('all', () {
      final query = db.select(db.taskDeps).join([
        innerJoin(
          db.tasks,
          db.tasks.id.equalsExp(db.taskDeps.dependsOn) &
              db.tasks.deletedAt.isNull() &
              db.tasks.status.equals('done').not(),
        ),
      ]);
      return query.watch().map(
          (rows) => rows.map((row) => row.readTable(db.taskDeps).taskId).toList());
    });
  }

  /// Saves a prerequisite unless the edge would close a loop (design
  /// section 5.27). Returns false when the save was rejected.
  Future<bool> insertTaskDep(TaskDep dep) async {
    if (await hasCycle(dep.taskId, dep.dependsOn)) return false;
    await db.into(db.taskDeps).insert(dep);
    return true;
  }

  Future<void> deleteTaskDep(String taskId, String dependsOnId) async {
    await (db.delete(db.taskDeps)
          ..where((t) => t.taskId.equals(taskId) & t.dependsOn.equals(dependsOnId)))
        .go();
  }

  /// True when [dependsOnId] already reaches [taskId] through its own
  /// prerequisites: saving the edge then would strand both tasks in a loop.
  Future<bool> hasCycle(String taskId, String dependsOnId) async {
    if (taskId == dependsOnId) return true;
    final rows = await db.select(db.taskDeps).get();
    final next = <String, List<String>>{};
    for (final row in rows) {
      next.putIfAbsent(row.taskId, () => []).add(row.dependsOn);
    }
    final seen = <String>{};
    final stack = <String>[dependsOnId];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (current == taskId) return true;
      if (!seen.add(current)) continue;
      stack.addAll(next[current] ?? const <String>[]);
    }
    return false;
  }

  /// The tasks that become startable once [completedId] is finished: every
  /// task depending on it whose remaining prerequisites are all done or out
  /// of the way. A trashed prerequisite can never finish, so it stops
  /// holding its dependents back instead of stranding them (design section
  /// 5.27).
  Future<List<String>> unblockedBy(String completedId) async {
    final waitingOn = await (db.select(db.taskDeps)
          ..where((t) => t.dependsOn.equals(completedId)))
        .get();
    final checked = <String>{};
    final free = <String>[];
    for (final row in waitingOn) {
      if (!checked.add(row.taskId)) continue;
      final own = await (db.select(db.taskDeps)
            ..where((t) => t.taskId.equals(row.taskId)))
          .get();
      var stillBlocked = false;
      for (final dep in own) {
        final prereq = await (db.select(db.tasks)
              ..where((t) => t.id.equals(dep.dependsOn)))
            .getSingleOrNull();
        final open = prereq != null &&
            prereq.deletedAt == null &&
            prereq.status != 'done';
        if (open) {
          stillBlocked = true;
          break;
        }
      }
      if (!stillBlocked) free.add(row.taskId);
    }
    return free;
  }
}
