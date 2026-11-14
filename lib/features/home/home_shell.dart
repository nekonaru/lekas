import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../quick_add/quick_add_sheet.dart';
import '../settings/backup_screen.dart';
import '../settings/diagnostic_screen.dart';
import '../tasks/morning_night_summary.dart';
import '../tasks/overdue_reminder_screen.dart';
import '../tasks/quick_add_suara_screen.dart';
import '../tasks/saved_filter_screen.dart';
import '../tasks/search_filter_screen.dart';
import '../tasks/statistik_rekap_screen.dart';
import '../tasks/tautan_cepat_screen.dart';
import '../tasks/task_template_screen.dart';
import '../tasks/trash_screen.dart';
import '../tasks/tunda_smart_screen.dart';
import '../calendar/calendar_screen.dart';
import '../semester/semester_screen.dart';
import '../settings/settings_screen.dart';
import '../spaces/spaces_screen.dart';
import '../today/today_screen.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/components/lekas_logo.dart';
import '../../core/version_checker.dart';
import '../settings/update_dialog.dart';
import '../../l10n/app_localizations.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _i = 0;
  late final List<Widget> _pages;

  /// The drawer lives inside this state's own Scaffold, and a lookup with
  /// [Scaffold.maybeOf] from this context walks above it, where there is no
  /// Scaffold to find: the old check always came back null and the drawer
  /// stayed open underneath every screen pushed from it. The key reaches the
  /// Scaffold state directly instead.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _pages = const [
      TodayScreen(),
      SpacesScreen(view: SpaceView.free, embedded: true),
      SemesterScreen(embedded: true),
      CalendarScreen(),
      SettingsScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Once a day, quietly: ask GitHub whether a newer release exists and,
      // only then, offer the download. Off via the settings switch.
      _maybeCheckForUpdate();
    });
  }

  /// The background half of the update check: silent unless an update is
  /// actually there, rate limited to once a day, and skipped entirely when
  /// the user turned it off or the check fails.
  Future<void> _maybeCheckForUpdate() async {
    try {
      final settings = ref.read(settingsRepositoryProvider);
      if ((await settings.get('auto_update_check')) == '0') return;
      final last = int.tryParse(await settings.get('last_version_check_at') ?? '0') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - last < 24 * 60 * 60 * 1000) return;
      await settings.set('last_version_check_at', '$now');
      final result = await ref.read(versionCheckerProvider).check();
      if (!mounted) return;
      if (result is! UpdateAvailable) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.updateAvailableShort(result.version)),
          action: SnackBarAction(
            label: l10n.updateDownload,
            onPressed: () => openUpdateUrl(result.url),
          ),
        ),
      );
    } catch (_) {
      // No network, no GitHub, no permission: the check stays silent.
    }
  }

  /// Closes the navigation drawer when it is open, so a push does not leave
  /// the drawer sitting behind the new screen.
  void _closeDrawer() {
    final state = _scaffoldKey.currentState;
    if (state == null) return;
    if (state.isDrawerOpen || state.isEndDrawerOpen) {
      Navigator.pop(context);
    }
  }

  void _push(Widget screen) {
    _closeDrawer();
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _openQuickAdd() {
    _closeDrawer();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const QuickAddSheet(),
    );
  }

  /// Smart snooze needs one task: show the tasks that are due soon or late
  /// and open the snooze options for the chosen one (design section 5.5).
  Future<void> _openSmartSnooze() async {
    final l10n = AppLocalizations.of(context)!;
    _closeDrawer();
    final tasks = await ref
        .read(taskRepositoryProvider)
        .getTasks(includeInbox: true)
        .then(
          (list) =>
              list
                  .where(
                    (task) =>
                        task.status != 'done' &&
                        task.deadline != null &&
                        task.deletedAt == null,
                  )
                  .toList()
                ..sort((a, b) => (a.deadline ?? 0).compareTo(b.deadline ?? 0)),
        );
    if (!mounted) return;
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.emptyToday)));
      return;
    }
    final picked = await showModalBottomSheet<Task>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          children: [
            for (final task in tasks.take(20))
              ListTile(
                leading: const Icon(Icons.snooze),
                title: Text(task.title),
                onTap: () => Navigator.pop(sheetContext, task),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TundaSmartScreen(taskId: picked.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.todayTitle,
      l10n.kategoriTitle,
      l10n.semesterTitle,
      l10n.calendarTitle,
      l10n.settingsTitle,
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: AppMotion.fast,
          switchInCurve: AppMotion.ease,
          switchOutCurve: AppMotion.ease,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Text(labels[_i], key: ValueKey(labels[_i])),
        ),
      ),
      // A flat, low elevation drawer: the brand band up top, the sections
      // grouped with icons below, so the menu reads as one calm surface.
      drawer: NavigationDrawer(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        children: [
          _drawerHeader(context),
          // Tasks first: the tools that end at a task being done.
          _drawerSection(l10n.drawerSectionTasks, Icons.checklist),
          _drawerTile(Icons.add_circle_outline, l10n.quickAddMenuLabel, _openQuickAdd),
          _drawerTile(
            Icons.mic_none,
            l10n.voiceQuickAddTitle,
            () => _push(const QuickAddSuaraScreen()),
          ),
          _drawerTile(
            Icons.snooze,
            l10n.smartSnoozeLabel,
            _openSmartSnooze,
          ),
          _drawerTile(
            Icons.search,
            l10n.searchFilterTitle,
            () => _push(const SearchFilterScreen()),
          ),
          _drawerTile(
            Icons.bookmark_border,
            l10n.savedViewsTitle,
            () => _push(const SavedFilterScreen()),
          ),
          _drawerTile(
            Icons.description_outlined,
            l10n.taskTemplatesTitle,
            () => _push(const TaskTemplateScreen()),
          ),
          _drawerTile(
            Icons.access_time,
            l10n.morningNightSummaryShort,
            () => _push(const MorningNightSummaryScreen()),
          ),
          _drawerTile(
            Icons.warning_amber_outlined,
            l10n.overdueTasksMenuLabel,
            () => _push(const OverdueReminderScreen()),
          ),
          _drawerTile(
            Icons.bar_chart,
            l10n.semesterStatsTitle,
            () => _push(const StatistikRekapScreen()),
          ),
          _drawerTile(
            Icons.link,
            l10n.globalQuickLinksTitle,
            () => _push(const TautanCepatScreen()),
          ),
          // Data tools: backups and the reminder checker answer the same
          // job at different times.
          _drawerSection(l10n.drawerSectionData, Icons.storage_outlined),
          _drawerTile(
            Icons.file_download_outlined,
            l10n.exportBackupShort,
            () => _push(const BackupScreen()),
          ),
          _drawerTile(
            Icons.file_upload_outlined,
            l10n.importBackupShort,
            () => _push(const BackupScreen()),
          ),
          _drawerTile(
            Icons.notifications_active_outlined,
            l10n.checkReminder,
            () => _push(const DiagnosticScreen()),
          ),
          // Housekeeping last: the trash, where deletes can still come back.
          _drawerSection(l10n.drawerSectionSystem, Icons.tune),
          _TrashTile(onTap: () => _push(const TrashScreen())),
          const SizedBox(height: 8),
          _drawerFooter(context),
        ],
      ),
      // A short fade and slide between tabs: the swap reads as one motion
      // instead of a hard cut, and it settles fast for tests.
      body: AnimatedSwitcher(
        duration: AppMotion.normal,
        switchInCurve: AppMotion.ease,
        switchOutCurve: AppMotion.ease,
        child: KeyedSubtree(key: ValueKey(_i), child: _pages[_i]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: labels.asMap().entries.map((e) {
          return NavigationDestination(
            icon: Icon(_icons(e.key)),
            selectedIcon: Icon(_selectedIcons(e.key)),
            label: e.value,
          );
        }).toList(),
      ),
    );
  }

  /// The brand band: the indigo to violet gradient behind the logo,
  /// so the drawer opens with the same mark as the launcher, plus the
  /// tagline and the running version.
  Widget _drawerHeader(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.brandGradient),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Row(
            children: [
              const LekasLogo(size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lekas',
                      style: text.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)!.splashTagline,
                      style: text.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'v$appVersion',
                  style: text.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// One row of the drawer: a soft tinted glyph, the label, and an optional
  /// badge (used for the trash count). The whole row closes the drawer
  /// before running its action.
  Widget _drawerTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    String? badge,
  }) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: colors.primary),
      ),
      title: Text(label),
      trailing: badge == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onPrimaryContainer,
                    ),
              ),
            ),
      onTap: () {
        _closeDrawer();
        onTap();
      },
    );
  }

  /// The small caps section header of the drawer, in the accent color with
  /// a leading glyph, so the menu groups visually the way it works.
  Widget _drawerSection(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// A quiet footer under the sections: the running version and the one
  /// line promise of the app.
  Widget _drawerFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: [
          Icon(Icons.favorite, size: 13, color: Colors.pinkAccent.shade200),
          const SizedBox(width: 6),
          Text(
            'Lekas v$appVersion',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  IconData _icons(int index) {
    switch (index) {
      case 0:
        return Icons.today_outlined;
      case 1:
        return Icons.category_outlined;
      case 2:
        return Icons.school_outlined;
      case 3:
        return Icons.calendar_month_outlined;
      case 4:
        return Icons.settings_outlined;
      default:
        return Icons.today_outlined;
    }
  }

  /// The filled twin shown on the tab that is open, so the active tab
  /// reads as one motion instead of a plain color change.
  IconData _selectedIcons(int index) {
    switch (index) {
      case 0:
        return Icons.today;
      case 1:
        return Icons.category;
      case 2:
        return Icons.school;
      case 3:
        return Icons.calendar_month;
      case 4:
        return Icons.settings;
      default:
        return Icons.today;
    }
  }
}

/// The trash row with a live count badge instead of a guess.
class _TrashTile extends ConsumerWidget {
  const _TrashTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return StreamBuilder<List<Task>>(
      stream: ref.watch(taskRepositoryProvider).watchTrash(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.delete_outline, size: 20, color: colors.primary),
          ),
          title: Text(AppLocalizations.of(context)!.trashTitle),
          trailing: count == 0
              ? null
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onPrimaryContainer,
                        ),
                  ),
                ),
          onTap: onTap,
        );
      },
    );
  }
}
