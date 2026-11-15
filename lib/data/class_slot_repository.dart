import 'package:drift/drift.dart';
import 'database.dart';

class ClassSlotRepository {
  final AppDatabase db;
  ClassSlotRepository(this.db);

  final Map<String, Stream<List<ClassSlot>>> _watchCache = {};

  Stream<List<ClassSlot>> watchClassSlots(String spaceId) {
    return (db.select(db.classSlots)
          ..where((t) => t.spaceId.equals(spaceId) & t.deletedAt.isNull()))
        .watch();
  }

  Future<List<ClassSlot>> getClassSlots(String spaceId) async {
    return (db.select(db.classSlots)
          ..where((t) => t.spaceId.equals(spaceId) & t.deletedAt.isNull()))
        .get();
  }

  /// Every slot of every space, used by the summaries that count the classes
  /// of a whole day (design section 5.12).
  Future<List<ClassSlot>> getAllClassSlots() async {
    return (db.select(db.classSlots)..where((t) => t.deletedAt.isNull())).get();
  }

  /// Every slot across spaces as one watch stream, so the calendar lights
  /// up class days live instead of replacing the query per visit.
  Stream<List<ClassSlot>> watchAllClassSlots() {
    return _watchCache.putIfAbsent(
      'class-slots',
      () => (db.select(db.classSlots)..where((t) => t.deletedAt.isNull()))
          .watch(),
    );
  }

  Future<void> insertClassSlot(ClassSlot slot) async {
    await db.into(db.classSlots).insert(slot);
  }

  Future<void> updateClassSlot(ClassSlot slot) async {
    await db.update(db.classSlots).replace(slot);
  }

  Future<void> deleteClassSlot(String id) async {
    await (db.update(db.classSlots)..where((t) => t.id.equals(id))).write(
      ClassSlotsCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
