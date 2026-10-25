import 'package:drift/drift.dart';
import 'database.dart';
import 'models.dart';

class SavedFilterRepository {
  final AppDatabase db;
  SavedFilterRepository(this.db);

  Stream<List<SavedFilter>> watchSavedFilters() {
    return db.select(db.savedFilters)..where(db.savedFilters.deletedAt.isNull()).watch();
  }

  Future<List<SavedFilter>> getSavedFilters() async {
    return db.select(db.savedFilters)..where(db.savedFilters.deletedAt.isNull()).get();
  }

  Future<void> insertSavedFilter(SavedFilter filter) async {
    await db.into(db.savedFilters).insert(filter);
  }

  Future<void> updateSavedFilter(SavedFilter filter) async {
    await db.update(db.savedFilters).replace(filter);
  }

  Future<void> deleteSavedFilter(String id) async {
    await db.update(db.savedFilters).replace(SavedFilter(
      id: id,
      name: '',
      queryJson: '',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      deletedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}
