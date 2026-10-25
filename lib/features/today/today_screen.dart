import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../core/theme.dart';
import '../../core/date_util.dart';
import '../../domain/urgency.dart';
import '../../core/components/task_section.dart';
import '../../core/components/undo_snackbar.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'task_detail_screen.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todayTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const TaskFormSheet(),
              );
            },
            tooltip: l10n.quickAddHint,
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: repo.getTasks(includeInbox: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allTasks = snapshot.data ?? [];
          final now = DateTime.now();

          final Map<TodaySection, List<Task>> sections = {};
          for (final task in allTasks) {
            final section = _classifyTask(task, now);
            sections.putIfAbsent(section, () => []).add(task);
          }

          sections.forEach((section, tasks) {
            tasks.sort((a, b) {
              final sa = urgencyScore(
                now: now,
                deadline: a.deadline != null
                    ? DateTime.fromMillisecondsSinceEpoch(a.deadline!)
                    : null,
                priority: a.priority,
                weightPercent: a.weightPercent,
                estimateMinutes: a.estimateMinutes,
              );
              final sb = urgencyScore(
                now: now,
                deadline: b.deadline != null
                    ? DateTime.fromMillisecondsSinceEpoch(b.deadline!)
                    : null,
                priority: b.priority,
                weightPercent: b.weightPercent,
                estimateMinutes: b.estimateMinutes,
              );
              return sb.compareTo(sa);
            });
          });

          if (allTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.emptyToday),
                ],
              ),
            );
          }

          return ListView(
            children: [
              if (sections[TodaySection.overdue]?.isNotEmpty ?? false)
                TaskSection(
                  section: TodaySection.overdue,
                  tasks: sections[TodaySection.overdue]!,
                  now: now,
                  locale: locale,
                  onTaskTap: (task) => _navigateToDetail(context, task.id),
                ),
              if (sections[TodaySection.doing]?.isNotEmpty ?? false)
                TaskSection(
                  section: TodaySection.doing,
                  tasks: sections[TodaySection.doing]!,
                  now: now,
                  locale: locale,
                  onTaskTap: (task) => _navigateToDetail(context, task.id),
                ),
              if (sections[TodaySection.today]?.isNotEmpty ?? false)
                TaskSection(
                  section: TodaySection.today,
                  tasks: sections[TodaySection.today]!,
                  now: now,
                  locale: locale,
                  onTaskTap: (task) => _navigateToDetail(context, task.id),
                ),
              if (sections[TodaySection.thisWeek]?.isNotEmpty ?? false)
                TaskSection(
                  section: TodaySection.thisWeek,
                  tasks: sections[TodaySection.thisWeek]!,
                  now: now,
                  locale: locale,
                  onTaskTap: (task) => _navigateToDetail(context, task.id),
                ),
              if (sections[TodaySection.upcoming]?.isNotEmpty ?? false)
                TaskSection(
                  section: TodaySection.upcoming,
                  tasks: sections[TodaySection.upcoming]!,
                  now: now,
                  locale: locale,
                  onTaskTap: (task) => _navigateToDetail(context, task.id),
                ),
              if (sections[TodaySection.waiting]?.isNotEmpty ?? false)
                TaskSection(
                  section: TodaySection.waiting,
                  tasks: sections[TodaySection.waiting]!,
                  now: now,
                  locale: locale,
                  onTaskTap: (task) => _navigateToDetail(context, task.id),
                ),
              if (sections[TodaySection.someday]?.isNotEmpty ?? false)
                TaskSection(
                  section: TodaySection.someday,
                  tasks: sections[TodaySection.someday]!,
                  now: now,
                  locale: locale,
                  onTaskTap: (task) => _navigateToDetail(context, task.id),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const TaskFormSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(taskId: taskId),
      ),
    );
  }

  TodaySection _classifyTask(Task task, DateTime now) {
    if (task.status == 'doing') return TodaySection.doing;
    if (task.status == 'done') return TodaySection.someday;

    if (task.deadline == null) return TodaySection.someday;

    final deadline = DateTime.fromMillisecondsSinceEpoch(task.deadline!);
    final daysLeft = deadline.difference(now).inDays;

    if (deadline.isBefore(DateUtil.startOfDay(now))) {
      return TodaySection.overdue;
    }
    if (daysLeft <= 1) {
      return TodaySection.today;
    }
    if (daysLeft <= 7) {
      return TodaySection.thisWeek;
    }
    return TodaySection.upcoming;
  }
}
