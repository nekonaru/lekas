import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../core/components/empty_state.dart';
import '../../domain/card_types.dart';
import '../../domain/csv.dart';
import '../../l10n/app_localizations.dart';
import 'flashcard_review_screen.dart';

/// One deck: the review call to action on top, the cards below, edit and
/// delete per row. The subject name comes from the spaces table.
class FlashcardDeckScreen extends ConsumerStatefulWidget {
  const FlashcardDeckScreen({super.key, required this.spaceId});

  /// Null means the general deck.
  final String? spaceId;

  @override
  ConsumerState<FlashcardDeckScreen> createState() =>
      _FlashcardDeckScreenState();
}

class _FlashcardDeckScreenState extends ConsumerState<FlashcardDeckScreen> {
  late Future<List<FlashCard>> _cards;
  late Future<String> _title;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final repo = ref.read(flashcardRepositoryProvider);
    _cards = repo.cardsOf(widget.spaceId);
    _title = _deckTitle();
  }

  Future<String> _deckTitle() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.spaceId == null) return l10n.generalDeckLabel;
    try {
      final space =
          await ref.read(spaceRepositoryProvider).getSpace(widget.spaceId!);
      return space.name;
    } on StateError {
      return l10n.generalDeckLabel;
    }
  }

  Future<void> _confirmDelete(FlashCard card) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteCardTitle),
        content: Text(l10n.deleteCardBody),
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
    if (confirmed != true) return;
    await ref.read(flashcardRepositoryProvider).deleteCard(card.id);
    if (mounted) setState(_reload);
  }

  Future<void> _editCard(FlashCard card) async {
    final saved = await showFlashcardEditor(
      context,
      ref,
      spaceId: widget.spaceId,
      existing: card,
    );
    if (saved && mounted) setState(_reload);
  }

  Future<void> _addCard() async {
    final saved =
        await showFlashcardEditor(context, ref, spaceId: widget.spaceId);
    if (saved && mounted) setState(_reload);
  }

  /// Share this deck as a two-column CSV (front, back) so a subject's
  /// cards can be moved or shared as a plain file.
  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final cards = await ref.read(flashcardRepositoryProvider).cardsOf(widget.spaceId);
    final buffer = StringBuffer('\uFEFF');
    buffer.write(csvRow(const ['front', 'back', 'kind', 'options']));
    for (final card in cards) {
      buffer.write(csvRow([
        card.front,
        card.back,
        card.kind,
        card.options ?? '',
      ]));
    }
    try {
      final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/lekas-kartu.csv',
      );
      await file.writeAsString(buffer.toString(), encoding: utf8);
      await Share.shareXFiles([XFile(file.path)], subject: l10n.flashcardsTitle);
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.csvExportFailed)));
      }
    }
  }

  /// Add cards from a CSV with front and back columns to this deck.
  Future<void> _importCsv() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
      withData: true,
    );
    final bytes = result?.files.singleOrNull?.bytes;
    if (bytes == null) return;

    final String content;
    try {
      content = utf8.decode(bytes);
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.flashcardsImportInvalid)),
      );
      return;
    }
    final rows = parseCsv(content);
    if (rows.length < 2) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.flashcardsImportInvalid)),
      );
      return;
    }
    final header = rows.first
        .map((cell) => cell.trim().toLowerCase().replaceAll(' ', '_'))
        .toList();
    final frontCol = header.indexOf('front');
    final backCol = header.indexOf('back');
    if (frontCol < 0 || backCol < 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.flashcardsImportInvalid)),
      );
      return;
    }
    final kindCol = header.indexOf('kind');
    final optionsCol = header.indexOf('options');
    final pairs = <(String, String, String, String?)>[];
    for (final row in rows.skip(1)) {
      final front = frontCol < row.length ? row[frontCol].trim() : '';
      final back = backCol < row.length ? row[backCol].trim() : '';
      if (front.isEmpty || back.isEmpty) continue;
      final rawKind = kindCol >= 0 && kindCol < row.length
          ? row[kindCol].trim().toLowerCase()
          : 'qa';
      final kind = kCardKinds.contains(rawKind) ? rawKind : 'qa';
      final rawOptions = optionsCol >= 0 && optionsCol < row.length
          ? row[optionsCol].trim()
          : '';
      pairs.add((
        front.length > 500 ? front.substring(0, 500) : front,
        back.length > 500 ? back.substring(0, 500) : back,
        kind,
        kind == 'choice' && rawOptions.isNotEmpty ? rawOptions : null,
      ));
    }
    if (pairs.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.flashcardsImported(0))),
      );
      return;
    }
    final limited = pairs.take(500).toList();
    final capped = pairs.length > limited.length;

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.flashcardsImport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.flashcardsImportConfirm(limited.length)),
            if (capped) ...[
              const SizedBox(height: 8),
              Text(
                l10n.flashcardsImportCap,
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.importFileLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final repo = ref.read(flashcardRepositoryProvider);
    for (final (front, back, kind, options) in limited) {
      await repo.addCard(
        front: front,
        back: back,
        spaceId: widget.spaceId,
        kind: kind,
        options: options,
      );
    }
    if (!mounted) return;
    setState(_reload);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.flashcardsImported(limited.length))),
    );
  }

  Future<void> _review() async {
    final title = await _title;
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FlashcardReviewScreen(
          spaceId: widget.spaceId,
          deckName: title,
        ),
      ),
    );
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return FutureBuilder<String>(
      future: _title,
      builder: (context, titleSnapshot) => Scaffold(
        appBar: AppBar(
          title: Text(titleSnapshot.data ?? l10n.flashcardsTitle),
          actions: [
            IconButton(
              tooltip: l10n.flashcardsExport,
              icon: const Icon(Icons.ios_share_outlined),
              onPressed: _exportCsv,
            ),
            IconButton(
              tooltip: l10n.flashcardsImport,
              icon: const Icon(Icons.file_download_outlined),
              onPressed: _importCsv,
            ),
          ],
        ),
        body: FutureBuilder<List<FlashCard>>(
          future: _cards,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final cards = snapshot.data ?? const <FlashCard>[];
            final now = DateTime.now().millisecondsSinceEpoch;
            final due = cards.where((card) => card.dueAt <= now).length;

            if (cards.isEmpty) {
              return EmptyState(
                message: l10n.emptyDeckBody,
                icon: Icons.style_outlined,
              );
            }

            return Column(
              children: [
                if (due > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Material(
                      color: colors.primaryContainer.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: Icon(
                          Icons.replay_outlined,
                          color: colors.onPrimaryContainer,
                        ),
                        title: Text(
                          l10n.deckDueSummary(due, cards.length),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                        trailing: FilledButton(
                          onPressed: _review,
                          child: Text(l10n.reviewDeckAction),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    itemCount: cards.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final isDue = card.dueAt <= DateTime.now().millisecondsSinceEpoch;
                      return Material(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(18),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                          title: Text(
                            card.front,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(card.back, maxLines: 2),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isDue)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              IconButton(
                                tooltip: l10n.editFlashcard,
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _editCard(card),
                              ),
                              IconButton(
                                tooltip: l10n.deleteLabel,
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () => _confirmDelete(card),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addCard,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

/// The card editor: front and back, filled enough to save. Returns true
/// when a card was saved.
Future<bool> showFlashcardEditor(
  BuildContext context,
  WidgetRef ref, {
  required String? spaceId,
  FlashCard? existing,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final frontController = TextEditingController(text: existing?.front ?? '');
  final backController = TextEditingController(text: existing?.back ?? '');
  final optionsController =
      TextEditingController(text: existing?.options ?? '');
  var kind = existing?.kind ?? 'qa';

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final canSave = frontController.text.trim().isNotEmpty &&
            backController.text.trim().isNotEmpty &&
            (kind != 'choice' || optionsController.text.trim().isNotEmpty);
        return AlertDialog(
          title: Text(existing == null ? l10n.addFlashcard : l10n.editFlashcard),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: kind,
                  decoration: InputDecoration(
                    labelText: l10n.cardTypeLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'qa',
                      child: Text(l10n.typeQuestionAnswer),
                    ),
                    DropdownMenuItem(
                      value: 'cloze',
                      child: Text(l10n.typeCloze),
                    ),
                    DropdownMenuItem(
                      value: 'choice',
                      child: Text(l10n.typeChoice),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => kind = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: frontController,
                  minLines: 1,
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.flashcardFront,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                if (kind == 'cloze') ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.clozeHint,
                    style: Theme.of(dialogContext).textTheme.bodySmall,
                  ),
                ],
                if (kind == 'choice') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: optionsController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.optionsLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: backController,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: l10n.flashcardBack,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: canSave
                  ? () async {
                      final repo = ref.read(flashcardRepositoryProvider);
                      final front = frontController.text.trim();
                      final back = backController.text.trim();
                      if (existing == null) {
                        await repo.addCard(
                          front: front,
                          back: back,
                          spaceId: spaceId,
                          kind: kind,
                          options: kind == 'choice'
                              ? optionsController.text.trim()
                              : null,
                        );
                      } else {
                        await repo.updateCard(existing.copyWith(
                          front: front,
                          back: back,
                          kind: kind,
                          options: Value(kind == 'choice'
                              ? optionsController.text.trim()
                              : null),
                        ));
                      }
                      if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                    }
                  : null,
              child: Text(l10n.flashcardSave),
            ),
          ],
        );
      },
    ),
  );

  // Let the dialog close fully before disposing its controllers.
  Future<void>.delayed(const Duration(milliseconds: 400), () {
    frontController.dispose();
    backController.dispose();
    optionsController.dispose();
  });

  return saved == true;
}
