import 'package:flutter/material.dart';
import '../../data/models.dart';
import '../../domain/urgency.dart';
import '../../core/date_util.dart';

enum TodaySection {
  overdue,
  doing,
  today,
  thisWeek,
  upcoming,
  waiting,
  someday,
}

class TaskSection extends StatelessWidget {
  final TodaySection section;
  final List<Task> tasks;
  final DateTime now;
  final String locale;
  final void Function(Task)? onTaskTap;

  const TaskSection({
    super.key,
    required this.section,
    required this.tasks,
    required this.now,
    required this.locale,
    this.onTaskTap,
  });

  String get title {
    switch (section) {
      case TodaySection.overdue:
        return 'Terlambat';
      case TodaySection.doing:
        return 'Sedang Dikerjakan';
      case TodaySection.today:
        return 'Hari Ini dan Besok';
      case TodaySection.thisWeek:
        return 'Minggu Ini';
      case TodaySection.upcoming:
        return 'Mendatang';
      case TodaySection.waiting:
        return 'Menunggu';
      case TodaySection.someday:
        return 'Kapan-kapan';
    }
  }

  IconData get icon {
    switch (section) {
      case TodaySection.overdue:
        return Icons.warning;
      case TodaySection.doing:
        return Icons.play_circle;
      case TodaySection.today:
        return Icons.today;
      case TodaySection.thisWeek:
        return Icons.calendar_today;
      case TodaySection.upcoming:
        return Icons.schedule;
      case TodaySection.waiting:
        return Icons.hourglass_empty;
      case TodaySection.someday:
        return Icons.inbox;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...tasks.map((task) {
          final score = urgencyScore(
            now: now,
            deadline: task.deadline != null
                ? DateTime.fromMillisecondsSinceEpoch(task.deadline!)
                : null,
            priority: task.priority,
            weightPercent: task.weightPercent,
            estimateMinutes: task.estimateMinutes,
          );
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: _priorityIcon(task.priority),
              title: Text(task.title),
              subtitle: task.deadline != null
                  ? Text(DateUtil.formatDateTime(
                      DateTime.fromMillisecondsSinceEpoch(task.deadline!), locale))
                  : const Text('Kapan-kapan'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(score.toStringAsFixed(0)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _priorityIcon(int priority) {
    switch (priority) {
      case 0:
        return const Icon(Icons.circle, size: 12, color: Colors.green);
      case 1:
        return const Icon(Icons.circle, size: 12, color: Colors.orange);
      case 2:
        return const Icon(Icons.circle, size: 12, color: Colors.red);
      default:
        return const Icon(Icons.circle, size: 12, color: Colors.grey);
    }
  }
}
