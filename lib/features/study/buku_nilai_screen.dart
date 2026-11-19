import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/grades.dart';
import '../../domain/habits.dart';
import '../../l10n/app_localizations.dart';

/// The school grade book (SMA only, reached from the subject page). One
/// row per score event, newest first, with the live weighted average and
/// the KKM check up top. Weights come from the grade components the
/// school already knows about; without them the plain mean is used.
class BukuNilaiScreen extends ConsumerStatefulWidget {
  const BukuNilaiScreen({
    super.key,
    required this.spaceId,
    required this.spaceName,
  });

  final String spaceId;
  final String spaceName;

  @override
  ConsumerState<BukuNilaiScreen> createState() => _BukuNilaiScreenState();
}

class _BukuNilaiScreenState extends ConsumerState<BukuNilaiScreen> {
  late Future<_GradeConfig> _config;

  @override
  void initState() {
    super.initState();
    _config = _loadConfig();
  }

  Future<_GradeConfig> _loadConfig() async {
    final settings = ref.read(settingsRepositoryProvider);
    final kkm = int.tryParse(await settings.get('kkm') ?? '') ?? 75;
    final components = await ref
        .read(gradeComponentRepositoryProvider)
        .getGradeComponents(widget.spaceId);
    return _GradeConfig(
      kkm: kkm,
      weights: {
        for (final component in components)
          component.key.trim().toLowerCase(): component.weightPercent,
      },
    );
  }

  void _reloadConfig() => setState(() => _config = _loadConfig());

