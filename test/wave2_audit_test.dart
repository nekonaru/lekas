import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/attendance_repository.dart';
import 'package:lekas/data/backup_service.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/space_repository.dart';
import 'package:lekas/features/share_intake/share_intake_screen.dart';
import 'package:lekas/features/spaces/class_schedule_screen.dart';

/// Wave two of the post release audit: a shared message of any size used to
/// become one card and one saved task per sentence, an imported backup could
/// carry two attendance rows for one lesson and break the marking, an
/// imported class slot with a wild weekday crashed the schedule screen, and
/// the slot form parsed whatever text it was given into minutes.
void main() {
  group('splitShareCandidates stays bounded', () {
    test('a hostile message of thousands of sentences stops at the cap', () {
      final message = List.filled(5000, 'kumpul berkas batas besok').join('. ');

      final candidates = splitShareCandidates(message);

      expect(candidates, hasLength(kMaxShareCandidates));
    });

    test('an ordinary message keeps all of its sentences', () {
      final message = 'Kumpul laporan batas senin. Kerjakan prakarya sebelum jumat.';

      final candidates = splitShareCandidates(message);

      expect(candidates, hasLength(2));
    });
  });

  group('a class slot only accepts a real hour of the week', () {
    test('a written time becomes minutes, anything else becomes null', () {
      expect(parseHourMinute('07:30'), 7 * 60 + 30);
      expect(parseHourMinute('23:59'), 23 * 60 + 59);
      expect(parseHourMinute('99:99'), isNull);
      expect(parseHourMinute('7.30'), isNull);
      expect(parseHourMinute(''), isNull);
      expect(parseHourMinute('730'), isNull);
      expect(parseHourMinute('-1:30'), isNull);
      expect(parseHourMinute('7:70'), isNull);
    });
  });

  group('import refuses class slots the schedule cannot draw', () {
    late AppDatabase db;
    late BackupService backup;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      backup = BackupService(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<File> writeBackup(Map<String, dynamic> data) async {
      final file = File(
          '${Directory.systemTemp.createTempSync('lekas_wave2').path}/b.json');
      file.writeAsStringSync(jsonEncode(data));
      return file;
    }

    Map<String, dynamic> slotJson({
      String id = 'c1',
      int weekday = 1,
      int startMin = 420,
      int endMin = 530,
    }) =>
        {
          'id': id,
          'spaceId': 'sp1',
          'weekday': weekday,
          'startMin': startMin,
          'endMin': endMin,
          'kind': 'lecture',
          'updatedAt': 0,
        };

    test('weekday zero, weekday forty two and upside down hours are dropped',
        () async {
      final file = await writeBackup({
        'version': '1.0',
        'class_slots': [
          slotJson(),
          slotJson(id: 'bad0', weekday: 0),
          slotJson(id: 'bad42', weekday: 42),
          slotJson(id: 'upside', startMin: 530, endMin: 420),
        ],
      });

      final stats = await backup.importFromJson(file, mode: 'replace');

      expect(stats['class_slots'], 1);
      final rows = await db.select(db.classSlots).get();
      expect(rows.map((row) => row.id), ['c1']);
    });
  });

  group('marking survives the duplicate rows a merged backup can carry', () {
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

    test('two rows for the same lesson update the first instead of throwing',
        () async {
      await spaces.insertSpace(Space(
        id: 's1',
        name: 'Basdat',
        color: 0,
        kind: 'course',
        archived: false,
        createdAt: 0,
        updatedAt: 0,
      ));
      // What an imported merge looks like: same lesson, two ids.
      for (final id in ['a-old', 'a-new']) {
        await db.into(db.attendance).insert(AttendanceData(
              id: id,
              spaceId: 's1',
              date: '2026-10-26',
              status: 'absent',
              updatedAt: 0,
            ));
      }

      await attendance.mark(
        spaceId: 's1',
        date: '2026-10-26',
        status: 'present',
      );

      // The mark used to throw StateError before reaching either row; now
      // one of the two is corrected and nothing crashes.
      final records = await attendance.getForSpace('s1');
      expect(records.map((row) => row.status), contains('present'));
    });
  });
}
