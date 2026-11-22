import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:uuid/uuid.dart';

/// Regressions found in the v1.22 audit: a monthly repeat on a day the
/// target month lacks, and two rapid completions of a recurring task.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<(AppDatabase, TaskRepository, Task)> seeded({
    required int deadlineMs,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = TaskRepository(db);
    final now = DateTime.now().millisecondsSinceEpoch;
    final task = Task(
      id: const Uuid().v4(),
      title: 'Laporan bulanan',
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      deadline: deadlineMs,
      repeatKind: 'monthly',
      repeatEvery: 1,
      createdAt: now,
      updatedAt: now,
    );
    await repo.insertTask(task);
    return (db, repo, task);
  }

  test('monthly repeat clamps Jan 31 to Feb 28', () async {
    final (_, repo, task) = await seeded(
      deadlineMs: DateTime(2026, 1, 31, 23, 59).millisecondsSinceEpoch,
    );
    await repo.markDone(task.id);
    final followUps = (await repo.getTasks(includeInbox: true))
        .where((row) => row.id != task.id)
        .toList();
    expect(followUps, hasLength(1));
    expect(
      DateTime.fromMillisecondsSinceEpoch(followUps.single.deadline!),
      DateTime(2026, 2, 28, 23, 59),
    );
  });

  test('two rapid completions create exactly one next occurrence', () async {
    final (_, repo, task) = await seeded(
      deadlineMs: DateTime(2026, 11, 20, 23, 59).millisecondsSinceEpoch,
    );
    await Future.wait([
      repo.markDone(task.id),
      repo.markDone(task.id),
    ]);
    final all = await repo.getTasks(includeInbox: true);
    expect(all.where((row) => row.id != task.id), hasLength(1));
  });
}
