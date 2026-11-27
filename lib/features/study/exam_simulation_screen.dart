import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/card_types.dart';
import '../../l10n/app_localizations.dart';

/// A short exam simulation built from multiple-choice cards of one deck.
/// No timer is started until the first answer, and the result stays local.
class ExamSimulationScreen extends ConsumerStatefulWidget {
  const ExamSimulationScreen({super.key, required this.spaceId});

  final String? spaceId;

  @override
  ConsumerState<ExamSimulationScreen> createState() =>
      _ExamSimulationScreenState();
}

class _ExamSimulationScreenState extends ConsumerState<ExamSimulationScreen> {
  late Future<List<FlashCard>> _cards;
  int _index = 0;
  int _correct = 0;

  @override
  void initState() {
    super.initState();
    _cards = _load();
  }

  Future<List<FlashCard>> _load() async {
    final repo = ref.read(flashcardRepositoryProvider);
    final cards = await repo.cardsOf(widget.spaceId);
    return cards.where((card) => card.kind == 'choice').take(20).toList();
  }

  void _answer(FlashCard card, String option) {
    if (choiceMatches(card.options, card.back, option)) _correct += 1;
    setState(() => _index += 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.examSimulationTitle)),
      body: FutureBuilder<List<FlashCard>>(
        future: _cards,
        builder: (context, snapshot) {
          final cards = snapshot.data;
          if (cards == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cards.isEmpty || _index >= cards.length) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.grade_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.examSimulationScore(_correct, cards.length),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(() {
                      _index = 0;
                      _correct = 0;
                    }),
                    child: Text(l10n.retryLabel),
                  ),
                ],
              ),
            );
          }
          final card = cards[_index];
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.reviewProgress(_index + 1, cards.length),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  card.front,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 24),
                for (final option in parseChoices(card.options))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton(
                      onPressed: () => _answer(card, option),
                      child: Text(option),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
