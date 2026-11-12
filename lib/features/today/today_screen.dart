import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_util.dart';
import '../../domain/focus.dart';
import '../../domain/urgency.dart' hide TaskSection;
import '../../core/components/task_section.dart';
import '../../core/components/bulk_action_bar.dart';
import '../../core/components/bulk_actions.dart';
import '../../core/components/selection_bottom_bar.dart';
import '../../core/components/motion.dart';
import '../../core/components/undo_snackbar.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_service.dart';
import '../tasks/task_detail_screen.dart';
import '../tasks/task_form_sheet.dart';
import '../tasks/search_filter_screen.dart';
import '../inbox/inbox_screen.dart';

/// One row of the Today list, so the body can be a lazy ListView.builder:
/// the warning card, a section title, or a single task.
sealed class _Entry {
  const _Entry();
}

class _WarningEntry extends _Entry {
  const _WarningEntry(this.warning);

  final Widget warning;
}

class _TitleEntry extends _Entry {
  const _TitleEntry(this.section, this.count);

  final TodaySection section;
  final int count;
}

class _TaskEntry extends _Entry {
  const _TaskEntry(this.task, this.score);

  final Task task;
  final double score;
}

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  int? _inboxCount;
  bool? _notificationsOn;

  /// The FAB slides away while the list scrolls down and comes back on the
  /// first upward scroll, so it never covers the card being read. A notifier
  /// instead of state: flipping it never rebuilds the list, only the FAB.
  final ValueNotifier<bool> _fabVisible = ValueNotifier<bool>(true);

  /// Tasks picked by a long press, for the bulk actions of design 5.5.
  final Set<String> _selection = {};

  /// Last list loaded by the builder, so the action bar can reach it.
  List<Task> _tasks = const [];

  /// Key of the warning the user closed this session. At most one card
  /// is ever shown (design section 4.4).
  String? _dismissedWarning;

  void _toggleSelection(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_selection.remove(id)) _selection.add(id);
    });
  }

  /// Tap on a card: open the task, or toggle it while multi select is on.
  /// Hoisted so a rebuild of the list does not allocate a closure per row.
  void _onTaskTap(Task task) {
    if (_selection.isEmpty) {
      _navigateToDetail(context, task.id);
    } else {
      _toggleSelection(task.id);
    }
  }

  void _onTaskLongPress(Task task) => _toggleSelection(task.id);

  bool _isSelected(Task task) => _selection.contains(task.id);

  void _clearSelection() {
    setState(_selection.clear);
  }

  @override
  void initState() {
    super.initState();
    _loadWarnings();
  }

  @override
  void dispose() {
    _fabVisible.dispose();
    super.dispose();
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
  Widget? _warningCard(AppLocalizations l10n, List<Task> tasks, DateTime now) {
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
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFF59E0B)),
        title: Text(
          l10n.warningTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
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
    // The schedule follows the task stream (reminderSyncProvider), so it
    // reconciles once the writes settle instead of once per swipe.
    if (!mounted) return;
    setState(() {});
    UndoSnackbar.show(context, l10n.taskCompletedUndo, () async {
      await repository.updateTask(
        task.copyWith(
          status: 'todo',
          completedAt: const Value(null),
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      if (mounted) setState(() {});
    });
  }

  /// Bulk complete with an undo, as required by design section 5.5. The
  /// shared helper runs the same transaction and banner every other list
  /// uses; clearing first dismisses the action bar at once.
  Future<void> _completeSelected(List<Task> tasks) async {
    final picked = _picked(tasks);
    _clearSelection();
    await BulkActions.complete(context, ref, picked);
  }

  Future<void> _deleteSelected(List<Task> tasks) async {
    final picked = _picked(tasks);
    _clearSelection();
    await BulkActions.softDelete(context, ref, picked);
  }

  Future<void> _pickPriority(List<Task> tasks) async {
    final picked = _picked(tasks);
    await BulkActions.pickPriority(context, ref, picked);
    if (mounted) setState(() {});
  }

  Future<void> _pickSpace(List<Task> tasks) async {
    final picked = _picked(tasks);
    await BulkActions.pickSpace(context, ref, picked);
    if (mounted) setState(() {});
  }

  /// The selection bar shown under the list while rows are picked: it keeps
  /// the shell app bar untouched and puts every action one thumb away.
  Widget _selectionBar(List<Task> tasks) {
    return SelectionBottomBar(
      count: _selection.length,
      child: BulkSelectionBar(
        count: _selection.length,
        onSelectAll: () =>
            setState(() => _selection.addAll(tasks.map((task) => task.id))),
        onComplete: () => _completeSelected(tasks),
        onPriority: () => _pickPriority(tasks),
        onSpace: () => _pickSpace(tasks),
        onDelete: () => _deleteSelected(tasks),
        onClose: _clearSelection,
      ),
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
            : DateTime(
                now.year,
                now.month,
                now.day,
                19,
              ).add(const Duration(days: 1)),
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
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  ),
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
    final blocked = ref.watch(blockedTaskIdsProvider);

    final selecting = _selection.isNotEmpty;

    // The shell app bar carries the tab title and the drawer; the list
    // only provides its body, its FAB and, while rows are picked, the
    // selection bar along the bottom.
    return Scaffold(
      body: StreamBuilder<List<Task>>(
        stream: repo.watchTasks(includeInbox: false),
        builder: (context, snapshot) {
          // The waiting set arrives on its own stream: without it the
          // first frames would group blocked tasks by their date instead
          // of under Waiting (design section 5.27).
          if (snapshot.connectionState == ConnectionState.waiting ||
              !blocked.hasValue) {
            return const Center(child: CircularProgressIndicator());
          }
          final blockedIds = blocked.value?.toSet() ?? const <String>{};
          final allTasks = snapshot.data ?? [];
          _tasks = allTasks;
          final now = DateTime.now();

          final Map<TodaySection, List<Task>> sections = {};
          final scoresById = <String, double>{};
          for (final task in allTasks) {
            // Design section 5.24: today's focus gets its own group, 5.9
            // pins come next, and everything else follows the score.
            final section = isFocusOnDay(task.focusDate, now)
                ? TodaySection.focus
                : task.pinned
                ? TodaySection.pinned
                : _classifyTask(task, now, blockedIds);
            sections.putIfAbsent(section, () => []).add(task);
          }

          sections.forEach((section, tasks) {
            // The score only depends on the task and the current minute, so
            // it is computed once per task, kept for the row widget, and
            // never recomputed while the card is on screen; recomputing it
            // inside the comparison ran it twice per pair the sort compares.
            final scores = <String, double>{
              for (final task in tasks)
                task.id: urgencyScore(
                  now: now,
                  deadline: task.deadline != null
                      ? DateTime.fromMillisecondsSinceEpoch(task.deadline!)
                      : null,
                  priority: task.priority,
                  weightPercent: task.weightPercent,
                  estimateMinutes: task.estimateMinutes,
                ),
            };
            scoresById.addAll(scores);
            tasks.sort((a, b) => scores[b.id]!.compareTo(scores[a.id]!));
          });

          if (allTasks.isEmpty) {
            final warning = _warningCard(l10n, allTasks, now);
            if (warning == null) {
              return const _EmptyToday();
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

          // One flat row list: the warning, then a title and one entry per
          // task of every non empty section. A lazy ListView.builder walks
          // this, so a long list only lays out the cards on screen instead
          // of building every one of them on each rebuild.
          final entries = <_Entry>[
            if (warning != null) _WarningEntry(warning),
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
              if (sections[section]?.isNotEmpty ?? false) ...[
                _TitleEntry(section, sections[section]!.length),
                for (final task in sections[section]!)
                  _TaskEntry(task, scoresById[task.id]!),
              ],
          ];

          return NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              final visible = notification.direction != ScrollDirection.reverse;
              if (visible != _fabVisible.value) {
                _fabVisible.value = visible;
              }
              return false;
            },
            child: ListView.builder(
              // Bottom padding keeps the last card clear of the FAB instead
              // of hiding behind it while scrolling to the end.
              padding: const EdgeInsets.only(bottom: 88),
              addAutomaticKeepAlives: false,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return switch (entry) {
                  _WarningEntry(:final warning) => KeyedSubtree(
                    key: const ValueKey('today-warning'),
                    child: warning,
                  ),
                  _TitleEntry(:final section, :final count) =>
                    TaskSectionHeader(
                      key: ValueKey('today-title:$section'),
                      section: section,
                      count: count,
                    ),
                  _TaskEntry(:final task, :final score) => FadeSlideIn(
                    index: index,
                    child: TaskCard(
                      key: ValueKey('today-task:${task.id}'),
                      task: task,
                      now: now,
                      locale: locale,
                      score: score,
                      selected: _isSelected(task),
                      enableHero: true,
                      onTaskTap: _onTaskTap,
                      onTaskDone: _completeOne,
                      onTaskSnooze: _openSnooze,
                      onTaskLongPress: _onTaskLongPress,
                    ),
                  ),
                };
              },
            ),
          );
        },
      ),
      bottomNavigationBar:
          selecting ? _selectionBar(_tasks) : null,
      floatingActionButton: selecting
          ? null
          : AnimatedBuilder(
              animation: _fabVisible,
              builder: (context, child) {
                final visible = _fabVisible.value;
                return IgnorePointer(
                  ignoring: !visible,
                  child: AnimatedSlide(
                    duration: AppMotion.normal,
                    curve: AppMotion.ease,
                    offset: visible ? Offset.zero : const Offset(0, 1.4),
                    child: AnimatedScale(
                      duration: AppMotion.fast,
                      scale: visible ? 1 : 0.6,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const TaskFormSheet(),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addTask),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _navigateToDetail(BuildContext context, String taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: taskId)),
    );
  }

  TodaySection _classifyTask(Task task, DateTime now, Set<String> blocked) {
    if (task.status == 'doing') return TodaySection.doing;
    if (task.status == 'done') return TodaySection.someday;

    // Design section 5.27: a task with an unfinished prerequisite waits in
    // its own section whatever its date says, because it cannot be acted
    // on yet.
    if (blocked.contains(task.id)) return TodaySection.waiting;

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

/// The empty Today screen: a tinted check and the message, fading and
/// scaling in once. The animation is finite, so tests can settle on it.
class _EmptyToday extends StatefulWidget {
  const _EmptyToday();

  @override
  State<_EmptyToday> createState() => _EmptyTodayState();
}

class _EmptyTodayState extends State<_EmptyToday>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppMotion.normal,
  )..forward();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final curve = CurvedAnimation(parent: _entrance, curve: AppMotion.ease);
    return Center(
      child: FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curve),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.emptyToday,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
