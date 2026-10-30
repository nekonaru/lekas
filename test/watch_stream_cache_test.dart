import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/task_repository.dart';

/// A screen that builds `StreamBuilder(stream: repo.watchTasks(...))` gets a
/// brand new stream object from every `watch()` call, and StreamBuilder
/// resubscribes whenever the object identity changes. The repositories hand
/// out one cached instance per query instead, so a rebuild keeps its
/// subscription (and its rows) instead of reopening the query and flashing
/// the waiting state.
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

  Future<void> seed(String id, {bool inbox = false}) {
    return repo.insertTask(Task(
      id: id,
      title: 'Tugas $id',
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: inbox,
      createdAt: 1,
      updatedAt: 1,
    ));
  }

  test('the same query returns the identical stream instance', () {
    expect(
      identical(
        repo.watchTasks(includeInbox: false),
        repo.watchTasks(includeInbox: false),
      ),
      isTrue,
    );
    expect(
      identical(
        repo.watchTasks(spaceId: 'a'),
        repo.watchTasks(spaceId: 'a'),
      ),
      isTrue,
    );
    // Different queries stay different streams.
    expect(
      identical(
        repo.watchTasks(includeInbox: false),
        repo.watchTasks(includeInbox: true),
      ),
      isFalse,
    );
    expect(identical(repo.watchTasks(), repo.watchTrash()), isFalse);
  });

  test('two listeners of a shared stream both see live updates', () async {
    await seed('task-1');

    final first = <List<Task>>[];
    final second = <List<Task>>[];
    final subA = repo.watchTasks(includeInbox: false).listen(first.add);
    final subB = repo.watchTasks(includeInbox: false).listen(second.add);
    await pumpEventQueue();
    expect(first, hasLength(1), reason: 'initial snapshot');
    expect(second, hasLength(1), reason: 'initial snapshot');

    await seed('task-2');
    await pumpEventQueue();
    await subA.cancel();
    await subB.cancel();

    for (final events in [first, second]) {
      expect(events, hasLength(2), reason: 'both listeners get the update');
      expect(events.last.map((t) => t.id), ['task-1', 'task-2']);
    }
  });

  test('the trash stream is cached as its own instance', () async {
    expect(identical(repo.watchTrash(), repo.watchTrash()), isTrue);
    expect(
      identical(repo.watchInbox(), repo.watchTrash()),
      isFalse,
    );
  });
}
