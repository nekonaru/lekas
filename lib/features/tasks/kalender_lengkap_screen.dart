import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class KalenderLengkapScreen extends ConsumerStatefulWidget {
  const KalenderLengkapScreen({super.key});

  @override
  ConsumerState<KalenderLengkapScreen> createState() => _KalenderLengkapScreenState();
}

class _KalenderLengkapScreenState extends ConsumerState<KalenderLengkapScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.fullCalendarTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabMonth, icon: const Icon(Icons.calendar_month)),
              Tab(text: l10n.tabWeek, icon: const Icon(Icons.calendar_view_week)),
              Tab(text: l10n.tabAgenda, icon: const Icon(Icons.schedule)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text(l10n.monthView)),
            Center(child: Text(l10n.weekView)),
            Center(child: Text(l10n.agendaView)),
          ],
        ),
      ),
    );
  }
}
