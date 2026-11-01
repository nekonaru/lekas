import 'package:flutter/material.dart';
import '../../data/models.dart';
import '../../domain/urgency.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';

enum TodaySection {
  pinned,
  focus,
  overdue,
  doing,
  today,
  thisWeek,
  upcoming,
  waiting,
  someday,
}

/// Title of one group in the Today list (design section 5.9).
String sectionTitle(TodaySection section, AppLocalizations l10n) {
  switch (section) {
    case TodaySection.pinned:
      return l10n.sectionPinned;
    case TodaySection.focus:
      return l10n.todayFocusTitle;
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

/// Icon of one group in the Today list.
IconData sectionIcon(TodaySection section) {
  switch (section) {
    case TodaySection.pinned:
      return Icons.push_pin;
    case TodaySection.focus:
      return Icons.star_outline;
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

/// The icon and name row that opens a group. Kept as its own widget so the
/// Today list can build it straight from a lazy `ListView.builder`.
class TaskSectionHeader extends StatelessWidget {
  const TaskSectionHeader({super.key, required this.section});

  final TodaySection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Icon(
            sectionIcon(section),
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            sectionTitle(section, l10n),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

/// One task row: the card with its urgency score, the swipe actions and the
/// long press of design section 5.5.
///
/// It exists on its own (next to [TaskSection]) because the Today list no
/// longer builds a Column with every card in it: it asks a lazy
/// `ListView.builder` for one card at a time, so a long list only lays out
/// the rows actually on screen.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.now,
    required this.locale,
    this.selected = false,
    this.onTaskTap,
    this.onTaskDone,
    this.onTaskSnooze,
    this.onTaskLongPress,
  });

  final Task task;
  final DateTime now;
  final String locale;
  final bool selected;

  /// Tap: open the task, or toggle it while multi select is on.
  final void Function(Task)? onTaskTap;

  /// Swipe right: mark the task done (design section 5.5).
  final Future<void> Function(Task)? onTaskDone;

  /// Swipe left: open the smart snooze choices for the task.
  final Future<void> Function(Task)? onTaskSnooze;

  /// Long press: enter or leave multi select for bulk actions.
  final void Function(Task)? onTaskLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final score = urgencyScore(
      now: now,
      deadline: task.deadline != null
          ? DateTime.fromMillisecondsSinceEpoch(task.deadline!)
          : null,
      priority: task.priority,
      weightPercent: task.weightPercent,
      estimateMinutes: task.estimateMinutes,
    );
    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: selected
            ? Icon(Icons.check_circle,
                color: Theme.of(context).colorScheme.primary)
            : _priorityIcon(task.priority),
        selected: selected,
        title: Text(task.title),
        subtitle: Text(_subtitleText(l10n)),
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

    if (onTaskDone == null && onTaskSnooze == null) return card;

    // Swipe right to finish, swipe left to snooze (design section 5.5).
    return Dismissible(
      key: ValueKey('task:${task.id}'),
      direction: DismissDirection.horizontal,
      background: _swipeBackground(context, right: true),
      secondaryBackground: _swipeBackground(context, right: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await onTaskDone?.call(task);
        } else if (direction == DismissDirection.endToStart) {
          await onTaskSnooze?.call(task);
        }
        // The card snaps back and the list reloads with the new state.
        return false;
      },
      child: onTaskLongPress == null
          ? card
          : GestureDetector(
              onLongPress: () => onTaskLongPress!(task),
              child: card,
            ),
    );
  }

  /// The short reason why this card sits here, followed by the deadline
  /// (design section 4.4: "deadline 6 hours left, weight 30%").
  String _subtitleText(AppLocalizations l10n) {
    final deadline = task.deadline == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(task.deadline!);
    final reason = urgencyReason(
      now: now,
      deadline: deadline,
      priority: task.priority,
      weightPercent: task.weightPercent,
      estimateMinutes: task.estimateMinutes,
    );

    final hours =
        deadline == null ? 0 : deadline.difference(now).inMinutes / 60.0;
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
      parts.add(l10n.reasonWeight(task.weightPercent!.toStringAsFixed(0)));
    }
    if (deadline != null) {
      parts.add(DateUtil.formatDateTime(deadline, locale));
    }
    return parts.join(' · ');
  }

  /// Colored strip revealed while a card is dragged (design section 5.5).
  Widget _swipeBackground(BuildContext context, {required bool right}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: right ? colors.primary : colors.tertiary,
      alignment: right ? Alignment.centerLeft : Alignment.centerRight,
      child: Icon(
        right ? Icons.check : Icons.snooze,
        color: right ? colors.onPrimary : colors.onTertiary,
      ),
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

/// A whole group at once: the title row followed by every card. Screens that
/// build their list lazily use [TaskSectionHeader] and [TaskCard] directly.
class TaskSection extends StatelessWidget {
  final TodaySection section;
  final List<Task> tasks;
  final DateTime now;
  final String locale;
  final void Function(Task)? onTaskTap;

  /// Swipe right: mark the task done (design section 5.5).
  final Future<void> Function(Task)? onTaskDone;

  /// Swipe left: open the smart snooze choices for the task.
  final Future<void> Function(Task)? onTaskSnooze;

  /// Long press: enter or leave multi select for bulk actions.
  final void Function(Task)? onTaskLongPress;

  /// Highlights the tasks picked in multi select mode.
  final bool Function(Task)? isSelected;

  const TaskSection({
    super.key,
    required this.section,
    required this.tasks,
    required this.now,
    required this.locale,
    this.onTaskTap,
    this.onTaskDone,
    this.onTaskSnooze,
    this.onTaskLongPress,
    this.isSelected,
  });

  String title(AppLocalizations l10n) => sectionTitle(section, l10n);

  IconData get icon => sectionIcon(section);

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskSectionHeader(section: section),
        for (final task in tasks)
          TaskCard(
            task: task,
            now: now,
            locale: locale,
            selected: isSelected?.call(task) ?? false,
            onTaskTap: onTaskTap,
            onTaskDone: onTaskDone,
            onTaskSnooze: onTaskSnooze,
            onTaskLongPress: onTaskLongPress,
          ),
      ],
    );
  }
}
