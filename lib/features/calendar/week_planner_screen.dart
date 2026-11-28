import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/date_util.dart';
import '../../data/providers.dart';
import '../../domain/week_planner.dart';
import '../../l10n/app_localizations.dart';

/// A compact seven-day plan: deadlines and weekly classes side by side.
class WeekPlannerScreen extends ConsumerStatefulWidget {
  const WeekPlannerScreen({super.key});

  @override
  ConsumerState<WeekPlannerScreen> createState() => _WeekPlannerScreenState();
}

class _WeekPlannerScreenState extends ConsumerState<WeekPlannerScreen> {
  late Future<List<PlannerDay>> _days;
  DateTime _start = DateUtil.startOfDay(DateTime.now());

  @override
  void initState() {
    super.initState();
    _days = _load();
  }

  Future<List<PlannerDay>> _load() async {
    final tasks = await ref.read(taskRepositoryProvider).getTasks(includeInbox: true);
    final slots = await ref.read(classSlotRepositoryProvider).getAllClassSlots();
    return buildWeek(_start, tasks, slots);
  }

  void _shift(int weeks) {
    setState(() {
      _start = _start.add(Duration(days: 7 * weeks));
      _days = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final dayFormat = DateFormat.E(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weekPlannerTitle),
        actions: [
          IconButton(
            tooltip: l10n.weekPlannerPrevious,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _shift(-1),
          ),
          IconButton(
            tooltip: l10n.weekPlannerNext,
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _shift(1),
          ),
        ],
      ),
      body: FutureBuilder<List<PlannerDay>>(
        future: _days,
        builder: (context, snapshot) {
          final days = snapshot.data;
          if (days == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final day = days[index];
              final date = _start.add(Duration(days: index));
              final today = DateUtil.isSameDay(date, DateTime.now());
              return Material(
                color: today
                    ? colors.primaryContainer.withValues(alpha: 0.6)
                    : colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dayFormat.format(date)} ${date.day}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      for (final slot in day.classes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• ${slot.startMin ~/ 60}:${slot.startMin % 60 == 0 ? '00' : slot.startMin % 60} ${l10n.classScheduleTitle}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      for (final task in day.tasks)
                        Text(
                          '• ${task.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (day.classes.isEmpty && day.tasks.isEmpty)
                        Text(
                          l10n.noOtherTasks,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
