import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';

class OverdueReminderScreen extends ConsumerStatefulWidget {
  const OverdueReminderScreen({super.key});

  @override
  ConsumerState<OverdueReminderScreen> createState() => _OverdueReminderScreenState();
}

class _OverdueReminderScreenState extends ConsumerState<OverdueReminderScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat Tugas Terlambat')),
      body: FutureBuilder<List<Task>>(
        future: repo.getTasks(includeInbox: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final now = DateTime.now();
          final today = DateUtil.startOfDay(now);
          final overdue = snapshot.data?.where((t) =>
              t.deadline != null &&
              t.status != 'done' &&
              DateTime.fromMillisecondsSinceEpoch(t.deadline!).isBefore(today)).toList() ?? [];

          if (overdue.isEmpty) {
            return const Center(child: Text('Tidak ada tugas terlambat.'));
          }

          return ListView.builder(
            itemCount: overdue.length,
            itemBuilder: (context, index) {
              final task = overdue[index];
              final deadline = DateTime.fromMillisecondsSinceEpoch(task.deadline!);
              final daysLate = today.difference(deadline).inDays;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text(
                    'Terlambat $daysLate hari. Deadline: ${DateUtil.formatDate(deadline, locale)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await repo.markDone(task.id);
                          if (mounted) setState(() {});
                        },
                        child: const Text('Selesai'),
                      ),
                      TextButton(
                        onPressed: () => _resetDeadline(context, task),
                        child: const Text('Atur ulang'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _resetDeadline(BuildContext context, Task task) async {
    final newDeadline = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (newDeadline != null) {
      await repo.updateTask(task.copyWith(
        deadline: newDeadline.millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      if (mounted) setState(() {});
    }
  }
}
