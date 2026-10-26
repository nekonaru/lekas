import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models.dart';
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
  if (hits.isNotEmpty) return hits;
  return [message.trim()];
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

    for (final text in splitShareCandidates(widget.message)) {
      final parsed = parser.parse(text);
      _candidates.add(_Candidate(text)
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
    var saved = 0;
    for (final candidate in _candidates) {
      if (!candidate.checked) continue;
      final title = (candidate.title ?? candidate.text).trim();
      if (title.isEmpty) continue;
      await repository.insertTask(Task(
        id: const Uuid().v4(),
        spaceId: candidate.spaceId,
        title: title,
        notes: widget.message.trim(),
        priority: candidate.priority,
        status: 'todo',
        isGroup: candidate.isGroup,
        pinned: false,
        inbox: candidate.spaceId == null,
        deadline: candidate.deadline?.millisecondsSinceEpoch,
        sourceText: widget.message.trim(),
        createdAt: now,
        updatedAt: now,
      ));
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
