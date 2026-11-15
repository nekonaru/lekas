import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/empty_state.dart';
import '../../core/task_filter.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'search_filter_screen.dart';

/// Saved search views: each one stores a query plus category, type, tag,
/// status and sort of the Search & Filter screen, so a recurring view
/// (for example "overdue lab reports") is one tap away.
class SavedFilterScreen extends ConsumerStatefulWidget {
  const SavedFilterScreen({super.key});

  @override
  ConsumerState<SavedFilterScreen> createState() => _SavedFilterScreenState();
}

class _SavedFilterScreenState extends ConsumerState<SavedFilterScreen> {
  /// Decodes the saved query JSON; unknown enum values fall back to their
  /// defaults instead of throwing.
  SearchFilterScreen _decodedScreenFor(SavedFilter filter) {
    Map<String, dynamic> json = const {};
    try {
      json = jsonDecode(filter.queryJson) as Map<String, dynamic>;
    } catch (_) {
      json = const {};
    }

    TaskStatusFilter status;
    try {
      status = TaskStatusFilter.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => TaskStatusFilter.all,
      );
    } catch (_) {
      status = TaskStatusFilter.all;
    }

    TaskSort sort;
    try {
      sort = TaskSort.values.firstWhere(
        (value) => value.name == json['sort'],
        orElse: () => TaskSort.deadlineAsc,
      );
    } catch (_) {
      sort = TaskSort.deadlineAsc;
    }

    return SearchFilterScreen(
      initialSpaceId: json['spaceId'] as String?,
      initialTypeFilter: json['type'] as String?,
      initialTagFilter: json['tag'] as String?,
      initialStatus: status,
      initialSort: sort,
      initialQuery: json['query'] as String?,
    );
  }

  Future<void> _open(SavedFilter filter) async {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _decodedScreenFor(filter),
      ),
    );
  }

  Future<void> _delete(SavedFilter filter) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteSavedView),
        content: Text(filter.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(savedFilterRepositoryProvider).deleteSavedFilter(filter.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(savedFilterRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savedViewsTitle)),
      body: FutureBuilder<List<SavedFilter>>(
        // Future memoized on the const list so rebuilds do not requery.
        future: repo.getSavedFilters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final filters = snapshot.data ?? [];

          if (filters.isEmpty) {
            return EmptyState(
              message: l10n.emptySavedViews,
              icon: Icons.bookmark_border,
            );
          }
          return ListView.builder(
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              return ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text(filter.name),
                subtitle: Text(l10n.tapToOpenView),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.deleteLabel,
                  onPressed: () => _delete(filter),
                ),
                onTap: () => _open(filter),
              );
            },
          );
        },
      ),
    );
  }
}
