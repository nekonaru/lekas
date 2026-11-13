import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';
import '../spaces/space_detail_screen.dart';
import '../tasks/task_detail_screen.dart';
import 'day_tasks_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // Memoized slot cache so the month grid does not clear during reloads.
  List<ClassSlot>? _slotsCache;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final taskRepo = ref.watch(taskRepositoryProvider);
    final slotRepo = ref.watch(classSlotRepositoryProvider);
    final spaceRepo = ref.watch(spaceRepositoryProvider);

    return Scaffold(
      // The month navigation and the weekday header live in the body: the
      // shell owns the only app bar, so the calendar reads flat instead of
      // a bar stacked on another bar.
      body: StreamBuilder<List<ClassSlot>>(
        stream: slotRepo.watchAllClassSlots(),
        builder: (context, slotSnapshot) {
          _slotsCache = slotSnapshot.data ?? _slotsCache;
          final slots = _slotsCache ?? const <ClassSlot>[];
          return StreamBuilder<List<Task>>(
            stream: taskRepo.watchTasks(includeInbox: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final tasks = snapshot.data ?? const <Task>[];
              final daysInMonth =
                  DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
              final firstWeekday =
                  DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;
              final today = DateTime.now();

              // Mark which weekdays the courses meet on, so the grid can
              // light up class days next to the task dots.
              final classWeekdays = slots
                  .where((slot) => slot.deletedAt == null)
                  .map((slot) => slot.weekday)
                  .toSet();

              // Counts for the selected day agenda.
              final dayTasks = tasks
                  .where((task) =>
                      task.deadline != null &&
                      DateUtil.isSameDay(
                        DateTime.fromMillisecondsSinceEpoch(task.deadline!),
                        _selectedDate,
                      ))
                  .toList()
                ..sort((a, b) => (a.deadline ?? 0).compareTo(b.deadline ?? 0));
              final dayClasses = slots
                  .where((slot) => slot.weekday == _selectedDate.weekday)
                  .toList()
                ..sort((a, b) => a.startMin.compareTo(b.startMin));

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('MMMM yyyy', locale)
                                .format(_focusedMonth),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          tooltip: l10n.previousMonth,
                          onPressed: () => setState(() => _focusedMonth =
                              DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          tooltip: l10n.nextMonth,
                          onPressed: () => setState(() => _focusedMonth =
                              DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
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
                                DateFormat.E(locale)
                                    .format(DateTime(2024, 1, weekday)),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: 42,
                      itemBuilder: (context, index) {
                        if (index < firstWeekday - 1 ||
                            index >= firstWeekday - 1 + daysInMonth) {
                          return const SizedBox.shrink();
                        }
                        final day = index - (firstWeekday - 1) + 1;
                        final date =
                            DateTime(_focusedMonth.year, _focusedMonth.month, day);
                        final isToday = DateUtil.isSameDay(date, today);
                        final isSelected =
                            DateUtil.isSameDay(date, _selectedDate);
                        final dayTaskCount = tasks
                            .where((t) =>
                                t.deadline != null &&
                                DateUtil.isSameDay(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      t.deadline!),
                                  date,
                                ))
                            .length;
                        final hasClass = classWeekdays.contains(date.weekday);
                        final scheme = Theme.of(context).colorScheme;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => _selectedDate = date),
                          child: Container(
                            key: ValueKey('day-${date.toIso8601String()}'),
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? scheme.primaryContainer.withValues(alpha: 0.7)
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: scheme.primary,
                                      width: 1.6,
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$day',
                                  style: TextStyle(
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? scheme.primary
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (dayTaskCount > 0)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        margin: const EdgeInsets.only(right: 2),
                                        decoration: BoxDecoration(
                                          color: scheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    if (hasClass)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEC4899),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  StreamBuilder<List<Space>>(
                    stream: spaceRepo.watchSpaces(includeArchived: true),
                    builder: (context, spaceSnapshot) {
                      final spaces = spaceSnapshot.data ?? const <Space>[];
                      return _AgendaPreview(
                        date: _selectedDate,
                        tasks: dayTasks,
                        classes: dayClasses,
                        spaces: spaces,
                        onOpenAll: dayTasks.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        DayTasksScreen(date: _selectedDate),
                                  ),
                                );
                              },
                        onToggleDone: (task) => _toggleTask(task),
                        onOpenTask: (task) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  TaskDetailScreen(taskId: task.id),
                            ),
                          );
                        },
                        onOpenCourse: (space) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => SpaceDetailScreen(spaceId: space.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          final now = DateTime.now();
          _focusedMonth = DateTime(now.year, now.month);
          _selectedDate =
              DateTime(now.year, now.month, now.day);
        }),
        child: const Icon(Icons.today),
      ),
    );
  }

  Future<void> _toggleTask(Task task) async {
    final repo = ref.read(taskRepositoryProvider);
    if (task.status == 'done') {
      await repo.updateTask(task.copyWith(
        status: 'todo',
        completedAt: const Value(null),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));
    } else {
      await repo.markDone(task.id);
    }
    // The tasks stream republishes on write, so the agenda rows refresh
    // themselves; nothing to invalidate here.
  }
}

