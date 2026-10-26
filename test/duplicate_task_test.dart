import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/tag_repository.dart';
import 'package:lekas/data/task_repository.dart';

void main() {
  late AppDatabase db;
  late TaskRepository tasks;
  late TagRepository tags;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tasks = TaskRepository(db);
    tags = TagRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('duplicate (design section 5.9)', () {
    test('a copy carries subtasks and tags but starts fresh', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final source = Task(
        id: 't1',
        title: 'Laprak Basdat',
        deadline: now + 86400000,
        priority: 2,
        status: 'done',
        isGroup: false,
        pinned: true,
        inbox: false,
        createdAt: now,
        completedAt: now,
        updatedAt: now,
      );
      await tasks.insertTask(source);
      await db.into(db.subtasks).insert(Subtask(
            id: 's1',
            taskId: 't1',
            title: 'bab 1',
            done: true,
            sortOrder: 0,
            updatedAt: now,
          ));
      await tags.setTaskTags('t1', ['#revisi']);

      final copy = await tasks.duplicateTask('t1');

      expect(copy.id, isNot('t1'));
      expect(copy.title, 'Laprak Basdat');
      expect(copy.status, 'todo');
      expect(copy.pinned, isFalse);
      expect(copy.completedAt, isNull);
      expect(copy.deadline, source.deadline);

      final subtasks = await db.select(db.subtasks).get();
      expect(subtasks, hasLength(2));
      final copySubtasks =
          subtasks.where((subtask) => subtask.taskId == copy.id).toList();
      expect(copySubtasks.single.title, 'bab 1');
      expect(copySubtasks.single.done, isFalse);

      final copyTags = await tags.tagsForTask(copy.id);
      expect(copyTags.map((tag) => tag.name), ['revisi']);
      expect(await tags.tagsForTask('t1'), hasLength(1));
    });
  });
}
