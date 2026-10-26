import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/reminders/notification_policy.dart';

NotificationCandidate candidate({
  required String key,
  required DateTime fireAt,
  required DateTime deadline,
  String? title,
}) =>
    NotificationCandidate(
      key: key,
      fireAt: fireAt,
      deadline: deadline,
      title: title ?? key,
    );

void main() {
  group('intensity (design section 5.21)', () {
    test('calm keeps only H-1 and three hours', () {
      final specs = specsForIntensity(ReminderIntensity.calm);
      expect(specs.map((spec) => spec.kind), ['d1', 'h3']);
    });

    test('normal is the standard ladder plus the heavy day', () {
      final plain =
          specsForIntensity(ReminderIntensity.normal).map((s) => s.kind);
      expect(plain, ['d3', 'd1', 'h3', 'm30']);

      final heavy = specsForIntensity(
        ReminderIntensity.normal,
        weightPercent: 60,
      ).map((s) => s.kind);
      expect(heavy.first, 'd7');
    });

    test('eager adds every six hours of the deadline day', () {
      final specs = specsForIntensity(ReminderIntensity.eager);
      expect(specs.map((s) => s.kind), ['d3', 'd1', 'h3', 'm30', 'h6', 'h12', 'h18']);
      expect(specs.where((s) => s.deadlineDayOnly).length, 3);
    });

    test('an unknown stored value falls back to normal', () {
      expect(intensityFromSetting(null), ReminderIntensity.normal);
      expect(intensityFromSetting('loud'), ReminderIntensity.normal);
      expect(intensityFromSetting('calm'), ReminderIntensity.calm);
      expect(intensityFromSetting('eager'), ReminderIntensity.eager);
    });
  });

  group('merging and budget (design section 5.21)', () {
    final day = DateTime(2026, 10, 20, 8);
    final farDeadline = DateTime(2026, 10, 30, 23, 59);

    test('reminders within ten minutes become one notification', () {
      final plans = planNotifications([
        candidate(key: 'a', fireAt: day, deadline: farDeadline),
        candidate(
          key: 'b',
          fireAt: day.add(const Duration(minutes: 6)),
          deadline: farDeadline,
        ),
        candidate(
          key: 'c',
          fireAt: day.add(const Duration(minutes: 30)),
          deadline: farDeadline,
        ),
      ]);
      expect(plans.length, 2);
      expect(plans.first.members.map((m) => m.key), ['a', 'b']);
      expect(plans.first.merged, isTrue);
      expect(plans.first.summary, isFalse);
      expect(plans.last.members.single.key, 'c');
    });

    test('a day never uses more than the budget of non critical ones', () {
      final candidates = [
        for (var i = 0; i < 10; i++)
          candidate(
            key: 'k$i',
            fireAt: day.add(Duration(minutes: i * 30)),
            deadline: farDeadline,
          ),
      ];
      final plans = planNotifications(candidates, budget: 8);
      final plain = plans.where((plan) => !plan.summary).toList();
      final summaries = plans.where((plan) => plan.summary).toList();
      expect(plain.length, 8);
      expect(summaries, hasLength(1));
      expect(summaries.single.members.length, 2);
      // The summary keeps the earliest time of everything it collected.
      expect(summaries.single.fireAt, day.add(const Duration(minutes: 8 * 30)));
    });

    test('critical reminders are never trimmed', () {
      final candidates = [
        for (var i = 0; i < 8; i++)
          candidate(
            key: 'k$i',
            fireAt: day.add(Duration(minutes: i * 30)),
            deadline: farDeadline,
          ),
        candidate(
          key: 'late',
          fireAt: day.add(const Duration(hours: 5)),
          deadline: day.add(const Duration(hours: 7)),
        ),
      ];
      final plans = planNotifications(candidates, budget: 8);
      expect(plans.any((plan) => plan.summary), isFalse);
      expect(plans.any((plan) => plan.lead.key == 'late'), isTrue);
      expect(plans.length, 9);
    });

    test('the budget counts each local day on its own', () {
      final candidates = [
        for (var i = 0; i < 9; i++)
          candidate(
            key: 'd1-$i',
            fireAt: day.add(Duration(minutes: i * 30)),
            deadline: farDeadline,
          ),
        for (var i = 0; i < 9; i++)
          candidate(
            key: 'd2-$i',
            fireAt: day.add(Duration(days: 1, minutes: i * 30)),
            deadline: farDeadline,
          ),
      ];
      final plans = planNotifications(candidates, budget: 8);
      final summaries = plans.where((plan) => plan.summary).toList();
      expect(summaries.length, 2);
      for (final plan in summaries) {
        expect(plan.members, hasLength(1));
      }
    });
  });
}
