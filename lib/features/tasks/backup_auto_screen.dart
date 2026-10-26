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
  static const _keepLast4Key = 'backup_keep_last_4';
  static const _warnOldKey = 'backup_warn_older_than_14_days';

  bool? _keepLast4;
  bool? _warnOld;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    final keepLast4 = await repo.get(_keepLast4Key);
    final warnOld = await repo.get(_warnOldKey);
    if (!mounted) return;
    setState(() {
      _keepLast4 = keepLast4 == 'true';
      _warnOld = warnOld == 'true';
    });
  }

  Future<void> _toggle(String key, String title) async {
    final l10n = AppLocalizations.of(context)!;
    final next = !(await ref.read(settingsRepositoryProvider).get(key) == 'true');
    await ref.read(settingsRepositoryProvider).set(key, next ? 'true' : 'false');
    if (!mounted) return;
    setState(() {
      if (key == _keepLast4Key) {
        _keepLast4 = next;
      } else {
        _warnOld = next;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: ${next ? l10n.enabledLabel : l10n.disabledLabel}'),
      ),
    );
  }

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
            trailing: Icon(
              _keepLast4 == true ? Icons.check_circle : Icons.history,
              color: _keepLast4 == true ? Colors.green : null,
            ),
            onTap: () => _toggle(_keepLast4Key, l10n.keepLast4Backups),
          ),
          ListTile(
            title: Text(l10n.warnOlderThan14Days),
            subtitle: Text(l10n.warnOlderThan14DaysSubtitle),
            trailing: Icon(
              _warnOld == true ? Icons.check_circle : Icons.warning,
              color: _warnOld == true ? Colors.green : Colors.orange,
            ),
            onTap: () => _toggle(_warnOldKey, l10n.warnOlderThan14Days),
          ),
        ],
      ),
    );
  }
}
