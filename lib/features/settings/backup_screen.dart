import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      appBar: AppBar(title: const Text('Cadangan Data')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.exportBackup),
            trailing: _isExporting
                ? const CircularProgressIndicator()
                : const Icon(Icons.file_download),
            onTap: _isExporting ? null : () async {
              setState(() => _isExporting = true);
              try {
                final file = await backup.exportToJson();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Diekspor ke: ${file.path}')),
                  );
                }
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
            onTap: _isImporting ? null : () async {
              setState(() => _isImporting = true);
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.any,
                  allowedExtensions: ['json'],
                );
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  final stats = await backup.importFromJson(file);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Diimpor: ${stats['tasks'] ?? 0} tugas')),
                    );
                  }
                }
              } finally {
                if (mounted) setState(() => _isImporting = false);
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Pilih Folder Cadangan Otomatis'),
            subtitle: const Text('Untuk cadangan mingguan otomatis'),
            trailing: const Icon(Icons.folder),
            onTap: () async {
              final repo = ref.read(backupServiceProvider);
              final folder = await repo.pickBackupFolder();
              if (folder != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Folder: $folder')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
