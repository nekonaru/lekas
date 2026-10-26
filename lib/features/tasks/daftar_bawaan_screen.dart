import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class DaftarBawaanScreen extends ConsumerStatefulWidget {
  const DaftarBawaanScreen({super.key});

  @override
  ConsumerState<DaftarBawaanScreen> createState() => _DaftarBawaanScreenState();
}

class _DaftarBawaanScreenState extends ConsumerState<DaftarBawaanScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Bawaan per Matkul')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Laptop'),
            trailing: Checkbox(value: false, onChanged: (v) {}),
          ),
          ListTile(
            title: const Text('Kabel LAN'),
            trailing: Checkbox(value: false, onChanged: (v) {}),
          ),
          ListTile(
            title: const Text('Laprak Cetak'),
            trailing: Checkbox(value: false, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }
}
