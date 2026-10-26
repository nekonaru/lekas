import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

class ImportMergeScreen extends ConsumerStatefulWidget {
  const ImportMergeScreen({super.key});

  @override
  ConsumerState<ImportMergeScreen> createState() => _ImportMergeScreenState();
}

class _ImportMergeScreenState extends ConsumerState<ImportMergeScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backup = ref.watch(backupServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mergeImportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.importAndMergeBackup),
            subtitle: Text(l10n.importAndMergeBackupSubtitle),
            trailing: const Icon(Icons.file_upload),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final result = await FilePicker.platform.pickFiles(
                type: FileType.any,
                allowedExtensions: ['json'],
              );
              if (result != null && result.files.single.path != null) {
                final file = File(result.files.single.path!);
                try {
                  final stats = await backup.importFromJson(file, mode: 'merge');
                  final merged = int.tryParse('${stats['tasks']}') ?? 0;
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.mergedTasks(merged))),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.actionFailed('$e'))),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
