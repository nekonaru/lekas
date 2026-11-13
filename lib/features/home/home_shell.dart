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
      drawer: NavigationDrawer(
        children: [
          // The brand band: the indigo to violet gradient behind the logo,
          // so the drawer opens with the same mark as the launcher.
          Container(
            decoration: BoxDecoration(gradient: AppTheme.brandGradient),
            child: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    const LekasLogo(size: 44),
                    const SizedBox(width: 12),
                    Text(
                      'Lekas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tasks first: the tools that end at a task being done.
          _drawerSection(l10n.drawerSectionTasks),
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: Text(l10n.quickAddMenuLabel),
            onTap: _openQuickAdd,
          ),
          ListTile(
            leading: const Icon(Icons.mic_none),
            title: Text(l10n.voiceQuickAddTitle),
            onTap: () => _push(const QuickAddSuaraScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.snooze),
            title: Text(l10n.smartSnoozeLabel),
            onTap: _openSmartSnooze,
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: Text(l10n.searchFilterTitle),
            onTap: () => _push(const SearchFilterScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_border),
            title: Text(l10n.savedViewsTitle),
            onTap: () => _push(const SavedFilterScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.taskTemplatesTitle),
            onTap: () => _push(const TaskTemplateScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(l10n.morningNightSummaryShort),
            onTap: () => _push(const MorningNightSummaryScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: Text(l10n.overdueTasksMenuLabel),
            onTap: () => _push(const OverdueReminderScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(l10n.semesterStatsTitle),
            onTap: () => _push(const StatistikRekapScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: Text(l10n.globalQuickLinksTitle),
            onTap: () => _push(const TautanCepatScreen()),
          ),
          // Data tools: backups and the reminder checker answer the same
          // job at different times.
          _drawerSection(l10n.drawerSectionData),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: Text(l10n.exportBackupShort),
            onTap: () => _push(const BackupScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: Text(l10n.importBackupShort),
            onTap: () => _push(const BackupScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(l10n.checkReminder),
            onTap: () => _push(const DiagnosticScreen()),
          ),
          // Housekeeping last: the trash, where deletes can still come back.
          _drawerSection(l10n.drawerSectionSystem),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.trashTitle),
            onTap: () => _push(const TrashScreen()),
          ),
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

  /// One labeled group header of the drawer, in small caps and the accent
  /// color, so the entries group visually the way they group in the menus.
  Widget _drawerSection(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.primary,
        ),
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
