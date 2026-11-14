import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

/// The space form: name, color and, for courses, code, SKS and target
/// grade. Used for both adding (the FAB of Kategori and Courses) and
/// editing, so one shape of sheet covers the whole lifecycle.
Future<void> showSpaceFormDialog(
  BuildContext context,
  WidgetRef ref, {
  Space? existing,
  String kind = 'course',
}) async {
  final l10n = AppLocalizations.of(context)!;
  final isCollege = existing?.level == null
      ? true
      : existing!.level == 'college';
  final isCategory = (existing?.kind ?? kind) == 'category';
  final nameController =
      TextEditingController(text: existing?.name ?? '');
  final codeController =
      TextEditingController(text: existing?.code ?? '');
  final sksController =
      TextEditingController(text: existing?.sks?.toString() ?? '');
  final targetController =
      TextEditingController(text: existing?.targetGrade ?? '');
  var color =
      existing?.color ?? AppTheme.containerColors.first.toARGB32();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(
          existing == null
              ? (isCategory ? l10n.addCategory : l10n.addSpace)
              : l10n.editSpaceTitle,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.spaceName,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (!isCategory) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: l10n.spaceCode,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                l10n.colorLabel,
                style: Theme.of(dialogContext)
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color:
                          Theme.of(dialogContext).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final swatch in AppTheme.containerColors)
                    GestureDetector(
                      onTap: () =>
                          setDialogState(() => color = swatch.toARGB32()),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: swatch,
                          border: color == swatch.toARGB32()
                              ? Border.all(
                                  color: Theme.of(dialogContext)
                                      .colorScheme
                                      .onSurface,
                                  width: 2.5,
                                )
                              : null,
                        ),
                        child: color == swatch.toARGB32()
                            ? const Icon(Icons.check,
                                size: 20, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
              if (isCollege && !isCategory) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.targetGradeFieldLabel.toUpperCase(),
                  style: Theme.of(dialogContext)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color:
                            Theme.of(dialogContext).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sksController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'SKS',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: targetController,
                        decoration: InputDecoration(
                          labelText: l10n.targetGradeFieldLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final repo = ref.read(spaceRepositoryProvider);
              final code = codeController.text.trim().isEmpty
                  ? null
                  : codeController.text.trim();
              final sks = isCollege
                  ? int.tryParse(sksController.text.trim())
                  : null;
              final targetGrade =
                  targetController.text.trim().isEmpty
                      ? null
                      : targetController.text.trim();
              final now = DateTime.now().millisecondsSinceEpoch;
              if (existing == null) {
                final level = await ref.read(levelProvider.future);
                await repo.insertSpace(
                  Space(
                    id: const Uuid().v4(),
                    name: name,
                    code: code,
                    color: color,
                    level: level,
                    sks: sks,
                    targetGrade: targetGrade,
                    kind: kind,
                    archived: false,
                    sortOrder: 0,
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
              } else {
                await repo.updateSpace(
                  existing.copyWith(
                    name: name,
                    code: Value(code),
                    color: color,
                    sks: Value(sks),
                    targetGrade: Value(targetGrade),
                    updatedAt: now,
                  ),
                );
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    ),
  );

  // The exit animation holds the fields for a beat; dispose after it.
  Future<void>.delayed(
    const Duration(milliseconds: 400),
    () {
      nameController.dispose();
      codeController.dispose();
      sksController.dispose();
      targetController.dispose();
    },
  );
}
