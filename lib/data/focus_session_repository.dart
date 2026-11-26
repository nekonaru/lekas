import 'package:drift/drift.dart';

import 'database.dart';

class FocusSessionRepository {
  final AppDatabase db;
  FocusSessionRepository(this.db);

  /// Every session started at or after [sinceMillis], oldest first.
  /// Feeds the study statistics screen without a full table scan.
  Future<List<FocusSession>> getFocusSessionsSince(int sinceMillis) {
    return (db.select(db.focusSessions)
          ..where((t) => t.startedAt.isBiggerOrEqualValue(sinceMillis))
          ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
        .get();
  }

  Future<void> insertFocusSession(FocusSession session) async {
    await db.into(db.focusSessions).insert(session);
  }
}
