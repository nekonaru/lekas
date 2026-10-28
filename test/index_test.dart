import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';

/// Schema 3 adds the secondary indexes that every list, the reminder sync
/// and the attendance views depend on. Each test below is a real query
/// shape from the repositories: it must reach an index and never scan the
/// whole table, otherwise the screens keep getting slower as data grows.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<List<String>> indexNames() async {
    final rows = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%' "
      'ORDER BY name',
    ).get();
    return rows.map((row) => row.read<String>('name')).toList();
  }

  Future<String> plan(String sql) async {
    final rows = await db.customSelect('EXPLAIN QUERY PLAN $sql').get();
    return rows.map((row) => row.read<String>('detail')).join(' | ');
  }

  test('a fresh database carries every schema 3 index', () async {
    expect(await indexNames(), [
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
    ]);
  });

  test('the schema version is 3', () {
    expect(db.schemaVersion, 3);
  });

  test('the database declares nineteen secondary indexes', () {
    final names = db.allSchemaEntities
        .map((entity) => entity.entityName)
        .where((name) => name.startsWith('idx_'))
        .toList();
    expect(names, hasLength(19));
  });

  /// Every probe below must hit an index and must not degrade into a full
  /// table scan. The exact index SQLite picks is allowed to change with
  /// planner statistics, the full scan is not.
  Future<void> expectIndexed(String sql) async {
    final detail = await plan(sql);
    // SQLite writes "USING INDEX" or "USING COVERING INDEX" here.
    expect(detail, contains('INDEX'), reason: 'plan was: $detail');
    expect(detail, isNot(contains('SCAN tasks')), reason: 'plan was: $detail');
    expect(detail, isNot(contains('SCAN reminders')), reason: 'plan was: $detail');
    expect(
      detail,
      isNot(contains('SCAN class_exceptions')),
      reason: 'plan was: $detail',
    );
  }

  test('the today filter reaches an index', () async {
    await expectIndexed(
      "SELECT * FROM tasks WHERE deleted_at IS NULL AND inbox = 0 AND status != 'done'",
    );
  });

  test('the course list reaches the space index', () async {
    expect(
      await plan(
        "SELECT * FROM tasks WHERE deleted_at IS NULL AND space_id = 'sp1'",
      ),
      contains('idx_tasks_space'),
    );
  });

  test('the trash reaches the deleted index and orders without sorting',
      () async {
    final detail = await plan(
      'SELECT * FROM tasks WHERE deleted_at IS NOT NULL '
      'ORDER BY deleted_at DESC',
    );
    expect(detail, contains('idx_tasks_deleted'));
    expect(detail, isNot(contains('USE TEMP B-TREE')));
  });

  test('the focus filter reaches the focus index', () async {
    expect(
      await plan(
        'SELECT * FROM tasks WHERE focus_date = 20261028 AND deleted_at IS NULL',
      ),
      contains('idx_tasks_focus'),
    );
  });

  test('opening a task reaches the primary key', () async {
    expect(
      await plan("SELECT * FROM tasks WHERE id = 't1'"),
      contains('sqlite_autoindex_tasks_1'),
    );
  });

  test('the subtask list reaches the task index', () async {
    expect(
      await plan(
        "SELECT * FROM subtasks WHERE task_id = 't1' AND deleted_at IS NULL "
        'ORDER BY sort_order',
      ),
      contains('idx_subtasks_task'),
    );
  });

  test('the attachment list reaches the task index', () async {
    expect(
      await plan(
        "SELECT * FROM attachments WHERE task_id = 't1' ORDER BY created_at",
      ),
      contains('idx_attachments_task'),
    );
  });

  test('the event history reaches the task index', () async {
    expect(
      await plan(
        "SELECT * FROM task_events WHERE task_id = 't1' ORDER BY created_at DESC",
      ),
      contains('idx_task_events_task'),
    );
  });

  test('the reminder sync reaches the reminder indexes', () async {
    expect(
      await plan("SELECT * FROM reminders WHERE task_id = 't1' ORDER BY fire_at"),
      contains('idx_reminders_task'),
    );
    expect(
      await plan('SELECT * FROM reminders ORDER BY fire_at'),
      contains('idx_reminders_fire'),
    );
  });

  test('the attendance view reaches the space and day index', () async {
    expect(
      await plan(
        "SELECT * FROM attendance WHERE space_id = 'sp1' "
        "AND date = '2026-10-28' ORDER BY date DESC",
      ),
      contains('idx_attendance_space_date'),
    );
  });

  test('the holiday lookup reaches the date index instead of a scan',
      () async {
    final detail = await plan(
      "SELECT * FROM class_exceptions WHERE date = '2026-10-28' "
      'AND deleted_at IS NULL',
    );
    expect(detail, contains('idx_class_exceptions_date'), reason: detail);
    expect(detail, isNot(contains('SCAN class_exceptions')), reason: detail);
  });

  test('the schedule lookup reaches the slot index', () async {
    expect(
      await plan(
        "SELECT * FROM class_slots WHERE space_id = 'sp1' AND deleted_at IS NULL",
      ),
      contains('idx_class_slots_space'),
    );
  });

  test('the reverse tag lookup reaches the tag index', () async {
    expect(
      await plan("SELECT * FROM task_tags WHERE tag_id = 'tag1'"),
      contains('idx_task_tags_tag'),
    );
  });

  test('the course notes and checklist reach their space indexes', () async {
    expect(
      await plan(
        "SELECT * FROM class_notes WHERE space_id = 'sp1' AND deleted_at IS NULL",
      ),
      contains('idx_class_notes_space'),
    );
    expect(
      await plan(
        "SELECT * FROM space_items WHERE space_id = 'sp1' "
        'AND deleted_at IS NULL ORDER BY sort_order',
      ),
      contains('idx_space_items_space'),
    );
  });

  test('per task child tables never fall back to a table scan', () async {
    await expectIndexed(
      "SELECT * FROM focus_sessions WHERE task_id = 't1'",
    );
    await expectIndexed(
      "SELECT * FROM space_aliases WHERE space_id = 'sp1'",
    );
    await expectIndexed(
      "SELECT * FROM grade_components WHERE space_id = 'sp1'",
    );
    await expectIndexed(
      "SELECT * FROM class_exceptions WHERE class_slot_id = 'c1' "
      'AND deleted_at IS NULL',
    );
  });
}
