import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:lekas/domain/focus.dart';

void main() {
  group('focus of the day (design section 5.24)', () {
    test('a pick belongs to exactly one local day', () {
      final monday = DateTime(2026, 10, 26, 9, 30);
      final pick = startOfDayMs(monday) + 3600000;
      expect(isFocusOnDay(pick, monday), isTrue);
      expect(isFocusOnDay(pick, DateTime(2026, 10, 27)), isFalse);
      expect(isFocusOnDay(pick, DateTime(2026, 10, 25)), isFalse);
      expect(isFocusOnDay(null, monday), isFalse);
    });

    test('the first day of the month still counts', () {
      final first = DateTime(2026, 11, 1);
      expect(isFocusOnDay(startOfDayMs(first), first), isTrue);
      expect(isFocusOnDay(startOfDayMs(first), DateTime(2026, 10, 31)),
          isFalse);
    });

    test('at most three tasks share the focus', () {
      expect(focusHasRoom(0), isTrue);
      expect(focusHasRoom(2), isTrue);
      expect(focusHasRoom(3), isFalse);
      expect(focusHasRoom(4), isFalse);
    });

    test('the celebration needs focus tasks and all of them done', () {
      expect(focusAllDone(const []), isFalse);
      expect(focusAllDone(const [true]), isTrue);
      expect(focusAllDone(const [true, false]), isFalse);
      expect(focusAllDone(const [true, true, true]), isTrue);
    });
  });

  group('focus records (design section 5.24)', () {
    late AppDatabase db;
    late TaskRepository tasks;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      tasks = TaskRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> makeTask(String id) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await tasks.insertTask(Task(
        id: id,
        title: id,
        priority: 1,
        status: 'todo',
        isGroup: false,
        pinned: false,
        inbox: false,
        createdAt: now,
        updatedAt: now,
      ));
    }

    test('picking stores the day and clearing releases it', () async {
      await makeTask('t1');
      final day = startOfDayMs(DateTime.now());
      await tasks.setFocusDate('t1', day);
      expect((await tasks.getTask('t1')).focusDate, day);
      expect(isFocusOnDay((await tasks.getTask('t1')).focusDate, DateTime.now()),
          isTrue);

      await tasks.setFocusDate('t1', null);
      expect((await tasks.getTask('t1')).focusDate, isNull);
    });

    test('reopening clears the completion mark', () async {
      await makeTask('t1');
      await tasks.markDone('t1');
      expect((await tasks.getTask('t1')).status, 'done');

      await tasks.reopenTask('t1');
      final reopened = await tasks.getTask('t1');
      expect(reopened.status, 'todo');
      expect(reopened.completedAt, isNull);
    });

    test('a duplicate never steals a focus slot', () async {
      await makeTask('t1');
      await tasks.setFocusDate('t1', startOfDayMs(DateTime.now()));

      final copy = await tasks.duplicateTask('t1');
      expect(copy.focusDate, isNull);
      expect(isFocusOnDay((await tasks.getTask('t1')).focusDate, DateTime.now()),
          isTrue);
    });
  });
}
