import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class DiagnosticScreen extends ConsumerStatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  ConsumerState<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends ConsumerState<DiagnosticScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(diagnosticRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Diagnostik Pengingat')),
      body: FutureBuilder<List<Diagnostic>>(
        future: repo.getDiagnostics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              ListTile(
                title: const Text('Tes Notifikasi 1 Menit'),
                trailing: const Icon(Icons.notifications),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Cek Izin Notifikasi'),
                trailing: const Icon(Icons.check_circle),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Cek Pengecualian Baterai'),
                trailing: const Icon(Icons.battery_saver),
                onTap: () {},
              ),
              const Divider(),
              const Text('Riwayat Tes', style: TextStyle(fontWeight: FontWeight.bold)),
              ...snapshot.data?.map((d) => ListTile(
                title: Text(d.kind),
                subtitle: Text(d.result ?? '-'),
                trailing: Text(d.createdAt.toString()),
              )).toList() ?? [],
            ],
          );
        },
      ),
    );
  }
}
