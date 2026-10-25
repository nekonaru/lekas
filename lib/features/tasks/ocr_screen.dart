import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      appBar: AppBar(title: const Text('OCR Tangkapan Layar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Pilih Tangkapan Layar'),
            subtitle: const Text('Pilih gambar untuk diekstrak teksnya'),
            trailing: const Icon(Icons.image),
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );
              if (result != null && result.files.single.path != null) {
                final file = File(result.files.single.path!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Diekstrak: ${file.path}')),
                  );
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Batasan OCR'),
            subtitle: const Text('Hasil OCR pada tulisan tangan atau foto miring akan buruk.'),
          ),
        ],
      ),
    );
  }
}
