import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/backup_service.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/task_repository.dart';

/// The import used to hand raw JSON maps straight to drift, which threw on
/// the first row after every table had already been emptied. These tests
/// pin the ordering down: check, then write, and never in between.
void main() {
  late AppDatabase db;
  late BackupService backup;
  late TaskRepository tasks;
  late Directory temp;

  final now = DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> spaceJson({String id = 'sp1', String name = 'Basis Data'}) => {
        'id': id,
        'name': name,
        'code': 'BD',
        'color': 42,
        'kind': 'course',
        'archived': false,
        'createdAt': now,
        'updatedAt': now,
      };

  Map<String, dynamic> taskJson({String id = 't1', String title = 'Laprak'}) => {
        'id': id,
        'spaceId': 'sp1',
        'title': title,
        'priority': 1,
        'status': 'todo',
        'isGroup': false,
        'pinned': false,
        'inbox': false,
        'createdAt': now,
        'updatedAt': now,
      };

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    backup = BackupService(db);
    tasks = TaskRepository(db);
    temp = Directory.systemTemp.createTempSync('lekas_backup_test');
  });

  tearDown(() async {
    await db.close();
    if (temp.existsSync()) temp.deleteSync(recursive: true);
  });

  Future<File> writeBackup(Object payload) async {
    final file = File('${temp.path}/backup.json');
    await file.writeAsString(payload is String ? payload : jsonEncode(payload));
    return file;
  }

  group('import checks before it writes', () {
    test('a backup without a version is refused', () async {
      final file = await writeBackup({'spaces': []});

      await expectLater(
        backup.importFromJson(file, mode: 'replace'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('a backup that is not a JSON object is refused', () async {
      final file = await writeBackup('[1, 2, 3]');

      await expectLater(
        backup.importFromJson(file),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('a broken JSON file is refused', () async {
      final file = await writeBackup('{not json');

      await expectLater(
        backup.importFromJson(file),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('a table holding something other than rows is refused', () async {
      final file = await writeBackup({'version': '1.0', 'tasks': 'oops'});

      await expectLater(
        backup.importFromJson(file),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('a row with a broken field leaves the current data alone', () async {
      await tasks.insertTask(Task(
        id: 'keep',
        title: 'Tugas lama',
        priority: 1,
        status: 'todo',
        isGroup: false,
        pinned: false,
        inbox: false,
        createdAt: now,
        updatedAt: now,
      ));

      final file = await writeBackup({
        'version': '1.0',
        'tasks': [
          taskJson(id: 'new'),
          {'id': 'broken', 'title': 12},
        ],
      });

      await expectLater(
        backup.importFromJson(file, mode: 'replace'),
        throwsA(isA<BackupFormatException>()),
      );

      final kept = await db.select(db.tasks).get();
      expect(kept, hasLength(1));
      expect(kept.single.id, 'keep');
    });

    test('a file over the size limit is refused before it is read', () async {
      final file = File('${temp.path}/huge.json');
      final filler = ' ' * (1024 * 1024);
      for (var i = 0; i <= BackupService.maxBackupBytes ~/ (1024 * 1024); i++) {
        await file.writeAsString(filler, mode: FileMode.append);
      }

      await expectLater(
        backup.importFromJson(file, mode: 'replace'),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });

  group('import writes real rows', () {
    test('replace mode swaps the data and keeps every field', () async {
      await tasks.insertTask(Task(
        id: 'old',
        title: 'Tugas lama',
        priority: 1,
        status: 'todo',
        isGroup: false,
        pinned: false,
        inbox: false,
        createdAt: now,
        updatedAt: now,
      ));

      final file = await writeBackup({
        'version': '1.0',
        'spaces': [spaceJson()],
        'tasks': [taskJson()],
      });

      final stats = await backup.importFromJson(file, mode: 'replace');

      expect(stats['spaces'], 1);
      expect(stats['tasks'], 1);

      final space = await (db.select(db.spaces)
            ..where((t) => t.id.equals('sp1')))
          .getSingle();
      expect(space.name, 'Basis Data');
      expect(space.code, 'BD');
      expect(space.color, 42);
      expect(space.kind, 'course');
      expect(space.archived, isFalse);

      final rows = await db.select(db.tasks).get();
      expect(rows, hasLength(1));
      expect(rows.single.title, 'Laprak');
      expect(rows.single.spaceId, 'sp1');
    });

    test('merge mode keeps rows that are not in the file', () async {
      await tasks.insertTask(Task(
        id: 'keep',
        title: 'Tugas lama',
        priority: 1,
        status: 'todo',
        isGroup: false,
        pinned: false,
        inbox: false,
        createdAt: now,
        updatedAt: now,
      ));

      final file = await writeBackup({
        'version': '1.0',
        'tasks': [taskJson()],
      });
      await backup.importFromJson(file, mode: 'merge');

      final rows = await (db.select(db.tasks)
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();
      expect(rows.map((t) => t.id), ['keep', 't1']);
    });

    test('a table left out of the file reports no rows', () async {
      final file = await writeBackup({'version': '1.0'});

      final stats = await backup.importFromJson(file, mode: 'merge');

      expect(stats.containsKey('tasks'), isFalse);
    });
  });
}
