import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/reminders/reminder_service.dart';

Task _task(
  String id, {
  String title = 'Tugas',
  int? deadline,
  String status = 'todo',
}) {
  return Task(
    id: id,
    title: title,
    priority: 1,
    status: status,
    isGroup: false,
    pinned: false,
    inbox: false,
    createdAt: 1,
    updatedAt: 1,
    deadline: deadline,
  );
}

/// Counts the reconciliations the provider asks for. The provider only ever
/// calls [syncAll], so the rest of the service can stay unimplemented.
class _CountingReminderService implements ReminderService {
  int calls = 0;

  @override
  Future<void> syncAll() {
    calls += 1;
    return Future<void>.value();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('reminderSyncFingerprint', () {
    test('does not care about the order the rows are read in', () {
      final one = [_task('t1'), _task('t2', title: 'B')];
      final flipped = [_task('t2', title: 'B'), _task('t1')];

      expect(reminderSyncFingerprint(one), reminderSyncFingerprint(flipped));
    });

    test('moves when a field the schedule reads moves', () {
      final base = [_task('t1', deadline: 1000)];

      int of(List<Task> tasks) => reminderSyncFingerprint(tasks);

      expect(of(base), isNot(of([_task('t1', deadline: 1001)])));
      expect(of(base), isNot(of([_task('t1', deadline: 1000, title: 'Baru')])));
      expect(
        of(base),
        isNot(of([_task('t1', deadline: 1000, status: 'done')])),
      );
      expect(
        of(base),
        isNot(of([_task('t1', deadline: 1000), _task('t2', deadline: 2)])),
      );
    });
  });

  group('reminderSyncProvider', () {
    late StreamController<List<Task>> writes;
    late _CountingReminderService service;
    late ProviderContainer container;

    setUp(() {
      writes = StreamController<List<Task>>();
      service = _CountingReminderService();
      container = ProviderContainer(
        overrides: [
          reminderServiceProvider.overrideWithValue(service),
          allTasksProvider.overrideWith((ref) => writes.stream),
        ],
      );
      container.read(reminderSyncProvider);
    });

    tearDown(() async {
      container.dispose();
      await writes.close();
    });

    /// Waits out the debounce window with room to spare.
    Future<void> settle() =>
        Future<void>.delayed(kReminderSyncDebounce * 2);

    test('a burst of writes becomes a single reconciliation', () async {
      writes.add([_task('t1')]);
      writes.add([_task('t1'), _task('t2')]);
      writes.add([_task('t1'), _task('t2'), _task('t3')]);

      await settle();
      expect(service.calls, 1);
    });

    test('a write that changes nothing schedules nothing', () async {
      writes.add([_task('t1', deadline: 1000)]);
      await settle();
      expect(service.calls, 1);

      writes.add([_task('t1', deadline: 1000)]);
      await settle();
      expect(service.calls, 1);
    });

    test('a change the schedule reads reconciles again', () async {
      writes.add([_task('t1', deadline: 1000)]);
      await settle();
      expect(service.calls, 1);

      writes.add([_task('t1', deadline: 2000)]);
      await settle();
      expect(service.calls, 2);
    });

    test('a failed run is retried by the next write', () async {
      var fail = true;
      final flaky = _FlakyReminderService(() => fail);
      final ownWrites = StreamController<List<Task>>();
      final own = ProviderContainer(
        overrides: [
          reminderServiceProvider.overrideWithValue(flaky),
          allTasksProvider.overrideWith((ref) => ownWrites.stream),
        ],
      );
      addTearDown(() async {
        own.dispose();
        await ownWrites.close();
      });
      own.read(reminderSyncProvider);

      ownWrites.add([_task('t1', deadline: 1000)]);
      await settle();
      expect(flaky.calls, 1);

      fail = false;
      // The same rows again: the failed run was never recorded, so the
      // next write has to schedule what the failed run could not.
      ownWrites.add([_task('t1', deadline: 1000)]);
      await settle();
      expect(flaky.calls, 2);
    });
  });
}

class _FlakyReminderService implements ReminderService {
  _FlakyReminderService(this.shouldFail);

  final bool Function() shouldFail;
  int calls = 0;

  @override
  Future<void> syncAll() {
    calls += 1;
    if (shouldFail()) return Future<void>.error(StateError('offline'));
    return Future<void>.value();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
