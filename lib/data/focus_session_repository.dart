import 'package:drift/drift.dart';
import 'database.dart';
import 'models.dart';

class FocusSessionRepository {
  final AppDatabase db;
  FocusSessionRepository(this.db);

  Stream<List<FocusSession>> watchFocusSessions(String taskId) {
    return db.select(db.focusSessions)..where(db.focusSessions.taskId.equals(taskId)).watch();
  }

  Future<List<FocusSession>> getFocusSessions(String taskId) async {
    return db.select(db.focusSessions)..where(db.focusSessions.taskId.equals(taskId)).get();
  }

  Future<void> insertFocusSession(FocusSession session) async {
    await db.into(db.focusSessions).insert(session);
  }
}
