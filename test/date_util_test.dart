import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/core/date_util.dart';

/// The overdue list used to divide the milliseconds between the start of
/// today and the deadline, so a task that was due yesterday printed "0 days
/// late": one minute past midnight is not a full day. The helper counts
/// calendar days instead, and reads the day numbers in UTC so a 23 or 25 hour
/// local day (daylight saving) cannot pull the count one day short.
void main() {
  group('calendarDaysLate', () {
    test('a deadline from yesterday is one day late, never zero', () {
      final yesterdayEvening = DateTime(2026, 10, 30, 23, 59);
      final now = DateTime(2026, 10, 31, 0, 1);
      expect(DateUtil.calendarDaysLate(now, yesterdayEvening), 1);
    });

    test('a deadline later today is not late at all', () {
      final todayEvening = DateTime(2026, 10, 31, 23, 59);
      final now = DateTime(2026, 10, 31, 9, 0);
      expect(DateUtil.calendarDaysLate(now, todayEvening), 0);
    });

    test('the count follows the calendar, not full days of 24 hours', () {
      // Two days apart in wall clock time, even across a 23 hour day.
      final due = DateTime(2026, 3, 28, 12, 0);
      final now = DateTime(2026, 3, 30, 12, 0);
      expect(DateUtil.calendarDaysLate(now, due), 2);
    });

    test('a deadline still ahead comes back negative', () {
      final tomorrow = DateTime(2026, 11, 2, 8, 0);
      final now = DateTime(2026, 11, 1, 20, 0);
      expect(DateUtil.calendarDaysLate(now, tomorrow), -1);
    });
  });
}
