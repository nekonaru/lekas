import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'task_detail_screen.dart';

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

  String _typeName(AppLocalizations l10n, String type) {
    switch (type) {
      case 'quiz':
        return l10n.quizLabel;
      case 'lab_report':
        return l10n.typeLabReport;
      case 'paper':
        return l10n.typePaper;
      case 'presentation':
        return l10n.typePresentation;
      case 'midterm':
        return l10n.midtermLabel;
      case 'final':
        return l10n.finalExamLabel;
      default:
        return l10n.othersLabel;
    }
  }

  /// Bottom sheet with the space and type filters (design section 5.1).
  Future<void> _openFilter() async {
    final l10n = AppLocalizations.of(context)!;
    final spaces = await ref.read(spaceRepositoryProvider).getSpaces();
    if (!mounted) return;
    final types = const ['quiz', 'lab_report', 'paper', 'presentation', 'midterm', 'final'];

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(l10n.taskContainer),
                subtitle: Text(_spaceFilter == null
                    ? l10n.allLabel
                    : spaces.firstWhere((s) => s.id == _spaceFilter).name),
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(l10n.allLabel),
                selected: _spaceFilter == null,
                onTap: () {
                  setSheetState(() => _spaceFilter = null);
                  setState(() {});
                },
              ),
              for (final space in spaces)
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(space.name),
                  selected: _spaceFilter == space.id,
                  onTap: () {
                    setSheetState(() => _spaceFilter = space.id);
                    setState(() {});
                  },
                ),
              const Divider(),
              ListTile(
                title: Text(l10n.typeLabel),
                subtitle: Text(_typeFilter == null ? l10n.allLabel : _typeName(l10n, _typeFilter!)),
              ),
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(l10n.allLabel),
                selected: _typeFilter == null,
                onTap: () {
                  setSheetState(() => _typeFilter = null);
                  setState(() {});
                },
              ),
              for (final type in types)
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(_typeName(l10n, type)),
                  selected: _typeFilter == type,
                  onTap: () {
                    setSheetState(() => _typeFilter = type);
                    setState(() {});
                  },
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(l10n.cancel),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchFilterTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
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
            selected: _spaceFilter != null || _typeFilter != null,
            trailing: const Icon(Icons.chevron_right),
            onTap: _openFilter,
          ),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: repo.getTasks(spaceId: _spaceFilter, includeInbox: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tasks = (snapshot.data ?? [])
                    .where((t) =>
                        (_typeFilter == null || t.type == _typeFilter) &&
                        (query.isEmpty ||
                            t.title.toLowerCase().contains(query) ||
                            (t.notes ?? '').toLowerCase().contains(query)))
                    .toList();
                if (tasks.isEmpty) {
                  return Center(child: Text(l10n.emptyTaskList));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.notes ?? ''),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => TaskDetailScreen(taskId: task.id),
                        ),
                      ),
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
