import 'package:drift/drift.dart';
import 'database.dart';
import 'models.dart';

class ClassExceptionRepository {
  final AppDatabase db;
  ClassExceptionRepository(this.db);

  Stream<List<ClassException>> watchClassExceptions({String? classSlotId}) {
    final query = db.select(db.classExceptions);
    if (classSlotId != null) {
      query..where(db.classExceptions.classSlotId.equals(classSlotId));
    }
    return query.watch();
  }

  Future<List<ClassException>> getClassExceptions({String? classSlotId}) async {
    final query = db.select(db.classExceptions);
    if (classSlotId != null) {
      query..where(db.classExceptions.classSlotId.equals(classSlotId));
    }
    return query.get();
  }

  Future<void> insertClassException(ClassException exception) async {
    await db.into(db.classExceptions).insert(exception);
  }

  Future<void> updateClassException(ClassException exception) async {
    await db.update(db.classExceptions).replace(exception);
  }

  Future<void> deleteClassException(String id) async {
    await db.delete(db.classExceptions).delete(const Filter<ClassException>(db.classExceptions.id.equals(id)));
  }
}
