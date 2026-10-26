import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../core/theme.dart';
import '../../core/date_util.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'task_detail_screen.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  final Task? task;
  const TaskFormSheet({super.key, this.task});

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String? _spaceId;
  int _priority = 1;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _notesController.text = widget.task!.notes ?? '';
      _spaceId = widget.task!.spaceId;
      _priority = widget.task!.priority;
      _deadline = widget.task!.deadline != null
          ? DateTime.fromMillisecondsSinceEpoch(widget.task!.deadline!)
          : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.task == null ? l10n.addTask : l10n.editTask,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.taskTitle,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.taskNotes,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _spaceId,
            decoration: InputDecoration(labelText: l10n.taskContainer),
            items: const [],
            onChanged: (v) => setState(() => _spaceId = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(l10n.taskDeadline),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _deadline = date);
                  }
                },
                child: Text(_deadline != null
                    ? DateUtil.formatDate(_deadline!, 'id')
                    : l10n.pickDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(l10n.taskPriority),
              const Spacer(),
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(value: 0, label: Text(l10n.priorityLow)),
                  ButtonSegment(value: 1, label: Text(l10n.priorityMedium)),
                  ButtonSegment(value: 2, label: Text(l10n.priorityHigh)),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
              ),
            ],
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
                onPressed: _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) return;
    final repo = ref.read(taskRepositoryProvider);
    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      spaceId: _spaceId,
      title: _titleController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      priority: _priority,
      status: 'todo',
      isGroup: false,
      pinned: false,
      deadline: _deadline?.millisecondsSinceEpoch,
      createdAt: widget.task?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      inbox: _spaceId == null,
    );
    if (widget.task == null) {
      await repo.insertTask(task);
    } else {
      await repo.updateTask(task);
    }
    if (mounted) Navigator.pop(context);
  }
}
