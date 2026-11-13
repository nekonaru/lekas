import 'package:drift/drift.dart';
import 'database.dart';

class SpaceRepository {
  final AppDatabase db;
  SpaceRepository(this.db);

  Stream<List<Space>> watchSpaces({bool includeArchived = false}) {
    return (db.select(db.spaces)
          ..where((t) =>
              includeArchived ? const Constant(true) : t.archived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<Space>> getSpaces({bool includeArchived = false}) async {
    return (db.select(db.spaces)
          ..where((t) =>
              includeArchived ? const Constant(true) : t.archived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<Space> getSpace(String id) async {
    return (db.select(db.spaces)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> insertSpace(Space space) async {
    var toInsert = space;
    // Kind 'category' is a free container by design: it belongs to no
    // semester. Everything else (courses and legacy kinds) lands in the
    // active semester while one exists. An empty result here means the
    // user deleted every semester, so the space stays unassigned instead of
    // being dropped.
    if (space.semesterId == null && space.kind != 'category') {
      final active = await (db.select(db.semesters)
            ..where((t) => t.isActive.equals(true)))
          .getSingleOrNull();
      if (active != null) {
        toInsert = space.copyWith(semesterId: Value(active.id));
      }
    }
    await db.into(db.spaces).insert(toInsert);
  }

  Future<void> updateSpace(Space space) async {
    await db.update(db.spaces).replace(space);
  }

  Future<void> archiveSpace(String id) async {
    await (db.update(db.spaces)..where((t) => t.id.equals(id))).write(
      SpacesCompanion(
        archived: const Value(true),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> deleteSpace(String id) async {
    await (db.delete(db.spaces)..where((t) => t.id.equals(id))).go();
  }

  /// Rewrites the jenjang of every live space in one write, so the level
  /// switch in settings applies without reinstalling.
  Future<void> setAllLevels(String level) async {
    await (db.update(db.spaces)).write(
      SpacesCompanion(
        level: Value(level),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Persists the drag order in stepped values (1024 per row), so one
  /// drag rarely rewrites every row.
  Future<void> setSpaceOrder(List<String> orderedIds) async {
    await db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (db.update(db.spaces)..where((t) => t.id.equals(orderedIds[i]))).write(
          SpacesCompanion(
            sortOrder: Value((i + 1) * 1024),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
      }
    });
  }

  /// Deletes a space with everything that hangs off it: schedule, attendance,
  /// notes, grade weights, checklists, aliases and metadata, in one
  /// transaction. Tasks are never lost: they move to the inbox instead.
  Future<void> deleteSpaceCascade(String id) async {
    await db.transaction(() async {
      await (db.delete(db.attendance)
            ..where((t) => t.spaceId.equals(id)))
          .go();
      await (db.delete(db.classSlots)
            ..where((t) => t.spaceId.equals(id)))
          .go();
      await (db.delete(db.classNotes)
            ..where((t) => t.spaceId.equals(id)))
          .go();
      await (db.delete(db.gradeComponents)
            ..where((t) => t.spaceId.equals(id)))
          .go();
      await (db.delete(db.spaceItems)
            ..where((t) => t.spaceId.equals(id)))
          .go();
      await (db.delete(db.spaceAliases)
            ..where((t) => t.spaceId.equals(id)))
          .go();
      await (db.delete(db.spaceMeta)
            ..where((t) => t.spaceId.equals(id)))
          .go();
      await (db.update(db.tasks)
            ..where((t) => t.spaceId.equals(id)))
          .write(
        TasksCompanion(
          spaceId: const Value(null),
          inbox: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      await deleteSpace(id);
    });
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

  /// Attendance settings of one course (design section 5.19): planned
  /// meetings, absence limit in percent, how izin and sick days count and
  /// whether the prompt after class is on.
  Future<void> setAttendanceSettings(
    String spaceId, {
    int? totalMeetings,
    int? maxAbsentPercent,
    bool? excusedCountsAbsent,
    bool? attendPrompt,
  }) async {
    await (db.update(db.spaces)..where((t) => t.id.equals(spaceId))).write(
      SpacesCompanion(
        totalMeetings: totalMeetings == null
            ? const Value.absent()
            : Value(totalMeetings),
        maxAbsentPercent: maxAbsentPercent == null
            ? const Value.absent()
            : Value(maxAbsentPercent),
        excusedCountsAbsent: excusedCountsAbsent == null
            ? const Value.absent()
            : Value(excusedCountsAbsent),
        attendPrompt: attendPrompt == null
            ? const Value.absent()
            : Value(attendPrompt),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
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
