import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models.dart';
import '../../data/parsed_task_extras.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../parser/parser_service.dart';
import '../../reminders/reminder_service.dart';
import '../../voice/voice_input.dart';

/// Quick Add (design section 6.1): one text field, a live parse result and
/// tappable chips so nothing guessed by the parser is saved in silence.
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key, this.initialText = '', this.startVoice = false});

  /// Text the sheet opens with, so the voice screen can hand over what it
  /// heard (design section 7.1).
  final String initialText;

  /// Starts a speech session as soon as the sheet is up.
  final bool startVoice;

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

  /// The full parse result behind the extra chips of design section 7.15,
  /// and the chips the user has already dismissed for this text.
  ParsedTask? _parsed;
  final Set<String> _dismissed = <String>{};

  /// Voice input (design section 7.1): the recognizer is shared by this
  /// sheet and the voice screen, and the text typed before the session is
  /// kept in front of whatever is recognized.
  final VoiceInput _voice = VoiceInput();
  bool _listening = false;
  String _voiceBase = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_reparse);
    if (widget.initialText.isNotEmpty) _controller.text = widget.initialText;
    _load();
    if (widget.startVoice) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _toggleVoice());
    }
  }

  @override
  void dispose() {
    _voice.cancel();
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
        _parsed = null;
        _dismissed.clear();
        if (!_deadlineTouched) _deadline = null;
        if (!_spaceTouched) {
          _spaceId = null;
          _spaceName = null;
        }
        if (!_typeTouched) _type = null;
      });
      return;
    }
    // The active language decides which dictionary leads (design section
    // 8.5); until the setting is loaded the parser falls back to Indonesian.
    final language =
        ref.read(localeProvider).valueOrNull?.languageCode ?? 'id';
    final parsed = parser.parse(text, locale: language);
    setState(() {
      _parsed = parsed;
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

  /// Toggles the microphone of design section 7.1: the recognized sentence
  /// lands in the text field, so the parser turns it into chips right away.
  Future<void> _toggleVoice() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    if (_listening) {
      await _voice.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    final language =
        ref.read(localeProvider).valueOrNull?.languageCode ?? 'id';
    _voiceBase = _controller.text.trim();
    final started = await _voice.start(
      localeId: language == 'id' ? 'id_ID' : 'en_US',
      onText: _onVoiceText,
      onError: _onVoiceError,
    );
    if (!mounted) return;
    if (started) {
      setState(() => _listening = true);
    } else {
      _showVoiceMessage(l10n.micUnavailable);
    }
  }

  /// Writes the recognized sentence behind the text already there, so the
  /// user can keep typing while the session runs.
  void _onVoiceText(String text, bool isFinal) {
    if (!mounted) return;
    final heard = text.trim();
    final base = _voiceBase;
    final next =
        heard.isEmpty ? base : (base.isEmpty ? heard : '$base $heard');
    if (_controller.text != next) {
      _controller.text = next;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
    if (isFinal) setState(() => _listening = false);
  }

  void _onVoiceError(String errorCode, bool permanent) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    setState(() => _listening = false);
    _showVoiceMessage(errorCode == 'error_permission'
        ? l10n.micPermissionDenied
        : l10n.micUnavailable);
  }

  void _showVoiceMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _nameOf(String? id) {
    if (id == null) return null;
    for (final space in _spaces) {
      if (space['id'] == id) return space['name'];
    }
    return null;
  }

  /// True while the chip behind [id] has not been dismissed, so a value
  /// the user threw away never reaches the saved task.
  bool _stillWanted(String id) => !_dismissed.contains(id);

  void _dismiss(String id) => setState(() => _dismissed.add(id));

  /// The chips of design section 7.15: every guess the advanced parser
  /// makes is shown and can be corrected before saving.
  List<Widget> _extraChips(AppLocalizations l10n) {
    final parsed = _parsed;
    if (parsed == null) return const [];
    final chips = <Widget>[];

    final estimate = parsed.estimateMinutes;
    if (estimate != null && estimate > 0 && _stillWanted('estimate')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.timer_outlined, size: 18),
        label: Text(estimate >= 60 && estimate % 60 == 0
            ? l10n.chipEstimateHours(estimate ~/ 60)
            : l10n.estimateMinutesLabel(estimate)),
        onDeleted: () => _dismiss('estimate'),
      ));
    }

    final submit = parsed.submitMethod;
    if (submit != null && _stillWanted('submit')) {
      final label = switch (submit) {
        'lms' => l10n.chipSubmitLms,
        'email' => l10n.chipSubmitEmail,
        'paper' => l10n.chipSubmitPaper,
        _ => submit,
      };
      chips.add(InputChip(
        avatar: const Icon(Icons.upload_file, size: 18),
        label: Text(label),
        onDeleted: () => _dismiss('submit'),
      ));
    }

    final pattern = parsed.filenamePattern;
    if (pattern != null && _stillWanted('filename')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.badge_outlined, size: 18),
        label: Text(l10n.chipFilename(pattern)),
        onDeleted: () => _dismiss('filename'),
      ));
    }

    final tag = parsed.tag;
    if (tag != null && _stillWanted('tag')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.label_outline, size: 18),
        label: Text('#$tag'),
        onDeleted: () => _dismiss('tag'),
      ));
    }

    if (parsed.subtasks.isNotEmpty && _stillWanted('subtasks')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.checklist, size: 18),
        label: Text(l10n.chipSubtasks(parsed.subtasks.length)),
        onDeleted: () => _dismiss('subtasks'),
      ));
    }

    if (parsed.links.isNotEmpty && _stillWanted('links')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.link, size: 18),
        label: Text(l10n.chipLinks(parsed.links.length)),
        onDeleted: () => _dismiss('links'),
      ));
    }

    final note = parsed.inlineNote;
    if (note != null && _stillWanted('note')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.notes, size: 18),
        label: Text(l10n.chipNote(note)),
        onDeleted: () => _dismiss('note'),
      ));
    }

    if (parsed.priorityConflict && _stillWanted('conflict')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.priority_high, size: 18),
        label: Text(l10n.chipPriorityConflict),
        onDeleted: () => _dismiss('conflict'),
      ));
    }

    return chips;
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
    final parsed = _parsed;
    final taskId = const Uuid().v4();
    await ref.read(taskRepositoryProvider).insertTask(Task(
          id: taskId,
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
          estimateMinutes: _stillWanted('estimate')
              ? parsed?.estimateMinutes
              : null,
          submitMethod: _stillWanted('submit') ? parsed?.submitMethod : null,
          submitTarget: _stillWanted('submit') && parsed?.submitMethod == 'email'
              ? parsed?.submitTarget
              : null,
          filenamePattern:
              _stillWanted('filename') ? parsed?.filenamePattern : null,
          createdAt: now.millisecondsSinceEpoch,
          updatedAt: now.millisecondsSinceEpoch,
        ));

    // Design section 7.15: tag, subtasks and links live beside the row.
    await saveParsedExtras(
      taskId: taskId,
      tags: ref.read(tagRepositoryProvider),
      subtasks: ref.read(subtaskRepositoryProvider),
      attachments: ref.read(attachmentRepositoryProvider),
      tag: _stillWanted('tag') ? parsed?.tag : null,
      subtaskTitles: _stillWanted('subtasks')
          ? parsed?.subtasks ?? const []
          : const [],
      links: _stillWanted('links') ? parsed?.links ?? const [] : const [],
    );

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
              helperText: _listening ? l10n.voiceListening : null,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: l10n.voiceQuickAddTitle,
                icon: Icon(
                  _listening ? Icons.mic : Icons.mic_none,
                  color: _listening ? Theme.of(context).colorScheme.error : null,
                ),
                onPressed: _toggleVoice,
              ),
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
              ..._extraChips(l10n),
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
