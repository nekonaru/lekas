import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/urgency.dart';

void main() {
  test('urgency score positive for future deadline', () {
    final now = DateTime(2026, 1, 1, 12);
    final dl = now.add(const Duration(hours: 6));
    final s = urgencyScore(now: now, deadline: dl, priority: 2, weightPercent: 30);
    expect(s, greaterThan(0));
  });
  test('no deadline returns 0', () {
    final s = urgencyScore(now: DateTime.now(), deadline: null, priority: 1);
    expect(s, 0);
  });

  group('short reason shown on every card (design section 4.4)', () {
    final now = DateTime(2026, 1, 1, 12);

    test('a past deadline is overdue', () {
      expect(
        urgencyReason(
          now: now,
          deadline: now.subtract(const Duration(hours: 2)),
          priority: 1,
        ),
        UrgencyReason.overdue,
      );
    });

    test('a deadline six hours away is due soon', () {
      expect(
        urgencyReason(
          now: now,
          deadline: now.add(const Duration(hours: 6)),
          priority: 1,
          weightPercent: 30,
        ),
        UrgencyReason.dueSoon,
      );
    });

    test('a weight of 60 or more outranks priority', () {
      expect(
        urgencyReason(
          now: now,
          deadline: now.add(const Duration(days: 3)),
          priority: 2,
          weightPercent: 60,
        ),
        UrgencyReason.heavyWeight,
      );
      expect(
        urgencyReason(
          now: now,
          deadline: now.add(const Duration(days: 3)),
          priority: 2,
          weightPercent: 30,
        ),
        UrgencyReason.highPriority,
      );
    });

    test('an estimate longer than the time left is tight', () {
      expect(
        urgencyReason(
          now: now,
          deadline: now.add(const Duration(days: 3)),
          priority: 1,
          weightPercent: 30,
          estimateMinutes: 6000,
        ),
        UrgencyReason.tightEstimate,
      );
    });

    test('a task without a deadline reports no deadline', () {
      expect(
        urgencyReason(now: now, deadline: null, priority: 1),
        UrgencyReason.noDeadline,
      );
    });

    test('otherwise the plain time left wins', () {
      expect(
        urgencyReason(
          now: now,
          deadline: now.add(const Duration(days: 3)),
          priority: 0,
          weightPercent: 30,
          estimateMinutes: 60,
        ),
        UrgencyReason.timeLeft,
      );
    });
  });
}