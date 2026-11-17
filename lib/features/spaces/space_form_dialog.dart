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
  final level = existing?.level ?? await ref.read(levelProvider.future);
  final isSchool = level == 'school';
  final isCollege = level == 'college';
  final isCategory = (existing?.kind ?? kind) == 'category';
  final repo = ref.read(spaceRepositoryProvider);
  // School spaces carry a class year in meta, not in the table, so no
  // schema change is needed for SMA mode.
  final classYearInitial = !isCategory && isSchool && existing != null
      ? await repo.getMeta(existing.id, 'class_year')
      : null;
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
  var classYear = classYearInitial;

  if (!context.mounted) return;
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
              if (isSchool && !isCategory) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.classYearLabel.toUpperCase(),
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
                  spacing: 8,
                  children: [
                    for (final year in const ['10', '11', '12'])
                      ChoiceChip(
                        label: Text(year),
                        selected: classYear == year,
                        onSelected: (selected) => setDialogState(
                          () => classYear = selected ? year : null,
                        ),
                      ),
                  ],
                ),
              ],
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
                final newId = const Uuid().v4();
                await repo.insertSpace(
                  Space(
                    id: newId,
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
                if (isSchool && !isCategory) {
                  await repo.setMeta(newId, 'class_year', classYear);
                }
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
                if (isSchool && !isCategory) {
                  await repo.setMeta(existing.id, 'class_year', classYear);
                }
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
