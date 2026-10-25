import 'package:drift/drift.dart';
import 'database.dart';
import 'models.dart';

class TaskRepository {
  final AppDatabase db;
  TaskRepository(this.db);

  Stream<List<Task>> watchTasks({String? spaceId, bool includeInbox = false}) {
    final query = db.select(db.tasks)..where(db.tasks.deletedAt.isNull());
    if (spaceId != null) {
      query..where(db.tasks.spaceId.equals(spaceId));
    } else if (!includeInbox) {
      query..where(db.tasks.inbox.equals(false));
    }
    return query.watch();
  }

  Future<List<Task>> getTasks({String? spaceId, bool includeInbox = false}) async {
    final query = db.select(db.tasks)..where(db.tasks.deletedAt.isNull());
    if (spaceId != null) {
      query..where(db.tasks.spaceId.equals(spaceId));
    } else if (!includeInbox) {
      query..where(db.tasks.inbox.equals(false));
    }
    return query.get();
  }

  Future<Task> getTask(String id) async {
    final result = await db.select(db.tasks)..where(db.tasks.id.equals(id));
    return result.getSingle();
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
      createdAt: 0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      deletedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> restoreTask(String id) async {
    await db.update(db.tasks).replace(Task(
      id: id,
      title: '',
      createdAt: 0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      deletedAt: null,
    ));
  }

  Future<void> markDone(String id, {int? completedAt}) async {
    await db.update(db.tasks).replace(Task(
      id: id,
      title: '',
      status: 'done',
      completedAt: completedAt ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Stream<List<Task>> watchInbox() {
    return db.select(db.tasks)..where(
      db.tasks.inbox.equals(true).and(db.tasks.deletedAt.isNull()),
    ).watch();
  }

  Future<int> countInbox() async {
    return db.select(db.tasks)..where(
      db.tasks.inbox.equals(true).and(db.tasks.deletedAt.isNull()),
    ).get().then((rows) => rows.length);
  }
}
