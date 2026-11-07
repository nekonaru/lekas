import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/bulk_action_bar.dart';
import '../../core/components/empty_state.dart';
import '../../core/components/undo_snackbar.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../tasks/wadah_non_matkul_screen.dart';
import 'space_detail_screen.dart';
import 'space_form_dialog.dart';

class SpacesScreen extends ConsumerStatefulWidget {
  const SpacesScreen({super.key});

  @override
  ConsumerState<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends ConsumerState<SpacesScreen> {
  final Set<String> _selection = {};
  List<Space> _spaces = const [];

  void _toggleSelection(String id) {
    setState(() {
      if (!_selection.remove(id)) _selection.add(id);
    });
  }

  List<Space> get _picked =>
      _spaces.where((space) => _selection.contains(space.id)).toList();

  /// Bulk archive with an undo that brings the spaces back.
  Future<void> _archiveSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(spaceRepositoryProvider);
    final picked = _picked;
    setState(_selection.clear);
    await ref.read(appDatabaseProvider).transaction(() async {
      for (final space in picked) {
        await repo.archiveSpace(space.id);
      }
    });
    if (!mounted) return;
    UndoSnackbar.show(context, l10n.spacesArchivedUndo(picked.length), () async {
      await ref.read(appDatabaseProvider).transaction(() async {
        for (final space in picked) {
          await repo.updateSpace(space.copyWith(
            archived: false,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ));
        }
      });
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(spaceRepositoryProvider);
    final selecting = _selection.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(selecting
            ? l10n.selectedCount(_selection.length)
            : l10n.spacesTitle),
        actions: [
          if (selecting)
            BulkSelectionBar(
              count: _selection.length,
              onSelectAll: () => setState(
                () => _selection.addAll(_spaces.map((space) => space.id)),
              ),
              onArchive: _archiveSelected,
              onClose: () => setState(_selection.clear),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await showSpaceFormDialog(context, ref);
                if (mounted) setState(() {});
              },
              tooltip: l10n.addSpace,
            ),
            IconButton(
              icon: const Icon(Icons.category_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const WadahNonMatkulScreen(),
                  ),
                );
              },
              tooltip: l10n.nonCourseSpaceTitle,
            ),
          ],
        ],
      ),
      body: FutureBuilder<List<Space>>(
        future: repo.getSpaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final spaces = snapshot.data ?? [];
          _spaces = spaces;
          if (spaces.isEmpty) {
            return EmptyState(message: l10n.emptySpaces, icon: Icons.folder);
          }
          return ListView.builder(
            itemCount: spaces.length,
            itemBuilder: (context, index) {
              final space = spaces[index];
              final selected = _selection.contains(space.id);
              return ListTile(
                key: ValueKey('space:${space.id}'),
                selected: selected,
                leading: selected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : CircleAvatar(
                        backgroundColor: Color(space.color),
                        child: Text(
                          space.name.isNotEmpty ? space.name[0] : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                title: Text(space.name),
                subtitle: Text(space.code ?? ''),
                trailing: selecting
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: l10n.editSpaceTitle,
                            onPressed: () async {
                              await showSpaceFormDialog(context, ref,
                                  existing: space);
                              if (mounted) setState(() {});
                            },
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                onTap: selecting
                    ? () => _toggleSelection(space.id)
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SpaceDetailScreen(spaceId: space.id),
                          ),
                        );
                      },
                onLongPress: () => _toggleSelection(space.id),
              );
            },
          );
        },
      ),
      floatingActionButton: selecting
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await showSpaceFormDialog(context, ref);
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.addSpace),
            ),
    );
  }
}
