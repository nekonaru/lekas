import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';
import 'space_repository.dart';

/// Aggregate of one semester: how many courses it holds and how its tasks
/// stand across them (design section 4.3).
class SemesterStats {
  const SemesterStats({
    this.courses = 0,
    this.totalTasks = 0,
    this.doneTasks = 0,
    this.overdueTasks = 0,
  });

  final int courses;
  final int totalTasks;
  final int doneTasks;
  final int overdueTasks;

  double get progress => totalTasks == 0 ? 0 : doneTasks / totalTasks;
}

/// Semesters group the courses (design: the Semester tab). One is active at
/// a time; switching flips the flag in the same transaction, so a space is
/// never without its semester.
class SemesterRepository {
  final AppDatabase db;
  SemesterRepository(this.db);

  Stream<List<Semester>> watchSemesters() {
    return (db.select(db.semesters)
          ..orderBy([
            (s) => OrderingTerm.desc(s.isActive),
            (s) => OrderingTerm.desc(s.createdAt),
          ]))
        .watch();
  }

  Future<List<Semester>> getSemesters() {
    return (db.select(db.semesters)
          ..orderBy([
            (s) => OrderingTerm.desc(s.isActive),
            (s) => OrderingTerm.desc(s.createdAt),
          ]))
        .get();
  }

  Future<Semester?> activeSemester() {
    return (db.select(db.semesters)..where((s) => s.isActive.equals(true)))
        .getSingleOrNull();
  }

  /// Every semester with its numbers in one pass: one spaces read, one
  /// tasks read, aggregated in memory. The tables are small, so this stays
  /// cheap on a phone and avoids an N+1 per row.
  Future<List<(Semester, SemesterStats)>> overview() async {
    final semesters = await getSemesters();
    if (semesters.isEmpty) return const [];
    final spaces = await db.select(db.spaces).get();
    final tasks = await (db.select(db.tasks)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    final tasksBySpace = <String, List<Task>>{};
    for (final task in tasks) {
      final spaceId = task.spaceId;
      if (spaceId == null) continue;
      (tasksBySpace[spaceId] ??= <Task>[]).add(task);
    }
    final spacesBySemester = <String, List<Space>>{};
    for (final space in spaces) {
      final semesterId = space.semesterId;
      if (semesterId == null) continue;
      (spacesBySemester[semesterId] ??= <Space>[]).add(space);
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final result = <(Semester, SemesterStats)>[];
    for (final semester in semesters) {
      final semSpaces = spacesBySemester[semester.id] ?? const <Space>[];
      var total = 0;
      var done = 0;
      var overdue = 0;
      for (final space in semSpaces) {
        for (final task in tasksBySpace[space.id] ?? const <Task>[]) {
          total++;
          if (task.status == 'done') {
            done++;
            continue;
          }
          if (task.deadline != null && task.deadline! < now) overdue++;
        }
      }
      result.add((
        semester,
        SemesterStats(
          courses: semSpaces.length,
          totalTasks: total,
          doneTasks: done,
          overdueTasks: overdue,
        ),
      ));
    }
    return result;
  }

  Future<Semester> createSemester(String name, {bool activate = true}) async {
    final trimmed = name.trim().isEmpty ? 'Semester' : name.trim();
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = const Uuid().v4();
    await db.transaction(() async {
      if (activate) {
        await db.update(db.semesters).write(
              const SemestersCompanion(isActive: Value(false)),
            );
      }
      await db.into(db.semesters).insert(
            SemestersCompanion.insert(
              id: id,
              name: trimmed,
              isActive: Value(activate),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
    return Semester(
      id: id,
      name: trimmed,
      isActive: activate,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> setActive(String id) async {
    await db.transaction(() async {
      await db.update(db.semesters).write(
            const SemestersCompanion(isActive: Value(false)),
          );
      await (db.update(db.semesters)..where((t) => t.id.equals(id))).write(
        SemestersCompanion(
          isActive: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
    });
  }

  Future<void> rename(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await (db.update(db.semesters)..where((t) => t.id.equals(id))).write(
      SemestersCompanion(
        name: Value(trimmed),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Deletes a semester and everything inside it. Its courses run through
  /// the same cascade as deleting a single course: schedule, notes, grades
  /// and attendance go with it, and its tasks move to the inbox. If the
  /// deleted semester was the active one, the newest remaining semester is
  /// promoted so the tab never opens on a vacuum.
  Future<void> deleteSemester(String id) async {
    final spaces = await (db.select(db.spaces)
          ..where((t) => t.semesterId.equals(id)))
        .get();
    final spaceRepo = SpaceRepository(db);
    for (final space in spaces) {
      await spaceRepo.deleteSpaceCascade(space.id);
    }
    final wasActive = await (db.select(db.semesters)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    await (db.delete(db.semesters)..where((t) => t.id.equals(id))).go();
    if (wasActive?.isActive == true) {
      final rest = await (db.select(db.semesters)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .get();
      for (final semester in rest) {
        await (db.update(db.semesters)..where((t) => t.id.equals(semester.id)))
            .write(const SemestersCompanion(isActive: Value(true)));
      }
    }
  }
}
