import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/task_dep_repository.dart';
import 'package:lekas/data/task_repository.dart';

/// Design section 5.27: dependencies between tasks. The graph must stay
/// acyclic when a dependency is saved, the Today screen reads the waiting
/// set from one stream, and a completion reports the tasks it frees.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // One in-memory database per test; the runtime warning about multiple
  // databases does not apply to this deliberate test setup.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late TaskRepository tasks;
  late TaskDepRepository deps;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tasks = TaskRepository(db);
    deps = TaskDepRepository(db);
  });

  tearDown(() => db.close());

  Future<void> insert(String id, {String status = 'todo'}) async {
    await tasks.insertTask(Task(
      id: id,
      title: 'Task $id',
      priority: 0,
      status: status,
      isGroup: false,
      pinned: false,
      inbox: false,
      createdAt: 1,
      updatedAt: 1,
    ));
  }

  Future<bool> add(String taskId, String dependsOn) =>
      deps.insertTaskDep(TaskDep(taskId: taskId, dependsOn: dependsOn));

  group('cycle rejection', () {
    test('a task cannot wait for itself', () async {
      await insert('a');

      expect(await deps.hasCycle('a', 'a'), isTrue);
      expect(await add('a', 'a'), isFalse);
      expect(await deps.getTaskDeps('a'), isEmpty);
    });

    test('a direct and a transitive loop are both rejected', () async {
      await insert('a');
      await insert('b');
      await insert('c');

      expect(await add('a', 'b'), isTrue);
      expect(await add('b', 'a'), isFalse);
      expect(await add('b', 'c'), isTrue);
      // c -> a -> b -> c would close a loop three edges long.
      expect(await add('c', 'a'), isFalse);
      expect(await deps.getTaskDeps('c'), isEmpty);
      expect(await deps.getTaskDeps('b'), hasLength(1));
    });

    test('an edge that does not close a loop is accepted', () async {
      await insert('a');
      await insert('b');
      await insert('c');

      expect(await add('a', 'b'), isTrue);
      expect(await add('c', 'b'), isTrue);
      expect(await deps.getTaskDeps('b'), isEmpty);
      expect(await deps.getTaskDeps('a'), hasLength(1));
      expect(await deps.getTaskDeps('c'), hasLength(1));
    });
  });

  group('waiting set', () {
    test('a task is blocked while its prerequisite is open', () async {
      await insert('a');
      await insert('b');
      await add('a', 'b');

      final emissions = <List<String>>[];
      final subscription = deps.watchBlockedTaskIds().listen(emissions.add);
      await pumpEventQueue();
      expect(emissions, isNotEmpty);
      expect(emissions.last, ['a']);

      await tasks.markDone('b');
      await pumpEventQueue();
      expect(emissions.last, isEmpty);

      await subscription.cancel();
    });

    test('a trashed prerequisite stops holding the task back', () async {
      await insert('a');
      await insert('b');
      await add('a', 'b');

      final emissions = <List<String>>[];
      final subscription = deps.watchBlockedTaskIds().listen(emissions.add);
      await pumpEventQueue();
      expect(emissions.last, ['a']);

      await tasks.softDeleteTask('b');
      await pumpEventQueue();
      expect(emissions.last, isEmpty);

      await subscription.cancel();
    });

    test('a finished prerequisite is not in the waiting set', () async {
      await insert('a');
      await insert('b', status: 'done');
      await add('a', 'b');

      expect(await deps.watchBlockedTaskIds().first, isEmpty);
    });
  });

  group('unblockedBy', () {
    test('frees a dependent only when every prerequisite is finished',
        () async {
      await insert('a');
      await insert('b');
      await insert('c');
      await add('a', 'b');
      await add('a', 'c');

      // The other prerequisite is still open, so nothing is free yet.
      expect(await deps.unblockedBy('b'), isEmpty);
      await tasks.markDone('c');
      expect(await deps.unblockedBy('b'), isEmpty);

      await tasks.markDone('b');
      expect(await deps.unblockedBy('b'), ['a']);
    });

    test('a dependent with another open prerequisite stays out', () async {
      await insert('a');
      await insert('d');
      await insert('e');
      await insert('b');
      await add('a', 'b');
      await add('d', 'b');
      await add('d', 'e');

      await tasks.markDone('b');
      expect(await deps.unblockedBy('b'), ['a']);
    });

    test('a task with nothing waiting on it frees nothing', () async {
      await insert('a');
      await insert('b');

      expect(await deps.unblockedBy('b'), isEmpty);
    });
  });
}
