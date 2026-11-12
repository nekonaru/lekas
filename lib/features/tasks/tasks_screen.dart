import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_util.dart';
import '../../core/components/bulk_action_bar.dart';
import '../../core/components/bulk_actions.dart';
import '../../core/components/empty_state.dart';
import '../../core/components/task_filter_sheet.dart';
import '../../core/task_filter.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'task_detail_screen.dart';
import 'task_form_sheet.dart';

/// Every task in one list, with a category filter and an optional grouping
/// (design section 4.3). Pushed as a sub screen, so it keeps its own bar.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

sealed class _Row {
  const _Row();
}

class _HeaderRow extends _Row {
  const _HeaderRow(this.spaceId, this.count);

  final String? spaceId;
  final int count;
}

class _TaskRow extends _Row {
  const _TaskRow(this.task);

  final Task task;
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final Set<String> _selection = {};
  List<Task> _tasks = const [];

  /// The one filter row every list shares: category, status and sort.
  TaskFilter _filter = TaskFilter.none;

  /// Group the list under a header per category instead of one flat run.
  bool _grouped = false;

  List<Space> _spaces = const [];

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    // Archived categories still own live tasks, so they must both show up
    // in the filter sheet and head a group.
    final spaces = await ref
        .read(spaceRepositoryProvider)
        .getSpaces(includeArchived: true);
    if (!mounted) return;
    setState(() => _spaces = spaces);
  }

  void _toggleSelection(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_selection.remove(id)) _selection.add(id);
    });
  }

  List<Task> get _picked =>
      _tasks.where((t) => _selection.contains(t.id)).toList();

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

  Future<void> _openFilter() async {
    await showTaskFilterSheet(
      context: context,
      spaces: _spaces,
      current: _filter,
      onChanged: (next) => setState(() => _filter = next),
    );
  }

  String _groupName(AppLocalizations l10n, String? spaceId) {
    if (spaceId == null) return l10n.inboxTitle;
    for (final space in _spaces) {
      if (space.id == spaceId) return space.name;
    }
    return l10n.noCategoryFallback;
  }

  Color? _groupColor(String? spaceId) {
    if (spaceId == null) return null;
    for (final space in _spaces) {
      if (space.id == spaceId) return Color(space.color);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.watch(taskRepositoryProvider);
    final locale = ref.watch(localeProvider).valueOrNull?.languageCode ?? 'id';
    final selecting = _selection.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selecting
              ? l10n.selectedCount(_selection.length)
              : l10n.taskListTitle,
        ),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                FilterChip(
                  avatar: const Icon(Icons.filter_list, size: 18),
                  label: Text(
                    _filter.activeCount == 0
                        ? l10n.filterLabel
                        : '${l10n.filterLabel} (${_filter.activeCount})',
                  ),
                  selected: !_filter.isDefault,
                  showCheckmark: false,
                  onSelected: (_) => _openFilter(),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: const Icon(Icons.folder_outlined, size: 18),
                  label: Text(l10n.groupByCategory),
                  selected: _grouped,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _grouped = !_grouped),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: repository.watchTasks(includeInbox: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tasks = _filter.apply(snapshot.data ?? const <Task>[]);
                _tasks = tasks;
                if (tasks.isEmpty) {
                  // A filter that matches nothing gets its own message; the
                  // empty database message belongs to the no-filter state.
                  return EmptyState(
                    message: _filter.isDefault
                        ? l10n.emptyTaskList
                        : l10n.noFilterMatch,
                    icon: _filter.isDefault ? Icons.task_alt : Icons.search_off,
                  );
                }
                if (!_grouped) return _flatList(tasks, l10n, locale);
                return _groupedList(tasks, l10n, locale);
              },
            ),
          ),
        ],
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

  Widget _flatList(List<Task> tasks, AppLocalizations l10n, String locale) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _taskCard(tasks[index], l10n, locale),
    );
  }

  Widget _groupedList(List<Task> tasks, AppLocalizations l10n, String locale) {
    final groups = <String?, List<Task>>{};
    for (final task in tasks) {
      (groups[task.spaceId] ??= <Task>[]).add(task);
    }
    // Drag order first, inbox last, anything without a category resolving
    // at the end (never in practice: cascading deletes move tasks to the
    // inbox).
    final orderedKeys = <String?>[
      for (final space in _spaces)
        if (groups.containsKey(space.id)) space.id,
      for (final key in groups.keys)
        if (key != null && !_spaces.any((space) => space.id == key)) key,
      if (groups.containsKey(null)) null,
    ];
    final entries = <_Row>[
      for (final key in orderedKeys) ...[
        _HeaderRow(key, groups[key]!.length),
        for (final task in groups[key]!) _TaskRow(task),
      ],
    ];
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return switch (entry) {
          _HeaderRow(:final spaceId, :final count) => _groupHeader(
              l10n,
              spaceId,
              count,
            ),
          _TaskRow(:final task) => _taskCard(task, l10n, locale),
        };
      },
    );
  }

  Widget _groupHeader(
    AppLocalizations l10n,
    String? spaceId,
    int count,
  ) {
    final colors = Theme.of(context).colorScheme;
    final accent = _groupColor(spaceId);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(
            spaceId == null ? Icons.inbox_outlined : Icons.folder_outlined,
            size: 17,
            color: accent ?? colors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _groupName(l10n, spaceId),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(Task task, AppLocalizations l10n, String locale) {
    final done = task.status == 'done';
    final selected = _selection.contains(task.id);
    final selecting = _selection.isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
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
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: task.deadline == null
            ? null
            : Text(
                DateUtil.formatDate(
                  DateTime.fromMillisecondsSinceEpoch(task.deadline!),
                  locale,
                ),
              ),
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
      ),
    );
  }

  /// Mark done or reopen behind the row's check while not selecting.
  Future<void> _toggleDone(Task task, bool done) async {
    final repo = ref.read(taskRepositoryProvider);
    if (done) {
      await repo.updateTask(
        task.copyWith(
          status: 'todo',
          completedAt: const Value(null),
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else {
      await repo.markDone(task.id);
    }
  }
}
