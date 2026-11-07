import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

/// The space add and edit dialog, shared by the list and the detail
/// screen. Editing reuses the same name and code fields so a rename never
/// touches level, kind or the tasks already inside.
Future<void> showSpaceFormDialog(
  BuildContext context,
  WidgetRef ref, {
  Space? existing,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final nameController = TextEditingController(text: existing?.name ?? '');
  final codeController = TextEditingController(text: existing?.code ?? '');
  try {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? l10n.addSpace : l10n.editSpaceTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.spaceName),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: codeController,
              decoration: InputDecoration(labelText: l10n.spaceCode),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              final repo = ref.read(spaceRepositoryProvider);
              final code = codeController.text.isEmpty
                  ? null
                  : codeController.text;
              final now = DateTime.now().millisecondsSinceEpoch;
              if (existing == null) {
                final level = await ref.read(levelProvider.future);
                await repo.insertSpace(
                  Space(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    code: code,
                    color: AppTheme.containerColors[0].toARGB32(),
                    level: level,
                    kind: 'course',
                    archived: false,
                    sortOrder: 0,
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
              } else {
                await repo.updateSpace(
                  existing.copyWith(
                    name: nameController.text,
                    code: Value(code),
                    updatedAt: now,
                  ),
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  } finally {
    nameController.dispose();
    codeController.dispose();
  }
}
