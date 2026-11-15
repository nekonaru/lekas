import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_util.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'task_detail_screen.dart';

/// The morning and nightly summary of what is on the plate today,
/// tomorrow, and what already slipped. Rows can be checked off straight
/// from here or opened to their detail screen.
class MorningNightSummaryScreen extends ConsumerWidget {
  const MorningNightSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.morningNightSummaryTitle)),
      body: StreamBuilder<List<Task>>(
        stream: repo.watchTasks(includeInbox: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data ?? const <Task>[];
          final now = DateTime.now();
          final today = DateUtil.startOfDay(now);
          final tomorrow = today.add(const Duration(days: 1));

          /// Whether the task is due today or earlier (overdue included) and
          /// not yet done.
          bool dueBeforeOrToday(Task t) {
            if (t.deadline == null) return false;
            final deadline =
                DateTime.fromMillisecondsSinceEpoch(t.deadline!).toLocal();
            return deadline.isBefore(today) ||
                DateUtil.isSameDay(deadline, today);
          }

          bool dueTomorrow(Task t) {
            if (t.deadline == null) return false;
            final deadline =
                DateTime.fromMillisecondsSinceEpoch(t.deadline!).toLocal();
            return DateUtil.isSameDay(deadline, tomorrow);
          }

          // The row needs no `bool dueBefore` helper with a String argument;
          // this keeps the exact same logic inline where it is used.
          final todayTodo = tasks
              .where((t) => t.status != 'done' && dueBeforeOrToday(t))
              .toList()
            ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
          final tomorrowTodo = tasks
              .where((t) => t.status != 'done' && dueTomorrow(t))
              .toList()
            ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
          final overdue = tasks
              .where((t) => t.status != 'done' && t.deadline != null &&
                  DateTime.fromMillisecondsSinceEpoch(t.deadline!).toLocal().isBefore(today))
              .toList()
            ..sort((a, b) => a.deadline!.compareTo(b.deadline!));

          final doneToday = tasks
              .where((t) =>
                  t.status == 'done' &&
                  t.completedAt != null &&
                  DateUtil.isSameDay(
                    DateTime.fromMillisecondsSinceEpoch(t.completedAt!).toLocal(),
                    today,
                  ))
              .length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            children: [
              Text(
                l10n.todaySummary,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _statCard(context, l10n.todayTasksLabel, '${todayTodo.length}',
                  Icons.today),
              if (todayTodo.isNotEmpty) ...[
                const SizedBox(height: 4),
                ...todayTodo.map((task) => _taskRow(context, ref, task)),
                const SizedBox(height: 12),
              ],
              _statCard(context, l10n.tomorrowTasksLabel, '${tomorrowTodo.length}',
                  Icons.calendar_today),
              if (tomorrowTodo.isNotEmpty) ...[
                const SizedBox(height: 4),
                ...tomorrowTodo.map((task) => _taskRow(context, ref, task)),
                const SizedBox(height: 12),
              ],
              _statCard(context, l10n.overdueTasksLabel, '${overdue.length}',
                  Icons.warning_amber_outlined),
              if (overdue.isNotEmpty) ...[
                const SizedBox(height: 4),
                ...overdue.map((task) => _taskRow(context, ref, task)),
                const SizedBox(height: 12),
              ],
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(l10n.doneTodayLabel),
                  trailing: Text(
                    '$doneToday',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.summaryScheduleNote,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _taskRow(BuildContext context, WidgetRef ref, Task task) {
    final locale = Localizations.localeOf(context).languageCode;
    return ListTile(
      dense: true,
      leading: IconButton(
        icon: const Icon(Icons.radio_button_unchecked),
        tooltip: AppLocalizations.of(context)!.markLabel,
        onPressed: () => ref.read(taskRepositoryProvider).markDone(task.id),
      ),
      title: Text(task.title),
      subtitle: Text(DateUtil.formatDateTime(
        DateTime.fromMillisecondsSinceEpoch(task.deadline!).toLocal(),
        locale,
      )),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => TaskDetailScreen(taskId: task.id),
        ),
      ),
    );
  }
}
