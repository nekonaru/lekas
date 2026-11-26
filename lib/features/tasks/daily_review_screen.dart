import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/components/empty_state.dart';
import '../../core/components/stat_card.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/daily_review.dart';
import '../../domain/habits.dart';
import '../../l10n/app_localizations.dart';

/// A calm end-of-day sheet: what was finished, what is still late, how long
/// you focused and which habits you checked. Everything comes from data the
/// app already stores; the share button sends a plain text recap.
class DailyReviewScreen extends ConsumerStatefulWidget {
  const DailyReviewScreen({super.key});

  @override
  ConsumerState<DailyReviewScreen> createState() => _DailyReviewScreenState();
}

class _DailyReviewScreenState extends ConsumerState<DailyReviewScreen> {
  late Future<_ReviewData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_ReviewData> _load() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final key = dayKeyOf(today);
    final tasks =
        await ref.read(taskRepositoryProvider).getTasks(includeInbox: true);
    final sessions = await ref
        .read(focusSessionRepositoryProvider)
        .getFocusSessionsSince(today.millisecondsSinceEpoch);
    final habits = await ref.read(habitRepositoryProvider).watchActiveHabits().first;
    // One query instead of one per habit: the review needs only today's rows.
    final checks = (await ref
            .read(habitRepositoryProvider)
            .recentChecks(key))
        .where((row) => row.date == key)
        .toList();
    final review = buildDailyReview(
      tasks: tasks,
      sessions: sessions,
      checks: checks,
      habitsTotal: habits.length,
      today: today,
    );
    final finished = completedOn(tasks, today).map((task) => task.title).toList();
    return _ReviewData(review, finished, today);
  }

  Future<void> _share(_ReviewData data, AppLocalizations l10n) async {
    final dateFormat = DateFormat('d MMM yyyy', Localizations.localeOf(context).toString());
    await Share.share(
      [
        l10n.dailyReviewTitle,
        dateFormat.format(data.today),
        '',
        l10n.dailyReviewCompleted(data.review.completedTasks),
        l10n.dailyReviewOverdue(data.review.overdueTasks),
        l10n.dailyReviewFocus(data.review.focusMinutes),
        l10n.dailyReviewHabits(
          data.review.habitsChecked,
          data.review.habitsTotal,
        ),
        'Lekas',
      ].join('\n'),
      subject: l10n.dailyReviewTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final dateFormat = DateFormat(
      'EEEE, d MMMM',
      Localizations.localeOf(context).toString(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyReviewTitle),
        actions: [
          FutureBuilder<_ReviewData>(
            future: _data,
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (data == null || !data.review.hasActivity) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: l10n.dailyReviewShare,
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _share(data, l10n),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<_ReviewData>(
        future: _data,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final review = data.review;
          if (!review.hasActivity) {
            return EmptyState(
              message: l10n.dailyReviewEmpty,
              icon: Icons.insights_outlined,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(data.today),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${review.completedTasks}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                    ),
                    Text(
                      l10n.dailyReviewCompleted(review.completedTasks).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.warning_amber_outlined,
                      value: '${review.overdueTasks}',
                      label: l10n.dailyReviewOverdue(review.overdueTasks),
                      tint: const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      icon: Icons.timer_outlined,
                      value: '${review.focusMinutes}',
                      label: l10n.dailyReviewFocus(review.focusMinutes),
                      tint: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      icon: Icons.local_fire_department_outlined,
                      value: '${review.habitsChecked}/${review.habitsTotal}',
                      label: l10n.dailyReviewHabits(
                        review.habitsChecked,
                        review.habitsTotal,
                      ),
                      tint: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              if (data.finished.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  l10n.dailyReviewCompleted(data.finished.length),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: 8),
                for (final title in data.finished.take(10))
                  ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.check_circle,
                      color: colors.primary,
                      size: 20,
                    ),
                    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ReviewData {
  const _ReviewData(this.review, this.finished, this.today);

  final DailyReview review;
  final List<String> finished;
  final DateTime today;
}

