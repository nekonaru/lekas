import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../l10n/app_localizations.dart';

class OCRScreen extends ConsumerStatefulWidget {
  const OCRScreen({super.key});

  @override
  ConsumerState<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends ConsumerState<OCRScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ocrScreenshotTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.chooseScreenshot),
            subtitle: Text(l10n.chooseScreenshotSubtitle),
            trailing: const Icon(Icons.image),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );
              if (result != null && result.files.single.path != null) {
                final file = File(result.files.single.path!);
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.extractedFile(file.path))),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.ocrLimitations),
            subtitle: Text(l10n.ocrLimitationsSubtitle),
          ),
        ],
      ),
    );
  }
}
