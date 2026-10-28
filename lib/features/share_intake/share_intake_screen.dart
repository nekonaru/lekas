import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models.dart';
import '../../data/parsed_task_extras.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../parser/parser_service.dart';

/// Sentence separators used when one shared message becomes several tasks.
final RegExp _sentenceSplit = RegExp(r'(?<=[.!?])\s+|\n+');

/// Words that mark a sentence as a task candidate (design section 6.2).
const List<String> kDeadlineKeywords = [
  'dikumpul',
  'paling lambat',
  'batas',
  'deadline',
  'maksimal',
  'sebelum',
  'kumpul',
];

/// Splits a shared message into candidate tasks. Sentences carrying a
/// deadline keyword are proposed, otherwise the whole message is one
/// candidate (design section 6.2).
///
/// The list is capped: any app on the phone can share a text of any size,
/// and a message of ten thousand "batas" sentences used to become ten
/// thousand candidate cards and ten thousand saved tasks.
const int kMaxShareCandidates = 50;

List<String> splitShareCandidates(String message) {
  final sentences = message
      .split(_sentenceSplit)
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (sentences.isEmpty) return const [];

  final hits = sentences
      .where((s) => kDeadlineKeywords.any((k) => s.toLowerCase().contains(k)))
      .toList();
  if (hits.isNotEmpty) return hits.take(kMaxShareCandidates).toList();
  return [message.trim()];
}

/// The shared message trimmed and cut at the parser's character cap, so a
/// pasted document cannot be stored over and over once per saved task.
String _boundedMessage(String message) {
  final trimmed = message.trim();
  if (trimmed.length <= kMaxParsedChars) return trimmed;
  final cut = trimmed.lastIndexOf(' ', kMaxParsedChars);
  return trimmed.substring(0, cut <= 0 ? kMaxParsedChars : cut);
}

/// Shows the tasks proposed from a shared message with checkboxes and
/// correction chips. One message can become several tasks.
class ShareIntakeScreen extends ConsumerStatefulWidget {
  const ShareIntakeScreen({super.key, required this.message});

  final String message;

  @override
  ConsumerState<ShareIntakeScreen> createState() => _ShareIntakeScreenState();
}

class _Candidate {
  _Candidate(this.text);

  final String text;
  bool checked = true;
  String? title;
  DateTime? deadline;
  String? spaceId;
  String? spaceName;
  int priority = 1;
  bool isGroup = false;

  /// The full parse result behind the extra chips of design section 7.15,
  /// and the chips the user has dismissed for this candidate.
  ParsedTask? parsed;
  final Set<String> dismissed = <String>{};
}

class _ShareIntakeScreenState extends ConsumerState<ShareIntakeScreen> {
  final List<_Candidate> _candidates = [];
  List<Space> _spaces = const [];
  bool _saving = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final spaces = await ref.read(spaceRepositoryProvider).getSpaces();
    final aliases = <String, List<String>>{};
    for (final space in spaces) {
      aliases[space.id] = await ref.read(spaceRepositoryProvider).getAliases(space.id);
    }
    final parser = ParserService.forSpaces([
      for (final space in spaces)
        {
          'id': space.id,
          'name': space.name,
          'code': space.code ?? '',
          'aliases': aliases[space.id]?.join(',') ?? '',
        },
    ]);

    // The active language decides which dictionary leads (design section
    // 8.5); until the setting is loaded the parser falls back to Indonesian.
    final language =
        ref.read(localeProvider).valueOrNull?.languageCode ?? 'id';

    for (final text in splitShareCandidates(widget.message)) {
      final parsed = parser.parse(text, locale: language);
      _candidates.add(_Candidate(text)
        ..parsed = parsed
        ..title = parsed.title == kUntitledTask ? text : parsed.title
        ..deadline = parsed.deadline
        ..spaceId = parsed.spaceId
        ..priority = parsed.priority
        ..isGroup = parsed.isGroup);
    }

    // Resolve the matched space name for the chip label.
    for (final candidate in _candidates) {
      final id = candidate.spaceId;
      if (id == null) continue;
      candidate.spaceName =
          spaces.firstWhere((s) => s.id == id, orElse: () => spaces.first).name;
    }

