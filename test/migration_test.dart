import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';

/// v1.0.0 shipped `schemaVersion 2`, which created every table but none of
/// the secondary indexes. The audit bumped the schema to 3 and added nineteen
/// `CREATE INDEX` calls inside `onUpgrade`. A user who installs the new APK
/// on top of v1.0.0 runs that upgrade for the first time on a real file, so it
/// must not throw or leave the schema half built.
///
/// The tables of schema 2 and 3 are byte identical: the only difference is the
/// indexes. So the fixture below rebuilds schema 2 by opening a fresh database
/// (which creates schema 3), dropping the `idx_` indexes, and stamping
/// `user_version = 2`. Reopening it with the shipped [AppDatabase] then runs
/// the genuine `from < 3` branch.
void main() {
  late File file;

  setUp(() {
    file = File(
      '${Directory.systemTemp.path}/lekas_migration_'
      '${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
  });

  tearDown(() async {
    if (file.existsSync()) await file.delete();
  });

  /// The names of the nineteen schema 3 indexes, alphabetical.
  const schema3Indexes = [
    'idx_attachments_task',
    'idx_attendance_space_date',
    'idx_class_exceptions_date',
    'idx_class_exceptions_slot',
    'idx_class_notes_space',
    'idx_class_slots_space',
    'idx_focus_sessions_task',
    'idx_reminders_fire',
    'idx_reminders_task',
    'idx_space_items_space',
    'idx_spaces_deleted',
    'idx_subtasks_task',
    'idx_task_events_task',
    'idx_task_tags_tag',
    'idx_tasks_deadline',
    'idx_tasks_deleted',
    'idx_tasks_focus',
    'idx_tasks_space',
    'idx_tasks_status',
  ];

  Future<List<String>> idxNames(AppDatabase db) async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name LIKE 'idx_%' ORDER BY name",
        )
        .get();
    return rows.map((r) => r.read<String>('name')).toList();
  }

  /// Creates the schema 2 database v1.0.0 would have left behind: every table
  /// present, no `idx_` indexes, `user_version` stamped to 2.
  Future<void> createSchema2File() async {
    final seed = AppDatabase(NativeDatabase(file));
    // onCreate writes every table plus the schema 3 indexes. Verify they are
    // there so the drop below is meaningful.
    expect(await idxNames(seed), schema3Indexes);
    for (final name in schema3Indexes) {
      await seed.customStatement('DROP INDEX IF EXISTS "$name"');
    }
    expect(await idxNames(seed), isEmpty);
    await seed.customStatement('PRAGMA user_version = 2');
    await seed.close();
  }

  test('upgrading a v1.0.0 schema 2 database to schema 3 succeeds', () async {
    await createSchema2File();

    // Reopen with the shipped database: onUpgrade(from: 2, to: 3) runs.
    final db = AppDatabase(NativeDatabase(file));
    // A read forces the migration to complete before we assert.
    final tasks = await db.select(db.tasks).get();
    expect(tasks, isEmpty);

    // The version is now 3.
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 3);

    // Every schema 3 index was recreated by the upgrade.
    expect(await idxNames(db), schema3Indexes);
    await db.close();
  });

  test('the upgrade preserves data written by the older version', () async {
    // Build schema 2 and insert a row the way v1.0.0 would have stored it.
    final seed = AppDatabase(NativeDatabase(file));
    for (final name in schema3Indexes) {
      await seed.customStatement('DROP INDEX IF EXISTS "$name"');
    }
    await seed.into(seed.spaces).insert(
          SpacesCompanion.insert(
            id: 'space-1',
            name: 'Kalkulus',
            color: 0xFF2196F3,
            createdAt: 1700000000000,
            updatedAt: 1700000000000,
          ),
        );
    await seed.customStatement('PRAGMA user_version = 2');
    await seed.close();

    final db = AppDatabase(NativeDatabase(file));
    final spaces = await db.select(db.spaces).get();
    expect(spaces, hasLength(1));
    expect(spaces.single.name, 'Kalkulus');
    expect(await idxNames(db), schema3Indexes);
    await db.close();
  });

  test('a second open at schema 3 does not re-run the upgrade', () async {
    await createSchema2File();
    final first = AppDatabase(NativeDatabase(file));
    await first.select(first.tasks).get();
    expect(await idxNames(first), schema3Indexes);
    await first.close();

    // Reopen at the same version 3: onUpgrade must not run again, so it must
    // not try to recreate indexes that already exist (which would throw).
    final second = AppDatabase(NativeDatabase(file));
    final tasks = await second.select(second.tasks).get();
    expect(tasks, isEmpty);
    final version = await second.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 3);
    await second.close();
  });
}
