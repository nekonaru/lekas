import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'undo_snackbar.dart';

/// The bulk operations every task list shares: complete, delete, change
/// priority, move. They used to live only in the Today screen, so the other
/// lists could not manage tasks in bulk; every selection screen now calls
/// these, with the same transactions and the same undo banners.
class BulkActions {
  BulkActions._();

  /// Bulk complete with an undo, as required by design section 5.5.
  static Future<void> complete(
    BuildContext context,
    WidgetRef ref,
    List<Task> picked,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(taskRepositoryProvider);
    if (picked.isEmpty) return;
    // One transaction for the whole selection: a single commit instead of
    // one per task, and the stream reports the change once.
    await ref.read(appDatabaseProvider).transaction(() async {
      for (final task in picked) {
        await repository.markDone(task.id);
      }
    });
    if (!context.mounted) return;
    UndoSnackbar.show(context, l10n.taskCompletedUndo, () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await ref.read(appDatabaseProvider).transaction(() async {
        for (final task in picked) {
          await repository.updateTask(task.copyWith(
            status: 'todo',
            completedAt: const Value(null),
            updatedAt: now,
          ));
        }
      });
    });
  }

  /// Bulk soft delete with an undo that brings the tasks back.
  static Future<void> softDelete(
    BuildContext context,
    WidgetRef ref,
    List<Task> picked,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(taskRepositoryProvider);
    if (picked.isEmpty) return;
    await ref.read(appDatabaseProvider).transaction(() async {
      for (final task in picked) {
        await repository.softDeleteTask(task.id);
      }
    });
    if (!context.mounted) return;
    UndoSnackbar.show(context, l10n.tasksDeletedUndo(picked.length), () async {
      await ref.read(appDatabaseProvider).transaction(() async {
        for (final task in picked) {
          await repository.restoreTask(task.id);
        }
      });
    });
  }

  /// The priority picker for the picked tasks.
  static Future<void> pickPriority(
    BuildContext context,
    WidgetRef ref,
    List<Task> picked,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (picked.isEmpty) return;
    final priority = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(l10n.priorityLow),
              onTap: () => Navigator.pop(sheetContext, 0),
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: Text(l10n.priorityMedium),
              onTap: () => Navigator.pop(sheetContext, 1),
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: Text(l10n.priorityHigh),
              onTap: () => Navigator.pop(sheetContext, 2),
            ),
          ],
        ),
      ),
    );
    if (priority == null || !context.mounted) return;
    final repository = ref.read(taskRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    await ref.read(appDatabaseProvider).transaction(() async {
      for (final task in picked) {
        await repository
            .updateTask(task.copyWith(priority: priority, updatedAt: now));
      }
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.bulkUpdated(picked.length))),
    );
  }

  /// The destination picker: any space, or the inbox.
  static Future<void> pickSpace(
    BuildContext context,
    WidgetRef ref,
    List<Task> picked,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (picked.isEmpty) return;
    final spaces = await ref.read(spaceRepositoryProvider).getSpaces();
    if (!context.mounted) return;
    final spaceId = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(l10n.inboxTitle),
              onTap: () => Navigator.pop(sheetContext, ''),
            ),
            for (final space in spaces)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(space.name),
                onTap: () => Navigator.pop(sheetContext, space.id),
              ),
          ],
        ),
      ),
    );
    if (spaceId == null || !context.mounted) return;
    final repository = ref.read(taskRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    await ref.read(appDatabaseProvider).transaction(() async {
      for (final task in picked) {
        await repository.updateTask(task.copyWith(
          spaceId: Value(spaceId.isEmpty ? null : spaceId),
          inbox: spaceId.isEmpty,
          updatedAt: now,
        ));
      }
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.bulkUpdated(picked.length))),
    );
  }
}
