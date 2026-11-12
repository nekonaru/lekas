import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/date_util.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_service.dart';

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
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.task == null ? l10n.addTask : l10n.editTask,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.taskTitle,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.taskNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            // The container list loads the live spaces: the old empty list
            // meant the choice could never actually change, and a stored id
            // that no longer exists falls back to the inbox instead of
            // breaking the picker.
            FutureBuilder<List<Space>>(
              future: ref.read(spaceRepositoryProvider).getSpaces(),
              builder: (context, snapshot) {
                final spaces = snapshot.data ?? const <Space>[];
                final known = _spaceId == null ||
                    spaces.any((space) => space.id == _spaceId);
                return DropdownButtonFormField<String>(
                  initialValue: known ? _spaceId : null,
                  decoration: InputDecoration(labelText: l10n.taskContainer),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(l10n.inboxTitle),
                    ),
                    for (final space in spaces)
                      DropdownMenuItem<String>(
                        value: space.id,
                        child: Text(space.name),
                      ),
                  ],
                  onChanged: (v) => setState(() => _spaceId = v),
                );
              },
            ),
            const SizedBox(height: 16),
            // Deadline with date and time: one chip for the date, one for
            // the time, both filled with the current values so the row
            // always shows what will be saved.
            Text(
              l10n.taskDeadline,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.calendar_today, size: 18),
                  label: Text(_deadline == null
                      ? l10n.pickDate
                      : DateUtil.formatDate(
                          _deadline!,
                          Localizations.localeOf(context).languageCode,
                        )),
                  onPressed: () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      // A kept deadline from the past stays pickable: an edit
                      // always shows its own date first.
                      initialDate: _deadline ?? now,
                      firstDate: _deadline != null && _deadline!.isBefore(now)
                          ? DateTime(_deadline!.year, _deadline!.month,
                              _deadline!.day)
                          : now,
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (date == null) return;
                    setState(() {
                      _deadline = _withPickedDate(_deadline, date);
                    });
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.access_time, size: 18),
                  label: Text(_deadline != null
                      ? TimeOfDay.fromDateTime(_deadline!).format(context)
                      : l10n.pickTimeLabel),
                  onPressed: () async {
                    final now = DateTime.now();
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _deadline != null
                          ? TimeOfDay.fromDateTime(_deadline!)
                          : TimeOfDay(hour: now.hour, minute: now.minute),
                    );
                    if (time == null) return;
                    setState(() {
                      final base = _deadline ?? now;
                      _deadline = DateTime(
                        base.year,
                        base.month,
                        base.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),
                if (_deadline != null)
                  TextButton.icon(
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l10n.clearDeadline),
                    onPressed: () => setState(() => _deadline = null),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.taskPriority,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            // Full width, one thumb target per option: the old row pushed
            // the last segment off the screen with a long label next to it.
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(l10n.priorityLow)),
                ButtonSegment(value: 1, label: Text(l10n.priorityMedium)),
                ButtonSegment(value: 2, label: Text(l10n.priorityHigh)),
              ],
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _save,
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Keeps the currently picked time when the date moves: the user chose
  /// a day change, not a time change.
  DateTime _withPickedDate(DateTime? current, DateTime picked) {
    if (current == null) {
      final now = DateTime.now();
      return DateTime(picked.year, picked.month, picked.day, now.hour, now.minute);
    }
    return DateTime(
      picked.year,
      picked.month,
      picked.day,
      current.hour,
      current.minute,
    );
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) return;
    final repo = ref.read(taskRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    // Editing keeps the task's status, pin and group state: the old fresh
    // copy silently reopened done tasks and unpinned pinned ones.
    final task = widget.task == null
        ? Task(
            id: const Uuid().v4(),
            spaceId: _spaceId,
            title: _titleController.text,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            priority: _priority,
            status: 'todo',
            isGroup: false,
            pinned: false,
            deadline: _deadline?.millisecondsSinceEpoch,
            createdAt: now,
            updatedAt: now,
            inbox: _spaceId == null,
          )
        : widget.task!.copyWith(
            title: _titleController.text,
            notes: Value(_notesController.text.isEmpty
                ? null
                : _notesController.text),
            spaceId: Value(_spaceId),
            priority: _priority,
            deadline: Value(_deadline?.millisecondsSinceEpoch),
            inbox: _spaceId == null,
            updatedAt: now,
          );
    if (widget.task == null) {
      await repo.insertTask(task);
      if (_deadline != null) {
        // Design 4.1: ask for notification permission the first time a task
        // with a deadline is saved, right after the save succeeds.
        await _askNotificationPermission();
      }
    } else {
      await repo.updateTask(task);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _askNotificationPermission() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || !mounted) return;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.notifPermission),
        content: Text(l10n.permissionExplain),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.allow),
          ),
        ],
      ),
    );
    if (proceed != true || !mounted) return;
    await ref.read(reminderServiceProvider).requestNotificationPermission();
  }
}
