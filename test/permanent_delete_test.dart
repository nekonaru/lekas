import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/task_repository.dart';

/// Permanently deleting a task has to take its children with it. The schema
/// declares no `ON DELETE CASCADE`, so a bare `DELETE FROM tasks` leaves
/// subtasks, tags, attachments, reminders, events, focus sessions and
/// dependencies pointing at a row that no longer exists. Those orphans still
/// join against the missing task and quietly skew every later query.
void main() {
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = TaskRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<Task> seedTask(String id) async {
    final task = Task(
      id: id,
      title: 'Tugas $id',
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      createdAt: 1,
      updatedAt: 1,
    );
    await repo.insertTask(task);
    return task;
  }

  test('permanent delete removes every child row of the task', () async {
    final parent = await seedTask('task-1');
    await seedTask('task-2');

    await db.into(db.subtasks).insert(Subtask(
          id: 'sub-1',
          taskId: parent.id,
          title: 'bagian',
          done: false,
          sortOrder: 0,
          updatedAt: 1,
        ));
    await db.into(db.attachments).insert(Attachment(
          id: 'att-1',
          taskId: parent.id,
          kind: 'link',
          pathOrUrl: 'https://example.com',
          createdAt: 1,
        ));
    await db.into(db.reminders).insert(Reminder(
          id: 'rem-1',
          taskId: parent.id,
          fireAt: 2000,
          notifId: 1000,
          fired: false,
        ));
    await db.into(db.taskEvents).insert(TaskEvent(
          id: 'evt-1',
          taskId: parent.id,
          kind: 'created',
          createdAt: 1,
        ));
    await db.into(db.focusSessions).insert(FocusSession(
          id: 'foc-1',
          taskId: parent.id,
          startedAt: 1,
          durationSec: 60,
        ));
    await db.into(db.taskDeps).insert(TaskDep(taskId: parent.id, dependsOn: 'task-2'));

    await repo.deletePermanently(parent.id);

    Future<int> count(String table) async {
      final rows = await db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle();
      return rows.read<int>('c');
    }

    // The task is gone and every child row went with it.
    expect(await count('tasks'), 1); // task-2 remains
    expect(await count('subtasks'), 0);
    expect(await count('attachments'), 0);
    expect(await count('reminders'), 0);
    expect(await count('task_events'), 0);
    expect(await count('focus_sessions'), 0);
    expect(await count('task_deps'), 0);
  });

  test('a dependency pointing at the deleted task is removed too', () async {
    await seedTask('task-1');
    final child = await seedTask('task-2');
    // task-2 dependsOn task-1: the row references the deleted task as
    // `dependsOn`, so it must be caught by the cleanup.
    await db.into(db.taskDeps).insert(TaskDep(taskId: child.id, dependsOn: 'task-1'));

    await repo.deletePermanently('task-1');

    final rows = await db.customSelect('SELECT COUNT(*) AS c FROM task_deps').getSingle();
    expect(rows.read<int>('c'), 0);
  });

  test('children of a group task move to the inbox instead of dangling', () async {
    final group = await seedTask('group-1');
    final kid = await seedTask('kid-1');
    await (db.update(db.tasks)..where((t) => t.id.equals(kid.id))).write(
      const TasksCompanion(parentId: Value('group-1'), inbox: Value(false)),
    );

    await repo.deletePermanently(group.id);

    final survivor = await repo.getTask(kid.id);
    expect(survivor.parentId, isNull);
    expect(survivor.inbox, isTrue);
  });
}
