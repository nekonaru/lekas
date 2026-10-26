import 'package:drift/drift.dart';
import 'database.dart';

class GradeComponentRepository {
  final AppDatabase db;
  GradeComponentRepository(this.db);

  Stream<List<GradeComponent>> watchGradeComponents(String spaceId) {
    return (db.select(db.gradeComponents)
          ..where((t) => t.spaceId.equals(spaceId)))
        .watch();
  }

  Future<List<GradeComponent>> getGradeComponents(String spaceId) async {
    return (db.select(db.gradeComponents)
          ..where((t) => t.spaceId.equals(spaceId)))
        .get();
  }

  Future<void> insertGradeComponent(GradeComponent component) async {
    await db.into(db.gradeComponents).insert(component);
  }

  Future<void> updateGradeComponent(GradeComponent component) async {
    await db.update(db.gradeComponents).replace(component);
  }

  Future<void> deleteGradeComponent(String spaceId, String key) async {
    await (db.delete(db.gradeComponents)..where((t) => t.spaceId.equals(spaceId) & t.key.equals(key))).go();
  }
}
