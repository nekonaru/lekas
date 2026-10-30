import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'task_detail_screen.dart';

/// How long typing pauses before the search filter runs.
const Duration kSearchDebounce = Duration(milliseconds: 250);

class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  final _searchController = TextEditingController();
  String? _spaceFilter;
  String? _typeFilter;
  String? _tagFilter;

  /// The settled search text. Every keystroke used to rebuild the whole
  /// list, so the filter now waits until typing pauses (design section 5.9).
  String _query = '';
  Timer? _debounce;

  void _onQueryChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(kSearchDebounce, () {
      if (!mounted) return;
      setState(() => _query = text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
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

  /// Bottom sheet with the space, type and tag filters (design sections
  /// 5.1 and 5.9: the three combine).
  Future<void> _openFilter() async {
    final l10n = AppLocalizations.of(context)!;
    final spaces = await ref.read(spaceRepositoryProvider).getSpaces();
    final allTags = await ref.read(tagRepositoryProvider).getTags();
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
                    : spaces
                        .where((s) => s.id == _spaceFilter)
                        .map((s) => s.name)
                        .firstOrNull ??
                    l10n.allLabel),
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
                title: Text(l10n.tagsLabel),
                subtitle: Text(
                  _tagFilter == null ? l10n.allLabel : '#$_tagFilter',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.label_outline),
                title: Text(l10n.allLabel),
                selected: _tagFilter == null,
                onTap: () {
                  setSheetState(() => _tagFilter = null);
                  setState(() {});
                },
              ),
              for (final tag in allTags)
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text('#${tag.name}'),
                  selected: _tagFilter == tag.name,
                  onTap: () {
                    setSheetState(() => _tagFilter = tag.name);
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchFilterTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
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
            selected: _spaceFilter != null ||
                _typeFilter != null ||
                _tagFilter != null,
            trailing: const Icon(Icons.chevron_right),
            onTap: _openFilter,
          ),
          Expanded(
            child: FutureBuilder<List<Task>>(
              // The query is built once per filter change instead of on
              // every keystroke, which used to restart the database read
              // and flash the spinner while typing.
              future: _tasksFuture(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tasks = (snapshot.data ?? [])
                    .where((t) =>
                        (_typeFilter == null || t.type == _typeFilter) &&
                        (_query.isEmpty ||
                            t.title.toLowerCase().contains(_query) ||
                            (t.notes ?? '').toLowerCase().contains(_query)))
                    .toList();
                if (_tagFilter == null) return _taskList(tasks, l10n);
                // Design section 5.9: the tag filter combines with the
                // space and type filters applied above.
                return FutureBuilder<Map<String, List<String>>>(
                  future: _tagsFuture(tasks),
                  builder: (context, tagSnapshot) {
                    final tagsByTask = tagSnapshot.data;
                    if (tagsByTask == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final tagged = tasks
                        .where((t) =>
                            (tagsByTask[t.id] ?? []).contains(_tagFilter))
                        .toList();
                    return _taskList(tagged, l10n);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// The tag lookup for [tasks], kept while the matching tasks stay the
  /// same, for the same reason as [_tasksFuture].
  Future<Map<String, List<String>>>? _cachedTags;
  String? _cachedTagsKey;

  Future<Map<String, List<String>>> _tagsFuture(List<Task> tasks) {
    final key = [for (final t in tasks) t.id].join(',');
    final cached = _cachedTags;
    if (cached != null && _cachedTagsKey == key) return cached;
    final future = ref.read(tagRepositoryProvider).tagsForTasks([
      for (final t in tasks) t.id,
    ]);
    _cachedTags = future;
    _cachedTagsKey = key;
    return future;
  }

  /// The task query, kept until the space filter changes.
  ///
  /// FutureBuilder rebuilds on every keystroke and state change, and an
  /// inline `future:` argument kicked off a fresh database read each time.
  /// The result is memoized here so only a real filter change reads again.
  Future<List<Task>>? _cachedTasks;
  String? _cachedSpaceKey;

  Future<List<Task>> _tasksFuture() {
    final key = _spaceFilter ?? '';
    final cached = _cachedTasks;
    if (cached != null && _cachedSpaceKey == key) return cached;
    final future = ref
        .read(taskRepositoryProvider)
        .getTasks(spaceId: _spaceFilter, includeInbox: false);
    _cachedTasks = future;
    _cachedSpaceKey = key;
    return future;
  }

  Widget _taskList(List<Task> tasks, AppLocalizations l10n) {
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
  }
}
