import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/date_util.dart';
import '../../domain/urgency.dart' hide TaskSection;
import '../../core/components/task_section.dart';
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

  /// Key of the warning the user closed this session. At most one card
  /// is ever shown (design section 4.4).
  String? _dismissedWarning;

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
