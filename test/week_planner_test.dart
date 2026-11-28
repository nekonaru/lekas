import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/domain/week_planner.dart';

Task _task(String id, DateTime due) => Task(
      id: id,
      title: id,
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      deadline: due.millisecondsSinceEpoch,
      createdAt: 1,
      updatedAt: 1,
    );

void main() {
  test('a week lays out tasks on their due day', () {
    final monday = DateTime(2026, 11, 23);
    final days = buildWeek(
      monday,
      [
        _task('a', DateTime(2026, 11, 23, 9)),
        _task('b', DateTime(2026, 11, 25, 12)),
        _task('c', DateTime(2026, 12, 5)),
      ],
      const [],
    );
    expect(days, hasLength(7));
    expect(days.first.tasks.map((t) => t.id), ['a']);
    expect(days[2].tasks.map((t) => t.id), ['b']);
    expect(days.last.tasks, isEmpty);
  });

  test('weekday slots appear on the matching day', () {
    final days = buildWeek(
      DateTime(2026, 11, 23),
      const [],
      [
        ClassSlot(
          id: 's1',
          spaceId: 'sp1',
          weekday: 3,
          startMin: 480,
          endMin: 540,
          kind: 'lecture',
          updatedAt: 1,
        ),
      ],
    );
    expect(days[0].classes, isEmpty);
    expect(days[2].classes.single.id, 's1');
  });
}
