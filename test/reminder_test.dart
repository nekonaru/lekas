import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/reminders/class_quiet.dart';
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

  group('silent during class (design section 5.21)', () {
    // Tuesday 20 October 2026, weekday 2.
    final day = DateTime(2026, 10, 20);

    ClassSlot lecture({
      String id = 'slot1',
      int weekday = 2,
      int startMin = 8 * 60,
      int endMin = 9 * 60 + 30,
    }) =>
        ClassSlot(
          id: id,
          spaceId: 's1',
          weekday: weekday,
          startMin: startMin,
          endMin: endMin,
          kind: 'lecture',
          updatedAt: 0,
        );

    test('a reminder inside class waits until the class ends', () {
      final windows = classWindowsFor(
        date: day,
        spaceId: 's1',
        slots: [lecture()],
        exceptions: const [],
      );
      final held = holdOutOfClass(
        fireAt: DateTime(2026, 10, 20, 8, 45),
        deadline: DateTime(2026, 10, 21, 23, 59),
        windows: windows,
      );
      expect(held, DateTime(2026, 10, 20, 9, 30));
    });

    test('a reminder before class starts is untouched', () {
      final windows = classWindowsFor(
        date: day,
        spaceId: 's1',
        slots: [lecture()],
        exceptions: const [],
      );
      final fireAt = DateTime(2026, 10, 20, 7, 0);
      expect(
        holdOutOfClass(
          fireAt: fireAt,
          deadline: DateTime(2026, 10, 21, 23, 59),
          windows: windows,
        ),
        fireAt,
      );
    });

    test('a deadline under an hour after class is never held', () {
      final windows = classWindowsFor(
        date: day,
        spaceId: 's1',
        slots: [lecture()],
        exceptions: const [],
      );
      final fireAt = DateTime(2026, 10, 20, 8, 45);
      final held = holdOutOfClass(
        fireAt: fireAt,
        deadline: DateTime(2026, 10, 20, 10, 0),
        windows: windows,
      );
      expect(held, fireAt);
    });

    test('a cancelled class releases the reminder', () {
      final windows = classWindowsFor(
        date: day,
        spaceId: 's1',
        slots: [lecture()],
        exceptions: [
          ClassException(
            id: 'e1',
            classSlotId: 'slot1',
            date: '2026-10-20',
            kind: 'cancelled',
            updatedAt: 0,
          ),
        ],
      );
      expect(windows, isEmpty);
      final fireAt = DateTime(2026, 10, 20, 8, 45);
      expect(
        holdOutOfClass(
          fireAt: fireAt,
          deadline: DateTime(2026, 10, 21, 23, 59),
          windows: windows,
        ),
        fireAt,
      );
    });

    test('a moved class holds to its new end time', () {
      final windows = classWindowsFor(
        date: day,
        spaceId: 's1',
        slots: [lecture()],
        exceptions: [
          ClassException(
            id: 'e2',
            classSlotId: 'slot1',
            date: '2026-10-20',
            kind: 'moved',
            newStartMin: 13 * 60,
            newEndMin: 14 * 60 + 30,
            updatedAt: 0,
          ),
        ],
      );
      expect(windows.single.start, DateTime(2026, 10, 20, 13, 0));
      final held = holdOutOfClass(
        fireAt: DateTime(2026, 10, 20, 13, 30),
        deadline: DateTime(2026, 10, 21, 23, 59),
        windows: windows,
      );
      expect(held, DateTime(2026, 10, 20, 14, 30));
    });

    test('a class on another weekday does not hold anything', () {
      final windows = classWindowsFor(
        date: day,
        spaceId: 's1',
        slots: [lecture(weekday: 3)],
        exceptions: const [],
      );
      expect(windows, isEmpty);
    });
  });
}
