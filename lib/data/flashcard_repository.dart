import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/sm2.dart';
import 'database.dart';

/// One row per deck for the deck list screen.
class DeckSummary {
  /// Null means the general deck (cards that belong to no subject).
  final String? spaceId;
  final int total;
  final int due;

  const DeckSummary({required this.spaceId, required this.total, required this.due});
}

/// Flashcards with their own SM-2 counters on the row (design: v1.16 study
/// tools). Reviews rewrite the row, so no separate log table exists.
class FlashcardRepository {
  FlashcardRepository(this.db);

  final AppDatabase db;

  Future<FlashCard> addCard({
    required String front,
    required String back,
    String? spaceId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final card = FlashCard(
      id: const Uuid().v4(),
      spaceId: spaceId,
      front: front,
      back: back,
      dueAt: now,
      intervalDays: 0,
      easeFactor: 2.5,
      repetitions: 0,
      lapses: 0,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
    await db.into(db.flashCards).insert(card);
    return card;
  }

  Future<void> updateCard(FlashCard card) async {
    await db.update(db.flashCards).replace(
          card.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch),
        );
  }

  Future<void> deleteCard(String id) async {
    await (db.update(db.flashCards)..where((t) => t.id.equals(id))).write(
      FlashCardsCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// All live cards of one deck, oldest first.
  Future<List<FlashCard>> cardsOf(String? spaceId) {
    return (db.select(db.flashCards)
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => spaceId == null ? t.spaceId.isNull() : t.spaceId.equals(spaceId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Cards due today in one deck, most overdue first.
  Future<List<FlashCard>> dueCards(String? spaceId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (db.select(db.flashCards)
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.dueAt.isSmallerOrEqualValue(now))
          ..where((t) => spaceId == null ? t.spaceId.isNull() : t.spaceId.equals(spaceId))
          ..orderBy([(t) => OrderingTerm.asc(t.dueAt)]))
        .get();
  }

  /// Deck summaries for the deck list: one row for the general deck first
  /// when it holds cards, then one row per subject that has cards.
  Future<List<DeckSummary>> summaries() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final cards = await (db.select(db.flashCards)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    final byDeck = <String?, DeckSummary>{};
    for (final card in cards) {
      final key = card.spaceId;
      final current = byDeck[key] ??
          DeckSummary(spaceId: key, total: 0, due: 0);
      byDeck[key] = DeckSummary(
        spaceId: key,
        total: current.total + 1,
        due: current.due + (card.dueAt <= now ? 1 : 0),
      );
    }
    final result = byDeck.values.toList()
      ..sort((a, b) {
        if (a.spaceId == null) return -1;
        if (b.spaceId == null) return 1;
        return a.spaceId!.compareTo(b.spaceId!);
      });
    return result;
  }

  /// Live count of due cards for the drawer badge; the cutoff is read at
  /// every emission so a long-lived drawer never goes stale.
  Stream<int> watchDueCount() {
    return (db.select(db.flashCards)..where((t) => t.deletedAt.isNull()))
        .watch()
        .map((rows) => rows
            .where((card) => card.dueAt <= DateTime.now().millisecondsSinceEpoch)
            .length);
  }

  /// Cards due right now across every deck.
  Future<List<FlashCard>> dueCardsAny() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (db.select(db.flashCards)
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.dueAt.isSmallerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.dueAt)]))
        .get();
  }

  /// Applies one SM-2 review and persists the new counters.
  Future<void> reviewCard(FlashCard card, int quality) async {
    final next = scheduleReview(
      repetitions: card.repetitions,
      intervalDays: card.intervalDays,
      easeFactor: card.easeFactor,
      quality: quality,
    );
    await db.update(db.flashCards).replace(card.copyWith(
          repetitions: next.repetitions,
          intervalDays: next.intervalDays,
          easeFactor: next.easeFactor,
          dueAt: next.dueAt,
          lapses: quality < 3 ? card.lapses + 1 : card.lapses,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ));
  }

  /// Total cards per state for the stats screen.
  Future<({int total, int due})> totals() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final all = await (db.select(db.flashCards)..where((t) => t.deletedAt.isNull())).get();
    final due = all.where((card) => card.dueAt <= now).length;
    return (total: all.length, due: due);
  }
}
