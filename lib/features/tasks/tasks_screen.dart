import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_util.dart';
import '../../core/components/bulk_action_bar.dart';
import '../../core/components/bulk_actions.dart';
import '../../core/components/empty_state.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'task_detail_screen.dart';
import 'task_form_sheet.dart';

/// Every task in one list, sorted by deadline (design section 4.3).
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final Set<String> _selection = {};
  List<Task> _tasks = const [];

  void _toggleSelection(String id) {
    setState(() {
      if (!_selection.remove(id)) _selection.add(id);
    });
  }

  List<Task> get _picked => _tasks.where((t) => _selection.contains(t.id)).toList();

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.watch(taskRepositoryProvider);
    final locale = ref.watch(localeProvider).valueOrNull?.languageCode ?? 'id';
    final selecting = _selection.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(selecting
            ? l10n.selectedCount(_selection.length)
            : l10n.taskListTitle),
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
              onClose: () => setState(_selection.clear),
            ),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: repository.watchTasks(includeInbox: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = (snapshot.data ?? <Task>[])
            ..sort((a, b) => (a.deadline ?? 1 << 62)
                .compareTo(b.deadline ?? 1 << 62));
          _tasks = tasks;
          if (tasks.isEmpty) {
            return EmptyState(message: l10n.emptyTaskList, icon: Icons.task_alt);
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final done = task.status == 'done';
              final selected = _selection.contains(task.id);
              return ListTile(
                selected: selected,
                leading: IconButton(
                  icon: Icon(
                    selected
                        ? Icons.check_circle
                        : done
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked_outlined,
                    color: selected || done
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  tooltip: l10n.markLabel,
                  onPressed: () => selecting
                      ? _toggleSelection(task.id)
                      : _toggleDone(task, done),
                ),
                title: Text(
                  task.title,
                  style: done
                      ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                        )
                      : null,
                ),
                // `DateTime.toString()` never contains a "T" (only
                // toIso8601String does), so splitting on it printed the whole
                // timestamp with milliseconds. Show the date like every other
                // screen does.
                subtitle: task.deadline == null
                    ? null
                    : Text(DateUtil.formatDate(
                        DateTime.fromMillisecondsSinceEpoch(task.deadline!),
                        locale,
                      )),
                trailing: selected ? null : const Icon(Icons.chevron_right),
                onTap: selecting
                    ? () => _toggleSelection(task.id)
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => TaskDetailScreen(taskId: task.id),
                          ),
                        ),
                onLongPress: () => _toggleSelection(task.id),
              );
            },
          );
        },
      ),
      floatingActionButton: selecting
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const TaskFormSheet(),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.addTask),
            ),
    );
  }

  /// Mark done or reopen behind the row's check while not selecting.
  Future<void> _toggleDone(Task task, bool done) async {
    final repo = ref.read(taskRepositoryProvider);
    if (done) {
      await repo.updateTask(task.copyWith(
        status: 'todo',
        completedAt: const Value(null),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));
    } else {
      await repo.markDone(task.id);
    }
  }
}
