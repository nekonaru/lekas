import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class PintasanIkonScreen extends ConsumerStatefulWidget {
  const PintasanIkonScreen({super.key});

  @override
  ConsumerState<PintasanIkonScreen> createState() => _PintasanIkonScreenState();
}

class _PintasanIkonScreenState extends ConsumerState<PintasanIkonScreenState> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Pintasan Ikon dan Quick Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Pintasan Ikon Aplikasi'),
            subtitle: const Text('Tekan lama ikon peluncur: Tambah Tugas, Hari Ini, Inbox'),
            trailing: const Icon(Icons.shortcut),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Tile Quick Settings'),
            subtitle: const Text('Satu ketukan dari bilah notifikasi membuka Quick Add'),
            trailing: const Icon(Icons.settings_quick_settings),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Notifikasi Tetap Opsional'),
            subtitle: const Text('Kolom ketik cepat (dimatikan bawaan)'),
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }
}
