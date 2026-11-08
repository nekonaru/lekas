import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/bulk_action_bar.dart';
import '../../core/components/empty_state.dart';
import '../../core/components/undo_snackbar.dart';
import '../../core/date_util.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../data/task_repository.dart';
import '../../l10n/app_localizations.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  final Set<String> _selection = {};
  List<Task> _tasks = const [];

  void _toggleSelection(String id) {
    setState(() {
      if (!_selection.remove(id)) _selection.add(id);
    });
  }

  List<Task> get _picked =>
      _tasks.where((t) => _selection.contains(t.id)).toList();

  /// Bulk restore with an undo that sends them back to the trash.
  Future<void> _restoreSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(taskRepositoryProvider);
    final picked = _picked;
    setState(_selection.clear);
    await ref.read(appDatabaseProvider).transaction(() async {
      for (final task in picked) {
        await repo.restoreTask(task.id);
      }
    });
    if (!mounted) return;
    UndoSnackbar.show(context, l10n.tasksRestored(picked.length), () async {
      await ref.read(appDatabaseProvider).transaction(() async {
        for (final task in picked) {
          await repo.softDeleteTask(task.id);
        }
      });
    });
  }

  /// Bulk permanent delete asks once for the whole selection.
  Future<void> _deleteSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(taskRepositoryProvider);
    final picked = _picked;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePermanentlyLabel),
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
    if (confirmed != true || !mounted) return;
    setState(_selection.clear);
    for (final task in picked) {
      await repo.deletePermanently(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);
    final locale = ref.watch(localeProvider).valueOrNull?.languageCode ?? 'id';
    final selecting = _selection.isNotEmpty;

    // A stream keeps the list live: restore and delete show up at once
    // without a second query or a spinner flash on every rebuild. The
    // Scaffold carries the back button: pushed as a route, a bare list
    // would leave the user with no visible way out.
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selecting ? l10n.selectedCount(_selection.length) : l10n.trashTitle,
        ),
        actions: [
          if (selecting)
            BulkSelectionBar(
              count: _selection.length,
              onSelectAll: () => setState(
                () => _selection.addAll(_tasks.map((task) => task.id)),
              ),
              onRestore: _restoreSelected,
              onDelete: _deleteSelected,
              onClose: () => setState(_selection.clear),
            ),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: repo.watchTrash(),
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? const <Task>[];
          _tasks = tasks;
          if (tasks.isEmpty) {
            return EmptyState(
              message: l10n.emptyTrash,
              icon: Icons.delete_outline,
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final selected = _selection.contains(task.id);
              final deletedAt = DateTime.fromMillisecondsSinceEpoch(
                task.deletedAt ?? 0,
              );
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  key: ValueKey('trash:${task.id}'),
                  selected: selected,
                  leading: selected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  title: Text(task.title),
                  subtitle: Text(
                    l10n.deletedAtLabel(
                      DateUtil.formatDateTime(deletedAt, locale),
                    ),
                  ),
                  trailing: selecting
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: l10n.restoreLabel,
                              icon: const Icon(
                                Icons.restore,
                                color: Colors.green,
                              ),
                              onPressed: () => repo.restoreTask(task.id),
                            ),
                            IconButton(
                              tooltip: l10n.deletePermanentlyLabel,
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                              onPressed: () => _confirmPermanentDelete(
                                context,
                                l10n,
                                repo,
                                task,
                              ),
                            ),
                          ],
                        ),
                  onTap: selecting ? () => _toggleSelection(task.id) : null,
                  onLongPress: () => _toggleSelection(task.id),
                ),
              );
            },
          );
        },
      ),
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
