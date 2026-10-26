import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';

class MorningNightSummaryScreen extends ConsumerStatefulWidget {
  const MorningNightSummaryScreen({super.key});

  @override
  ConsumerState<MorningNightSummaryScreen> createState() => _MorningNightSummaryScreenState();
}

class _MorningNightSummaryScreenState extends ConsumerState<MorningNightSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.morningNightSummaryTitle)),
      body: FutureBuilder<List<Task>>(
        future: repo.getTasks(includeInbox: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data ?? [];
          final now = DateTime.now();
          final today = DateUtil.startOfDay(now);
          final tomorrow = today.add(const Duration(days: 1));

          final todayTasks = tasks.where((t) =>
              t.deadline != null &&
              DateUtil.isSameDay(DateTime.fromMillisecondsSinceEpoch(t.deadline!), today)).length;
          final tomorrowTasks = tasks.where((t) =>
              t.deadline != null &&
              DateUtil.isSameDay(DateTime.fromMillisecondsSinceEpoch(t.deadline!), tomorrow)).length;
          final overdue = tasks.where((t) =>
              t.deadline != null &&
              DateTime.fromMillisecondsSinceEpoch(t.deadline!).isBefore(today)).length;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              Text(
                l10n.todaySummary,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _summaryCard(context, l10n.todayTasksLabel, todayTasks.toString(), Icons.today),
              const SizedBox(height: 12),
              _summaryCard(context, l10n.tomorrowTasksLabel, tomorrowTasks.toString(),
                  Icons.calendar_today),
              const SizedBox(height: 12),
              _summaryCard(
                  context, l10n.overdueTasksLabel, overdue.toString(), Icons.warning),
              const SizedBox(height: 40),
              Text(
                l10n.summaryScheduleNote,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
