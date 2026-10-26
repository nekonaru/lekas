import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class StatistikRekapScreen extends ConsumerStatefulWidget {
  const StatistikRekapScreen({super.key});

  @override
  ConsumerState<StatistikRekapScreen> createState() => _StatistikRekapScreenState();
}

class _StatistikRekapScreenState extends ConsumerState<StatistikRekapScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik dan Rekap Semester')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Persentase Tepat Waktu'),
            trailing: const Icon(Icons.access_time),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Matkul Terpadat'),
            trailing: const Icon(Icons.school),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Rekap Kehadiran'),
            trailing: const Icon(Icons.check_circle),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Tren Per Minggu'),
            trailing: const Icon(Icons.trending_up),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
