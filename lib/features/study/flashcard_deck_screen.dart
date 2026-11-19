import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../core/components/empty_state.dart';
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
        appBar: AppBar(title: Text(titleSnapshot.data ?? l10n.flashcardsTitle)),
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

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final canSave = frontController.text.trim().isNotEmpty &&
            backController.text.trim().isNotEmpty;
        return AlertDialog(
          title: Text(existing == null ? l10n.addFlashcard : l10n.editFlashcard),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                        );
                      } else {
                        await repo.updateCard(existing.copyWith(
                          front: front,
                          back: back,
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
  });

  return saved == true;
}
