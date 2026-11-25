import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/domain/daily_review.dart';

Task _task({
  required String id,
  String status = 'todo',
  int? completedAt,
  int? deadline,
  int? estimateMinutes,
}) =>
    Task(
      id: id,
      title: id,
      priority: 1,
      status: status,
      isGroup: false,
      pinned: false,
      inbox: false,
      completedAt: completedAt,
      deadline: deadline,
      estimateMinutes: estimateMinutes,
      createdAt: 1,
      updatedAt: 1,
    );

FocusSession _session(String taskId, int minutes, DateTime at) => FocusSession(
      id: '$taskId-${at.millisecondsSinceEpoch}',
      taskId: taskId,
      startedAt: at.millisecondsSinceEpoch,
      durationSec: minutes * 60,
    );

void main() {
  final today = DateTime(2026, 11, 26, 15, 0);

  test('daily review counts only today completions and open overdue', () {
    final tasks = [
      _task(
        id: 'done-today',
        status: 'done',
        completedAt: DateTime(2026, 11, 26, 9).millisecondsSinceEpoch,
      ),
      _task(
        id: 'done-yesterday',
        status: 'done',
        completedAt: DateTime(2026, 11, 25, 9).millisecondsSinceEpoch,
      ),
      _task(
        id: 'overdue',
        deadline: DateTime(2026, 11, 25, 23).millisecondsSinceEpoch,
      ),
      _task(
        id: 'future',
        deadline: DateTime(2026, 11, 27, 23).millisecondsSinceEpoch,
      ),
    ];
    final review = buildDailyReview(
      tasks: tasks,
      sessions: [
        _session('a', 25, DateTime(2026, 11, 26, 8)),
        _session('b', 50, DateTime(2026, 11, 25, 8)),
      ],
      checks: [
        HabitCheck(
          id: 'c1',
          habitId: 'h1',
          date: '2026-11-26',
          createdAt: 1,
        ),
        HabitCheck(
          id: 'c2',
          habitId: 'h2',
          date: '2026-11-26',
          createdAt: 1,
        ),
        HabitCheck(
          id: 'c3',
          habitId: 'h3',
          date: '2026-11-25',
          createdAt: 1,
        ),
      ],
      habitsTotal: 3,
      today: today,
    );
    expect(review.completedTasks, 1);
    expect(review.overdueTasks, 1);
    expect(review.focusMinutes, 25);
    expect(review.habitsChecked, 2);
    expect(review.habitsTotal, 3);
    expect(review.hasActivity, isTrue);
  });

  test('estimate accuracy pairs sessions with task estimates', () {
    final tasks = [
      _task(id: 'a', estimateMinutes: 30),
      _task(id: 'b', estimateMinutes: 60),
      _task(id: 'c'),
    ];
    final accuracy = estimateAccuracy(tasks, [
      _session('a', 45, today),
      _session('b', 30, today),
      _session('c', 90, today),
    ]);
    expect(accuracy.sampleCount, 2);
    expect(accuracy.plannedMinutes, 90);
    expect(accuracy.actualMinutes, 75);
    expect(accuracy.excessPercent, -17);
  });

  test('estimate accuracy ignores tasks without an estimate', () {
    final accuracy = estimateAccuracy(
      [_task(id: 'a')],
      [_session('a', 90, today)],
    );
    expect(accuracy.sampleCount, 0);
    expect(accuracy.excessPercent, 0);
  });
}
