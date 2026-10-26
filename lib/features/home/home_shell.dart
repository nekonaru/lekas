import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../quick_add/quick_add_sheet.dart';
import '../settings/backup_screen.dart';
import '../settings/diagnostic_screen.dart';
import '../tasks/morning_night_summary.dart';
import '../tasks/overdue_reminder_screen.dart';
import '../tasks/search_filter_screen.dart';
import '../tasks/tunda_smart_screen.dart';
import '../calendar/calendar_screen.dart';
import '../inbox/inbox_screen.dart';
import '../settings/settings_screen.dart';
import '../spaces/spaces_screen.dart';
import '../today/today_screen.dart';
import '../../l10n/app_localizations.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _i = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      TodayScreen(),
      InboxScreen(),
      SpacesScreen(),
      CalendarScreen(),
      SettingsScreen(),
    ];
  }

  /// Closes the navigation drawer when it is open, so a push does not pop
  /// the shell itself.
  void _closeDrawer() {
    final state = Scaffold.maybeOf(context);
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
        .then((list) => list
            .where((task) =>
                task.status != 'done' &&
                task.deadline != null &&
                task.deletedAt == null)
            .toList()
          ..sort((a, b) => (a.deadline ?? 0).compareTo(b.deadline ?? 0)));
    if (!mounted) return;
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emptyToday)),
      );
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
      l10n.inboxTitle,
      l10n.spacesTitle,
      l10n.calendarTitle,
      l10n.settingsTitle,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(labels[_i]),
        actions: [
          if (_i == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openQuickAdd,
              tooltip: l10n.quickAddHint,
            ),
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          const DrawerHeader(
            child: Text('Lekas',
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: Text(l10n.quickAddMenuLabel),
            onTap: _openQuickAdd,
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
            leading: const Icon(Icons.access_time),
            title: Text(l10n.morningNightSummaryShort),
            onTap: () => _push(const MorningNightSummaryScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: Text(l10n.overdueTasksMenuLabel),
            onTap: () => _push(const OverdueReminderScreen()),
          ),
          const Divider(),
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
        ],
      ),
      body: _pages[_i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: labels.asMap().entries.map((e) {
          return NavigationDestination(
            icon: Icon(_icons(e.key)),
            label: e.value,
          );
        }).toList(),
      ),
    );
  }

  IconData _icons(int index) {
    switch (index) {
      case 0:
        return Icons.today;
      case 1:
        return Icons.inbox;
      case 2:
        return Icons.folder;
      case 3:
        return Icons.calendar_month;
      case 4:
        return Icons.settings;
      default:
        return Icons.today;
    }
  }
}
