import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

class StatistikRekapScreen extends ConsumerStatefulWidget {
  const StatistikRekapScreen({super.key});

  @override
  ConsumerState<StatistikRekapScreen> createState() => _StatistikRekapScreenState();
}

class _StatistikRekapScreenState extends ConsumerState<StatistikRekapScreen> {
  /// Computes the value first, then shows it in a dialog so the tile always
  /// reports a real number instead of doing nothing.
  Future<void> _showStat(String title, Future<String> Function() compute) async {
    final l10n = AppLocalizations.of(context)!;
    final text = await compute();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  Future<String> _onTimeText() async {
    final l10n = AppLocalizations.of(context)!;
    final tasks = await ref.read(taskRepositoryProvider).getTasks(includeInbox: true);
    final finished = tasks
        .where((t) => t.deadline != null && t.completedAt != null)
        .toList();
    if (finished.isEmpty) return l10n.noStatsDataYet;
    final onTime = finished.where((t) => t.completedAt! <= t.deadline!).length;
    return '${(onTime * 100 / finished.length).round()}%';
  }

  Future<String> _busiestCourseText() async {
    final l10n = AppLocalizations.of(context)!;
    final tasks = await ref.read(taskRepositoryProvider).getTasks(includeInbox: false);
    final counts = <String, int>{};
    for (final task in tasks) {
      final spaceId = task.spaceId;
      if (spaceId == null) continue;
      counts[spaceId] = (counts[spaceId] ?? 0) + 1;
    }
    if (counts.isEmpty) return l10n.noStatsDataYet;
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final spaces = await ref.read(spaceRepositoryProvider).getSpaces(includeArchived: true);
    final names = {for (final space in spaces) space.id: space.name};
    return '${names[top.key] ?? l10n.othersLabel} (${top.value})';
  }

  Future<String> _attendanceText() async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(appDatabaseProvider);
    final rows = await (db.select(db.attendance)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    final counts = <String, int>{};
    for (final row in rows) {
      counts[row.status] = (counts[row.status] ?? 0) + 1;
    }
    final labels = <String, String>{
      'present': l10n.presentLabel,
      'absent': l10n.absentLabel,
      'excused': l10n.excusedLabel,
      'sick': l10n.sickLabel,
    };
    final lines = [
      for (final entry in labels.entries)
        if (counts.containsKey(entry.key)) '${entry.value}: ${counts[entry.key]}',
    ];
    if (lines.isEmpty) return l10n.noStatsDataYet;
    return lines.join('\n');
  }

  Future<String> _weeklyTrendText() async {
    final l10n = AppLocalizations.of(context)!;
    final tasks = await ref.read(taskRepositoryProvider).getTasks(includeInbox: true);
    final now = DateTime.now();
    final thisMonday =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final format = DateFormat('dd/MM');
    final lines = <String>[];
    var total = 0;
    for (var week = 3; week >= 0; week--) {
      final start = thisMonday.subtract(Duration(days: 7 * week));
      final end = start.add(const Duration(days: 7));
      final count = tasks.where((task) {
        final done = task.completedAt;
        if (done == null) return false;
        final date = DateTime.fromMillisecondsSinceEpoch(done);
        return !date.isBefore(start) && date.isBefore(end);
      }).length;
      total += count;
      lines.add(
        '${format.format(start)} - ${format.format(end.subtract(const Duration(days: 1)))}: $count',
      );
    }
    if (total == 0) return l10n.noStatsDataYet;
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.semesterStatsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.onTimePercentage),
            trailing: const Icon(Icons.access_time),
            onTap: () => _showStat(l10n.onTimePercentage, _onTimeText),
          ),
          ListTile(
            title: Text(l10n.busiestCourse),
            trailing: const Icon(Icons.school),
            onTap: () => _showStat(l10n.busiestCourse, _busiestCourseText),
          ),
          ListTile(
            title: Text(l10n.attendanceRecap),
            trailing: const Icon(Icons.check_circle),
            onTap: () => _showStat(l10n.attendanceRecap, _attendanceText),
          ),
          ListTile(
            title: Text(l10n.weeklyTrend),
            trailing: const Icon(Icons.trending_up),
            onTap: () => _showStat(l10n.weeklyTrend, _weeklyTrendText),
          ),
        ],
      ),
    );
  }
}
