import 'package:drift/drift.dart';
import 'database.dart';

class SpaceRepository {
  final AppDatabase db;
  SpaceRepository(this.db);

  Stream<List<Space>> watchSpaces({bool includeArchived = false}) {
    return (db.select(db.spaces)
          ..where((t) =>
              includeArchived ? const Constant(true) : t.archived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<Space>> getSpaces({bool includeArchived = false}) async {
    return (db.select(db.spaces)
          ..where((t) =>
              includeArchived ? const Constant(true) : t.archived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<Space> getSpace(String id) async {
    return (db.select(db.spaces)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> insertSpace(Space space) async {
    await db.into(db.spaces).insert(space);
  }

  Future<void> updateSpace(Space space) async {
    await db.update(db.spaces).replace(space);
  }

  Future<void> archiveSpace(String id) async {
    await db.update(db.spaces).replace(Space(
      id: id,
      name: '',
      color: 0,
      kind: 'course',
      archived: true,
      createdAt: 0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> deleteSpace(String id) async {
    await (db.delete(db.spaces)..where((t) => t.id.equals(id))).go();
  }

  Future<void> insertAlias(SpaceAliase alias) async {
    await db.into(db.spaceAliases).insert(alias);
  }

  Future<List<String>> getAliases(String spaceId) async {
    final rows = await (db.select(db.spaceAliases)
          ..where((t) => t.spaceId.equals(spaceId)))
        .get();
    return rows.map((r) => r.alias).toList();
  }

  Future<void> setMeta(String spaceId, String key, String? value) async {
    await db.customStatement('''
      INSERT INTO space_meta (space_id, key, value) VALUES (?, ?, ?)
      ON CONFLICT(space_id, key) DO UPDATE SET value = excluded.value
    ''', [spaceId, key, value]);
  }

  Future<String?> getMeta(String spaceId, String key) async {
    final result = await (db.select(db.spaceMeta)
          ..where((t) => t.spaceId.equals(spaceId) & t.key.equals(key)))
        .get();
    return result.isEmpty ? null : result.first.value;
  }
}
