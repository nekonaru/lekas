/// A week column of a simple weekly planner. Pure over tasks and class
/// slots; the UI only renders the result.
library;

import '../data/database.dart' show ClassSlot, Task;

class PlannerDay {
  const PlannerDay({
    required this.key,
    required this.tasks,
    required this.classes,
  });

  final String key;
  final List<Task> tasks;
  final List<ClassSlot> classes;
}

/// Seven days starting at [start], with tasks due that day and weekly
/// class slots whose weekday matches.
List<PlannerDay> buildWeek(
  DateTime start,
  Iterable<Task> tasks,
  Iterable<ClassSlot> slots,
) {
  final days = <PlannerDay>[];
  for (var i = 0; i < 7; i++) {
    final date = DateTime(start.year, start.month, start.day + i);
    final dayTasks = tasks
        .where((task) {
          if (task.deadline == null) return false;
          final due = DateTime.fromMillisecondsSinceEpoch(task.deadline!);
          return due.year == date.year &&
              due.month == date.month &&
              due.day == date.day;
        })
        .toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
    days.add(
      PlannerDay(
        key: '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        tasks: dayTasks,
        classes: slots.where((slot) => slot.weekday == date.weekday).toList(),
      ),
    );
  }
  return days;
}
