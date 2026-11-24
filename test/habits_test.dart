import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/habits.dart';

void main() {
  test('dayKeyOf formats the local day with padding', () {
    expect(dayKeyOf(DateTime(2026, 1, 5)), '2026-01-05');
    expect(dayKeyOf(DateTime(2026, 12, 31)), '2026-12-31');
  });

  test('dayFromKey round-trips valid keys and rejects garbage', () {
    expect(dayFromKey('2026-11-17'), DateTime(2026, 11, 17));
    expect(dayFromKey('2026-13-01'), isNull);
    expect(dayFromKey('hello'), isNull);
    expect(dayFromKey(''), isNull);
  });

  test('lastNDayKeys ends at the given day, oldest first', () {
    final keys = lastNDayKeys(3, end: DateTime(2026, 11, 17));
    expect(keys, ['2026-11-15', '2026-11-16', '2026-11-17']);
  });

  test('habitStreak counts today and walks back consecutive days', () {
    final today = DateTime(2026, 11, 17);
    expect(
      habitStreak(const ['2026-11-15', '2026-11-16', '2026-11-17'], today: today),
      3,
    );
    // A gap breaks the chain.
    expect(
      habitStreak(const ['2026-11-14', '2026-11-16', '2026-11-17'], today: today),
      2,
    );
  });

  test('habitStreak holds when today has no check yet', () {
    final today = DateTime(2026, 11, 17);
    expect(
      habitStreak(const ['2026-11-15', '2026-11-16'], today: today),
      2,
    );
    expect(habitStreak(const [], today: today), 0);
  });

  test('habitWindowCount counts only the window', () {
    final end = DateTime(2026, 11, 17);
    expect(
      habitWindowCount(
        const ['2026-11-01', '2026-11-15', '2026-11-16', '2026-11-17'],
        end: end,
        days: 7,
      ),
      3,
    );
  });

  test('nextDailyReminder picks the next future occurrence', () {
    expect(
      nextDailyReminder(DateTime(2026, 11, 17, 8), 20, 0),
      DateTime(2026, 11, 17, 20, 0),
    );
    expect(
      nextDailyReminder(DateTime(2026, 11, 17, 21), 20, 0),
      DateTime(2026, 11, 18, 20, 0),
    );
    expect(
      nextDailyReminder(DateTime(2026, 11, 17, 20, 0), 20, 0),
      DateTime(2026, 11, 18, 20, 0),
    );
  });
}
