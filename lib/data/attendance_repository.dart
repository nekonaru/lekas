import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../domain/attendance.dart';
import 'database.dart';

/// Records who attended which class meeting (design section 5.19). The row
/// type is `AttendanceData`, drift's generated name for the `attendance`
/// table, because the table class itself is called `Attendance`.
class AttendanceRepository {
  final AppDatabase db;
  AttendanceRepository(this.db);

  Stream<List<AttendanceData>> watchForSpace(String spaceId) {
    return (db.select(db.attendance)
          ..where((t) => t.spaceId.equals(spaceId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<AttendanceData>> getForSpace(String spaceId) async {
    return (db.select(db.attendance)
          ..where((t) => t.spaceId.equals(spaceId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Marks one meeting. The same slot on the same day is overwritten, so
  /// tapping a different mark corrects the record instead of adding one.
  Future<void> mark({
    required String spaceId,
    String? slotId,
    required String date,
    required String status,
    String? note,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final query = db.select(db.attendance)
      ..where((t) =>
          t.spaceId.equals(spaceId) &
          t.date.equals(date) &
          (slotId == null
              ? t.slotId.isNull()
              : t.slotId.equals(slotId)) &
          t.deletedAt.isNull());
    final existing = await query.getSingleOrNull();
    final normalized = normalizeAttendanceStatus(status);
    if (existing != null) {
      await (db.update(db.attendance)..where((t) => t.id.equals(existing.id)))
          .write(AttendanceCompanion(
        status: Value(normalized),
        note: Value(note),
        updatedAt: Value(now),
      ));
      return;
    }
    await db.into(db.attendance).insert(AttendanceData(
          id: const Uuid().v4(),
          spaceId: spaceId,
          slotId: slotId,
          date: date,
          status: normalized,
          note: note,
          updatedAt: now,
        ));
  }

  /// The quota numbers of one course (design section 5.19).
  Future<AttendanceSummary> summaryFor(Space space) async {
    final records = await getForSpace(space.id);
    return summarizeAttendance(
      totalMeetings: space.totalMeetings,
      maxAbsentPercent: space.maxAbsentPercent,
      excusedCountsAbsent: space.excusedCountsAbsent ?? false,
      statuses: [for (final record in records) record.status],
    );
  }

  /// Every course whose absence quota is down to its last one, used by the
  /// morning summary (design sections 5.12 and 5.19).
  Future<List<({String spaceId, int remaining})>> tightQuotas() async {
    final spaces = await (db.select(db.spaces)
          ..where((t) => t.deletedAt.isNull() & t.archived.equals(false)))
        .get();
    final result = <({String spaceId, int remaining})>[];
    for (final space in spaces) {
      final summary = await summaryFor(space);
      if (summary.lastOne || summary.exhausted) {
        result.add((spaceId: space.id, remaining: summary.remaining));
      }
    }
    return result;
  }
}
