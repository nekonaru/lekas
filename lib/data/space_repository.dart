import 'package:drift/drift.dart';
import 'database.dart';
import 'models.dart';

class SpaceRepository {
  final AppDatabase db;
  SpaceRepository(this.db);

  Stream<List<Space>> watchSpaces({bool includeArchived = false}) {
    return db.select(db.spaces).where(
      includeArchived ? const Constant(true) : db.spaces.archived.equals(false),
    ).watch();
  }

  Future<List<Space>> getSpaces({bool includeArchived = false}) async {
    return db.select(db.spaces).where(
      includeArchived ? const Constant(true) : db.spaces.archived.equals(false),
    ).get();
  }

  Future<Space> getSpace(String id) async {
    final result = await db.select(db.spaces)..where(db.spaces.id.equals(id));
    return result.getSingle();
  }

  Future<void> insertSpace(Space space) async {
    await db.into(db.spaces).insert(space);
  }

  Future<void> updateSpace(Space space) async {
    await db.update(db.spaces).replace(space);
  }

  Future<void> archiveSpace(String id) async {
    await db.update(db.spaces).replace(Space(id: id, name: '', archived: true, createdAt: 0, updatedAt: DateTime.now().millisecondsSinceEpoch));
  }

  Future<void> deleteSpace(String id) async {
    await (delete(db.spaces)..where(db.spaces.id.equals(id))).go();
  }

  Future<void> insertAlias(SpaceAlias alias) async {
    await db.into(db.spaceAliases).insert(alias);
  }

  Future<List<String>> getAliases(String spaceId) async {
    final query = db.select(db.spaceAliases)..where(db.spaceAliases.spaceId.equals(spaceId));
    final rows = await query.get();
    return rows.map((r) => r.alias).toList();
  }

  Future<void> setMeta(String spaceId, String key, String? value) async {
    await db.customStatement('''
      INSERT INTO space_meta (space_id, key, value) VALUES (?, ?, ?)
      ON CONFLICT(space_id, key) DO UPDATE SET value = excluded.value
    ''', [spaceId, key, value]);
  }

  Future<String?> getMeta(String spaceId, String key) async {
    final result = await db.select(db.spaceMeta)..where(
      db.spaceMeta.spaceId.equals(spaceId).and(db.spaceMeta.key.equals(key)),
    );
    final rows = result.get();
    return rows.isEmpty ? null : rows.first.value;
  }
}
