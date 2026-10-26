import 'package:flutter/material.dart';
import '../today/today_screen.dart';
import '../inbox/inbox_screen.dart';
import '../spaces/spaces_screen.dart';
import '../calendar/calendar_screen.dart';
import '../settings/settings_screen.dart';
import '../../l10n/app_localizations.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;
  late List<Widget> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      TodayScreen(),
      InboxScreen(),
      SpacesScreen(),
      CalendarScreen(),
      SettingsScreen(),
    ];
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
              onPressed: () {},
              tooltip: l10n.quickAddHint,
            ),
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          const DrawerHeader(
            child: Text('Lekas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: Text(l10n.quickAddMenuLabel),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.snooze),
            title: Text(l10n.smartSnoozeLabel),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: Text(l10n.searchFilterTitle),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(l10n.morningNightSummaryShort),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: Text(l10n.overdueTasksMenuLabel),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: Text(l10n.exportBackupShort),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: Text(l10n.importBackupShort),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(l10n.checkReminder),
            onTap: () {},
          ),
        ],
      ),
      body: _pages.isEmpty ? const Center(child: CircularProgressIndicator()) : _pages[_i],
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
      case 0: return Icons.today;
      case 1: return Icons.inbox;
      case 2: return Icons.folder;
      case 3: return Icons.calendar_month;
      case 4: return Icons.settings;
      default: return Icons.today;
    }
  }
}
