import 'database.dart';

class QuickLinkRepository {
  final AppDatabase db;
  QuickLinkRepository(this.db);

  Stream<List<QuickLink>> watchQuickLinks() {
    return (db.select(db.quickLinks)..where((t) => t.deletedAt.isNull()))
        .watch();
  }

  Future<List<QuickLink>> getQuickLinks() async {
    return (db.select(db.quickLinks)..where((t) => t.deletedAt.isNull()))
        .get();
  }

  Future<void> insertQuickLink(QuickLink link) async {
    await db.into(db.quickLinks).insert(link);
  }

  Future<void> updateQuickLink(QuickLink link) async {
    await db.update(db.quickLinks).replace(link);
  }

  Future<void> deleteQuickLink(String id) async {
    await db.update(db.quickLinks).replace(QuickLink(
      id: id,
      title: '',
      url: '',
      sortOrder: 0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      deletedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}
