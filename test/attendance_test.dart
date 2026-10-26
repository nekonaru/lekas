import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/attendance_repository.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/space_repository.dart';
import 'package:lekas/domain/attendance.dart';

void main() {
  group('absence quota (design section 5.19)', () {
    test('the campus defaults are 16 meetings and 25 percent', () {
      final summary = summarizeAttendance(
        excusedCountsAbsent: false,
        statuses: const [],
      );
      expect(summary.planned, 16);
      expect(summary.limit, 4);
      expect(summary.remaining, 4);
    });

    test('present marks fill the attended count', () {
      final summary = summarizeAttendance(
        totalMeetings: 11,
        maxAbsentPercent: 25,
        excusedCountsAbsent: false,
        statuses: const [
          'present',
          'present',
          'present',
          'absent',
          'absent',
        ],
      );
      expect(summary.attended, 3);
      expect(summary.absentCount, 2);
      expect(summary.limit, 2);
      expect(summary.remaining, 0);
      expect(summary.exhausted, isTrue);
      expect(summary.lastOne, isFalse);
    });

    test('izin and sakit only spend the quota when the course says so', () {
      final lenient = summarizeAttendance(
        totalMeetings: 16,
        maxAbsentPercent: 25,
        excusedCountsAbsent: false,
        statuses: const ['excused', 'sick', 'absent'],
      );
      expect(lenient.absentCount, 1);

      final strict = summarizeAttendance(
        totalMeetings: 16,
        maxAbsentPercent: 25,
        excusedCountsAbsent: true,
        statuses: const ['excused', 'sick', 'absent'],
      );
      expect(strict.absentCount, 3);
      expect(strict.remaining, 1);
      expect(strict.lastOne, isTrue);
    });

    test('the alert key separates the soft and the red warning', () {
      final lastOne = summarizeAttendance(
        totalMeetings: 8,
        maxAbsentPercent: 25,
        excusedCountsAbsent: false,
        statuses: const ['absent'],
      );
      expect(lastOne.limit, 2);
      expect(lastOne.remaining, 1);
      expect(attendanceAlertKey(lastOne), 'lastOne');

      final usedUp = summarizeAttendance(
        totalMeetings: 4,
        maxAbsentPercent: 25,
        excusedCountsAbsent: false,
        statuses: const ['absent'],
      );
      expect(usedUp.limit, 1);
      expect(attendanceAlertKey(usedUp), 'exhausted');

      final fine = summarizeAttendance(
        totalMeetings: 16,
        maxAbsentPercent: 25,
        excusedCountsAbsent: false,
        statuses: const ['present'],
      );
      expect(attendanceAlertKey(fine), isNull);
    });
  });

  group('attendance records (design section 5.19)', () {
    late AppDatabase db;
    late SpaceRepository spaces;
    late AttendanceRepository attendance;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      spaces = SpaceRepository(db);
      attendance = AttendanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> makeSpace() async {
      await spaces.insertSpace(Space(
        id: 's1',
        name: 'Basdat',
        color: 0,
        kind: 'course',
        totalMeetings: 11,
        maxAbsentPercent: 25,
        archived: false,
        createdAt: 0,
        updatedAt: 0,
      ));
    }

    test('marking the same day twice corrects the record', () async {
      await makeSpace();
      await attendance.mark(
        spaceId: 's1',
        date: '2026-10-26',
        status: 'absent',
      );
      await attendance.mark(
        spaceId: 's1',
        date: '2026-10-26',
        status: 'present',
      );

      final records = await attendance.getForSpace('s1');
      expect(records, hasLength(1));
      expect(records.single.status, 'present');
    });

    test('the summary reads the settings of the course', () async {
      await makeSpace();
      for (final date in ['2026-10-20', '2026-10-22']) {
        await attendance.mark(
          spaceId: 's1',
          date: date,
          status: 'present',
        );
      }
      await attendance.mark(
        spaceId: 's1',
        date: '2026-10-24',
        status: 'absent',
      );

      final space = await spaces.getSpace('s1');
      final summary = await attendance.summaryFor(space);
      expect(summary.planned, 11);
      expect(summary.attended, 2);
      expect(summary.absentCount, 1);
      expect(summary.limit, 2);
      expect(summary.remaining, 1);
      expect(summary.lastOne, isTrue);

      final tight = await attendance.tightQuotas();
      expect(tight.single.spaceId, 's1');
      expect(tight.single.remaining, 1);
    });
  });
}
