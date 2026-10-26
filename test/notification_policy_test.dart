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

  group('weekly summary (design note "Minggu malam")', () {
    test('the next weekly summary is a Sunday at 20:30', () {
      expect(
        nextWeeklySummaryAt(DateTime(2026, 10, 21, 12)),
        DateTime(2026, 10, 25, 20, 30),
      );
      expect(
        nextWeeklySummaryAt(DateTime(2026, 10, 25, 19)),
        DateTime(2026, 10, 25, 20, 30),
      );
      expect(
        nextWeeklySummaryAt(DateTime(2026, 10, 25, 21)),
        DateTime(2026, 11, 1, 20, 30),
      );
    });

    test('the week ahead starts on the coming Monday', () {
      expect(nextWeekStart(DateTime(2026, 10, 21, 12)),
          DateTime(2026, 10, 26));
      expect(nextWeekStart(DateTime(2026, 10, 26, 8)),
          DateTime(2026, 11, 2));
    });

    test('on time means finished before the deadline in the last week', () {
      final now = DateTime(2026, 10, 26, 12);
      expect(
        finishedOnTimeThisWeek(
          now: now,
          completedAt: DateTime(2026, 10, 25, 10),
          deadline: DateTime(2026, 10, 26, 23, 59),
        ),
        isTrue,
      );
      expect(
        finishedOnTimeThisWeek(
          now: now,
          completedAt: DateTime(2026, 10, 25, 10),
          deadline: DateTime(2026, 10, 24, 23, 59),
        ),
        isFalse,
      );
      expect(
        finishedOnTimeThisWeek(
          now: now,
          completedAt: DateTime(2026, 10, 10, 10),
          deadline: DateTime(2026, 10, 20, 23, 59),
        ),
        isFalse,
      );
      expect(
        finishedOnTimeThisWeek(now: now, completedAt: null, deadline: null),
        isFalse,
      );
    });

    test('the busiest course only counts deadlines of the week ahead', () {
      final from = DateTime(2026, 10, 26);
      final to = DateTime(2026, 11, 2);
      final busiest = busiestSpace(
        tasks: [
          (spaceId: 'a', deadline: DateTime(2026, 10, 27)),
          (spaceId: 'a', deadline: DateTime(2026, 10, 28)),
          (spaceId: 'b', deadline: DateTime(2026, 10, 30)),
          (spaceId: 'a', deadline: DateTime(2026, 11, 3)),
          (spaceId: null, deadline: DateTime(2026, 10, 27)),
          (spaceId: 'b', deadline: null),
        ],
        from: from,
        to: to,
      );
      expect(busiest, isNotNull);
      expect(busiest!.spaceId, 'a');
      expect(busiest.count, 2);
      expect(
        busiestSpace(
          tasks: [(spaceId: 'a', deadline: DateTime(2026, 10, 20))],
          from: from,
          to: to,
        ),
        isNull,
      );
    });
  });

  group('summaries (design section 5.12)', () {
    final day = DateTime(2026, 10, 20, 12);

    test('the next morning summary waits for 07:00', () {
      expect(nextMomentAt(DateTime(2026, 10, 20, 6, 59), 7),
          DateTime(2026, 10, 20, 7));
      expect(nextMomentAt(DateTime(2026, 10, 20, 7, 1), 7),
          DateTime(2026, 10, 21, 7));
    });

    test('the evening wrap-up sits at 20:30', () {
      expect(nextMomentAt(DateTime(2026, 10, 20, 9), 20, 30),
          DateTime(2026, 10, 20, 20, 30));
      expect(nextMomentAt(DateTime(2026, 10, 20, 21), 20, 30),
          DateTime(2026, 10, 21, 20, 30));
    });

    test('a deadline counts on its own calendar day', () {
      expect(
        dueOnDay(
          deadline: DateTime(2026, 10, 20, 23, 59),
          day: day,
        ),
        isTrue,
      );
      expect(
        dueOnDay(
          deadline: DateTime(2026, 10, 21, 0, 1),
          day: day,
        ),
        isFalse,
      );
    });
  });

  group('daily overdue digest (design section 5.22)', () {
    final now = DateTime(2026, 10, 20, 9);

    test('a task is only mentioned while it is overdue', () {
      final deadline = now.add(const Duration(hours: 1));
      expect(
        countsAsFreshOverdue(deadline: deadline, now: now),
        isFalse,
      );
      expect(
        countsAsFreshOverdue(
          deadline: now.subtract(const Duration(minutes: 30)),
          now: now,
        ),
        isTrue,
      );
    });

    test('a task stops appearing after three days', () {
      final deadline = DateTime(2026, 10, 17, 23, 59);
      expect(countsAsFreshOverdue(deadline: deadline, now: now), isTrue);
      final later = DateTime(2026, 10, 21, 0, 1);
      expect(countsAsFreshOverdue(deadline: deadline, now: later), isFalse);
    });

    test('the next digest is always at 09:00', () {
      final beforeNine = DateTime(2026, 10, 20, 7, 30);
      final afterNine = DateTime(2026, 10, 20, 10, 0);
      expect(
        nextDigestAt(beforeNine),
        DateTime(2026, 10, 20, 9),
      );
      expect(
        nextDigestAt(afterNine),
        DateTime(2026, 10, 21, 9),
      );
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
