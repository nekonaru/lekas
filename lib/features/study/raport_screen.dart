import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/grades.dart';
import '../../l10n/app_localizations.dart';
import 'buku_nilai_screen.dart';

/// The report card (SMA only): every subject of the active semester with
/// its live average, the semester average on top, a KKM verdict per
/// subject and one tap to share the whole thing as text.
class RaportScreen extends ConsumerStatefulWidget {
  const RaportScreen({super.key});

  @override
  ConsumerState<RaportScreen> createState() => _RaportScreenState();
}

class _RaportScreenState extends ConsumerState<RaportScreen> {
  late Future<_RaportData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  void _reload() => setState(() => _data = _load());

  Future<_RaportData> _load() async {
    final settings = ref.read(settingsRepositoryProvider);
    final kkm = int.tryParse(await settings.get('kkm') ?? '') ?? 75;
    final active = await ref.read(semesterRepositoryProvider).activeSemester();
    final spaces = await ref.read(spaceRepositoryProvider).getSpaces();
    final subjects = spaces
        .where((space) =>
            space.kind != 'category' && space.semesterId == active?.id)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final scoreRepo = ref.read(scoreRepositoryProvider);
    final gradeRepo = ref.read(gradeComponentRepositoryProvider);

    final rows = <_RaportRow>[];
    for (final subject in subjects) {
      final scores = await scoreRepo.getScores(subject.id);
      final components = await gradeRepo.getGradeComponents(subject.id);
      final average = averageScore(
        [
          for (final score in scores)
            ScoreLike(label: score.label, value: score.value),
        ],
        {
          for (final component in components)
            component.key.trim().toLowerCase(): component.weightPercent,
        },
      );
      rows.add(_RaportRow(subject: subject, average: average, count: scores.length));
    }

    final averages = [
      for (final row in rows)
        if (row.average != null) row.average!,
    ];
    final semesterAverage = averages.isEmpty
        ? null
        : averages.reduce((a, b) => a + b) / averages.length;

    return _RaportData(
      semesterName: active?.name,
      kkm: kkm,
      rows: rows,
      average: semesterAverage,
    );
  }

  static String? _avgText(double? value) {
    if (value == null) return null;
    return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);
  }

  Future<void> _share(_RaportData data) async {
    final l10n = AppLocalizations.of(context)!;
    final lines = <String>[
      l10n.raportTitle,
      if (data.semesterName != null) data.semesterName!,
      '',
      for (final row in data.rows)
        row.average == null
            ? '${row.subject.name}: -'
            : '${row.subject.name}: ${_avgText(row.average)}',
      '',
      '${l10n.raportAverage}: ${_avgText(data.average) ?? '-'}',
      '${l10n.kkmLabel}: ${data.kkm}',
      'Lekas',
    ];
    await Share.share(lines.join('\n'), subject: l10n.raportTitle);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.raportTitle),
        actions: [
          IconButton(
            tooltip: l10n.raportShare,
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final data = await _data;
              if (data.rows.isEmpty) return;
              await _share(data);
            },
          ),
        ],
      ),
      body: FutureBuilder<_RaportData>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null || data.rows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.raportSubjectEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ),
            );
          }
          final progress = data.average == null
              ? 0.0
              : (data.average! / 100).clamp(0.0, 1.0);

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // The semester headline on the brand gradient.
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.semesterName != null)
                        Text(
                          data.semesterName!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        _avgText(data.average) ?? '–',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.raportAverage.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                for (final row in data.rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SubjectRow(
                      row: row,
                      kkm: data.kkm,
                      onOpen: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => BukuNilaiScreen(
                              spaceId: row.subject.id,
                              spaceName: row.subject.name,
                            ),
                          ),
                        );
                        if (mounted) _reload();
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RaportData {
  const _RaportData({
    required this.semesterName,
    required this.kkm,
    required this.rows,
    required this.average,
  });

  final String? semesterName;
  final int kkm;
  final List<_RaportRow> rows;
  final double? average;
}

class _RaportRow {
  const _RaportRow({
    required this.subject,
    required this.average,
    required this.count,
  });

  final Space subject;
  final double? average;
  final int count;
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.row,
    required this.kkm,
    required this.onOpen,
  });

  final _RaportRow row;
  final int kkm;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final average = row.average;
    final passed = average != null && average >= kkm;
    final statusColor =
        passed ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
        leading: Container(
          width: 10,
          height: 44,
          decoration: BoxDecoration(
            color: Color(row.subject.color),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: Text(
          row.subject.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          average == null ? l10n.noScoresYet : l10n.scoresCount(row.count),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: average == null
            ? const Icon(Icons.chevron_right)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    average.toStringAsFixed(
                        average == average.roundToDouble() ? 0 : 1),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                  ),
                  Text(
                    passed ? l10n.kkmPassed : l10n.kkmFailed,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
        onTap: onOpen,
      ),
    );
  }
}
