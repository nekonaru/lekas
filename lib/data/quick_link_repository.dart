import 'package:drift/drift.dart';
import 'database.dart';

class QuickLinkRepository {
  final AppDatabase db;
  QuickLinkRepository(this.db);

  final Map<String, Stream<List<QuickLink>>> _watchCache = {};

  SimpleSelectStatement<$QuickLinksTable, QuickLink> _active() =>
      db.select(db.quickLinks)..where((t) => t.deletedAt.isNull());

  Stream<List<QuickLink>> watchQuickLinks() {
    return _watchCache.putIfAbsent('quicklinks', () => _active().watch());
  }

  Future<void> insertQuickLink(QuickLink link) async {
    await db.into(db.quickLinks).insert(link);
  }

  Future<void> updateQuickLink(QuickLink link) async {
    await db.update(db.quickLinks).replace(link);
  }

  Future<void> deleteQuickLink(String id) async {
    await (db.update(db.quickLinks)..where((t) => t.id.equals(id))).write(
      QuickLinksCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
