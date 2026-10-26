import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: Text(l10n.savedViewsTitle)),
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
              title: Text(l10n.saveViewTitle),
              content: TextField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.viewNameLabel),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    if (_nameController.text.isEmpty) return;
                    final navigator = Navigator.of(context);
                    await repo.insertSavedFilter(SavedFilter(
                      id: const Uuid().v4(),
                      name: _nameController.text,
                      queryJson: '{}',
                      sortOrder: 0,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    ));
                    navigator.pop();
                    if (mounted) setState(() {});
                  },
                  child: Text(l10n.save),
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
