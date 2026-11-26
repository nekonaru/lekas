/// Aggregations over focus sessions and task completions for the study
/// statistics screen. Pure functions, testable without a database.
library;

import '../data/database.dart' show FocusSession;
import 'habits.dart' show countDayStreak, dayKeyOf;

/// Focus minutes per day for the last [days] days, oldest first.
/// The bucket key is the local calendar day of each session.
List<int> focusMinutesByDay(
  Iterable<FocusSession> sessions, {
  required DateTime endDay,
  required int days,
}) {
  final start = DateTime(endDay.year, endDay.month, endDay.day)
      .subtract(Duration(days: days - 1));
  final buckets = List<int>.filled(days, 0);
  for (final session in sessions) {
    final day = DateTime.fromMillisecondsSinceEpoch(session.startedAt);
    final local = DateTime(day.year, day.month, day.day);
    final offset = local.difference(start).inDays;
    if (offset < 0 || offset >= days) continue;
    buckets[offset] += (session.durationSec / 60).floor();
  }
  return buckets;
}

/// One weekly goal with its current value and target.
class GoalProgress {
  const GoalProgress({required this.current, required this.target});

  final int current;
  final int target;

  /// 0..1, saturated, and safe with a missing or zero target.
  double get ratio =>
      target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);

  bool get reached => target > 0 && current >= target;
}

/// Total focus minutes in the last [days] days.
int focusMinutesInWindow(
  Iterable<FocusSession> sessions, {
  required DateTime endDay,
  required int days,
}) =>
    focusMinutesByDay(sessions, endDay: endDay, days: days)
        .fold(0, (sum, minutes) => sum + minutes);

/// Days with any study activity: a completed task, a focus session or a
/// checked habit. Walks back from today (or yesterday when today is empty).
int studyStreak({
  required Iterable<int> completedAt,
  required Iterable<FocusSession> sessions,
  required Iterable<String> habitDays,
  required DateTime today,
}) {
  final days = <String>{
    for (final millis in completedAt)
      dayKeyOf(DateTime.fromMillisecondsSinceEpoch(millis)),
    for (final session in sessions)
      dayKeyOf(DateTime.fromMillisecondsSinceEpoch(session.startedAt)),
    ...habitDays,
  };
  return countDayStreak(days, today);
}

/// Consecutive days with at least one completed task, counting back from
/// [today]. A today without a completion yet does not break the streak.
int completionStreak(
  Iterable<int> completedAtMillis, {
  required DateTime today,
}) =>
    countDayStreak(
      {
        for (final millis in completedAtMillis)
          dayKeyOf(DateTime.fromMillisecondsSinceEpoch(millis)),
      },
      today,
    );
