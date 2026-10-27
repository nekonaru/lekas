import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/date_util.dart';
import '../../domain/focus.dart';
import '../../domain/urgency.dart' hide TaskSection;
import '../../core/components/task_section.dart';
import '../../core/components/undo_snackbar.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_service.dart';
import '../tasks/task_detail_screen.dart';
import '../tasks/task_form_sheet.dart';
import '../tasks/search_filter_screen.dart';
import '../inbox/inbox_screen.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  int? _inboxCount;
  bool? _notificationsOn;

  /// Tasks picked by a long press, for the bulk actions of design 5.5.
  final Set<String> _selection = {};

  /// Last list loaded by the builder, so the action bar can reach it.
  List<Task> _tasks = const [];

  /// Key of the warning the user closed this session. At most one card
  /// is ever shown (design section 4.4).
  String? _dismissedWarning;

  void _toggleSelection(String id) {
    setState(() {
      if (!_selection.remove(id)) _selection.add(id);
    });
  }

  void _clearSelection() {
    setState(_selection.clear);
  }

  @override
  void initState() {
    super.initState();
    _loadWarnings();
  }

  Future<void> _loadWarnings() async {
    final repository = ref.read(taskRepositoryProvider);
    final inbox = await repository.countInbox();
    final on = await ref.read(reminderServiceProvider).notificationsEnabled();
    if (!mounted) return;
    setState(() {
      _inboxCount = inbox;
      _notificationsOn = on;
    });
  }

  Future<void> _openNotificationSettings() async {
    try {
      await const MethodChannel('lekas/platform')
          .invokeMethod<void>('openNotificationSettings');
    } catch (_) {
      // The channel only exists on Android.
    }
  }

  /// The one warning card of this screen, or null when there is nothing to
  /// warn about (design section 4.4: permission revoked, busy week, inbox
  /// pile-up; at most one card, and the user can close it).
  Widget? _warningCard(
    AppLocalizations l10n,
    List<Task> tasks,
    DateTime now,
  ) {
    if (_notificationsOn == false && _dismissedWarning != 'permission') {
      return _buildWarning(
        key: 'permission',
        icon: Icons.notifications_off,
        message: l10n.warningPermissionRevoked,
        onOpen: _openNotificationSettings,
      );
    }

    final inbox = _inboxCount ?? 0;
    if (inbox >= 5 && _dismissedWarning != 'inbox') {
      return _buildWarning(
        key: 'inbox',
        icon: Icons.inbox,
        message: l10n.warningInboxPile(inbox),
        onOpen: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const InboxScreen()),
        ),
      );
    }

    final week = tasks.where((task) {
      if (task.status == 'done' || task.deadline == null) return false;
      final deadline = DateTime.fromMillisecondsSinceEpoch(task.deadline!);
      if (deadline.isBefore(DateUtil.startOfDay(now))) return false;
      return deadline.difference(now).inDays <= 7;
    }).length;
    if (week >= 10 && _dismissedWarning != 'week') {
      return _buildWarning(
        key: 'week',
        icon: Icons.calendar_month,
        message: l10n.warningBusyWeek(week),
        onOpen: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const SearchFilterScreen()),
        ),
      );
    }

    return null;
  }

  Widget _buildWarning({
    required String key,
    required IconData icon,
    required String message,
    required VoidCallback onOpen,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: colors.errorContainer,
      child: ListTile(
        leading: Icon(icon, color: colors.onErrorContainer),
        title: Text(
          l10n.warningTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.onErrorContainer,
          ),
        ),
        subtitle: Text(message, style: TextStyle(color: colors.onErrorContainer)),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.closeLabel,
          onPressed: () => setState(() => _dismissedWarning = key),
        ),
        onTap: onOpen,
      ),
    );
  }
  List<Task> _picked(List<Task> tasks) =>
      tasks.where((task) => _selection.contains(task.id)).toList();

  /// Swipe right: finish one task and offer undo (design section 5.5).
  Future<void> _completeOne(Task task) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(taskRepositoryProvider);
    await repository.markDone(task.id);
    await ref.read(reminderServiceProvider).syncAll();
    if (!mounted) return;
    setState(() {});
    UndoSnackbar.show(context, l10n.taskCompletedUndo, () async {
      await repository.updateTask(task.copyWith(
        status: 'todo',
        completedAt: const Value(null),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      if (mounted) setState(() {});
      await ref.read(reminderServiceProvider).syncAll();
    });
  }

  /// Bulk complete with an undo, as required by design section 5.5.
  Future<void> _completeSelected(List<Task> tasks) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(taskRepositoryProvider);
    final picked = _picked(tasks);
    if (picked.isEmpty) return;
    for (final task in picked) {
      await repository.markDone(task.id);
    }
    _clearSelection();
    await ref.read(reminderServiceProvider).syncAll();
    if (!mounted) return;
    UndoSnackbar.show(context, l10n.taskCompletedUndo, () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final task in picked) {
        await repository.updateTask(task.copyWith(
          status: 'todo',
          completedAt: const Value(null),
          updatedAt: now,
        ));
      }
      if (mounted) setState(() {});
      await ref.read(reminderServiceProvider).syncAll();
    });
  }

  Future<void> _deleteSelected(List<Task> tasks) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(taskRepositoryProvider);
    final picked = _picked(tasks);
    if (picked.isEmpty) return;
    for (final task in picked) {
      await repository.softDeleteTask(task.id);
    }
    _clearSelection();
    await ref.read(reminderServiceProvider).syncAll();
    if (!mounted) return;
    UndoSnackbar.show(context, l10n.tasksDeletedUndo(picked.length), () async {
      for (final task in picked) {
        await repository.restoreTask(task.id);
      }
      if (mounted) setState(() {});
      await ref.read(reminderServiceProvider).syncAll();
    });
  }

  Future<void> _pickPriority(List<Task> tasks) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = _picked(tasks);
    if (picked.isEmpty) return;
    final priority = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(l10n.priorityLow),
              onTap: () => Navigator.pop(sheetContext, 0),
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: Text(l10n.priorityMedium),
              onTap: () => Navigator.pop(sheetContext, 1),
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: Text(l10n.priorityHigh),
              onTap: () => Navigator.pop(sheetContext, 2),
            ),
          ],
        ),
      ),
    );
    if (priority == null || !mounted) return;
    final repository = ref.read(taskRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final task in picked) {
      await repository
          .updateTask(task.copyWith(priority: priority, updatedAt: now));
    }
    if (!mounted) return;
    setState(() {});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.bulkUpdated(picked.length))),
    );
  }

  Future<void> _pickSpace(List<Task> tasks) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = _picked(tasks);
    if (picked.isEmpty) return;
    final spaces = await ref.read(spaceRepositoryProvider).getSpaces();
    if (!mounted) return;
    final spaceId = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(l10n.inboxTitle),
              onTap: () => Navigator.pop(sheetContext, ''),
            ),
            for (final space in spaces)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(space.name),
                onTap: () => Navigator.pop(sheetContext, space.id),
              ),
          ],
        ),
      ),
    );
    if (spaceId == null || !mounted) return;
    final repository = ref.read(taskRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final task in picked) {
      await repository.updateTask(task.copyWith(
        spaceId: Value(spaceId.isEmpty ? null : spaceId),
        inbox: spaceId.isEmpty,
        updatedAt: now,
      ));
    }
    if (!mounted) return;
    setState(() {});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.bulkUpdated(picked.length))),
    );
  }

  /// Smart snooze choices offered by the left swipe (design section 5.5).
  Future<void> _openSnooze(Task task) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final tomorrow7 = now.add(const Duration(days: 1));
    final options = <MapEntry<String, DateTime>>[
      MapEntry(l10n.oneHourLabel, now.add(const Duration(hours: 1))),
      MapEntry(
        l10n.tonight7pmLabel,
        now.hour < 19
            ? DateTime(now.year, now.month, now.day, 19)
            : DateTime(now.year, now.month, now.day, 19)
                .add(const Duration(days: 1)),
      ),
      MapEntry(
        l10n.tomorrow7amLabel,
        DateTime(tomorrow7.year, tomorrow7.month, tomorrow7.day, 7),
      ),
      MapEntry(l10n.weekendLabel, _nextSaturdayAt(now, 9)),
    ];

    final chosen = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final option in options)
              ListTile(
                leading: const Icon(Icons.snooze),
                title: Text(option.key),
                subtitle: Text(DateUtil.formatDateTime(option.value, locale)),
                onTap: () => Navigator.pop(sheetContext, option.value),
              ),
            ListTile(
              leading: const Icon(Icons.edit_calendar),
              title: Text(l10n.pickTimeLabel),
              onTap: () async {
                final date = await showDatePicker(
                  context: sheetContext,
                  initialDate: now,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                );
                if (date == null || !sheetContext.mounted) return;
                final time = await showTimePicker(
                  context: sheetContext,
                  initialTime: TimeOfDay.fromDateTime(now),
                );
                if (time == null) return;
                if (!sheetContext.mounted) return;
                Navigator.pop(
                  sheetContext,
                  DateTime(
                      date.year, date.month, date.day, time.hour, time.minute),
                );
              },
            ),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    // Tunda moves the reminder only, never the deadline (design 5.5).
    await ref.read(reminderServiceProvider).snoozeTaskAt(task.id, chosen);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.snoozeSet(DateUtil.formatTime(chosen, locale))),
      ),
    );
  }

  /// The next Saturday at [hour], never today (design section 5.5).
  DateTime _nextSaturdayAt(DateTime from, int hour) {
    final ahead = (DateTime.saturday - from.weekday + 7) % 7;
    final day = from.add(Duration(days: ahead == 0 ? 7 : ahead));
    return DateTime(day.year, day.month, day.day, hour);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(taskRepositoryProvider);

    final selecting = _selection.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(selecting
            ? l10n.selectedCount(_selection.length)
            : l10n.todayTitle),
        actions: [
          if (selecting) ...[
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: l10n.markLabel,
              onPressed: () => _completeSelected(_tasks),
            ),
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: l10n.priorityMedium,
              onPressed: () => _pickPriority(_tasks),
            ),
            IconButton(
              icon: const Icon(Icons.folder_outlined),
              tooltip: l10n.taskContainer,
              onPressed: () => _pickSpace(_tasks),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deleteLabel,
              onPressed: () => _deleteSelected(_tasks),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.closeLabel,
              onPressed: _clearSelection,
            ),
          ] else
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
          _tasks = allTasks;
          final now = DateTime.now();

          final Map<TodaySection, List<Task>> sections = {};
          for (final task in allTasks) {
            // Design section 5.24: today's focus gets its own group, 5.9
            // pins come next, and everything else follows the score.
            final section = isFocusOnDay(task.focusDate, now)
                ? TodaySection.focus
                : task.pinned
                    ? TodaySection.pinned
                    : _classifyTask(task, now);
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
            final warning = _warningCard(l10n, allTasks, now);
            if (warning == null) {
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
                warning,
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.emptyToday)),
                ),
              ],
            );
          }

          final warning = _warningCard(l10n, allTasks, now);

          return ListView(
            children: [
              ?warning,
              for (final section in const [
                TodaySection.pinned,
                TodaySection.focus,
                TodaySection.overdue,
                TodaySection.doing,
                TodaySection.today,
                TodaySection.thisWeek,
                TodaySection.upcoming,
                TodaySection.waiting,
                TodaySection.someday,
              ])
                if (sections[section]?.isNotEmpty ?? false)
                  TaskSection(
                    section: section,
                    tasks: sections[section]!,
                    now: now,
                    locale: locale,
                    onTaskTap: (task) => _selection.isEmpty
                        ? _navigateToDetail(context, task.id)
                        : _toggleSelection(task.id),
                    onTaskDone: _completeOne,
                    onTaskSnooze: _openSnooze,
                    onTaskLongPress: (task) => _toggleSelection(task.id),
                    isSelected: (task) => _selection.contains(task.id),
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
