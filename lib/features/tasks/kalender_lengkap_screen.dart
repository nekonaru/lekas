import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
          title: const Text('Kalender Lengkap'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bulan', icon: Icon(Icons.calendar_month)),
              Tab(text: 'Minggu', icon: Icon(Icons.calendar_view_week)),
              Tab(text: 'Agenda', icon: Icon(Icons.agenda)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Tampilan bulan')),
            Center(child: Text('Tampilan minggu')),
            Center(child: Text('Agenda kronologis')),
          ],
        ),
      ),
    );
  }
}
