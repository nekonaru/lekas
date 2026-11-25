/// Aggregation for the daily review screen and the estimate accuracy card.
/// Pure functions over repositories' data, no Flutter and no database.
library;

import '../data/database.dart' show FocusSession, HabitCheck, Task;
import 'habits.dart' show dayKeyOf;

/// The numbers of one local calendar day.
class DailyReview {
  const DailyReview({
    required this.completedTasks,
    required this.overdueTasks,
    required this.focusMinutes,
    required this.habitsChecked,
    required this.habitsTotal,
  });

  final int completedTasks;
  final int overdueTasks;
  final int focusMinutes;
  final int habitsChecked;
  final int habitsTotal;

  bool get hasActivity =>
      completedTasks > 0 || focusMinutes > 0 || habitsChecked > 0;
}

/// Collects today's facts from tasks, focus sessions and habit checks.
DailyReview buildDailyReview({
  required List<Task> tasks,
  required List<FocusSession> sessions,
  required List<HabitCheck> checks,
  required int habitsTotal,
  required DateTime today,
}) {
  final key = dayKeyOf(today);
  final start = DateTime(today.year, today.month, today.day);
  final completed = tasks
      .where((task) =>
          task.status == 'done' &&
          task.completedAt != null &&
          dayKeyOf(DateTime.fromMillisecondsSinceEpoch(task.completedAt!)) == key)
      .length;
  final overdue = tasks
      .where((task) =>
          task.status != 'done' &&
          task.deadline != null &&
          DateTime.fromMillisecondsSinceEpoch(task.deadline!).isBefore(start))
      .length;
  final minutes = sessions
      .where((session) =>
          dayKeyOf(DateTime.fromMillisecondsSinceEpoch(session.startedAt)) == key)
      .fold<int>(0, (sum, session) => sum + (session.durationSec / 60).floor());
  final checkedHabits = checks.where((row) => row.date == key).map((row) => row.habitId).toSet();
  return DailyReview(
    completedTasks: completed,
    overdueTasks: overdue,
    focusMinutes: minutes,
    habitsChecked: checkedHabits.length,
    habitsTotal: habitsTotal,
  );
}

/// Estimate accuracy from tasks that carry both an estimate and recorded
/// focus sessions. Only completed tasks with actual minutes are counted.
class EstimateAccuracy {
  const EstimateAccuracy({
    required this.sampleCount,
    required this.plannedMinutes,
    required this.actualMinutes,
  });

  final int sampleCount;
  final int plannedMinutes;
  final int actualMinutes;

  /// Percent by which actual focus exceeded the estimate, rounded.
  int get excessPercent => plannedMinutes == 0
      ? 0
      : (((actualMinutes - plannedMinutes) / plannedMinutes) * 100).round();
}

/// Pairs [sessions] with their tasks' estimates by task id.
EstimateAccuracy estimateAccuracy(
  List<Task> tasks,
  List<FocusSession> sessions,
) {
  final taskById = {for (final task in tasks) task.id: task};
  final actualByTask = <String, int>{};
  for (final session in sessions) {
    actualByTask[session.taskId] =
        (actualByTask[session.taskId] ?? 0) + (session.durationSec / 60).floor();
  }
  var count = 0;
  var planned = 0;
  var actual = 0;
  for (final entry in actualByTask.entries) {
    final task = taskById[entry.key];
    final estimate = task?.estimateMinutes ?? 0;
    if (task == null || estimate <= 0 || entry.value <= 0) continue;
    count += 1;
    planned += estimate;
    actual += entry.value;
  }
  return EstimateAccuracy(
    sampleCount: count,
    plannedMinutes: planned,
    actualMinutes: actual,
  );
}
