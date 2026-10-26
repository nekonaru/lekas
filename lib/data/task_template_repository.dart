import 'package:drift/drift.dart';
import 'database.dart';

class TaskTemplateRepository {
  final AppDatabase db;
  TaskTemplateRepository(this.db);

  Stream<List<TaskTemplate>> watchTaskTemplates() {
    return db.select(db.taskTemplates).watch();
  }

  Future<List<TaskTemplate>> getTaskTemplates() async {
    return db.select(db.taskTemplates).get();
  }

  Future<void> insertTaskTemplate(TaskTemplate template) async {
    await db.into(db.taskTemplates).insert(template);
  }

  Future<void> updateTaskTemplate(TaskTemplate template) async {
    await db.update(db.taskTemplates).replace(template);
  }

  Future<void> deleteTaskTemplate(String id) async {
    await (db.delete(db.taskTemplates)..where((t) => t.id.equals(id))).go();
  }
}
