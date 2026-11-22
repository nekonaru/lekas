import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../core/components/activity_heatmap.dart';
import '../../core/components/empty_state.dart';
import '../../data/providers.dart';
import '../../domain/habits.dart';
import '../../domain/study_stats.dart';
import '../../l10n/app_localizations.dart';

/// The study statistics: focus minutes today and this week, the day
/// streak of completed tasks, and a 14-day bar chart built from focus
/// sessions. Pulls once on open; cheap enough to redo on re-entry.
class StatistikBelajarScreen extends ConsumerStatefulWidget {
  const StatistikBelajarScreen({super.key});

  @override
  ConsumerState<StatistikBelajarScreen> createState() =>
      _StatistikBelajarScreenState();
}

class _StatistikBelajarScreenState
    extends ConsumerState<StatistikBelajarScreen> {
  late Future<_StatsData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_StatsData> _load() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start14 = today.subtract(const Duration(days: 13));
    final focusRepo = ref.read(focusSessionRepositoryProvider);
    final taskRepo = ref.read(taskRepositoryProvider);
    final cards =
        await ref.read(flashcardRepositoryProvider).totals();
    final sessions = await focusRepo.getFocusSessionsSince(
      start14.millisecondsSinceEpoch,
    );
    final tasks = await taskRepo.getTasks(includeInbox: true);
    final completed = tasks
        .where((task) => task.status == 'done' && task.completedAt != null)
        .map((task) => task.completedAt!)
        .toList();
    final weekStart = today.subtract(const Duration(days: 6));
    final doneThisWeek = completed
        .where((millis) => millis >= weekStart.millisecondsSinceEpoch)
        .length;
    final prevWeekStart = today.subtract(const Duration(days: 13));
    final donePrevWeek = completed
        .where((millis) =>
            millis >= prevWeekStart.millisecondsSinceEpoch &&
            millis < weekStart.millisecondsSinceEpoch)
        .length;
    final buckets14 =
        focusMinutesByDay(sessions, endDay: today, days: 14);
    final weekMinutes =
        buckets14.sublist(7).fold<int>(0, (sum, minutes) => sum + minutes);
    final prevWeekMinutes =
        buckets14.sublist(0, 7).fold<int>(0, (sum, minutes) => sum + minutes);
    var heatStart = today.subtract(const Duration(days: 83));
    // Match the heatmap grid, which aligns its first cell to Monday.
    heatStart = heatStart.subtract(Duration(days: heatStart.weekday - 1));
    final completedByDay = <String, int>{};
    for (final millis in completed) {
      final day = DateTime.fromMillisecondsSinceEpoch(millis);
      final local = DateTime(day.year, day.month, day.day);
      if (local.isBefore(heatStart)) continue;
      final key = dayKeyOf(local);
      completedByDay[key] = (completedByDay[key] ?? 0) + 1;
    }

    // Focus minutes grouped by subject: task -> space -> name.
    final spaces = await ref.read(spaceRepositoryProvider).getSpaces();
    final spaceName = {for (final space in spaces) space.id: space.name};
    final taskSpace = {
      for (final task in tasks)
        if (task.spaceId != null) task.id: task.spaceId!,
    };
    final minutesBySpace = <String, int>{};
    for (final session in sessions) {
      final spaceId = taskSpace[session.taskId];
      if (spaceId == null) continue;
      minutesBySpace[spaceId] =
          (minutesBySpace[spaceId] ?? 0) + (session.durationSec / 60).floor();
    }
    final subjectMinutes = minutesBySpace.entries
        .map((entry) => _SubjectMinutes(
              name: spaceName[entry.key] ?? '?',
              minutes: entry.value,
            ))
        .toList()
      ..sort((a, b) => b.minutes.compareTo(a.minutes));

    return _StatsData(
      buckets: buckets14,
      todayMinutes: focusMinutesInWindow(sessions, endDay: today, days: 1),
      weekMinutes: weekMinutes,
      doneThisWeek: doneThisWeek,
      streak: completionStreak(completed, today: today),
      totalCards: cards.total,
      dueCards: cards.due,
      completedByDay: completedByDay,
      subjectMinutes: subjectMinutes.take(5).toList(),
      prevWeekMinutes: prevWeekMinutes,
      donePrevWeek: donePrevWeek,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.studyStatsTitle)),
      body: FutureBuilder<_StatsData>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null ||
              (data.todayMinutes + data.weekMinutes + data.doneThisWeek == 0 &&
                  data.totalCards == 0 &&
                  data.streak == 0)) {
            return EmptyState(
              message: l10n.noStudyData,
              icon: Icons.insights_outlined,
            );
          }
          final peak = data.buckets.fold<int>(0, (a, b) => a > b ? a : b);
          final maxBar = peak == 0 ? 1 : peak;
          final maxSubjectMinutes = data.subjectMinutes.fold<int>(
            0,
            (a, b) => a > b.minutes ? a : b.minutes,
          );
          final safeMaxSubject = maxSubjectMinutes == 0 ? 1 : maxSubjectMinutes;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '${data.todayMinutes}',
                      unit: l10n.minutesUnit,
                      label: l10n.focusToday,
                      icon: Icons.timer_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      value: '${data.weekMinutes}',
                      unit: l10n.minutesUnit,
                      label: l10n.focusThisWeek,
                      icon: Icons.calendar_view_week_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      value: '${data.streak}',
                      unit: '',
                      label: l10n.completionStreakLabel,
                      icon: Icons.local_fire_department_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _WideStatCard(
                icon: Icons.task_alt,
                label: l10n.tasksDoneThisWeek,
                value: '${data.doneThisWeek}',
              ),
              const SizedBox(height: 10),
              _WideStatCard(
                icon: Icons.style_outlined,
                label: l10n.flashcardsTitle,
                value: '${data.totalCards}',
                trailing: data.dueCards > 0
                    ? Text(
                        l10n.deckDueSummary(data.dueCards, data.totalCards),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      )
                    : null,
              ),
              const SizedBox(height: 10),
              // The week-over-week scorecard: one card, two honest deltas.
              Material(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Text(
                        l10n.thisWeekVsLastWeek.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    _DeltaRow(
                      icon: Icons.timer_outlined,
                      label: l10n.focusThisWeek,
                      value: data.weekMinutes,
                      unit: l10n.minutesUnit,
                      delta: data.weekMinutes - data.prevWeekMinutes,
                    ),
                    _DeltaRow(
                      icon: Icons.task_alt,
                      label: l10n.tasksDoneThisWeek,
                      value: data.doneThisWeek,
                      unit: '',
                      delta: data.doneThisWeek - data.donePrevWeek,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ActivityHeatmap(
                counts: data.completedByDay,
                endDay: DateTime.now(),
                title: l10n.heatmapTitle,
                lessLabel: l10n.heatmapLess,
                moreLabel: l10n.heatmapMore,
              ),
              const SizedBox(height: 18),
              Text(
                l10n.last14Days,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < data.buckets.length; i++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (data.buckets[i] > 0)
                                      Text(
                                        '${data.buckets[i]}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(fontSize: 9),
                                      ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 8 + (data.buckets[i] / maxBar) * 84,
                                      decoration: BoxDecoration(
                                        color: i == data.buckets.length - 1
                                            ? colors.primary
                                            : colors.primary.withValues(alpha: 0.45),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (var i = 0; i < data.buckets.length; i++)
                          Expanded(
                            child: Text(
                              _dayLabel(i, data.buckets.length),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    color: colors.onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (data.subjectMinutes.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  l10n.focusPerSubject,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: 10),
                for (final subject in data.subjectMinutes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 92,
                          child: Text(
                            subject.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: subject.minutes / safeMaxSubject,
                              minHeight: 8,
                              backgroundColor: colors.surfaceContainerLow,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${subject.minutes}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _dayLabel(int index, int length) {
    final day = DateTime.now().subtract(Duration(days: length - 1 - index));
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.E(locale).format(day);
  }
}

class _StatsData {
  const _StatsData({
    required this.buckets,
    required this.todayMinutes,
    required this.weekMinutes,
    required this.doneThisWeek,
    required this.streak,
    required this.totalCards,
    required this.dueCards,
    required this.completedByDay,
    required this.subjectMinutes,
    required this.prevWeekMinutes,
    required this.donePrevWeek,
  });

  final List<int> buckets;
  final int todayMinutes;
  final int weekMinutes;
  final int doneThisWeek;
  final int streak;
  final int totalCards;
  final int dueCards;
  final Map<String, int> completedByDay;
  final List<_SubjectMinutes> subjectMinutes;
  final int prevWeekMinutes;
  final int donePrevWeek;
}

class _SubjectMinutes {
  const _SubjectMinutes({required this.name, required this.minutes});

  final String name;
  final int minutes;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.unit,
    required this.label,
    required this.icon,
  });

  final String value;
  final String unit;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.25,
                ),
          ),
        ],
      ),
    );
  }
}

/// One line of the week-over-week scorecard: a metric, its value, and a
/// small colored delta chip (green up, red down, grey flat).
class _DeltaRow extends StatelessWidget {
  const _DeltaRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.delta,
  });

  final IconData icon;
  final String label;
  final int value;
  final String unit;
  final int delta;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (chipColor, chipText) = delta > 0
        ? (const Color(0xFF10B981), '+$delta')
        : delta < 0
            ? (const Color(0xFFEF4444), '$delta')
            : (colors.onSurfaceVariant, '±0');
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(icon, size: 18, color: colors.primary),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            unit.isEmpty ? '$value' : '$value $unit',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              chipText,
              style: TextStyle(
                color: chipColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WideStatCard extends StatelessWidget {
  const _WideStatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, color: colors.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: trailing ??
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
      ),
    );
  }
}
