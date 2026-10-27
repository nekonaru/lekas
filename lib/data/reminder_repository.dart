import 'package:drift/drift.dart';
import 'database.dart';

class ReminderRepository {
  final AppDatabase db;
  ReminderRepository(this.db);

  Stream<List<Reminder>> watchReminders() {
    return (db.select(db.reminders)..where((t) => t.fired.equals(false)))
        .watch();
  }

  Future<List<Reminder>> getReminders() async {
    return (db.select(db.reminders)..where((t) => t.fired.equals(false)))
        .get();
  }

  Future<void> insertReminder(Reminder reminder) async {
    await db.into(db.reminders).insert(reminder);
  }

  Future<void> updateReminder(Reminder reminder) async {
    await db.update(db.reminders).replace(reminder);
  }

  Future<void> deleteReminder(String id) async {
    await (db.delete(db.reminders)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markAcked(String id) async {
    await (db.update(db.reminders)..where((t) => t.id.equals(id)))
        .write(RemindersCompanion(
      ackedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }
}
