import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/empty_state.dart';
import '../../data/providers.dart';
import '../../domain/transcript.dart';
import '../../l10n/app_localizations.dart';

/// Every semester with its numeric average, one tap to the detailed rapor.
class TranscriptScreen extends ConsumerStatefulWidget {
  const TranscriptScreen({super.key});

  @override
  ConsumerState<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends ConsumerState<TranscriptScreen> {
  late Future<List<TranscriptEntry>> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<List<TranscriptEntry>> _load() async {
    final semesters = await ref.read(semesterRepositoryProvider).getSemesters();
    final spaces = await ref.read(spaceRepositoryProvider).getSpaces();
    final result = <TranscriptEntry>[];
    for (final semester in semesters) {
      final courses = spaces.where(
        (space) => space.semesterId == semester.id && space.kind != 'category',
      );
      final grades = courses
          .map((space) => double.tryParse(space.finalGrade ?? ''))
          .whereType<double>()
          .toList();
      result.add(
        TranscriptEntry(
          semesterName: semester.name,
          average: grades.isEmpty
              ? null
              : grades.reduce((a, b) => a + b) / grades.length,
          subjectCount: courses.length,
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.transcriptTitle)),
      body: FutureBuilder<List<TranscriptEntry>>(
        future: _data,
        builder: (context, snapshot) {
          final entries = snapshot.data;
          if (entries == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (entries.isEmpty) {
            return EmptyState(
              message: l10n.noExamsYet,
              icon: Icons.school_outlined,
            );
          }
          final overall = transcriptAverage(entries);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: colors.primaryContainer.withValues(alpha: 0.6),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.raportAverage.toUpperCase(),
                        style: TextStyle(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        overall == null
                            ? '–'
                            : overall.toStringAsFixed(overall == overall.roundToDouble() ? 0 : 1),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: colors.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final entry in entries)
                ListTile(
                  leading: Icon(Icons.school_outlined, color: colors.primary),
                  title: Text(entry.semesterName ?? l10n.semesterTitle),
                  subtitle: Text(l10n.scoresCount(entry.subjectCount)),
                  trailing: Text(
                    entry.average == null
                        ? '–'
                        : entry.average!.toStringAsFixed(
                            entry.average == entry.average!.roundToDouble() ? 0 : 1),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
