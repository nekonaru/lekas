import 'package:drift/drift.dart';
import 'database.dart';

class AttachmentRepository {
  final AppDatabase db;
  AttachmentRepository(this.db);

  Stream<List<Attachment>> watchAttachments(String taskId) {
    return (db.select(db.attachments)
          ..where((t) => t.taskId.equals(taskId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<List<Attachment>> getAttachments(String taskId) async {
    return (db.select(db.attachments)
          ..where((t) => t.taskId.equals(taskId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> insertAttachment(Attachment attachment) async {
    await db.into(db.attachments).insert(attachment);
  }

  Future<void> deleteAttachment(String id) async {
    await (db.delete(db.attachments)..where((t) => t.id.equals(id))).go();
  }
}
