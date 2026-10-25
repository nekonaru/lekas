import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class WidgetLanjutanScreen extends ConsumerStatefulWidget {
  const WidgetLanjutanScreen({super.key});

  @override
  ConsumerState<WidgetLanjutanScreen> createState() => _WidgetLanjutanScreenState();
}

class _WidgetLanjutanScreenState extends ConsumerState<WidgetLanjutanScreenState> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Lanjutan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Daftar Tugas'),
            subtitle: const Text('3-6 baris dengan kotak centang'),
            trailing: const Icon(Icons.list),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Kelas Hari Ini'),
            subtitle: const Text('Jadwal singkat'),
            trailing: const Icon(Icons.school),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Hitung Mundur Ujian'),
            subtitle: const Text('Countdown ke ujian berikutnya'),
            trailing: const Icon(Icons.timer),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Fokus Hari Ini'),
            subtitle: const Text('Tiga tugas fokus dengan kotak centang'),
            trailing: const Icon(Icons.star),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
