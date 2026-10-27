import 'package:drift/drift.dart';
import 'database.dart';

class ClassNoteRepository {
  final AppDatabase db;
  ClassNoteRepository(this.db);

  Stream<List<ClassNote>> watchClassNotes(String spaceId) {
    return (db.select(db.classNotes)
          ..where((t) => t.spaceId.equals(spaceId) & t.deletedAt.isNull()))
        .watch();
  }

  Future<List<ClassNote>> getClassNotes(String spaceId) async {
    return (db.select(db.classNotes)
          ..where((t) => t.spaceId.equals(spaceId) & t.deletedAt.isNull()))
        .get();
  }

  Future<void> insertClassNote(ClassNote note) async {
    await db.into(db.classNotes).insert(note);
  }

  Future<void> updateClassNote(ClassNote note) async {
    await db.update(db.classNotes).replace(note);
  }

  Future<void> deleteClassNote(String id) async {
    await (db.update(db.classNotes)..where((t) => t.id.equals(id))).write(
      ClassNotesCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
