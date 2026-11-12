import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/core/task_filter.dart';
import 'package:lekas/data/database.dart';

Task _task({
  required String id,
  String? spaceId,
  String status = 'todo',
  int? deadline,
  int priority = 1,
  int createdAt = 0,
}) {
  return Task(
    id: id,
    spaceId: spaceId,
    title: id,
    priority: priority,
    status: status,
    isGroup: false,
    pinned: false,
    inbox: spaceId == null,
    deadline: deadline,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

void main() {
  const day = 24 * 60 * 60 * 1000;
  final now = DateTime.now().millisecondsSinceEpoch;

  group('TaskFilter.apply', () {
    test('deadlineAsc sorts earliest first and no-deadline last', () {
      final tasks = [
        _task(id: 'none', deadline: null),
        _task(id: 'later', deadline: now + 2 * day),
        _task(id: 'sooner', deadline: now + 1 * day),
      ];
      final result = const TaskFilter().apply(tasks);
      expect(result.map((t) => t.id), ['sooner', 'later', 'none']);
    });

    test('deadlineDesc sorts farthest first and no-deadline last', () {
      final tasks = [
        _task(id: 'none', deadline: null),
        _task(id: 'sooner', deadline: now + 1 * day),
        _task(id: 'later', deadline: now + 2 * day),
      ];
      final result =
          const TaskFilter(sort: TaskSort.deadlineDesc).apply(tasks);
      expect(result.map((t) => t.id), ['later', 'sooner', 'none']);
    });

    test('createdDesc sorts newest first', () {
      final tasks = [
        _task(id: 'old', createdAt: now - 3 * day),
        _task(id: 'new', createdAt: now),
        _task(id: 'mid', createdAt: now - 1 * day),
      ];
      final result =
          const TaskFilter(sort: TaskSort.createdDesc).apply(tasks);
      expect(result.map((t) => t.id), ['new', 'mid', 'old']);
    });

    test('priorityHighFirst sorts high to low, deadline breaks ties', () {
      final tasks = [
        _task(id: 'low', priority: 0, deadline: now),
        _task(id: 'highLate', priority: 2, deadline: now + 2 * day),
        _task(id: 'highSoon', priority: 2, deadline: now + 1 * day),
        _task(id: 'mid', priority: 1, deadline: now - 5 * day),
      ];
      final result = const TaskFilter(sort: TaskSort.priorityHighFirst)
          .apply(tasks);
      expect(result.map((t) => t.id), ['highSoon', 'highLate', 'mid', 'low']);
    });

    test('pending keeps only tasks that are not done', () {
      final tasks = [
        _task(id: 'open'),
        _task(id: 'done', status: 'done'),
      ];
      final result =
          const TaskFilter(status: TaskStatusFilter.pending).apply(tasks);
      expect(result.map((t) => t.id), ['open']);
    });

    test('done keeps only finished tasks', () {
      final tasks = [
        _task(id: 'open'),
        _task(id: 'done', status: 'done'),
      ];
      final result =
          const TaskFilter(status: TaskStatusFilter.done).apply(tasks);
      expect(result.map((t) => t.id), ['done']);
    });

    test('spaceId keeps only that category', () {
      final tasks = [
        _task(id: 'a', spaceId: 'math'),
        _task(id: 'b', spaceId: 'art'),
        _task(id: 'inbox'),
      ];
      final result = const TaskFilter(spaceId: 'math').apply(tasks);
      expect(result.map((t) => t.id), ['a']);
    });

    test('filters combine: category plus pending plus sort', () {
      final tasks = [
        _task(id: 'aDone', spaceId: 'math', status: 'done', deadline: now + 1),
        _task(id: 'bOpen', spaceId: 'math', deadline: now + 2 * day),
        _task(id: 'cOpen', spaceId: 'math', deadline: now + 1 * day),
        _task(id: 'dArt', spaceId: 'art', deadline: now),
      ];
      final result = const TaskFilter(
        spaceId: 'math',
        status: TaskStatusFilter.pending,
      ).apply(tasks);
      expect(result.map((t) => t.id), ['cOpen', 'bOpen']);
    });
  });

  group('TaskFilter bookkeeping', () {
    test('isDefault only for the default filter', () {
      expect(TaskFilter.none.isDefault, isTrue);
      expect(const TaskFilter(spaceId: 'x').isDefault, isFalse);
      expect(
        const TaskFilter(status: TaskStatusFilter.done).isDefault,
        isFalse,
      );
      expect(const TaskFilter(sort: TaskSort.deadlineDesc).isDefault, isFalse);
    });

    test('activeCount counts the changed parts', () {
      expect(TaskFilter.none.activeCount, 0);
      expect(const TaskFilter(spaceId: 'x').activeCount, 1);
      expect(
        const TaskFilter(
          spaceId: 'x',
          status: TaskStatusFilter.done,
          sort: TaskSort.deadlineDesc,
        ).activeCount,
        3,
      );
    });

    test('copyWith clears the category with an explicit null', () {
      const filter = TaskFilter(spaceId: 'math', status: TaskStatusFilter.done);
      final cleared = filter.copyWith(spaceId: null);
      expect(cleared.spaceId, isNull);
      expect(cleared.status, TaskStatusFilter.done);
    });
  });
}
