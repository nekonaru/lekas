import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'database.dart';

class TaskRepository {
  final AppDatabase db;
  TaskRepository(this.db);

  Stream<List<Task>> watchTasks({String? spaceId, bool includeInbox = false}) {
    final query = db.select(db.tasks)..where((t) => t.deletedAt.isNull());
    if (spaceId != null) {
      query.where((t) => t.spaceId.equals(spaceId));
    } else if (!includeInbox) {
      query.where((t) => t.inbox.equals(false));
    }
    return query.watch();
  }

  Future<List<Task>> getTasks(
      {String? spaceId, bool includeInbox = false}) async {
    final query = db.select(db.tasks)..where((t) => t.deletedAt.isNull());
    if (spaceId != null) {
      query.where((t) => t.spaceId.equals(spaceId));
    } else if (!includeInbox) {
      query.where((t) => t.inbox.equals(false));
    }
    return query.get();
  }

  Future<Task> getTask(String id) async {
    return (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> insertTask(Task task) async {
    await db.into(db.tasks).insert(task);
  }

  Future<void> updateTask(Task task) async {
    await db.update(db.tasks).replace(task);
  }

  Future<void> softDeleteTask(String id) async {
    await db.update(db.tasks).replace(Task(
      id: id,
      title: '',
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      createdAt: 0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      deletedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> restoreTask(String id) async {
    final existing = await getTask(id);
    await db.update(db.tasks).replace(existing.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      deletedAt: const Value(null),
    ));
  }

  Future<void> markDone(String id, {int? completedAt}) async {
    final existing = await getTask(id);
    await db.update(db.tasks).replace(existing.copyWith(
      status: 'done',
      completedAt: Value(completedAt ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  /// Pins or unpins a task (design section 5.9): pinned tasks always come
  /// first on the Today screen, outside the urgency order.
  Future<void> setPinned(String id, bool pinned) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        pinned: Value(pinned),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Copies a task with its subtasks and tags in one tap (design section
  /// 5.9). The copy starts fresh: not done, not pinned, deadline unchanged.
  Future<Task> duplicateTask(String id) async {
    final source = await getTask(id);
    final now = DateTime.now().millisecondsSinceEpoch;
    final copy = source.copyWith(
      id: const Uuid().v4(),
      status: 'todo',
      pinned: false,
      submittedAt: const Value(null),
      completedAt: const Value(null),
      createdAt: now,
      updatedAt: now,
      deletedAt: const Value(null),
    );
    await insertTask(copy);

    final subtasks = await (db.select(db.subtasks)
          ..where((t) => t.taskId.equals(id) & t.deletedAt.isNull()))
        .get();
    for (final subtask in subtasks) {
      await db.into(db.subtasks).insert(subtask.copyWith(
            id: const Uuid().v4(),
            taskId: copy.id,
            done: false,
            updatedAt: now,
          ));
    }

    final links = await (db.select(db.taskTags)
          ..where((t) => t.taskId.equals(id)))
        .get();
    for (final link in links) {
      await db.into(db.taskTags).insert(
            TaskTag(taskId: copy.id, tagId: link.tagId),
            mode: InsertMode.insertOrIgnore,
          );
    }
    return copy;
  }

  Stream<List<Task>> watchInbox() {
    return (db.select(db.tasks)
          ..where((t) => t.inbox.equals(true) & t.deletedAt.isNull()))
        .watch();
  }

  Future<int> countInbox() async {
    final rows = await (db.select(db.tasks)
          ..where((t) => t.inbox.equals(true) & t.deletedAt.isNull()))
        .get();
    return rows.length;
  }
}
