import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';

/// Habits and their daily check-offs. Deleting a habit is a soft delete;
/// its check-offs stay behind in case the habit is revived later.
class HabitRepository {
  HabitRepository(this.db);

  final AppDatabase db;

  Future<Habit> createHabit({required String name, String color = '#6366F1'}) async {
    final trimmed = name.trim();
    final now = DateTime.now().millisecondsSinceEpoch;
    final habit = Habit(
      id: const Uuid().v4(),
      name: trimmed,
      color: color,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
    await db.into(db.habits).insert(habit);
    return habit;
  }

  Future<void> updateHabit(Habit habit) async {
    await db.update(db.habits).replace(
          habit.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch),
        );
  }

  Future<void> deleteHabit(String id) async {
    await (db.update(db.habits)..where((t) => t.id.equals(id))).write(
      HabitsCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Stream<List<Habit>> watchActiveHabits() {
    return (db.select(db.habits)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// One habit by id, or null when it is gone or deleted.
  Future<Habit?> getHabit(String id) {
    return (db.select(db.habits)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// All check-offs of one habit in a day-key range, inclusive.
  Future<List<HabitCheck>> checksOf({
    required String habitId,
    required String from,
    required String to,
  }) {
    return (db.select(db.habitChecks)
          ..where((t) => t.habitId.equals(habitId))
          ..where((t) => t.date.isBiggerOrEqualValue(from))
          ..where((t) => t.date.isSmallerOrEqualValue(to)))
        .get();
  }

  /// All check-offs of one habit, oldest first.
  Future<List<HabitCheck>> allChecksOf(String habitId) {
    return (db.select(db.habitChecks)
          ..where((t) => t.habitId.equals(habitId))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// Toggles the check for [habitId] on [date]. Tapping a rest day clears
  /// it instead of stacking a check on top.
  Future<bool> toggleCheck(String habitId, String date) async {
    return db.transaction(() async {
      final rows = await (db.select(db.habitChecks)
            ..where((t) => t.habitId.equals(habitId) & t.date.equals(date)))
          .get();
      for (final row in rows) {
        await (db.delete(db.habitChecks)..where((t) => t.id.equals(row.id))).go();
      }
      if (rows.isNotEmpty) return false;
      await db.into(db.habitChecks).insert(HabitCheck(
            id: const Uuid().v4(),
            habitId: habitId,
            date: date,
            kind: 'check',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ));
      return true;
    });
  }

  /// Marks [date] as a protected rest day: the streak continues but the
  /// day does not count as a check-in. Long press toggles it.
  Future<bool> toggleSkip(String habitId, String date) async {
    return db.transaction(() async {
      final rows = await (db.select(db.habitChecks)
            ..where((t) => t.habitId.equals(habitId) & t.date.equals(date)))
          .get();
      final wasSkipped = rows.any((row) => row.kind == 'skip');
      for (final row in rows) {
        await (db.delete(db.habitChecks)..where((t) => t.id.equals(row.id))).go();
      }
      if (wasSkipped) return false;
      await db.into(db.habitChecks).insert(HabitCheck(
            id: const Uuid().v4(),
            habitId: habitId,
            date: date,
            kind: 'skip',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ));
      return true;
    });
  }

  /// Check-offs of every active habit since [from], grouped flat.
  Future<List<HabitCheck>> recentChecks(String from) {
    return (db.select(db.habitChecks)
          ..where((t) => t.date.isBiggerOrEqualValue(from)))
        .get();
  }
}
