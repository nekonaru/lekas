import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class WadahNonMatkulScreen extends ConsumerStatefulWidget {
  const WadahNonMatkulScreen({super.key});

  @override
  ConsumerState<WadahNonMatkulScreen> createState() => _WadahNonMatkulScreenState();
}

class _WadahNonMatkulScreenState extends ConsumerState<WadahNonMatkulScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Wadah Non-Matkul')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Organisasi'),
            subtitle: const Text('Organisasi kampus'),
            trailing: const Icon(Icons.group),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Proyek'),
            subtitle: const Text('Proyek kampus'),
            trailing: const Icon(Icons.work),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Pribadi'),
            subtitle: const Text('Kegiatan pribadi'),
            trailing: const Icon(Icons.person),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Lainnya'),
            subtitle: const Text('Wadah lainnya'),
            trailing: const Icon(Icons.folder),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
