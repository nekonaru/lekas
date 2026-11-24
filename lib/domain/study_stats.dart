/// Aggregations over focus sessions and task completions for the study
/// statistics screen. Pure functions, testable without a database.
library;

import '../data/database.dart' show FocusSession;

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

/// Consecutive days with at least one completed task, counting back from
/// [today]. A today without a completion yet does not break the streak.
int completionStreak(
  Iterable<int> completedAtMillis, {
  required DateTime today,
}) {
  final days = <String>{
    for (final millis in completedAtMillis)
      _dayKey(DateTime.fromMillisecondsSinceEpoch(millis)),
  };
  var streak = 0;
  var cursor = DateTime(today.year, today.month, today.day);
  if (days.contains(_dayKey(cursor))) {
    streak += 1;
  }
  while (true) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(_dayKey(cursor))) break;
    streak += 1;
    // Today not completed yet: the streak still counts yesterday back.
    if (streak > 3650) break;
  }
  return streak;
}

String _dayKey(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
