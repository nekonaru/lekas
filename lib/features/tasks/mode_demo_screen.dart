import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class ModeDemoScreen extends ConsumerStatefulWidget {
  const ModeDemoScreen({super.key});

  @override
  ConsumerState<ModeDemoScreen> createState() => _ModeDemoScreenState();
}

class _ModeDemoScreenState extends ConsumerState<ModeDemoScreenState> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Mode Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Coba dengan Data Contoh'),
            subtitle: const Text('3 matkul, 8 tugas, jadwal contoh'),
            trailing: const Icon(Icons.description),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Hapus Data Contoh'),
            subtitle: const Text('Hapus semua data contoh'),
            trailing: const Icon(Icons.delete),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
