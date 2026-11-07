import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/bulk_action_bar.dart';
import '../../core/components/bulk_actions.dart';
import '../../core/components/empty_state.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';
import '../tasks/task_detail_screen.dart';

/// The tasks due on one calendar day: tick them off, select them in bulk,
/// and tap through to the detail screen.
class DayTasksScreen extends ConsumerStatefulWidget {
  const DayTasksScreen({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<DayTasksScreen> createState() => _DayTasksScreenState();
}

class _DayTasksScreenState extends ConsumerState<DayTasksScreen> {
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
    final locale = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(taskRepositoryProvider);
    final selecting = _selection.isNotEmpty;
    final title = DateUtil.formatDate(widget.date, locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(selecting
            ? l10n.selectedCount(_selection.length)
            : title),
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
        stream: repo.watchTasks(includeInbox: true),
        builder: (context, snapshot) {
          final tasks = (snapshot.data ?? const <Task>[])
              .where((task) =>
                  task.deadline != null &&
                  DateUtil.isSameDay(
                    DateTime.fromMillisecondsSinceEpoch(task.deadline!),
                    widget.date,
                  ))
              .toList()
            ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
          _tasks = tasks;
          if (tasks.isEmpty) {
            return EmptyState(
              message: l10n.emptyTaskList,
              icon: Icons.calendar_month,
            );
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
                subtitle: task.deadline == null
                    ? null
                    : Text(DateUtil.formatTime(
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
