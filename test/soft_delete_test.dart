import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/class_note_repository.dart';
import 'package:lekas/data/class_slot_repository.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/quick_link_repository.dart';
import 'package:lekas/data/reminder_repository.dart';
import 'package:lekas/data/saved_filter_repository.dart';
import 'package:lekas/data/space_item_repository.dart';
import 'package:lekas/data/space_repository.dart';
import 'package:lekas/data/subtask_repository.dart';
import 'package:lekas/data/task_repository.dart';

/// Every soft delete in the app used to rebuild the whole row from a
/// handful of literals, so the row kept the new timestamp and lost its
/// title, notes, deadline, space and everything else. These tests pin the
/// column level updates down.
void main() {
  late AppDatabase db;
  late TaskRepository tasks;
  late SubtaskRepository subtasks;
  late SpaceRepository spaces;
  late ReminderRepository reminders;
  late ClassSlotRepository slots;
  late ClassNoteRepository notes;
  late SpaceItemRepository items;
  late SavedFilterRepository filters;
  late QuickLinkRepository links;

  final now = DateTime.now().millisecondsSinceEpoch;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tasks = TaskRepository(db);
    subtasks = SubtaskRepository(db);
    spaces = SpaceRepository(db);
    reminders = ReminderRepository(db);
    slots = ClassSlotRepository(db);
    notes = ClassNoteRepository(db);
    items = SpaceItemRepository(db);
    filters = SavedFilterRepository(db);
    links = QuickLinkRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Task buildTask({String id = 't1'}) => Task(
        id: id,
        spaceId: 'sp1',
        title: 'Laprak Basdat',
        notes: 'buat ERD',
        deadline: now + 86400000,
        priority: 1,
        status: 'todo',
        isGroup: false,
        pinned: true,
        inbox: false,
        createdAt: now,
        updatedAt: now,
      );

  group('soft delete keeps the row intact', () {
    test('trashing a task keeps title, notes, deadline and space', () async {
      await tasks.insertTask(buildTask());

      await tasks.softDeleteTask('t1');

      final trashed = await tasks.watchTrash().first;
      expect(trashed, hasLength(1));
      final row = trashed.single;
      expect(row.title, 'Laprak Basdat');
      expect(row.notes, 'buat ERD');
      expect(row.deadline, now + 86400000);
      expect(row.spaceId, 'sp1');
      expect(row.deletedAt, isNotNull);
      expect(row.pinned, isTrue);
      expect(await tasks.getTasks(), isEmpty);
    });

    test('restore brings the same task back', () async {
      await tasks.insertTask(buildTask());
      await tasks.softDeleteTask('t1');

      await tasks.restoreTask('t1');

      final back = await tasks.getTask('t1');
      expect(back.title, 'Laprak Basdat');
      expect(back.notes, 'buat ERD');
      expect(back.spaceId, 'sp1');
      expect(back.deletedAt, isNull);
      expect(await tasks.watchTrash().first, isEmpty);
    });

    test('permanent delete removes the row the trash shows', () async {
      await tasks.insertTask(buildTask());
      await tasks.softDeleteTask('t1');

      await tasks.deletePermanently('t1');

      expect(await tasks.watchTrash().first, isEmpty);
      expect(
        () => tasks.getTask('t1'),
        throwsA(isA<StateError>()),
      );
    });

    test('toggling a subtask keeps its title and parent', () async {
      await tasks.insertTask(buildTask());
      await subtasks.insertSubtask(Subtask(
        id: 's1',
        taskId: 't1',
        title: 'bab 1',
        done: false,
        sortOrder: 0,
        updatedAt: now,
      ));

      await subtasks.toggleSubtask('s1', true);

      final kept = await subtasks.getSubtasks('t1');
      expect(kept, hasLength(1));
      expect(kept.single.title, 'bab 1');
      expect(kept.single.taskId, 't1');
      expect(kept.single.done, isTrue);
    });

    test('deleting a subtask hides it but keeps the row content', () async {
      await tasks.insertTask(buildTask());
      await subtasks.insertSubtask(Subtask(
        id: 's1',
        taskId: 't1',
        title: 'bab 1',
        done: false,
        sortOrder: 0,
        updatedAt: now,
      ));

      await subtasks.deleteSubtask('s1');

      expect(await subtasks.getSubtasks('t1'), isEmpty);
      final row = await db.select(db.subtasks).getSingle();
      expect(row.title, 'bab 1');
      expect(row.taskId, 't1');
      expect(row.deletedAt, isNotNull);
    });

    test('archiving a space keeps its name, color and kind', () async {
      await spaces.insertSpace(Space(
        id: 'sp1',
        name: 'Basis Data',
        color: 0xFF2196F3,
        kind: 'course',
        archived: false,
        createdAt: now,
        updatedAt: now,
      ));

      await spaces.archiveSpace('sp1');

      final row = await spaces.getSpace('sp1');
      expect(row.name, 'Basis Data');
      expect(row.color, 0xFF2196F3);
      expect(row.kind, 'course');
      expect(row.archived, isTrue);
      expect(row.createdAt, now);
    });

    test('acking a reminder keeps its schedule', () async {
      await db.into(db.reminders).insert(Reminder(
            id: 'r1',
            taskId: 't1',
            fireAt: now + 3600000,
            kind: 'h1',
            notifId: 42,
            fired: true,
          ));

      await reminders.markAcked('r1');

      final row = await (db.select(db.reminders)
            ..where((t) => t.id.equals('r1')))
          .getSingle();
      expect(row.fireAt, now + 3600000);
      expect(row.notifId, 42);
      expect(row.fired, isTrue);
      expect(row.kind, 'h1');
      expect(row.ackedAt, isNotNull);
    });

    test('deleting a class slot keeps its timetable', () async {
      await slots.insertClassSlot(ClassSlot(
        id: 'c1',
        spaceId: 'sp1',
        weekday: 3,
        startMin: 480,
        endMin: 570,
        room: 'TIF 203',
        kind: 'lecture',
        updatedAt: now,
      ));

      await slots.deleteClassSlot('c1');

      final row = await (db.select(db.classSlots)
            ..where((t) => t.id.equals('c1')))
          .getSingle();
      expect(row.spaceId, 'sp1');
      expect(row.weekday, 3);
      expect(row.startMin, 480);
      expect(row.endMin, 570);
      expect(row.room, 'TIF 203');
      expect(row.deletedAt, isNotNull);
    });

    test('deleting a class note keeps its body', () async {
      await db.into(db.classNotes).insert(ClassNote(
            id: 'n1',
            spaceId: 'sp1',
            meetingNo: 2,
            title: 'Normalisasi',
            body: '1NF sampai 3NF',
            createdAt: now,
            updatedAt: now,
          ));

      await notes.deleteClassNote('n1');

      final row = await (db.select(db.classNotes)
            ..where((t) => t.id.equals('n1')))
          .getSingle();
      expect(row.title, 'Normalisasi');
      expect(row.body, '1NF sampai 3NF');
      expect(row.spaceId, 'sp1');
      expect(row.deletedAt, isNotNull);
    });

    test('deleting a space item keeps its title', () async {
      await db.into(db.spaceItems).insert(SpaceItem(
            id: 'i1',
            spaceId: 'sp1',
            title: 'Beli buku',
            sortOrder: 1,
            updatedAt: now,
          ));

      await items.deleteSpaceItem('i1');

      final row = await (db.select(db.spaceItems)
            ..where((t) => t.id.equals('i1')))
          .getSingle();
      expect(row.title, 'Beli buku');
      expect(row.deletedAt, isNotNull);
    });

    test('deleting a saved filter keeps its query', () async {
      await db.into(db.savedFilters).insert(SavedFilter(
            id: 'f1',
            name: 'Terlambat',
            queryJson: '{"status":"overdue"}',
            sortOrder: 0,
            updatedAt: now,
          ));

      await filters.deleteSavedFilter('f1');

      final row = await (db.select(db.savedFilters)
            ..where((t) => t.id.equals('f1')))
          .getSingle();
      expect(row.name, 'Terlambat');
      expect(row.queryJson, '{"status":"overdue"}');
      expect(row.deletedAt, isNotNull);
    });

    test('deleting a quick link keeps its url', () async {
      await db.into(db.quickLinks).insert(QuickLink(
            id: 'q1',
            title: 'Elearning',
            url: 'https://elearning.example.ac.id',
            sortOrder: 0,
            updatedAt: now,
          ));

      await links.deleteQuickLink('q1');

      final row = await (db.select(db.quickLinks)
            ..where((t) => t.id.equals('q1')))
          .getSingle();
      expect(row.title, 'Elearning');
      expect(row.url, 'https://elearning.example.ac.id');
      expect(row.deletedAt, isNotNull);
    });
  });

  group('inbox badge', () {
    test('counts inbox rows without loading them', () async {
      await tasks.insertTask(buildTask(id: 'a'));
      await tasks.insertTask(buildTask(id: 'b')
          .copyWith(inbox: true, spaceId: const Value(null)));
      await tasks.insertTask(buildTask(id: 'c')
          .copyWith(inbox: true, spaceId: const Value(null)));
      await tasks.softDeleteTask('c');

      expect(await tasks.countInbox(), 1);
    });
  });
}
