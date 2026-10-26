import 'package:drift/drift.dart';
import 'database.dart';

class ClassSlotRepository {
  final AppDatabase db;
  ClassSlotRepository(this.db);

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

  Future<void> insertClassSlot(ClassSlot slot) async {
    await db.into(db.classSlots).insert(slot);
  }

  Future<void> updateClassSlot(ClassSlot slot) async {
    await db.update(db.classSlots).replace(slot);
  }

  Future<void> deleteClassSlot(String id) async {
    await db.update(db.classSlots).replace(ClassSlot(
      id: id,
      spaceId: '',
      weekday: 0,
      startMin: 0,
      endMin: 0,
      kind: 'lecture',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      deletedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}
