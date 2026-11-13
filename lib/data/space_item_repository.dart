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
    await (db.update(db.spaceItems)..where((t) => t.id.equals(id))).write(
      SpaceItemsCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Rewrites the order in stepped values (1024 per row), so one drag
  /// rarely rewrites every row.
  Future<void> setSpaceItemOrder(List<String> orderedIds) async {
    await db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (db.update(db.spaceItems)
              ..where((t) => t.id.equals(orderedIds[i])))
            .write(
          SpaceItemsCompanion(
            sortOrder: Value((i + 1) * 1024),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
      }
    });
  }
}
