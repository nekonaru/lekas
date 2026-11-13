import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/components/bulk_action_bar.dart';
import '../../core/components/empty_state.dart';
import '../../core/components/selection_bottom_bar.dart';
import '../../core/components/undo_snackbar.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../inbox/inbox_screen.dart';
import 'space_detail_screen.dart';
import 'space_form_dialog.dart';

/// What the list shows: every space (the old manage view), the free,
/// semester-less categories (the Kategori tab), or the courses of the
/// active and past semesters (pushed from the Semester tab).
enum SpaceView { all, free, courses }

class SpacesScreen extends ConsumerStatefulWidget {
  const SpacesScreen({super.key, this.view = SpaceView.all, this.embedded = false});

  final SpaceView view;

  /// True inside the shell's tab body; the shell owns the app bar then.
  final bool embedded;

  @override
  ConsumerState<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends ConsumerState<SpacesScreen> {
  final Set<String> _selection = {};
  List<Space> _spaces = const [];

  /// Drag mode: long press selects everywhere else, so reordering needs
  /// its own mode (tap the reorder button, drag, tap again to done).
  bool _reordering = false;

  /// Which side of the archive switch the list shows.
  bool _showingArchive = false;

  @override
  void initState() {
    super.initState();
  }

  bool _inScope(Space space) {
    switch (widget.view) {
      case SpaceView.all:
        return true;
      case SpaceView.free:
        return space.semesterId == null;
      case SpaceView.courses:
        return space.semesterId != null;
    }
  }

  void _toggleSelection(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_selection.remove(id)) _selection.add(id);
    });
  }

  List<Space> get _picked =>
      _spaces.where((space) => _selection.contains(space.id)).toList();

  bool get _isFree => widget.view == SpaceView.free;

  String _addLabel(AppLocalizations l10n) {
    if (_isFree) return l10n.addCategory;
    return widget.view == SpaceView.courses ? l10n.addCourse : l10n.addSpace;
  }

  String _emptyMessage(AppLocalizations l10n) {
    if (_isFree) return l10n.kategoriEmpty;
    return l10n.emptySpaces;
  }

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

  /// One tap restore from the archive list.
  Future<void> _restore(Space space) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(spaceRepositoryProvider);
    final fresh = space.copyWith(
      archived: false,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await repo.updateSpace(fresh);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.spaceRestored)),
    );
  }

  /// Permanent delete with the confirm dialog: schedule, attendance, notes,
  /// grades and checklist children are removed with the space, and its
  /// tasks move to the inbox instead of disappearing.
  Future<void> _delete(Space space) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(spaceRepositoryProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteSpaceTitle),
        content: Text(l10n.deleteSpaceBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.deleteLabel,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await repo.deleteSpaceCascade(space.id);
    if (mounted) setState(() {});
  }

  /// The create dialog for the tab: a free-form name for a category or a
  /// course. Colors are derived from the name so the same name always
  /// gets the same avatar.
  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_addLabel(l10n)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.categoryNameLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(dialogContext, true);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    final name = controller.text.trim();
    // Let the exit animation of the dialog finish before disposing the
    // controller; dropping it right after pop crashes the closing frames.
    Future<void>.delayed(
      const Duration(milliseconds: 400),
      controller.dispose,
    );
    if (created != true || name.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final color = AppTheme.containerColors[name.hashCode.abs() %
        AppTheme.containerColors.length];
    // A course lands in the active semester; a category belongs to none.
    await ref.read(spaceRepositoryProvider).insertSpace(
          Space(
            id: const Uuid().v4(),
            name: name,
            color: color.toARGB32(),
            kind: _isFree ? 'category' : 'course',
            archived: false,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
            semesterId: null,
          ),
        );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(spaceRepositoryProvider);
    final selecting = _selection.isNotEmpty;

    final addLabel = _addLabel(l10n);
    final emptyMessage = _emptyMessage(l10n);

    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(title: Text(_isFree ? l10n.kategoriTitle : widget.view == SpaceView.courses ? l10n.mataKuliahTitle : l10n.spacesTitle)),
      // The stream keeps the rows in drag order from the table, so a
      // reorder writes the order and the list follows; it also means a
      // rename or archive anywhere else shows up at once.
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(l10n.archiveActive),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(l10n.archiveArchive),
                      ),
                    ],
                    selected: {_showingArchive},
                    onSelectionChanged: (selection) => setState(() {
                      _showingArchive = selection.first;
                      _selection.clear();
                    }),
                  ),
                ),
                if (!_showingArchive)
                  IconButton(
                    icon: Icon(_reordering ? Icons.check : Icons.reorder),
                    tooltip: l10n.reorderLabel,
                    onPressed: () =>
                        setState(() => _reordering = !_reordering),
                  ),
              ],
            ),
          ),
          if (widget.view == SpaceView.free && !_showingArchive)
            _UncategorizedRow(),
          Expanded(
            child: StreamBuilder<List<Space>>(
              stream: repo.watchSpaces(includeArchived: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final spaces = (snapshot.data ?? const <Space>[])
                    .where(_inScope)
                    .where((space) => space.archived == _showingArchive)
                    .toList();
                // The drag mutates this list directly for instant feedback;
                // the stream emission after the write carries the same order.
                _spaces = spaces;
                if (spaces.isEmpty) {
                  return _showingArchive
                      ? EmptyState(
                          message: l10n.archiveEmptyText,
                          icon: Icons.archive,
                        )
                      : EmptyState(
                          message: emptyMessage,
                          icon: _isFree ? Icons.folder_outlined : Icons.folder,
                        );
                }
                if (_showingArchive) {
                  return _archiveList(spaces);
                }
                return _activeList(spaces, selecting);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: selecting
          ? SelectionBottomBar(
              count: _selection.length,
              child: BulkSelectionBar(
                count: _selection.length,
                onSelectAll: () => setState(
                  () => _selection.addAll(_spaces.map((space) => space.id)),
                ),
                onArchive: _archiveSelected,
                onClose: () => setState(_selection.clear),
              ),
            )
          : null,
      floatingActionButton: selecting || _showingArchive
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                if (_isFree || widget.view == SpaceView.courses) {
                  await _create();
                } else {
                  await showSpaceFormDialog(context, ref);
                }
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.add),
              label: Text(addLabel),
            ),
    );
  }

  /// The active list: long-press select, dot-three menu, drag reorder,
  /// tap to open.
  Widget _activeList(List<Space> spaces, bool selecting) {
    if (_reordering) {
      return ReorderableListView.builder(
        itemCount: spaces.length,
        onReorderItem: (oldIndex, newIndex) async {
          setState(() {
            final moved = spaces.removeAt(oldIndex);
            spaces.insert(newIndex, moved);
          });
          await ref.read(spaceRepositoryProvider).setSpaceOrder(
                [for (final space in spaces) space.id],
              );
        },
        itemBuilder: (context, index) {
          final space = spaces[index];
          return ListTile(
            key: ValueKey('space:${space.id}'),
            leading: CircleAvatar(
              backgroundColor: Color(space.color),
              child: Text(
                space.name.isNotEmpty ? space.name[0] : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(space.name),
            subtitle: Text(space.code ?? ''),
            trailing: const Icon(Icons.drag_handle),
          );
        },
      );
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
              : IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _spaceMenu(space),
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
  }

  /// The archive list: restore or delete permanently, one row at a time.
  Widget _archiveList(List<Space> spaces) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      itemCount: spaces.length,
      itemBuilder: (context, index) {
        final space = spaces[index];
        return ListTile(
          key: ValueKey('space:${space.id}'),
          leading: CircleAvatar(
            backgroundColor: Color(space.color),
            child: Text(
              space.name.isNotEmpty ? space.name[0] : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(space.name),
          subtitle: Text(space.code ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.restore),
                tooltip: l10n.restoreLabel,
                onPressed: () => _restore(space),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                tooltip: l10n.deletePermanentlyLabel,
                onPressed: () => _delete(space),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpaceDetailScreen(spaceId: space.id),
              ),
            );
          },
        );
      },
    );
  }

  /// The three-dot menu of one active space: edit, archive, delete.
  /// The icon is the one other cards use, so it reads the same everywhere.
  void _spaceMenu(Space space) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.editSpaceTitle),
              onTap: () async {
                Navigator.pop(sheetContext);
                if (widget.view != SpaceView.all) {
                  await _rename(space);
                } else {
                  await showSpaceFormDialog(context, ref, existing: space);
                }
                if (mounted) setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(l10n.archiveLabel),
              onTap: () async {
                Navigator.pop(sheetContext);
                await ref.read(spaceRepositoryProvider).archiveSpace(space.id);
                if (!mounted) return;
                setState(() {});
                UndoSnackbar.show(
                  context,
                  l10n.spacesArchivedUndo(1),
                  () async {
                    final repo = ref.read(spaceRepositoryProvider);
                    await repo.updateSpace(space.copyWith(
                      archived: false,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    ));
                    if (mounted) setState(() {});
                  },
                );
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.delete_outline, color: colors.error),
              title: Text(
                l10n.deleteSpaceTitle,
                style: TextStyle(color: colors.error),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _delete(space);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Rename dialog for the category and course flows (no code field).
  Future<void> _rename(Space space) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: space.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editSpaceTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.categoryNameLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    final name = controller.text.trim();
    Future<void>.delayed(
      const Duration(milliseconds: 400),
      controller.dispose,
    );
    if (confirmed != true || name.isEmpty || name == space.name) return;
    await ref.read(spaceRepositoryProvider).updateSpace(
          space.copyWith(
            name: name,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }
}

/// The uncategorized row of the Kategori tab: the tasks that fell out of
/// every category land in the inbox, so the tab surfaces them here with
/// their open count instead of hiding them behind another screen.
class _UncategorizedRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);
    final colors = Theme.of(context).colorScheme;
    return StreamBuilder(
      stream: repo.watchTasks(includeInbox: true),
      builder: (context, snapshot) {
        final tasks = (snapshot.data ?? const <Task>[])
            .where((task) => task.inbox && task.status != 'done')
            .toList();
        return Material(
          color: colors.surfaceContainerLow,
          child: ListTile(
            leading: const Icon(Icons.inbox_outlined),
            title: Text(l10n.inboxTitle),
            subtitle: Text(tasks.isEmpty
                ? l10n.uncategorizedInfo
                : l10n.openTasksCount(tasks.length)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const InboxScreen(),
              ),
            ),
          ),
        );
      },
    );
  }
}
