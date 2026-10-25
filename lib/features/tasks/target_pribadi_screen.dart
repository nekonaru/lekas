import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class TargetPribadiScreen extends ConsumerStatefulWidget {
  final String taskId;
  const TargetPribadiScreen({super.key, required this.taskId});

  @override
  ConsumerState<TargetPribadiScreen> createState() => _TargetPribadiScreenState();
}

class _TargetPribadiScreenState extends ConsumerState<TargetPribadiScreen> {
  DateTime? _targetAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Target Pribadi')),
      body: FutureBuilder<Task>(
        future: repo.getTask(widget.taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final task = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('Target Selesai'),
                subtitle: Text(_targetAt != null
                    ? '${_targetAt!.day}/${_targetAt!.month}/${_targetAt!.year}'
                    : 'Belum diatur'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: task.deadline != null
                        ? DateTime.fromMillisecondsSinceEpoch(task.deadline!)
                        : DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _targetAt = date);
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      await repo.updateTask(task.copyWith(
                        targetAt: _targetAt?.millisecondsSinceEpoch,
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      ));
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
