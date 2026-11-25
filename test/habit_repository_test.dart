import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/habit_repository.dart';
import 'package:lekas/domain/habits.dart';

/// The habit repository owns the one-tap check off. These tests pin the
/// toggle contract the 7-day grid relies on.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<(AppDatabase, HabitRepository, Habit)> seeded() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = HabitRepository(db);
    final habit = await repo.createHabit(name: 'Baca', color: '#10B981');
    return (db, repo, habit);
  }

  test('createHabit trims the name and defaults the color', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = HabitRepository(db);
    final habit = await repo.createHabit(name: '  Olahraga  ');
    expect(habit.name, 'Olahraga');
    expect(habit.color, '#6366F1');
  });

  test('toggleCheck flips on and off, exactly once per day', () async {
    final (_, repo, habit) = await seeded();
    final day = dayKeyOf(DateTime.now());

    expect(await repo.toggleCheck(habit.id, day), isTrue);
    expect(await repo.toggleCheck(habit.id, day), isFalse);

    // A third toggle checks again; there is never a duplicate row.
    expect(await repo.toggleCheck(habit.id, day), isTrue);
    final checks = await repo.allChecksOf(habit.id);
    expect(checks.where((row) => row.date == day), hasLength(1));
  });

  test('soft-deleted habits disappear from active lists but keep history',
      () async {
    final (_, repo, habit) = await seeded();
    final day = dayKeyOf(DateTime.now());
    await repo.toggleCheck(habit.id, day);
    await repo.deleteHabit(habit.id);

    expect(await repo.watchActiveHabits().first, isEmpty);
    expect(await repo.allChecksOf(habit.id), hasLength(1));
  });

  test('a rest day swaps with a check and is not counted as a check-in',
      () async {
    final (_, repo, habit) = await seeded();
    final day = dayKeyOf(DateTime.now());
    expect(await repo.toggleSkip(habit.id, day), isTrue);
    var rows = await repo.allChecksOf(habit.id);
    expect(rows.single.kind, 'skip');
    // Tapping clears the rest day in one step.
    expect(await repo.toggleCheck(habit.id, day), isFalse);
    rows = await repo.allChecksOf(habit.id);
    expect(rows, isEmpty);
    // Long press again turns it into a rest day, then back off.
    expect(await repo.toggleSkip(habit.id, day), isTrue);
    expect(await repo.toggleSkip(habit.id, day), isFalse);
  });

  test('recentChecks returns everything inside the window only', () async {
    final (_, repo, habit) = await seeded();
    final today = dayKeyOf(DateTime.now());
    final old = dayKeyOf(DateTime.now().subtract(const Duration(days: 60)));
    await repo.toggleCheck(habit.id, today);
    await repo.toggleCheck(habit.id, old);

    final recent = await repo.recentChecks(
      dayKeyOf(DateTime.now().subtract(const Duration(days: 7))),
    );
    expect(recent.map((row) => row.date), [today]);
  });
}
