import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: Text(l10n.encryptedBackupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.enableBackupEncryption),
            subtitle: Text(l10n.backupEncryptionMethod),
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
          ListTile(
            title: Text(l10n.passwordWarning),
            subtitle: Text(l10n.passwordLostWarning),
          ),
        ],
      ),
    );
  }
}
