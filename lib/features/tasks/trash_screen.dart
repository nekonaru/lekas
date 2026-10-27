import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/date_util.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../data/task_repository.dart';
import '../../l10n/app_localizations.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);
    final locale = ref.watch(localeProvider).valueOrNull?.languageCode ?? 'id';

    // A stream keeps the list live: restore and delete show up at once
    // without a second query or a spinner flash on every rebuild.
    return StreamBuilder<List<Task>>(
      stream: repo.watchTrash(),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? const <Task>[];
        if (tasks.isEmpty) {
          return Center(child: Text(l10n.emptyTrash));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final deletedAt = DateTime.fromMillisecondsSinceEpoch(
              task.deletedAt ?? 0,
            );
            return ListTile(
              title: Text(task.title),
              subtitle: Text(
                l10n.deletedAtLabel(
                  DateUtil.formatDateTime(deletedAt, locale),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l10n.restoreLabel,
                    icon: const Icon(Icons.restore, color: Colors.green),
                    onPressed: () => repo.restoreTask(task.id),
                  ),
                  IconButton(
                    tooltip: l10n.deletePermanentlyLabel,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () => _confirmPermanentDelete(context, l10n, repo, task),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Permanent removal is irreversible, so it always asks first.
  Future<void> _confirmPermanentDelete(
    BuildContext context,
    AppLocalizations l10n,
    TaskRepository repo,
    Task task,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Text(l10n.deletePermanentlyBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deletePermanentlyLabel),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await repo.deletePermanently(task.id);
    }
  }
}
