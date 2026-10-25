import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class ExportGambarPDFScreen extends ConsumerStatefulWidget {
  const ExportGambarPDFScreen({super.key});

  @override
  ConsumerState<ExportGambarPDFScreen> createState() => _ExportGambarPDFScreenState();
}

class _ExportGambarPDFScreenState extends ConsumerState<ExportGambarPDFScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Ekspor Gambar dan PDF')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Ekspor Jadwal Minggu'),
            subtitle: const Text('Gambar jadwal minggu ini'),
            trailing: const Icon(Icons.image),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Ekspor Daftar Tugas'),
            subtitle: const Text('Gambar daftar tugas minggu ini'),
            trailing: const Icon(Icons.image),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Ekspor Rekap Nilai'),
            subtitle: const Text('PDF rekap nilai per matkul'),
            trailing: const Icon(Icons.picture_as_pdf),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Ekspor Riwayat Deadline'),
            subtitle: const Text('PDF bukti perubahan deadline'),
            trailing: const Icon(Icons.picture_as_pdf),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
