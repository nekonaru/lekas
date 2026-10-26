import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/task_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class TundaSmartScreen extends ConsumerStatefulWidget {
  final String taskId;
  const TundaSmartScreen({super.key, required this.taskId});

  @override
  ConsumerState<TundaSmartScreen> createState() => _TundaSmartScreenState();
}

class _TundaSmartScreenState extends ConsumerState<TundaSmartScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);

    return FutureBuilder<Task>(
      future: repo.getTask(widget.taskId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final task = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.snoozeReminderTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              Text(l10n.pickSnoozeTimeLabel),
              const SizedBox(height: 16),
              _tundaButton(context, l10n.oneHourLabel, Duration(hours: 1), repo, task),
              const SizedBox(height: 8),
              _tundaButton(context, l10n.tonight7pmLabel, null, repo, task,
                  customTime: const TimeOfDay(hour: 19, minute: 0)),
              const SizedBox(height: 8),
              _tundaButton(context, l10n.tomorrow7amLabel, null, repo, task,
                  customTime: const TimeOfDay(hour: 7, minute: 0),
                  isTomorrow: true),
              const SizedBox(height: 8),
              _tundaButton(context, l10n.weekendLabel, null, repo, task),
              const SizedBox(height: 8),
              _tundaButton(context, l10n.pickTimeLabel, null, repo, task),
            ],
          ),
        );
      },
    );
  }

  Widget _tundaButton(BuildContext context, String label, Duration? duration,
      TaskRepository repo, Task task,
      {TimeOfDay? customTime, bool isTomorrow = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.snooze),
        label: Text(label),
        onPressed: () async {
          DateTime fireAt;
          if (customTime != null) {
            var base = DateTime.now();
            if (isTomorrow) {
              base = base.add(const Duration(days: 1));
            }
            fireAt = DateTime(base.year, base.month, base.day,
                customTime.hour, customTime.minute);
          } else if (duration != null) {
            fireAt = DateTime.now().add(duration);
          } else {
            fireAt = DateTime.now().add(const Duration(days: 2));
          }
          await repo.updateTask(
                task.copyWith(
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                ),
              );
          if (!context.mounted) return;
          Navigator.pop(context, fireAt);
        },
      ),
    );
  }
}
