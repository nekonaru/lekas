import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../data/providers.dart';
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
    return _StatsData(
      buckets: focusMinutesByDay(sessions, endDay: today, days: 14),
      todayMinutes: focusMinutesInWindow(sessions, endDay: today, days: 1),
      weekMinutes: focusMinutesInWindow(sessions, endDay: today, days: 7),
      doneThisWeek: doneThisWeek,
      streak: completionStreak(completed, today: today),
      totalCards: cards.total,
      dueCards: cards.due,
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
          if (data == null || (data.todayMinutes + data.weekMinutes + data.doneThisWeek == 0 && data.totalCards == 0)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.noStudyData,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ),
            );
          }
          final peak = data.buckets.fold<int>(0, (a, b) => a > b ? a : b);
          final maxBar = peak == 0 ? 1 : peak;

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
  });

  final List<int> buckets;
  final int todayMinutes;
  final int weekMinutes;
  final int doneThisWeek;
  final int streak;
  final int totalCards;
  final int dueCards;
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
