import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../core/components/activity_heatmap.dart';
import '../../core/components/stat_card.dart';
import '../../core/components/empty_state.dart';
import '../../core/date_util.dart';
import '../../data/providers.dart';
import '../../domain/daily_review.dart';
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

  void _reload() => setState(() => _data = _load());

  /// Edits the two weekly targets. Zero is allowed and means the goal is off.
  Future<void> _editGoals(int taskGoal, int focusGoal) async {
    final l10n = AppLocalizations.of(context)!;
    final taskController = TextEditingController(text: '$taskGoal');
    final focusController = TextEditingController(text: '$focusGoal');
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editWeeklyGoals),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.weeklyTaskGoalLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: focusController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.weeklyFocusGoalLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.weeklyGoalHint,
              style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    final nextTask = int.tryParse(taskController.text.trim());
    final nextFocus = int.tryParse(focusController.text.trim());
    taskController.dispose();
    focusController.dispose();
    if (saved != true || !mounted) return;
    final settings = ref.read(settingsRepositoryProvider);
    await settings.set('weekly_task_goal', '${nextTask ?? taskGoal}');
    await settings.set('weekly_focus_goal', '${nextFocus ?? focusGoal}');
    if (mounted) _reload();
  }

  Future<_StatsData> _load() async {
    final now = DateTime.now();
    final settings = ref.read(settingsRepositoryProvider);
    final taskGoal =
        int.tryParse(await settings.get('weekly_task_goal') ?? '') ?? 20;
    final focusGoal =
        int.tryParse(await settings.get('weekly_focus_goal') ?? '') ?? 300;
    final today = DateTime(now.year, now.month, now.day);
    final start14 = today.subtract(const Duration(days: 13));
    final focusRepo = ref.read(focusSessionRepositoryProvider);
    final taskRepo = ref.read(taskRepositoryProvider);
    final cards =
        await ref.read(flashcardRepositoryProvider).totals();
    final sessions = await focusRepo.getFocusSessionsSince(
      start14.millisecondsSinceEpoch,
    );
    // One query for all recent checks instead of one per habit (N+1).
    final checks = await ref
        .read(habitRepositoryProvider)
        .recentChecks(dayKeyOf(today.subtract(const Duration(days: 83))));
    final habitDays = {
      for (final row in checks)
        if (row.kind == 'check') row.date,
    };
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
    final heatStart = DateUtil.heatmapStart(today);
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
      streak: studyStreak(
        completedAt: completed,
        sessions: sessions,
        habitDays: habitDays,
        today: today,
      ),
      totalCards: cards.total,
      dueCards: cards.due,
      completedByDay: completedByDay,
      subjectMinutes: subjectMinutes.take(5).toList(),
      prevWeekMinutes: prevWeekMinutes,
      donePrevWeek: donePrevWeek,
      taskGoal: taskGoal,
      focusGoal: focusGoal,
      accuracy: estimateAccuracy(tasks, sessions),
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
                    child: StatCard(
                      value: '${data.todayMinutes}',
                      unit: l10n.minutesUnit,
                      label: l10n.focusToday,
                      icon: Icons.timer_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      value: '${data.weekMinutes}',
                      unit: l10n.minutesUnit,
                      label: l10n.focusThisWeek,
                      icon: Icons.calendar_view_week_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      value: '${data.streak}',
                      unit: '',
                      label: l10n.studyStreakLabel,
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
              if (data.accuracy.sampleCount > 0) ...[
                const SizedBox(height: 10),
                Material(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: Icon(Icons.speed_outlined, color: colors.primary),
                    title: Text(
                      l10n.estimateLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      l10n.estimateDetail(
                        data.accuracy.plannedMinutes,
                        data.accuracy.actualMinutes,
                      ),
                    ),
                    trailing: Text(
                      l10n.estimateDiff(data.accuracy.excessPercent),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: data.accuracy.excessPercent > 0
                                ? colors.error
                                : colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // Editable weekly promises, measured from the same data.
              Material(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.flag_outlined, color: colors.primary),
                      title: Text(
                        l10n.weeklyGoalsTitle,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: TextButton(
                        onPressed: () => _editGoals(
                          data.taskGoal,
                          data.focusGoal,
                        ),
                        child: Text(l10n.editWeeklyGoals),
                      ),
                    ),
                    _GoalRow(
                      label: l10n.weeklyTaskGoalLabel,
                      progress: GoalProgress(
                        current: data.doneThisWeek,
                        target: data.taskGoal,
                      ),
                    ),
                    _GoalRow(
                      label: l10n.weeklyFocusGoalLabel,
                      progress: GoalProgress(
                        current: data.weekMinutes,
                        target: data.focusGoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
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
    required this.taskGoal,
    required this.focusGoal,
    required this.accuracy,
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
  final int taskGoal;
  final int focusGoal;
  final EstimateAccuracy accuracy;
}

class _SubjectMinutes {
  const _SubjectMinutes({required this.name, required this.minutes});

  final String name;
  final int minutes;
}


/// One weekly goal line: label, current/target and a progress bar that
/// turns full when the promise is kept.
class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.label, required this.progress});

  final String label;
  final GoalProgress progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final caption = progress.target <= 0
        ? '—'
        : '${progress.current}/${progress.target}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ),
              Text(
                caption,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: progress.reached ? colors.primary : null,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.ratio,
              minHeight: 7,
              backgroundColor: colors.surfaceContainerHighest,
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
