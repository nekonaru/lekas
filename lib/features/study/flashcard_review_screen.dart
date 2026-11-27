import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/flip_card.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/card_types.dart';
import '../../l10n/app_localizations.dart';

/// The review session: due cards one at a time, tap to flip, then grade.
/// Again (1) rebooks the card for tomorrow, Hard (3) keeps it on a short
/// leash, Easy (5) widens the interval. Progress counts the whole queue.
class FlashcardReviewScreen extends ConsumerStatefulWidget {
  const FlashcardReviewScreen({
    super.key,
    required this.spaceId,
    required this.deckName,
  });

  /// Null means the general deck.
  final String? spaceId;
  final String deckName;

  @override
  ConsumerState<FlashcardReviewScreen> createState() =>
      _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState
    extends ConsumerState<FlashcardReviewScreen> {
  List<FlashCard> _queue = const [];
  int _index = 0;
  bool _flipped = false;
  bool _loading = true;
  int _reviewed = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cards = await ref.read(flashcardRepositoryProvider).dueCards(widget.spaceId);
    if (!mounted) return;
    setState(() {
      _queue = cards;
      _loading = false;
    });
  }

  Future<void> _grade(int quality) async {
    final card = _queue[_index];
    await ref.read(flashcardRepositoryProvider).reviewCard(card, quality);
    if (!mounted) return;
    setState(() {
      _reviewed += 1;
      _flipped = false;
      _index += 1;
    });
  }

  Widget _face(FlashCard card, bool flipped, TextStyle? style) {
    if (card.kind == 'cloze') {
      return Text(
        flipped ? card.front.replaceFirst('____', card.back) : card.front,
        style: flipped
            ? style?.copyWith(color: const Color(0xFF10B981))
            : style,
        textAlign: TextAlign.center,
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Text(
        flipped ? card.back : card.front,
        key: ValueKey(flipped),
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deckName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final done = _index >= _queue.length;
    if (done) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deckName)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.reviewDoneTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(l10n.reviewDoneBody(_reviewed)),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.closeLabel),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final card = _queue[_index];
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _queue.isEmpty ? 0 : (_index / _queue.length),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.reviewProgress(_index + 1, _queue.length),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              // The card: a real 3D flip with the shared motion curve.
              Expanded(
                child: FlipCard(
                  key: ValueKey(card.id),
                  color: colors.primary,
                  front: _face(
                    card,
                    false,
                    Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                  ),
                  back: _face(
                    card,
                    true,
                    Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                  ),
                  onFlip: (shown) => setState(() => _flipped = shown),
                ),
              ),
              const SizedBox(height: 12),
              if (!_flipped)
                Text(
                  l10n.tapToFlip,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              const SizedBox(height: 12),
              if (card.kind == 'choice' && !_flipped) ...[
                Text(
                  l10n.choicePickPrompt,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final option in parseChoices(card.options))
                      ChoiceChip(
                        label: Text(option),
                        selected: false,
                        onSelected: (_) => choiceMatches(
                              card.options,
                              card.back,
                              option,
                            )
                            ? _grade(5)
                            : _grade(1),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: _GradeButton(
                      label: l10n.gradeForgot,
                      color: const Color(0xFFEF4444),
                      enabled: _flipped,
                      onTap: () => _grade(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GradeButton(
                      label: l10n.gradeHard,
                      color: const Color(0xFFF59E0B),
                      enabled: _flipped,
                      onTap: () => _grade(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GradeButton(
                      label: l10n.gradeEasy,
                      color: const Color(0xFF10B981),
                      enabled: _flipped,
                      onTap: () => _grade(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onTap : null,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withValues(alpha: 0.25),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
