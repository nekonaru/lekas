import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../parser/parser_service.dart';
import '../../reminders/reminder_service.dart';

/// Quick Add (design section 6.1): one text field, a live parse result and
/// tappable chips so nothing guessed by the parser is saved in silence.
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> _spaces = const [];
  ParserService? _parser;

  String? _title;
  DateTime? _deadline;
  String? _spaceId;
  String? _spaceName;
  String? _type;
  int _priority = 1;
  bool _isGroup = false;

  // Keeps a manually picked value while the user keeps typing.
  bool _deadlineTouched = false;
  bool _spaceTouched = false;
  bool _typeTouched = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
    _controller.addListener(_reparse);
  }

  @override
  void dispose() {
    _controller.removeListener(_reparse);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repository = ref.read(spaceRepositoryProvider);
    final spaces = await repository.getSpaces();
    final loaded = <Map<String, String>>[];
    for (final space in spaces) {
      final aliases = await repository.getAliases(space.id);
      loaded.add({
        'id': space.id,
        'name': space.name,
        'code': space.code ?? '',
        'aliases': aliases.join(','),
      });
    }
    if (!mounted) return;
    setState(() {
      _spaces = loaded;
      _parser = ParserService.forSpaces(loaded);
    });
    _reparse();
  }

  void _reparse() {
    final parser = _parser;
    if (parser == null) return;
    final text = _controller.text;
    if (text.trim().isEmpty) {
      setState(() {
        _title = null;
        if (!_deadlineTouched) _deadline = null;
        if (!_spaceTouched) {
          _spaceId = null;
          _spaceName = null;
        }
        if (!_typeTouched) _type = null;
      });
      return;
    }
    final parsed = parser.parse(text);
    setState(() {
      _title = parsed.title;
      if (!_deadlineTouched) _deadline = parsed.deadline;
      if (!_spaceTouched) {
        _spaceId = parsed.spaceId;
        _spaceName = _nameOf(parsed.spaceId);
      }
      if (!_typeTouched) _type = parsed.type;
      _priority = parsed.priority;
      _isGroup = parsed.isGroup;
    });
  }

  String? _nameOf(String? id) {
    if (id == null) return null;
    for (final space in _spaces) {
      if (space['id'] == id) return space['name'];
    }
    return null;
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _deadline == null
          ? const TimeOfDay(hour: 23, minute: 59)
          : TimeOfDay.fromDateTime(_deadline!),
    );
    if (time == null) return;
    setState(() {
      _deadlineTouched = true;
      _deadline =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickSpace() async {
    final spaces = await ref.read(spaceRepositoryProvider).getSpaces();
    if (!mounted) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(AppLocalizations.of(sheetContext)!.inboxTitle),
              onTap: () => Navigator.pop(sheetContext, ''),
            ),
            for (final space in spaces)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(space.name),
                onTap: () => Navigator.pop(sheetContext, space.id),
              ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _spaceTouched = true;
      _spaceId = selected.isEmpty ? null : selected;
      _spaceName = _nameOf(_spaceId);
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text.trim();
    if (l10n == null || text.isEmpty || _saving) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    await ref.read(taskRepositoryProvider).insertTask(Task(
          id: const Uuid().v4(),
          spaceId: _spaceId,
          title: (_title ?? text).trim(),
          notes: text,
          type: _type,
          deadline: _deadline?.millisecondsSinceEpoch,
          priority: _priority,
          status: 'todo',
          isGroup: _isGroup,
          pinned: false,
          inbox: _spaceId == null,
          sourceText: text,
          createdAt: now.millisecondsSinceEpoch,
          updatedAt: now.millisecondsSinceEpoch,
        ));

    if (_deadline != null) {
      // Design 4.1: notification permission is asked the first time a task
      // with a deadline is saved.
      final service = ref.read(reminderServiceProvider);
      if (await service.notificationsEnabled() == false) {
        await service.requestNotificationPermission();
      }
      await service.syncAll();
    }

    if (!mounted) return;
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savedTasksCount(1))),
    );
  }

  String _deadlineLabel(AppLocalizations l10n) {
    final deadline = _deadline;
    if (deadline == null) return l10n.taskDeadline;
    final two = deadline.minute.toString().padLeft(2, '0');
    return '${deadline.day}/${deadline.month} ${deadline.hour.toString().padLeft(2, '0')}.$two';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSave = _controller.text.trim().isNotEmpty && !_saving;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l10n.quickAddHint,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              if (canSave) _save();
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.event, size: 18),
                label: Text(_deadlineLabel(l10n)),
                onPressed: _pickDeadline,
              ),
              ActionChip(
                avatar: const Icon(Icons.folder_outlined, size: 18),
                label: Text(_spaceName ?? l10n.taskContainer),
                onPressed: _pickSpace,
              ),
              if (_type != null)
                InputChip(
                  label: Text(_type!),
                  onDeleted: () => setState(() {
                    _typeTouched = true;
                    _type = null;
                  }),
                ),
              FilterChip(
                label: Text(switch (_priority) {
                  2 => l10n.priorityHigh,
                  0 => l10n.priorityLow,
                  _ => l10n.priorityMedium,
                }),
                selected: _priority != 1,
                onSelected: (_) => setState(() {
                  _priority = _priority == 2 ? 1 : _priority + 1;
                }),
              ),
              FilterChip(
                label: Text(l10n.taskModeGroup),
                selected: _isGroup,
                onSelected: (value) => setState(() => _isGroup = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canSave ? _save : null,
              child: Text(l10n.addTask),
            ),
          ),
        ],
      ),
    );
  }
}
