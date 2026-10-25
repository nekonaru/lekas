import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'backup_screen.dart';
import 'diagnostic_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: FutureBuilder<String?>(
        future: repo.getLanguage(),
        builder: (context, snapshot) {
          return ListView(
            children: [
              ListTile(
                title: Text(l10n.language),
                subtitle: Text(snapshot.data ?? 'id'),
                onTap: () async {
                  await repo.setLanguage(snapshot.data == 'id' ? 'en' : 'id');
                  if (mounted) setState(() {});
                },
              ),
              ListTile(
                title: Text(l10n.darkMode),
                trailing: Switch(
                  value: false,
                  onChanged: (v) async {
                    await repo.setDarkMode(v);
                    if (mounted) setState(() {});
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.exportBackup),
                trailing: const Icon(Icons.file_download),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BackupScreen()),
                  );
                },
              ),
              ListTile(
                title: Text(l10n.importBackup),
                trailing: const Icon(Icons.file_upload),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BackupScreen()),
                  );
                },
              ),
              ListTile(
                title: Text(l10n.checkReminder),
                trailing: const Icon(Icons.notifications),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DiagnosticScreen()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
