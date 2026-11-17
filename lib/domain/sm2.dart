/// Spaced repetition scheduling (SM-2 variant) for the study flashcards.
/// Pure functions so the algorithm is testable without a database.
///
/// Quality scale used by the review UI: 5 = remembered with ease,
/// 3 = remembered with effort, 1 = forgotten. The stored counters follow
/// the classic SM-2 shape: repetitions, interval in days and an ease
/// factor that never drops below 1.3.
class Sm2Schedule {
  const Sm2Schedule({
    required this.repetitions,
    required this.intervalDays,
    required this.easeFactor,
    required this.dueAt,
  });

  /// How many consecutive successful recalls (quality >= 3) so far.
  final int repetitions;

  /// Days until the card is due again.
  final int intervalDays;

  /// Ease factor, never below 1.3.
  final double easeFactor;

  /// When the card should be shown again, epoch milliseconds at day precision.
  final int dueAt;
}

/// Reschedules one card after a review of [quality] (0-5).
///
/// A quality below 3 resets the repetition count and books the card for
/// tomorrow. The ease factor decays towards 1.3 on hard answers and grows
/// on easy ones. [now] is injectable for tests.
Sm2Schedule scheduleReview({
  required int repetitions,
  required int intervalDays,
  required double easeFactor,
  required int quality,
  DateTime? now,
}) {
  final q = quality.clamp(0, 5);
  final current = now ?? DateTime.now();

  var ease = easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
  if (ease < 1.3) ease = 1.3;

  int reps;
  int interval;
  if (q < 3) {
    reps = 0;
    interval = 1;
  } else {
    reps = repetitions + 1;
    if (reps == 1) {
      interval = 1;
    } else if (reps == 2) {
      interval = 6;
    } else {
      interval = (intervalDays * ease).round().clamp(1, 36500);
    }
  }

  final due = DateTime(current.year, current.month, current.day)
      .add(Duration(days: interval));
  return Sm2Schedule(
    repetitions: reps,
    intervalDays: interval,
    easeFactor: ease,
    dueAt: due.millisecondsSinceEpoch,
  );
}

/// Whether a card is due right now (epoch millisecond comparison).
bool isCardDue(int dueAt, [DateTime? now]) =>
    dueAt <= (now ?? DateTime.now()).millisecondsSinceEpoch;
