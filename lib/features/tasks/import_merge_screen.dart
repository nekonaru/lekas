import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      appBar: AppBar(title: const Text('Impor Gabung')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Impor dan Gabung Cadangan'),
            subtitle: const Text('Gabungkan data dari cadangan dengan data saat ini'),
            trailing: const Icon(Icons.file_upload),
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.any,
                allowedExtensions: ['json'],
              );
              if (result != null && result.files.single.path != null) {
                final file = File(result.files.single.path!);
                try {
                  final stats = await backup.importFromJson(file, mode: 'merge');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Digabung: ${stats['tasks'] ?? 0} tugas')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
