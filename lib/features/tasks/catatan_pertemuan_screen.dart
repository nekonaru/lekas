import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class CatatanPertemuanScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const CatatanPertemuanScreen({super.key, required this.spaceId});

  @override
  ConsumerState<CatatanPertemuanScreen> createState() => _CatatanPertemuanScreenState();
}

class _CatatanPertemuanScreenState extends ConsumerState<CatatanPertemuanScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(classNoteRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Pertemuan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Judul catatan'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bodyController,
                  decoration: const InputDecoration(labelText: 'Isi catatan'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.isEmpty) return;
                    await repo.insertClassNote(ClassNote(
                      id: const Uuid().v4(),
                      spaceId: widget.spaceId,
                      title: _titleController.text,
                      body: _bodyController.text.isEmpty ? null : _bodyController.text,
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    ));
                    _titleController.clear();
                    _bodyController.clear();
                    if (mounted) setState(() {});
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ClassNote>>(
              future: repo.getClassNotes(widget.spaceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notes = snapshot.data ?? [];
                if (notes.isEmpty) {
                  return const Center(child: Text('Belum ada catatan pertemuan.'));
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      title: Text(note.title ?? 'Tanpa judul'),
                      subtitle: Text(note.body ?? ''),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
