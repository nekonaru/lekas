import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../data/providers.dart';
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
          appBar: AppBar(title: const Text('Tunda Pengingat')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              const Text('Pilih waktu tunda:'),
              const SizedBox(height: 16),
              _tundaButton(context, '1 jam', Duration(hours: 1), repo, task.id),
              const SizedBox(height: 8),
              _tundaButton(context, 'Nanti malam 19.00', null, repo, task.id,
                  customTime: const TimeOfDay(hour: 19, minute: 0)),
              const SizedBox(height: 8),
              _tundaButton(context, 'Besok pagi 07.00', null, repo, task.id,
                  customTime: const TimeOfDay(hour: 7, minute: 0),
                  isTomorrow: true),
              const SizedBox(height: 8),
              _tundaButton(context, 'Akhir pekan', null, repo, task.id),
              const SizedBox(height: 8),
              _tundaButton(context, 'Pilih waktu', null, repo, task.id),
            ],
          ),
        );
      },
    );
  }

  Widget _tundaButton(BuildContext context, String label, Duration? duration,
      WidgetRef ref, String taskId, {TimeOfDay? customTime, bool isTomorrow = false}) {
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
          await ref.read(taskRepositoryProvider).updateTask(
                task.copyWith(
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                ),
              );
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }
}
