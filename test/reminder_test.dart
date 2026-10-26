import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/reminders/reminder_service.dart';

void main() {
  group('quiet hours rule (design section 4.6)', () {
    final deadline = DateTime(2026, 10, 20, 23, 59);

    test('a reminder at 23:29 moves to 21:55 the same evening', () {
      final moved = moveOutOfQuietHours(DateTime(2026, 10, 20, 23, 29), deadline);
      expect(moved, DateTime(2026, 10, 20, 21, 55));
      expect(moved.isBefore(deadline), isTrue);
    });

    test('a reminder at 22:59 moves to 21:55 the same evening', () {
      final moved = moveOutOfQuietHours(DateTime(2026, 10, 20, 22, 59), deadline);
      expect(moved, DateTime(2026, 10, 20, 21, 55));
    });

    test('a reminder at 04:30 moves to 21:55 the previous evening', () {
      final moved = moveOutOfQuietHours(DateTime(2026, 10, 21, 4, 30), deadline);
      expect(moved, DateTime(2026, 10, 20, 21, 55));
    });

    test('a reminder outside quiet hours is untouched', () {
      final fireAt = DateTime(2026, 10, 20, 21, 0);
      expect(moveOutOfQuietHours(fireAt, deadline), fireAt);
      final afternoon = DateTime(2026, 10, 20, 15, 0);
      expect(moveOutOfQuietHours(afternoon, deadline), afternoon);
    });

    test('the shift never moves a reminder past its deadline', () {
      // The candidate time 21:55 is later than this deadline, so the helper
      // must leave the original time alone instead of firing too late.
      final earlyDeadline = DateTime(2026, 10, 20, 21, 50);
      final fireAt = DateTime(2026, 10, 20, 22, 10);
      final moved = moveOutOfQuietHours(fireAt, earlyDeadline);
      expect(moved, fireAt);
      expect(moved, isNot(DateTime(2026, 10, 20, 21, 55)));
    });

    test('the 22:00 boundary is inside quiet hours, 21:59 is not', () {
      expect(moveOutOfQuietHours(DateTime(2026, 10, 20, 22, 0), deadline),
          DateTime(2026, 10, 20, 21, 55));
      final atLimit = DateTime(2026, 10, 20, 21, 59);
      expect(moveOutOfQuietHours(atLimit, deadline), atLimit);
    });
  });

  group('notification payload', () {
    test('round trips through encode and parse', () {
      const payload = ReminderPayload('task-1', ReminderPayload.actionDone);
      final parsed = ReminderPayload.tryParse(payload.encode());
      expect(parsed, isNotNull);
      expect(parsed!.taskId, 'task-1');
      expect(parsed.action, ReminderPayload.actionDone);
    });

    test('rejects foreign payloads', () {
      expect(ReminderPayload.tryParse(null), isNull);
      expect(ReminderPayload.tryParse(''), isNull);
      expect(ReminderPayload.tryParse('nope'), isNull);
      expect(ReminderPayload.tryParse('task|only-two|parts|extra'), isNull);
      expect(ReminderPayload.tryParse('other|id|action'), isNull);
    });
  });

  group('reminder ladder', () {
    test('covers H-3, H-1, 3 hours and 30 minutes', () {
      final kinds = kReminderSpecs.map((spec) => spec.kind).toList();
      expect(kinds, ['d3', 'd1', 'h3', 'm30']);
      expect(kReminderSpecs.first.offset, const Duration(days: 3));
      expect(kReminderSpecs.last.offset, const Duration(minutes: 30));
    });

    test('heavy tasks get an extra week of lead time', () {
      expect(kHeavyTaskSpec.kind, 'd7');
      expect(kHeavyTaskSpec.offset, const Duration(days: 7));
      expect(kHeavyTaskWeight, 60);
    });

    test('only two weeks ahead are ever scheduled', () {
      expect(kScheduleHorizonDays, 14);
    });
  });
}
