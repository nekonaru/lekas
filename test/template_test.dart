import 'dart:convert';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:lekas/data/task_template_repository.dart';

void main() {
  group('template payload (design section 5.9)', () {
    test('titles survive a round trip', () {
      final encoded = encodeSubtaskTitles(['bab 1', 'bab 2']);
      expect(jsonDecode(encoded), isA<List>());
      expect(decodeSubtaskTitles(encoded), ['bab 1', 'bab 2']);
    });

    test('a damaged payload reads as no subtasks', () {
      expect(decodeSubtaskTitles(null), isEmpty);
      expect(decodeSubtaskTitles(''), isEmpty);
      expect(decodeSubtaskTitles('not json'), isEmpty);
      expect(decodeSubtaskTitles('{"a":1}'), isEmpty);
    });

    test('an object list from an older backup still loads', () {
      expect(
        decodeSubtaskTitles('[{"title":"bab 1"},{"title":"bab 2"}]'),
        ['bab 1', 'bab 2'],
      );
    });
  });

  group('tasks from templates (design section 5.9)', () {
    late AppDatabase db;
    late TaskRepository tasks;
    late TaskTemplateRepository templates;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      tasks = TaskRepository(db);
      templates = TaskTemplateRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('a template keeps name, type, estimate and subtask titles', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final source = Task(
        id: 't1',
        title: 'Laprak',
        type: 'laporan',
        estimateMinutes: 120,
        priority: 1,
        status: 'todo',
        isGroup: false,
        pinned: false,
        inbox: false,
        createdAt: now,
        updatedAt: now,
      );

      final template = await templates.saveFromTask(
        source,
        'Laprak mingguan',
        ['bab 1', 'bab 2'],
      );

      expect(template.name, 'Laprak mingguan');
      expect(template.type, 'laporan');
      expect(template.estimateMinutes, 120);
      expect(decodeSubtaskTitles(template.subtasksJson), ['bab 1', 'bab 2']);
      expect(await templates.getTaskTemplates(), hasLength(1));
    });

    test('a new task from a template comes pre filled', () async {
      final template = TaskTemplate(
        id: 'tpl1',
        name: 'Laprak mingguan',
        type: 'laporan',
        estimateMinutes: 90,
        subtasksJson: encodeSubtaskTitles(['bab 1', 'revisi']),
      );
      await templates.insertTaskTemplate(template);

      final task = await tasks.createFromTemplate(template);

      expect(task.title, 'Laprak mingguan');
      expect(task.type, 'laporan');
      expect(task.estimateMinutes, 90);
      expect(task.status, 'todo');
      expect(task.inbox, isTrue);
      expect(task.deadline, isNull);

      final subtasks = await (db.select(db.subtasks)
            ..where((t) => t.taskId.equals(task.id))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
      expect(subtasks.map((subtask) => subtask.title), ['bab 1', 'revisi']);
      expect(subtasks.every((subtask) => !subtask.done), isTrue);
    });
  });
}
