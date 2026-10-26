import 'package:drift/drift.dart';
import 'database.dart';

class SpaceItemRepository {
  final AppDatabase db;
  SpaceItemRepository(this.db);

  Stream<List<SpaceItem>> watchSpaceItems(String spaceId) {
    return (db.select(db.spaceItems)
          ..where((t) => t.spaceId.equals(spaceId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<List<SpaceItem>> getSpaceItems(String spaceId) async {
    return (db.select(db.spaceItems)
          ..where((t) => t.spaceId.equals(spaceId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<void> insertSpaceItem(SpaceItem item) async {
    await db.into(db.spaceItems).insert(item);
  }

  Future<void> updateSpaceItem(SpaceItem item) async {
    await db.update(db.spaceItems).replace(item);
  }

  Future<void> deleteSpaceItem(String id) async {
    await db.update(db.spaceItems).replace(SpaceItem(
      id: id,
      spaceId: '',
      title: '',
      sortOrder: 0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      deletedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}
