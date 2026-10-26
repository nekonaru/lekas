import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../today/today_screen.dart';
import '../inbox/inbox_screen.dart';
import '../spaces/spaces_screen.dart';
import '../calendar/calendar_screen.dart';
import '../settings/settings_screen.dart';
import '../tasks/morning_night_summary.dart';
import '../tasks/overdue_reminder_screen.dart';
import '../tasks/search_filter_screen.dart';
import '../tasks/attachment_screen.dart';
import '../tasks/prediksi_nilai_screen.dart';
import '../tasks/tunda_smart_screen.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
            title: const Text('Tambah Tugas Cepat'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.snooze),
            title: const Text('Tunda Cerdas'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Pencarian dan Penyaring'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Ringkasan Pagi/Malam'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Tugas Terlambat'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Ekspor Cadangan'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Impor Cadangan'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Cek Pengingat'),
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
