import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: Text(l10n.personalTargetTitle)),
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
                title: Text(l10n.targetCompletionDate),
                subtitle: Text(_targetAt != null
                    ? '${_targetAt!.day}/${_targetAt!.month}/${_targetAt!.year}'
                    : l10n.notSetYet),
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
                    child: Text(l10n.cancel),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await repo.updateTask(task.copyWith(
                        targetAt: Value(_targetAt?.millisecondsSinceEpoch),
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      ));
                      navigator.pop();
                    },
                    child: Text(l10n.save),
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