/// The agenda of the selected day: the classes meeting that weekday and the
/// tasks due that day, both as tappable rows. One page stays out of the way
/// until the user wants detail.
class _AgendaPreview extends StatelessWidget {
  const _AgendaPreview({
    required this.date,
    required this.tasks,
    required this.classes,
    required this.spaces,
    required this.onOpenAll,
    required this.onToggleDone,
    required this.onOpenTask,
    required this.onOpenCourse,
  });

  final DateTime date;
  final List<Task> tasks;
  final List<ClassSlot> classes;
  final List<Space> spaces;
  final VoidCallback? onOpenAll;
  final Future<void> Function(Task) onToggleDone;
  final void Function(Task) onOpenTask;
  final void Function(Space) onOpenCourse;

  String _spaceName(ClassSlot slot) {
    for (final space in spaces) {
      if (space.id == slot.spaceId) return space.name;
    }
    return '';
  }

  Space? _spaceOf(ClassSlot slot) {
    for (final space in spaces) {
      if (space.id == slot.spaceId) return space;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final colors = Theme.of(context).colorScheme;
    final isToday = DateUtil.isSameDay(date, DateTime.now());

    // The preview list sits on tinted surface, so the Material ancestor
    // list tiles need lives on top of the decoration.
    return Material(
      color: colors.surfaceContainerLow,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colors.outlineVariant),
          ),
        ),
        child: SafeArea(
        top: false,
        child: SizedBox(
          height: 190,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.today_outlined,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isToday
                          ? l10n.todayTitle
                          : DateUtil.formatDate(date, locale),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    if (onOpenAll != null)
                      TextButton.icon(
                        onPressed: onOpenAll,
                        icon: const Icon(Icons.chevron_right, size: 18),
                        label: Text('${l10n.seeAllTasks} (${tasks.length})'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: classes.isEmpty && tasks.isEmpty
                    ? Center(
                        child: Text(
                          l10n.agendaEmpty,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 12),
                        children: [
                          for (final slot in classes)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.class_outlined),
                              title: Text(_spaceName(slot)),
                              subtitle: Text(
                                '${DateUtil.formatTime(
                                  DateTime(2026, 1, 1, slot.startMin ~/ 60, slot.startMin % 60),
                                  locale,
                                )}–${DateUtil.formatTime(
                                  DateTime(2026, 1, 1, slot.endMin ~/ 60, slot.endMin % 60),
                                  locale,
                                )}${slot.room == null || slot.room!.isEmpty ? '' : ' · ${slot.room}'}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                final space = _spaceOf(slot);
                                if (space != null) onOpenCourse(space);
                              },
                            ),
                          for (final task in tasks)
                            ListTile(
                              dense: true,
                              leading: IconButton(
                                icon: Icon(
                                  task.status == 'done'
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: task.status == 'done'
                                      ? colors.primary
                                      : null,
                                ),
                                tooltip: l10n.markLabel,
                                onPressed: () => onToggleDone(task),
                              ),
                              title: Text(
                                task.title,
                                style: task.status == 'done'
                                    ? const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                      )
                                    : null,
                              ),
                              subtitle: task.deadline == null
                                  ? null
                                  : Text(DateUtil.formatTime(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          task.deadline!),
                                      locale,
                                    )),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => onOpenTask(task),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
