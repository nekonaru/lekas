import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class GantiSemesterScreen extends ConsumerStatefulWidget {
  const GantiSemesterScreen({super.key});

  @override
  ConsumerState<GantiSemesterScreen> createState() => _GantiSemesterScreenState();
}

class _GantiSemesterScreenState extends ConsumerState<GantiSemesterScreen> {
  final _periodController = TextEditingController();

  @override
  void dispose() {
    _periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(spaceRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ganti Semester')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Semester Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _periodController,
              decoration: const InputDecoration(
                labelText: 'Contoh: Ganjil 2026/2027',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Pilih opsi untuk tugas belum selesai:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Biarkan di arsip'),
              leading: const Icon(Icons.archive),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Pindahkan ke wadah baru'),
              leading: const Icon(Icons.folder_copy),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Hapus'),
              leading: const Icon(Icons.delete, color: Colors.red),
              onTap: () {},
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(spaceRepositoryProvider);
                await repo.insertSpace(Space(
                  id: const Uuid().v4(),
                  name: _periodController.text.isEmpty ? 'Semester Baru' : _periodController.text,
                  period: _periodController.text.isEmpty ? 'Semester Baru' : _periodController.text,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                ));
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Buat Semester Baru'),
            ),
          ],
        ),
      ),
    );
  }
}
