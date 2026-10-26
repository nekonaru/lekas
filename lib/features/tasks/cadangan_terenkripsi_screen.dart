import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class CadanganTerenkripsiScreen extends ConsumerStatefulWidget {
  const CadanganTerenkripsiScreen({super.key});

  @override
  ConsumerState<CadanganTerenkripsiScreen> createState() => _CadanganTerenkripsiScreenState();
}

class _CadanganTerenkripsiScreenState extends ConsumerState<CadanganTerenkripsiScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Cadangan Terenkripsi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Aktifkan Enkripsi Cadangan'),
            subtitle: const Text('AES-GCM dengan kata sandi'),
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
          ListTile(
            title: const Text('Peringatan'),
            subtitle: const Text('Kata sandi yang hilang berarti cadangan tidak bisa dibuka.'),
          ),
        ],
      ),
    );
  }
}
