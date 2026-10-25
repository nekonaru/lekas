import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

class BackupAutoScreen extends ConsumerStatefulWidget {
  const BackupAutoScreen({super.key});

  @override
  ConsumerState<BackupAutoScreen> createState() => _BackupAutoScreenState();
}

class _BackupAutoScreenState extends ConsumerState<BackupAutoScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backup = ref.watch(backupServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cadangan Otomatis')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Cadangan Mingguan'),
            subtitle: const Text('Cadangan otomatis ke folder yang dipilih'),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final folder = await backup.pickBackupFolder();
              if (folder != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Folder cadangan: $folder')),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Simpan 4 Cadangan Terakhir'),
            subtitle: const Text('Cadangan lebih lama akan dihapus otomatis'),
            trailing: const Icon(Icons.history),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Peringatan Bila > 14 Hari'),
            subtitle: const Text('Peringatkan bila cadangan terakhir lebih dari 14 hari'),
            trailing: const Icon(Icons.warning),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
