import 'package:flutter/material.dart';
import '../../data/models.dart';
import '../../domain/urgency.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';

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

  String title(AppLocalizations l10n) {
    switch (section) {
      case TodaySection.overdue:
        return l10n.sectionOverdue;
      case TodaySection.doing:
        return l10n.sectionDoing;
      case TodaySection.today:
        return l10n.sectionToday;
      case TodaySection.thisWeek:
        return l10n.sectionThisWeek;
      case TodaySection.upcoming:
        return l10n.sectionUpcoming;
      case TodaySection.waiting:
        return l10n.sectionWaiting;
      case TodaySection.someday:
        return l10n.sectionSomeday;
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
    final l10n = AppLocalizations.of(context)!;

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
                title(l10n),
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
              subtitle: Text(_subtitleText(l10n, task)),
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

  /// The short reason why this card sits here, followed by the deadline
  /// (design section 4.4: "deadline 6 hours left, weight 30%").
  String _subtitleText(AppLocalizations l10n, Task task) {
    final deadline =
        task.deadline == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(task.deadline!);
    final reason = urgencyReason(
      now: now,
      deadline: deadline,
      priority: task.priority,
      weightPercent: task.weightPercent,
      estimateMinutes: task.estimateMinutes,
    );

    final hours = deadline == null
        ? 0
        : deadline.difference(now).inMinutes / 60.0;
    final String text;
    switch (reason) {
      case UrgencyReason.overdue:
        text = l10n.reasonOverdue;
      case UrgencyReason.dueSoon:
        text = l10n.reasonDueInHours(hours.ceil() < 1 ? 1 : hours.ceil());
      case UrgencyReason.highPriority:
        text = l10n.reasonHighPriority;
      case UrgencyReason.heavyWeight:
        text = l10n.reasonWeight(task.weightPercent!.toStringAsFixed(0));
      case UrgencyReason.tightEstimate:
        text = l10n.reasonTightEstimate;
      case UrgencyReason.noDeadline:
        text = l10n.reasonNoDeadline;
      case UrgencyReason.timeLeft:
        text = l10n.reasonTimeLeft(hours.floor());
    }

    final parts = <String>[text];
    if (task.weightPercent != null &&
        task.weightPercent! > 0 &&
        reason != UrgencyReason.heavyWeight) {
      parts.add(
        l10n.reasonWeight(task.weightPercent!.toStringAsFixed(0)),
      );
    }
    if (deadline != null) {
      parts.add(DateUtil.formatDateTime(deadline, locale));
    }
    return parts.join(' · ');
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
