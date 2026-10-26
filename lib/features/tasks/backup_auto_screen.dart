import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: Text(l10n.autoBackupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.weeklyBackup),
            subtitle: Text(l10n.weeklyBackupSubtitle),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final folder = await backup.pickBackupFolder();
              if (folder != null) {
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.backupFolderPicked(folder))),
                );
              }
            },
          ),
          ListTile(
            title: Text(l10n.keepLast4Backups),
            subtitle: Text(l10n.keepLast4BackupsSubtitle),
            trailing: const Icon(Icons.history),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.warnOlderThan14Days),
            subtitle: Text(l10n.warnOlderThan14DaysSubtitle),
            trailing: const Icon(Icons.warning),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
