import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/components/bulk_action_bar.dart';
import '../../core/components/bulk_actions.dart';
import '../../core/components/empty_state.dart';
import '../../core/components/motion.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../tasks/task_detail_screen.dart';
import '../tasks/task_form_sheet.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final Set<String> _selection = {};
  List<Task> _tasks = const [];

  void _toggleSelection(String id) {
    setState(() {
      if (!_selection.remove(id)) _selection.add(id);
    });
  }

  List<Task> get _picked => _tasks.where((t) => _selection.contains(t.id)).toList();

  /// Clears the selection first so the action bar dismisses at once.
  Future<void> _complete() async {
    final picked = _picked;
    setState(_selection.clear);
    await BulkActions.complete(context, ref, picked);
  }

  Future<void> _delete() async {
    final picked = _picked;
    setState(_selection.clear);
    await BulkActions.softDelete(context, ref, picked);
  }

  void _clear() => setState(_selection.clear);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);
    final selecting = _selection.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(selecting
            ? l10n.selectedCount(_selection.length)
            : l10n.inboxTitle),
        actions: [
          if (selecting)
            BulkSelectionBar(
              count: _selection.length,
              onSelectAll: () => setState(
                () => _selection.addAll(_tasks.map((task) => task.id)),
              ),
              onComplete: _complete,
              onPriority: () => BulkActions.pickPriority(context, ref, _picked),
              onSpace: () => BulkActions.pickSpace(context, ref, _picked),
              onDelete: _delete,
              onClose: _clear,
            ),
        ],
      ),
      // The stream keeps the rows in step with writes, so bulk actions and
      // their undo both refresh the list without a spinner flash.
      body: StreamBuilder<List<Task>>(
        stream: repo.watchTasks(includeInbox: true),
        builder: (context, snapshot) {
          var tasks = (snapshot.data ?? const <Task>[])
              .where((t) => t.inbox)
              .toList();
          _tasks = tasks;

          if (tasks.isEmpty) {
            return EmptyState(message: l10n.emptyInboxNote, icon: Icons.inbox);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final selected = _selection.contains(task.id);
              return FadeSlideIn(
                index: index,
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    selected: selected,
                    leading: selected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    title: Text(task.title),
                    subtitle: Text(task.notes ?? l10n.noNotesLabel),
                    trailing: Icon(selected ? null : Icons.chevron_right),
                    onTap: selecting
                        ? () => _toggleSelection(task.id)
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(taskId: task.id),
                              ),
                            );
                          },
                    onLongPress: () => _toggleSelection(task.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: selecting
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const TaskFormSheet(),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.addTask),
            ),
    );
  }
}
