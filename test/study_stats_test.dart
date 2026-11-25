import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/domain/study_stats.dart';

FocusSession _session(int minutes, DateTime when) => FocusSession(
      id: '${when.millisecondsSinceEpoch}-$minutes',
      taskId: 't',
      startedAt: when.millisecondsSinceEpoch,
      durationSec: minutes * 60,
    );

void main() {
  final day = DateTime(2026, 11, 16);

  test('focusMinutesByDay buckets the last days, oldest first', () {
    final yesterday = day.subtract(const Duration(days: 1));
    final sessions = [
      _session(25, yesterday.add(const Duration(hours: 10))),
      _session(50, yesterday.add(const Duration(hours: 20))),
      _session(25, day),
      _session(25, day.subtract(const Duration(days: 40))), // outside window
    ];
    final buckets = focusMinutesByDay(sessions, endDay: day, days: 14);
    expect(buckets.length, 14);
    expect(buckets[13], 25); // today
    expect(buckets[12], 75); // yesterday
    expect(buckets.fold<int>(0, (a, b) => a + b), 100); // the 40-day-old one is dropped
  });

  test('focusMinutesInWindow sums the buckets', () {
    final sessions = [
      _session(25, day),
      _session(25, day.subtract(const Duration(days: 3))),
      _session(25, day.subtract(const Duration(days: 20))),
    ];
    expect(focusMinutesInWindow(sessions, endDay: day, days: 7), 50);
    expect(focusMinutesInWindow(sessions, endDay: day, days: 1), 25);
  });

  test('completionStreak counts today, then walks back consecutive days', () {
    final millis = [
      day.millisecondsSinceEpoch,
      day.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      day.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      day.subtract(const Duration(days: 4)).millisecondsSinceEpoch, // gap at 3
    ];
    expect(completionStreak(millis, today: day), 3);
  });

  test('completionStreak holds when today has no completion yet', () {
    final millis = [
      day.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      day.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      day.subtract(const Duration(days: 3)).millisecondsSinceEpoch,
    ];
    expect(completionStreak(millis, today: day), 3);
  });

  test('completionStreak breaks on a gap', () {
    final millis = [
      day.millisecondsSinceEpoch,
      day.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
    ];
    expect(completionStreak(millis, today: day), 1);
  });

  test('completionStreak of no completions is zero', () {
    expect(completionStreak(const [], today: day), 0);
  });

  test('goal progress is saturated and safe with no target', () {
    final none = GoalProgress(current: 5, target: 0);
    expect(none.ratio, 0);
    expect(none.reached, isFalse);

    final partial = GoalProgress(current: 3, target: 4);
    expect(partial.ratio, closeTo(0.75, 1e-9));
    expect(partial.reached, isFalse);

    final over = GoalProgress(current: 12, target: 10);
    expect(over.ratio, 1);
    expect(over.reached, isTrue);
  });

  test('study streak counts any activity, not just tasks', () {
    final today = DateTime(2026, 11, 26, 15);
    final streak = studyStreak(
      completedAt: [DateTime(2026, 11, 24).millisecondsSinceEpoch],
      sessions: [
        FocusSession(
          id: 's1',
          taskId: 't1',
          startedAt: DateTime(2026, 11, 25, 9).millisecondsSinceEpoch,
          durationSec: 1500,
        ),
      ],
      habitDays: ['2026-11-26'],
      today: today,
    );
    expect(streak, 3);
  });
}
