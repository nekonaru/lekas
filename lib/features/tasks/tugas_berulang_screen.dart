import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class TugasBerulangScreen extends ConsumerStatefulWidget {
  const TugasBerulangScreen({super.key});

  @override
  ConsumerState<TugasBerulangScreen> createState() => _TugasBerulangScreenState();
}

class _TugasBerulangScreenState extends ConsumerState<TugasBerulangScreenState> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas Berulang Sederhana')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Harian'),
            subtitle: const Text('Setiap hari'),
            trailing: const Icon(Icons.repeat),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Mingguan'),
            subtitle: const Text('Hari tertentu setiap minggu'),
            trailing: const Icon(Icons.repeat),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Bulanan'),
            subtitle: const Text('Tanggal tertentu setiap bulan'),
            trailing: const Icon(Icons.repeat),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
