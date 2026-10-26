import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class SavedFilterScreen extends ConsumerStatefulWidget {
  const SavedFilterScreen({super.key});

  @override
  ConsumerState<SavedFilterScreen> createState() => _SavedFilterScreenState();
}

class _SavedFilterScreenState extends ConsumerState<SavedFilterScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(savedFilterRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tampilan Tersimpan')),
      body: FutureBuilder<List<SavedFilter>>(
        future: repo.getSavedFilters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final filters = snapshot.data ?? [];

          return ListView.builder(
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              return ListTile(
                title: Text(filter.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Simpan Tampilan'),
              content: TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nama tampilan'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_nameController.text.isEmpty) return;
                    await repo.insertSavedFilter(SavedFilter(
                      id: const Uuid().v4(),
                      name: _nameController.text,
                      queryJson: '{}',
                      sortOrder: 0,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    ));
                    if (mounted) Navigator.pop(context);
                    if (mounted) setState(() {});
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