    if (mounted) {
      setState(() {
        _spaces = spaces;
        _ready = true;
      });
    }
  }

  Future<void> _pickDeadline(int index) async {
    final current = _candidates[index].deadline;
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = current == null
        ? const TimeOfDay(hour: 23, minute: 59)
        : TimeOfDay.fromDateTime(current);
    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => _candidates[index].deadline = picked);
  }

  void _pickSpace(int index) {
    final spaces = _spaces;
    showModalBottomSheet<String>(
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
    ).then((selected) {
      if (selected == null || !mounted) return;
      if (selected.isEmpty) {
        setState(() {
          _candidates[index].spaceId = null;
          _candidates[index].spaceName = null;
        });
        return;
      }
      final space = spaces.firstWhere((s) => s.id == selected);
      setState(() {
        _candidates[index].spaceId = space.id;
        _candidates[index].spaceName = space.name;
      });
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    setState(() => _saving = true);
    final repository = ref.read(taskRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    // The full shared message used to be copied into notes and sourceText
    // of every saved task, so one hostile megabyte grew with every row.
    // Both fields share one bounded copy; the parser only ever reads the
    // first part of it anyway (design section 6.2 and 7.15).
    final storedMessage = _boundedMessage(widget.message);
    var saved = 0;
    for (final candidate in _candidates) {
      if (!candidate.checked) continue;
      final title = (candidate.title ?? candidate.text).trim();
      if (title.isEmpty) continue;
      final parsed = candidate.parsed;
      final taskId = const Uuid().v4();
      bool wanted(String id) => !candidate.dismissed.contains(id);
      await repository.insertTask(Task(
        id: taskId,
        spaceId: candidate.spaceId,
        title: title,
        notes: storedMessage,
        priority: candidate.priority,
        status: 'todo',
        isGroup: candidate.isGroup,
        pinned: false,
        inbox: candidate.spaceId == null,
        deadline: candidate.deadline?.millisecondsSinceEpoch,
        sourceText: storedMessage,
        // Design section 7.15: the values of the extra chips.
        estimateMinutes:
            wanted('estimate') ? parsed?.estimateMinutes : null,
        submitMethod: wanted('submit') ? parsed?.submitMethod : null,
        submitTarget:
            wanted('submit') && parsed?.submitMethod == 'email'
                ? parsed?.submitTarget
                : null,
        filenamePattern: wanted('filename') ? parsed?.filenamePattern : null,
        createdAt: now,
        updatedAt: now,
      ));
      await saveParsedExtras(
        taskId: taskId,
        tags: ref.read(tagRepositoryProvider),
        subtasks: ref.read(subtaskRepositoryProvider),
        attachments: ref.read(attachmentRepositoryProvider),
        tag: wanted('tag') ? parsed?.tag : null,
        subtaskTitles:
            wanted('subtasks') ? parsed?.subtasks ?? const [] : const [],
        links: wanted('links') ? parsed?.links ?? const [] : const [],
        nowMs: now,
      );
      saved++;
    }
    if (!mounted) return;
    Navigator.pop(context, saved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savedTasksCount(saved))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shareIntakeTitle)),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.shareIntakeHint,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                if (_candidates.isEmpty)
                  Text(l10n.shareNoCandidates),
                for (var i = 0; i < _candidates.length; i++)
                  _buildCandidate(l10n, i),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _ready && !_saving ? _save : null,
            child: Text(l10n.saveSelected),
          ),
        ),
      ),
    );
  }

  /// The chips of design section 7.15: every guess the advanced parser
  /// made for this candidate, shown so it can be corrected before saving.
  List<Widget> _extraChips(AppLocalizations l10n, _Candidate candidate) {
    final parsed = candidate.parsed;
    if (parsed == null) return const [];
    bool wanted(String id) => !candidate.dismissed.contains(id);
    void dismiss(String id) => setState(() => candidate.dismissed.add(id));
    final chips = <Widget>[];

    final estimate = parsed.estimateMinutes;
    if (estimate != null && estimate > 0 && wanted('estimate')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.timer_outlined, size: 18),
        label: Text(estimate >= 60 && estimate % 60 == 0
            ? l10n.chipEstimateHours(estimate ~/ 60)
            : l10n.estimateMinutesLabel(estimate)),
        onDeleted: () => dismiss('estimate'),
      ));
    }

    final submit = parsed.submitMethod;
    if (submit != null && wanted('submit')) {
      final label = switch (submit) {
        'lms' => l10n.chipSubmitLms,
        'email' => l10n.chipSubmitEmail,
        'paper' => l10n.chipSubmitPaper,
        _ => submit,
      };
      chips.add(InputChip(
        avatar: const Icon(Icons.upload_file, size: 18),
        label: Text(label),
        onDeleted: () => dismiss('submit'),
      ));
    }

    final pattern = parsed.filenamePattern;
    if (pattern != null && wanted('filename')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.badge_outlined, size: 18),
        label: Text(l10n.chipFilename(pattern)),
        onDeleted: () => dismiss('filename'),
      ));
    }

    final tag = parsed.tag;
    if (tag != null && wanted('tag')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.label_outline, size: 18),
        label: Text('#$tag'),
        onDeleted: () => dismiss('tag'),
      ));
    }

    if (parsed.subtasks.isNotEmpty && wanted('subtasks')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.checklist, size: 18),
        label: Text(l10n.chipSubtasks(parsed.subtasks.length)),
        onDeleted: () => dismiss('subtasks'),
      ));
    }

    if (parsed.links.isNotEmpty && wanted('links')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.link, size: 18),
        label: Text(l10n.chipLinks(parsed.links.length)),
        onDeleted: () => dismiss('links'),
      ));
    }

    if (parsed.priorityConflict && wanted('conflict')) {
      chips.add(InputChip(
        avatar: const Icon(Icons.priority_high, size: 18),
        label: Text(l10n.chipPriorityConflict),
        onDeleted: () => dismiss('conflict'),
      ));
    }

    return chips;
  }

  Widget _buildCandidate(AppLocalizations l10n, int index) {
    final candidate = _candidates[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: candidate.checked,
                  onChanged: (value) => setState(
                      () => candidate.checked = value ?? false),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: candidate.title ?? candidate.text,
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (value) => candidate.title = value,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.event, size: 18),
                  label: Text(candidate.deadline == null
                      ? l10n.taskDeadline
                      : '${candidate.deadline!.day}/${candidate.deadline!.month} ${candidate.deadline!.hour.toString().padLeft(2, '0')}.${candidate.deadline!.minute.toString().padLeft(2, '0')}'),
                  onPressed: () => _pickDeadline(index),
                ),
                ActionChip(
                  avatar: const Icon(Icons.folder_outlined, size: 18),
                  label: Text(candidate.spaceName ?? l10n.taskContainer),
                  onPressed: () => _pickSpace(index),
                ),
                ..._extraChips(l10n, candidate),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