  Future<void> _editKkm(int current) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: '$current');
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final parsed = int.tryParse(controller.text.trim());
          final valid = parsed != null && parsed >= 0 && parsed <= 100;
          return AlertDialog(
            title: Text(l10n.kkmEditTitle),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.kkmLabel,
                border: const OutlineInputBorder(),
                errorText: valid || controller.text.isEmpty
                    ? null
                    : l10n.kkmInvalid,
              ),
              onChanged: (_) => setDialogState(() {}),
              onSubmitted: (_) {
                if (valid) Navigator.pop(dialogContext, true);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: valid ? () => Navigator.pop(dialogContext, true) : null,
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
    controller.dispose();
    if (saved != true || !mounted) return;
    final parsed = int.tryParse(controller.text.trim());
    if (parsed == null) return;
    await ref.read(settingsRepositoryProvider).set('kkm', '$parsed');
    if (mounted) _reloadConfig();
  }

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context)!;
    // Score events for this subject, newest first is fine for a ledger.
    final scores = await ref.read(scoreRepositoryProvider).getScores(widget.spaceId);
    final buffer = StringBuffer('\uFEFF')
      ..writeln('label,value,date,note');
    for (final score in scores) {
      final date = dayKeyOf(DateTime.fromMillisecondsSinceEpoch(score.takenAt));
      buffer.writeln([
        _csvCell(score.label),
        '${score.value}',
        date,
        _csvCell(score.note ?? ''),
      ].join(','));
    }
    final safeName = widget.spaceName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$safeName-nilai.csv');
    await file.writeAsString(buffer.toString(), encoding: utf8);
    await Share.shareXFiles([XFile(file.path)], subject: l10n.exportCsv);
  }

  /// One CSV cell; double quotes are escaped by doubling them.
  String _csvCell(String value) {
    final needsQuotes =
        value.contains(',') || value.contains('"') || value.contains('\n');
    final escaped = value.replaceAll('"', '""');
    return needsQuotes ? '"$escaped"' : escaped;
  }

  Future<void> _addScore() async {
    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _ScoreEditorDialog(
        spaceId: widget.spaceId,
      ),
    );
    if (added == true && mounted) _reloadConfig();
  }

  Future<void> _deleteScore(Score score) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteScoreTitle),
        content: Text(l10n.deleteScoreBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(scoreRepositoryProvider).deleteScore(score.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('d MMM yyyy', locale);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.gradeBookTitle} · ${widget.spaceName}'),
        actions: [
          IconButton(
            tooltip: l10n.exportCsv,
            icon: const Icon(Icons.share_outlined),
            onPressed: _exportCsv,
          ),
        ],
      ),
      body: FutureBuilder<_GradeConfig>(
        future: _config,
        builder: (context, configSnapshot) {
          final config = configSnapshot.data;
          if (config == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<List<Score>>(
            stream:
                ref.watch(scoreRepositoryProvider).watchScores(widget.spaceId),
            builder: (context, snapshot) {
              final scores = snapshot.data ?? const <Score>[];
              final weighted = averageScore(
                [
                  for (final score in scores)
                    ScoreLike(label: score.label, value: score.value),
                ],
                config.weights,
              );
              final averageText = weighted == null
                  ? '–'
                  : weighted.toStringAsFixed(weighted == weighted.roundToDouble() ? 0 : 1);

              return Column(
                children: [
                  // The headline: average, KKM and the pass/fail verdict.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.brandGradient,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.averageLabel.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  averageText,
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                if (weighted != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: weighted >= config.kkm
                                          ? const Color(0xFF34D399).withValues(alpha: 0.25)
                                          : const Color(0xFFFCA5A5).withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: weighted >= config.kkm
                                            ? const Color(0xFF34D399).withValues(alpha: 0.6)
                                            : const Color(0xFFFCA5A5).withValues(alpha: 0.6),
                                      ),
                                    ),
                                    child: Text(
                                      weighted >= config.kkm
                                          ? l10n.kkmPassed
                                          : l10n.kkmFailed,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // KKM chip, tap to edit.
                          InkWell(
                            onTap: () => _editKkm(config.kkm),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    l10n.kkmLabel.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.4,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  Text(
                                    '${config.kkm}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 13,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: scores.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                l10n.noScoresYet,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                            itemCount: scores.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final score = scores[index];
                              return Material(
                                color: colors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  leading: _ScoreBadge(
                                    value: score.value,
                                    kkm: config.kkm,
                                  ),
                                  title: Text(
                                    score.label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: Text(
                                    score.note == null
                                        ? dateFormat.format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                score.takenAt))
                                        : '${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(score.takenAt))} · ${score.note}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    tooltip: l10n.deleteLabel,
                                    icon: const Icon(Icons.delete_outline,
                                        size: 20),
                                    onPressed: () => _deleteScore(score),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addScore,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GradeConfig {
  const _GradeConfig({required this.kkm, required this.weights});

  final int kkm;
  final Map<String, double> weights;
}

/// The colored score circle: green at KKM or above, amber just below,
/// red when the student needs to catch up.
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.value, required this.kkm});

  final int value;
  final int kkm;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = value >= kkm
        ? (const Color(0xFF10B981), Colors.white)
        : value >= kkm - 10
            ? (const Color(0xFFF59E0B), Colors.white)
            : (const Color(0xFFEF4444), Colors.white);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 13),
      ),
    );
  }
}

/// The add dialog: label, value, date, note. Enabled only when the label
/// is present and the value parses as 0-100.
class _ScoreEditorDialog extends ConsumerStatefulWidget {
  const _ScoreEditorDialog({required this.spaceId});

  final String spaceId;

  @override
  ConsumerState<_ScoreEditorDialog> createState() => _ScoreEditorDialogState();
}

class _ScoreEditorDialogState extends ConsumerState<_ScoreEditorDialog> {
  final _labelController = TextEditingController();
  final _valueController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _takenAt = DateTime.now();

  @override
  void dispose() {
    _labelController.dispose();
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSave {
    final value = int.tryParse(_valueController.text.trim());
    return _labelController.text.trim().isNotEmpty &&
        value != null &&
        value >= 0 &&
        value <= 100;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _takenAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && mounted) setState(() => _takenAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('d MMM yyyy', locale);

    return AlertDialog(
      title: Text(l10n.addScore),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.scoreLabel,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.scoreValue,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.takenAtLabel,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                ),
                child: Text(dateFormat.format(_takenAt)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.scoreNote,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _canSave
              ? () async {
                  final value = int.parse(_valueController.text.trim());
                  await ref.read(scoreRepositoryProvider).addScore(
                        spaceId: widget.spaceId,
                        label: _labelController.text.trim(),
                        value: value,
                        note: _noteController.text.trim().isEmpty
                            ? null
                            : _noteController.text.trim(),
                        takenAt: _takenAt,
                      );
                  if (context.mounted) Navigator.pop(context, true);
                }
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
