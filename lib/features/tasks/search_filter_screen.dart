import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  final _searchController = TextEditingController();
  String? _spaceFilter;
  String? _typeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchFilterTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchTitleOrNotesLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.filterLabel),
            subtitle: Text(l10n.filterSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: repo.getTasks(spaceId: _spaceFilter, includeInbox: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tasks = (snapshot.data ?? [])
                    .where((t) => _typeFilter == null || t.type == _typeFilter)
                    .toList();
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.notes ?? ''),
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
