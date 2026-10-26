import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';

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
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy', locale).format(_focusedMonth)),
        actions: [
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
                    final dayTasks = tasks.where((t) =>
                        t.deadline != null &&
                        DateUtil.isSameDay(DateTime.fromMillisecondsSinceEpoch(t.deadline!), date)).length;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$day'),
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
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.today),
      ),
    );
  }
}
