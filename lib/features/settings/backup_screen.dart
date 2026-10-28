import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backup = ref.watch(backupServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.exportBackup),
            trailing: _isExporting
                ? const CircularProgressIndicator()
                : const Icon(Icons.file_download),
            onTap: _isExporting
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => _isExporting = true);
                    try {
                      final file = await backup.exportToJson();
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.exportedTo(file.path))),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.exportFailed)),
                      );
                    } finally {
                      if (mounted) setState(() => _isExporting = false);
                    }
                  },
          ),
          ListTile(
            title: Text(l10n.importBackup),
            trailing: _isImporting
                ? const CircularProgressIndicator()
                : const Icon(Icons.file_upload),
            onTap: _isImporting
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => _isImporting = true);
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.any,
                        allowedExtensions: ['json'],
                      );
                      if (result != null && result.files.single.path != null) {
                        final file = File(result.files.single.path!);
                        final stats = await backup.importFromJson(file);
                        final tasks =
                            int.tryParse('${stats['tasks']}') ?? 0;
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.importedTasks(tasks))),
                        );
                      }
                    } catch (e) {
                      // The service validates before it deletes anything,
                      // so the current data is still here after this.
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.importFailed)),
                      );
                    } finally {
                      if (mounted) setState(() => _isImporting = false);
                    }
                  },
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.autoBackupFolder),
            subtitle: Text(l10n.autoBackupFolderHint),
            trailing: const Icon(Icons.folder),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final folder = await ref.read(backupServiceProvider).pickBackupFolder();
              if (folder != null) {
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.folderPicked(folder))),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
