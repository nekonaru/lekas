import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/components/empty_state.dart';
import '../../core/components/undo_snackbar.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

/// The per course bring list: what to pack for the next class, kept per
/// space and editable item by item (design section 5.32).
class DaftarBawaanScreen extends ConsumerStatefulWidget {
  const DaftarBawaanScreen({
    super.key,
    required this.spaceId,
    required this.spaceName,
  });

  final String spaceId;
  final String spaceName;

  @override
  ConsumerState<DaftarBawaanScreen> createState() => _DaftarBawaanScreenState();
}

class _DaftarBawaanScreenState extends ConsumerState<DaftarBawaanScreen> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String get _today => DateTime.now().toIso8601String().split('T').first;

  Future<String?> _pickTitle({String? initial}) async {
    final l10n = AppLocalizations.of(context)!;
    _titleController.text = initial ?? '';
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(initial == null ? l10n.addBringItem : l10n.editBringItem),
        content: TextField(
          controller: _titleController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.bringItemLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = _titleController.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(dialogContext, text);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    _titleController.clear();
    return result;
  }

  Future<void> _add() async {
    final title = await _pickTitle();
    if (title == null) return;
    await ref.read(spaceItemRepositoryProvider).insertSpaceItem(
          SpaceItem(
            id: const Uuid().v4(),
            spaceId: widget.spaceId,
            title: title,
            sortOrder: 0,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    if (mounted) setState(() {});
  }

  Future<void> _edit(SpaceItem item) async {
    final title = await _pickTitle(initial: item.title);
    if (title == null) return;
    await ref.read(spaceItemRepositoryProvider).updateSpaceItem(
          item.copyWith(
            title: title,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    if (mounted) setState(() {});
  }

  Future<void> _toggle(SpaceItem item) async {
    await ref.read(spaceItemRepositoryProvider).updateSpaceItem(
          item.copyWith(
            checkedOn: Value(item.checkedOn == null ? _today : null),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    if (mounted) setState(() {});
  }

  Future<void> _delete(SpaceItem item) async {
    final repo = ref.read(spaceItemRepositoryProvider);
    await repo.deleteSpaceItem(item.id);
    if (!mounted) return;
    setState(() {});
    UndoSnackbar.show(
      context,
      AppLocalizations.of(context)!.bringItemDeleted,
      () async {
        await repo.updateSpaceItem(
          item.copyWith(
            deletedAt: const Value(null),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(spaceItemRepositoryProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.defaultChecklistShort),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addBringItem,
            onPressed: _add,
          ),
        ],
      ),
      body: StreamBuilder<List<SpaceItem>>(
        stream: repo.watchSpaceItems(widget.spaceId),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <SpaceItem>[];
          final checked = items.where((item) => item.checkedOn != null).length;
          if (items.isEmpty) {
            return EmptyState(
              message: l10n.emptyBringList(widget.spaceName),
              icon: Icons.inventory_2_outlined,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.spaceName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '$checked/${items.length}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: items.length,
                  onReorderItem: (oldIndex, newIndex) async {
                    setState(() {
                      final moved = items.removeAt(oldIndex);
                      items.insert(newIndex, moved);
                    });
                    await repo.setSpaceItemOrder(
                      [for (final item in items) item.id],
                    );
                  },
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final done = item.checkedOn != null;
                    return ListTile(
                      key: ValueKey('bring:${item.id}'),
                      leading: IconButton(
                        icon: Icon(
                          done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: done ? colors.primary : null,
                        ),
                        tooltip: l10n.markLabel,
                        onPressed: () => _toggle(item),
                      ),
                      title: Text(
                        item.title,
                        style: done
                            ? const TextStyle(
                                decoration: TextDecoration.lineThrough,
                              )
                            : null,
                      ),
                      subtitle: done ? Text(l10n.broughtLabel) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: l10n.editBringItem,
                            onPressed: () => _edit(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: l10n.deleteLabel,
                            onPressed: () => _delete(item),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle),
                          ),
                        ],
                      ),
                      onTap: () => _toggle(item),
                      onLongPress: () => _edit(item),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text(l10n.addBringItem),
      ),
    );
  }
}
