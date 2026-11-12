import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';
import 'day_tasks_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      // The month navigation and the weekday header live in the body: the
      // shell owns the only app bar, so the calendar reads flat instead of
      // a bar stacked on another bar.
      body: FutureBuilder<List<Task>>(
        future: repo.getTasks(includeInbox: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data ?? [];
          final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
          final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('MMMM yyyy', locale).format(_focusedMonth),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      tooltip: l10n.previousMonth,
                      onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      tooltip: l10n.nextMonth,
                      onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Row(
                  children: [
                    for (var weekday = 1; weekday <= 7; weekday++)
                      Expanded(
                        child: Center(
                          child: Text(
                            DateFormat.E(locale).format(DateTime(2024, 1, weekday)),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    if (index < firstWeekday - 1 || index >= firstWeekday - 1 + daysInMonth) {
                      return const SizedBox.shrink();
                    }
                    final day = index - (firstWeekday - 1) + 1;
                    final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                    final today = DateTime.now();
                    final isToday = DateUtil.isSameDay(date, today);
                    final dayTasks = tasks.where((t) =>
                        t.deadline != null &&
                        DateUtil.isSameDay(DateTime.fromMillisecondsSinceEpoch(t.deadline!), date)).length;

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => DayTasksScreen(date: date),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isToday
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontWeight:
                                    isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (dayTasks > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            setState(() => _focusedMonth = DateTime.now()),
        child: const Icon(Icons.today),
      ),
    );
  }
}
