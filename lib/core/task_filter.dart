import '../data/models.dart';

/// How the task list is ordered (design section 4.3).
enum TaskSort {
  /// Earliest deadline first, tasks without one last (alphabetical tie
  /// breaker keeps the order stable while typing).
  deadlineAsc,

  /// Latest deadline first, tasks without one last.
  deadlineDesc,

  /// Newest created first.
  createdDesc,

  /// Highest priority first, then earliest deadline.
  priorityHighFirst,
}

/// Which tasks to show by completion state.
enum TaskStatusFilter {
  all,
  pending,
  done,
}

/// The filter every task list can apply: one category, one status, one
/// sort order. Pure Dart on purpose so the behavior is unit testable and
/// the lists stay small enough to filter in memory.
class TaskFilter {
  const TaskFilter({
    this.spaceId,
    this.status = TaskStatusFilter.all,
    this.sort = TaskSort.deadlineAsc,
  });

  /// The category to keep, or null for all of them (the Inbox included).
  final String? spaceId;

  final TaskStatusFilter status;
  final TaskSort sort;

  static const TaskFilter none = TaskFilter();

  bool get isDefault =>
      spaceId == null &&
      status == TaskStatusFilter.all &&
      sort == TaskSort.deadlineAsc;

  /// How many filters differ from the default: the count shown on the
  /// filter button's badge.
  int get activeCount {
    var count = 0;
    if (spaceId != null) count++;
    if (status != TaskStatusFilter.all) count++;
    if (sort != TaskSort.deadlineAsc) count++;
    return count;
  }

  TaskFilter copyWith({
    Object? spaceId = _unset,
    TaskStatusFilter? status,
    TaskSort? sort,
  }) {
    return TaskFilter(
      spaceId: identical(spaceId, _unset) ? this.spaceId : spaceId as String?,
      status: status ?? this.status,
      sort: sort ?? this.sort,
    );
  }

  static const Object _unset = Object();

  /// Applies the filter and the sort to [tasks], returning a new list.
  List<Task> apply(Iterable<Task> tasks) {
    final filtered = tasks.where((task) {
      if (spaceId != null && task.spaceId != spaceId) return false;
      switch (status) {
        case TaskStatusFilter.all:
          break;
        case TaskStatusFilter.pending:
          if (task.status == 'done') return false;
          break;
        case TaskStatusFilter.done:
          if (task.status != 'done') return false;
          break;
      }
      return true;
    }).toList();
    switch (sort) {
      case TaskSort.deadlineAsc:
      case TaskSort.deadlineDesc:
        final direction = sort == TaskSort.deadlineAsc ? 1 : -1;
        filtered.sort((a, b) {
          final deadlineA = a.deadline;
          final deadlineB = b.deadline;
          if (deadlineA == null && deadlineB == null) {
            return a.title.compareTo(b.title);
          }
          if (deadlineA == null) return 1;
          if (deadlineB == null) return -1;
          final byDeadline = deadlineA.compareTo(deadlineB) * direction;
          return byDeadline != 0 ? byDeadline : a.title.compareTo(b.title);
        });
        break;
      case TaskSort.createdDesc:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSort.priorityHighFirst:
        filtered.sort((a, b) {
          final byPriority = b.priority.compareTo(a.priority);
          if (byPriority != 0) return byPriority;
          final deadlineA = a.deadline ?? 1 << 62;
          final deadlineB = b.deadline ?? 1 << 62;
          return deadlineA.compareTo(deadlineB);
        });
        break;
    }
    return filtered;
  }
}
