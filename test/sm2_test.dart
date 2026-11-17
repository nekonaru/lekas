import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/sm2.dart';

void main() {
  final monday = DateTime(2026, 11, 16);

  test('a forgotten card rebooks for tomorrow and resets repetitions', () {
    final result = scheduleReview(
      repetitions: 4,
      intervalDays: 30,
      easeFactor: 2.5,
      quality: 1,
      now: monday,
    );
    expect(result.repetitions, 0);
    expect(result.intervalDays, 1);
    expect(result.dueAt, monday.add(const Duration(days: 1)).millisecondsSinceEpoch);
    expect(result.easeFactor, lessThan(2.5));
  });

  test('the first two successful reviews use the fixed steps', () {
    final first = scheduleReview(
      repetitions: 0,
      intervalDays: 0,
      easeFactor: 2.5,
      quality: 5,
      now: monday,
    );
    expect(first.intervalDays, 1);
    expect(first.repetitions, 1);

    final second = scheduleReview(
      repetitions: first.repetitions,
      intervalDays: first.intervalDays,
      easeFactor: first.easeFactor,
      quality: 5,
      now: monday,
    );
    expect(second.intervalDays, 6);
    expect(second.repetitions, 2);
  });

  test('later intervals scale with the ease factor', () {
    // Ease grows by 0.1 on a quality 5 answer, so 6 days becomes
    // round(6 * 2.6) = 16 days.
    final result = scheduleReview(
      repetitions: 2,
      intervalDays: 6,
      easeFactor: 2.5,
      quality: 5,
      now: monday,
    );
    expect(result.intervalDays, 16);
    expect(result.easeFactor, closeTo(2.6, 1e-9));
    expect(result.dueAt, monday.add(const Duration(days: 16)).millisecondsSinceEpoch);
  });

  test('the ease factor never drops below 1.3', () {
    var ease = 2.5;
    var reps = 0;
    var interval = 0;
    for (var i = 0; i < 30; i++) {
      final result = scheduleReview(
        repetitions: reps,
        intervalDays: interval,
        easeFactor: ease,
        quality: 0,
        now: monday,
      );
      ease = result.easeFactor;
      reps = result.repetitions;
      interval = result.intervalDays;
    }
    expect(ease, greaterThanOrEqualTo(1.3));
  });

  test('a hard answer still schedules forward but keeps the leash short', () {
    final result = scheduleReview(
      repetitions: 5,
      intervalDays: 20,
      easeFactor: 2.5,
      quality: 3,
      now: monday,
    );
    expect(result.repetitions, 6);
    expect(result.intervalDays, greaterThan(1));
  });

  test('isCardDue compares against the injected clock', () {
    final now = DateTime(2026, 11, 16, 12);
    expect(isCardDue(now.millisecondsSinceEpoch, now), isTrue);
    expect(isCardDue(now.add(const Duration(days: 1)).millisecondsSinceEpoch, now), isFalse);
  });
}
