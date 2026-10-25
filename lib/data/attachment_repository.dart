import 'package:drift/drift.dart';
import 'database.dart';
import 'models.dart';

class AttachmentRepository {
  final AppDatabase db;
  AttachmentRepository(this.db);

  Stream<List<Attachment>> watchAttachments(String taskId) {
    return db.select(db.attachments)..where(db.attachments.taskId.equals(taskId)).watch();
  }

  Future<List<Attachment>> getAttachments(String taskId) async {
    return db.select(db.attachments)..where(db.attachments.taskId.equals(taskId)).get();
  }

  Future<void> insertAttachment(Attachment attachment) async {
    await db.into(db.attachments).insert(attachment);
  }

  Future<void> deleteAttachment(String id) async {
    await db.delete(db.attachments).delete(const Filter<Attachment>(db.attachments.id.equals(id)));
  }
}
