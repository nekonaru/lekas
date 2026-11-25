import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';

/// v1.0.0 shipped `schemaVersion 2`, which created every table but none of
/// the secondary indexes. The audit bumped the schema to 3 and added the
/// secondary indexes inside `onUpgrade`. Schema 4 then added the spaces
/// drag order column, schema 5 added semesters with a backfill that turns
/// existing periods into semesters, schema 6 added the flashcards table
/// with its due index, schema 7 added the SMA grade book table, and schema 8
/// added the habit tracker tables, and schema 9 lets a check be a rest day.
/// A user who installs this APK on top of
/// v1.0.0 runs all of those upgrades for the first time on a real file, so
/// they must not throw or leave the schema half built.
///
/// The fixture below rebuilds schema 2 by opening a fresh database (which
/// creates the latest schema), dropping the `idx_` indexes, dropping the
/// schema 4, 5, 6, 7, 8 and 9 pieces, and stamping `user_version = 2`. Reopening it
/// with the shipped [AppDatabase] then runs the genuine `from < 3`,
/// `from < 4`, `from < 5`, `from < 6`, `from < 7`, `from < 8` and `from < 9` branches.
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

  /// The names of the twenty schema indexes, alphabetical.
  const schemaIndexes = [
    'idx_attachments_task',
    'idx_attendance_space_date',
    'idx_class_exceptions_date',
    'idx_class_exceptions_slot',
    'idx_class_notes_space',
    'idx_class_slots_space',
    'idx_flash_cards_due',
    'idx_focus_sessions_task',
    'idx_habit_checks_habit_date',
    'idx_habits_deleted',
    'idx_reminders_fire',
    'idx_reminders_task',
    'idx_scores_space',
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

  /// Creates the schema 2 database v1.0.0 would have left behind: every
  /// table present, no `idx_` indexes, no schema 4, 5, 6 or 7 pieces,
  /// `user_version` stamped to 2.
  Future<void> createSchema2File() async {
    final seed = AppDatabase(NativeDatabase(file));
    // onCreate writes every table plus the indexes and the default
    // semester. Verify the indexes are there so the drop below is meaningful.
    expect(await idxNames(seed), schemaIndexes);
    for (final name in schemaIndexes) {
      await seed.customStatement('DROP INDEX IF EXISTS "$name"');
    }
    expect(await idxNames(seed), isEmpty);
    // Schema 4 added a column, not an index, so the legacy fixture never had
    // it. Drop it, or the `from < 4` add would hit a duplicate column.
    final cols = await seed
        .customSelect("PRAGMA table_info('spaces')")
        .get();
    // The generated column name in SQLite is snake case.
    if (cols.any((row) => row.read<String>('name') == 'sort_order')) {
      await seed.customStatement(
          'ALTER TABLE spaces DROP COLUMN sort_order');
    }
    // Schema 5 added the semester column the same way.
    if (cols.any((row) => row.read<String>('name') == 'semester_id')) {
      await seed.customStatement(
          'ALTER TABLE spaces DROP COLUMN semester_id');
    }
    await seed.customStatement('DROP TABLE IF EXISTS semesters');
    // Schemas 6, 7 and 8 added whole tables: the legacy fixture never had them.
    await seed.customStatement('DROP TABLE IF EXISTS flash_cards');
    await seed.customStatement('DROP TABLE IF EXISTS scores');
    await seed.customStatement('DROP TABLE IF EXISTS habit_checks');
    await seed.customStatement('DROP TABLE IF EXISTS habits');
    await seed.customStatement('PRAGMA user_version = 2');
    await seed.close();
  }

  test('upgrading a v1.0.0 schema 2 database to schema 9 succeeds', () async {
    await createSchema2File();

    // Reopen with the shipped database: onUpgrade(from: 2, to: 9) runs.
    final db = AppDatabase(NativeDatabase(file));
    // A read forces the migration to complete before we assert.
    final tasks = await db.select(db.tasks).get();
    expect(tasks, isEmpty);

    // The version is now 9.
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 9);

    // Every schema index was recreated by the upgrade, including schema 8.
    expect(await idxNames(db), schemaIndexes);
    // And the schema 4, 5, 6, 7 and 8 pieces exist again.
    final cols = await db
        .customSelect("PRAGMA table_info('spaces')")
        .get();
    final names = cols.map((r) => r.read<String>('name')).toList();
    expect(names, contains('sort_order'));
    expect(names, contains('semester_id'));
    final cards = await db.select(db.flashCards).get();
    expect(cards, isEmpty);
    final scores = await db.select(db.scores).get();
    expect(scores, isEmpty);
    final habits = await db.select(db.habits).get();
    expect(habits, isEmpty);
    final checks = await db.select(db.habitChecks).get();
    expect(checks, isEmpty);
    // An empty old database still gets the default semester, active.
    final semesters = await db.select(db.semesters).get();
    expect(semesters, hasLength(1));
    expect(semesters.single.name, 'Semester 1');
    expect(semesters.single.isActive, isTrue);
    await db.close();
  });

  test('the upgrade preserves data written by the older version', () async {
    // Build schema 2 and insert a row the way v1.0.0 would have stored it.
    final seed = AppDatabase(NativeDatabase(file));
    for (final name in schemaIndexes) {
      await seed.customStatement('DROP INDEX IF EXISTS "$name"');
    }
    // No sort_order or semester_id either: the legacy table predates both.
    final cols = await seed.customSelect("PRAGMA table_info('spaces')").get();
    if (cols.any((row) => row.read<String>('name') == 'sort_order')) {
      await seed.customStatement(
          'ALTER TABLE spaces DROP COLUMN sort_order');
    }
    if (cols.any((row) => row.read<String>('name') == 'semester_id')) {
      await seed.customStatement(
          'ALTER TABLE spaces DROP COLUMN semester_id');
    }
    await seed.customStatement('DROP TABLE IF EXISTS semesters');
    await seed.customStatement('DROP TABLE IF EXISTS flash_cards');
    await seed.customStatement('DROP TABLE IF EXISTS scores');
    await seed.customStatement('DROP TABLE IF EXISTS habit_checks');
    await seed.customStatement('DROP TABLE IF EXISTS habits');
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
    // A space without a period lands in the default semester, and that
    // semester ends up active.
    final semesters = await db.select(db.semesters).get();
    expect(semesters, hasLength(1));
    expect(semesters.single.isActive, isTrue);
    expect(spaces.single.semesterId, semesters.single.id);
    expect(await idxNames(db), schemaIndexes);
    await db.close();
  });

  test('a second open at schema 9 does not re-run the upgrade', () async {
    await createSchema2File();
    final first = AppDatabase(NativeDatabase(file));
    await first.select(first.tasks).get();
    expect(await idxNames(first), schemaIndexes);
    await first.close();

    // Reopen at the same version 9: onUpgrade must not run again, so it must
    // not try to recreate indexes or columns that already exist (which would
    // throw).
    final second = AppDatabase(NativeDatabase(file));
    final tasks = await second.select(second.tasks).get();
    expect(tasks, isEmpty);
    final version =
        await second.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 9);
    await second.close();
  });
}
