import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/attachment_repository.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/parsed_task_extras.dart';
import 'package:lekas/data/subtask_repository.dart';
import 'package:lekas/data/tag_repository.dart';
import 'package:lekas/data/task_repository.dart';

/// The side data of design section 7.15: the `#tag`, the proposed subtasks
/// and the links of a parsed message, written next to the saved task.
void main() {
  late AppDatabase db;
  late TaskRepository tasks;
  late TagRepository tags;
  late SubtaskRepository subtasks;
  late AttachmentRepository attachments;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tasks = TaskRepository(db);
    tags = TagRepository(db);
    subtasks = SubtaskRepository(db);
    attachments = AttachmentRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> newTask() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    const id = 't1';
    await tasks.insertTask(Task(
      id: id,
      title: 'Laprak Basdat',
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }

  group('saveParsedExtras (design section 7.15)', () {
    test('the tag is stored normalized and linked to the task', () async {
      final id = await newTask();

      await saveParsedExtras(
        taskId: id,
        tags: tags,
        subtasks: subtasks,
        attachments: attachments,
        tag: '#Kelompok',
      );

      final saved = await tags.tagsForTask(id);
      expect(saved.map((tag) => tag.name), ['kelompok']);
    });

    test('subtasks keep the order the parser proposed them in', () async {
      final id = await newTask();

      await saveParsedExtras(
        taskId: id,
        tags: tags,
        subtasks: subtasks,
        attachments: attachments,
        subtaskTitles: ['tepung', ' gula ', '', 'fermipan'],
        nowMs: 1000,
      );

      final saved = await subtasks.getSubtasks(id);
      expect(saved.map((subtask) => subtask.title),
          ['tepung', 'gula', 'fermipan']);
      expect(saved.map((subtask) => subtask.sortOrder), [0, 1, 2]);
      expect(saved.every((subtask) => !subtask.done), isTrue);
    });

    test('a link becomes an attachment with the link kind', () async {
      final id = await newTask();

      await saveParsedExtras(
        taskId: id,
        tags: tags,
        subtasks: subtasks,
        attachments: attachments,
        links: ['https://classroom.google.com/c/abc', ' www.contoh.ac.id '],
        nowMs: 2000,
      );

      final saved = await attachments.getAttachments(id);
      expect(saved, hasLength(2));
      expect(saved.first.kind, 'link');
      expect(saved.first.pathOrUrl, 'https://classroom.google.com/c/abc');
      expect(saved.last.pathOrUrl, 'www.contoh.ac.id');
      expect(saved.every((attachment) => attachment.createdAt == 2000), isTrue);
    });

    test('an empty parse writes nothing at all', () async {
      final id = await newTask();

      await saveParsedExtras(
        taskId: id,
        tags: tags,
        subtasks: subtasks,
        attachments: attachments,
      );

      expect(await tags.tagsForTask(id), isEmpty);
      expect(await subtasks.getSubtasks(id), isEmpty);
      expect(await attachments.getAttachments(id), isEmpty);
    });
  });
}
