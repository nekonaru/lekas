import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/batch_edit.dart';
import '../../l10n/app_localizations.dart';

/// Applies one change to a set of tasks in a single pass. The selection
/// comes from the caller; this screen only decides what to write.
class BatchEditScreen extends ConsumerStatefulWidget {
  const BatchEditScreen({super.key, required this.taskIds});

  final List<String> taskIds;

  @override
  ConsumerState<BatchEditScreen> createState() => _BatchEditScreenState();
}

class _BatchEditScreenState extends ConsumerState<BatchEditScreen> {
  String? _spaceId;
  int? _priority;
  bool? _done;
  final _tagController = TextEditingController();
  bool _saving = false;
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.taskIds};
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final edit = BatchEdit(
      spaceId: _spaceId,
      priority: _priority,
      done: _done,
      tagNames: normalizeTagNames(_tagController.text.split(RegExp(r'[,;]'))),
    );
    final repo = ref.read(taskRepositoryProvider);
    final tagRepo = ref.read(tagRepositoryProvider);
    try {
      for (final id in _selected) {
        Task task;
        try {
          task = await repo.getTask(id);
        } catch (_) {
          continue;
        }
        final next = task.copyWith(
          spaceId: edit.spaceId == null
              ? const Value.absent()
              : Value(edit.spaceId),
          priority: edit.priority ?? task.priority,
          status: edit.done == null
              ? task.status
              : (edit.done! ? 'done' : 'todo'),
          completedAt: edit.done == null
              ? const Value.absent()
              : Value(edit.done!
                  ? DateTime.now().millisecondsSinceEpoch
                  : null),
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await repo.updateTask(next);
        if (edit.tagNames.isNotEmpty) {
          await tagRepo.setTaskTags(id, edit.tagNames);
        }
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final spaces = ref.watch(spaceRepositoryProvider).watchSpaces();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchEditTitle(_selected.length))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.taskIds.isEmpty) ...[
            Text(
              l10n.batchPickTasks,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Task>>(
              stream: ref.watch(taskRepositoryProvider).watchTasks(includeInbox: true),
              builder: (context, snapshot) {
                final tasks = snapshot.data ?? const <Task>[];
                if (tasks.isEmpty) {
                  return Text(l10n.batchNoTasks);
                }
                return Column(
                  children: [
                    for (final task in tasks.take(30))
                      CheckboxListTile(
                        dense: true,
                        value: _selected.contains(task.id),
                        title: Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _selected.add(task.id);
                          } else {
                            _selected.remove(task.id);
                          }
                        }),
                      ),
                  ],
                );
              },
            ),
            const Divider(),
          ],
          Text(
            l10n.batchEditHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Space>>(
            stream: spaces,
            builder: (context, snapshot) {
              final list = snapshot.data ?? const <Space>[];
              return DropdownButtonFormField<String?>(
                initialValue: _spaceId,
                decoration: InputDecoration(
                  labelText: l10n.batchMoveToCategory,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.batchKeepValue),
                  ),
                  for (final space in list)
                    DropdownMenuItem<String?>(
                      value: space.id,
                      child: Text(space.name),
                    ),
                ],
                onChanged: (value) => setState(() => _spaceId = value),
              );
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _priority,
            decoration: InputDecoration(
              labelText: l10n.batchSetPriority,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(l10n.batchKeepValue),
              ),
              DropdownMenuItem(value: 0, child: Text(l10n.priorityLow)),
              DropdownMenuItem(value: 1, child: Text(l10n.priorityMedium)),
              DropdownMenuItem(value: 2, child: Text(l10n.priorityHigh)),
            ],
            onChanged: (value) => setState(() => _priority = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<bool?>(
            initialValue: _done,
            decoration: InputDecoration(
              labelText: l10n.batchSetStatus,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<bool?>(
                value: null,
                child: Text(l10n.batchKeepValue),
              ),
              DropdownMenuItem(value: true, child: Text(l10n.doneLabel)),
              DropdownMenuItem(value: false, child: Text(l10n.statusTodo)),
            ],
            onChanged: (value) => setState(() => _done = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagController,
            decoration: InputDecoration(
              labelText: l10n.batchAddTags,
              hintText: 'urgent, revisi',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving || _selected.isEmpty ? null : _save,
        label: Text(l10n.save),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
