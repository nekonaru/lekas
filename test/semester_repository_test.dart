import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/models.dart';
import 'package:lekas/data/semester_repository.dart';
import 'package:lekas/data/space_repository.dart';
import 'package:lekas/data/task_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  const day = 24 * 60 * 60 * 1000;
  final now = DateTime.now().millisecondsSinceEpoch;

  Space spaceFixture(String id, String name) => Space(
        id: id,
        name: name,
        color: 0xFF42A5F5,
        kind: 'course',
        archived: false,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );

  Task taskFixture(String id, String? spaceId, {String status = 'todo', int? deadline}) =>
      Task(
        id: id,
        spaceId: spaceId,
        title: id,
        priority: 1,
        status: status,
        isGroup: false,
        pinned: false,
        inbox: spaceId == null,
        deadline: deadline,
        createdAt: now,
        updatedAt: now,
      );

  test('a fresh database has one active default semester', () async {
    final semesters = await SemesterRepository(db).getSemesters();
    expect(semesters, hasLength(1));
    expect(semesters.single.name, 'Semester 1');
    expect(semesters.single.isActive, isTrue);
  });

  test('a new space lands in the active semester', () async {
    await SpaceRepository(db).insertSpace(spaceFixture('s1', 'Kalkulus'));
    final space = await SpaceRepository(db).getSpace('s1');
    final active = await SemesterRepository(db).activeSemester();
    expect(active, isNotNull);
    expect(space.semesterId, active!.id);
  });

  test('createSemester flips the active flag atomically', () async {
    final repo = SemesterRepository(db);
    final created = await repo.createSemester('Ganjil 2026/2027');
    final semesters = await repo.getSemesters();
    final actives = semesters.where((s) => s.isActive).toList();
    expect(actives, hasLength(1));
    expect(actives.single.id, created.id);
  });

  test('setActive moves the flag to the chosen semester', () async {
    final repo = SemesterRepository(db);
    final a = await repo.activeSemester();
    final b = await repo.createSemester('Genap 2026/2027');
    expect(b.isActive, isTrue);

    await repo.setActive(a!.id);
    final semesters = await repo.getSemesters();
    final actives = semesters.where((s) => s.isActive).toList();
    expect(actives, hasLength(1));
    expect(actives.single.id, a.id);
  });

  test('overview aggregates courses and task progress per semester', () async {
    final spaceRepo = SpaceRepository(db);
    final taskRepo = TaskRepository(db);
    final semesterRepo = SemesterRepository(db);
    final active = await semesterRepo.activeSemester();
    await spaceRepo.insertSpace(spaceFixture('s1', 'Kalkulus'));
    await spaceRepo.insertSpace(spaceFixture('s2', 'Fisika'));
    await taskRepo.insertTask(taskFixture('t1', 's1', status: 'done'));
    await taskRepo.insertTask(taskFixture('t2', 's1'));
    await taskRepo.insertTask(
      taskFixture('t3', 's2', deadline: now - day), // overdue
    );

    final overview = await semesterRepo.overview();
    final entry = overview.singleWhere((e) => e.$1.id == active!.id);
    expect(entry.$2.courses, 2);
    expect(entry.$2.totalTasks, 3);
    expect(entry.$2.doneTasks, 1);
    expect(entry.$2.overdueTasks, 1);
    expect(entry.$2.progress, closeTo(1 / 3, 0.001));
  });

  test('deleting a semester moves its tasks to the inbox and deletes courses',
      () async {
    final semesterRepo = SemesterRepository(db);
    final spaceRepo = SpaceRepository(db);
    final taskRepo = TaskRepository(db);
    await spaceRepo.insertSpace(spaceFixture('s1', 'Kalkulus'));
    await taskRepo.insertTask(taskFixture('t1', 's1'));
    await taskRepo.insertTask(taskFixture('t2', null));

    // A separate semester holding the same space, so deleting the semester
    // takes the course and its task with it.
    final second = await semesterRepo.createSemester('Genap 2026/2027');
    await spaceRepo.insertSpace(
      spaceFixture('s1-copy', 'Kalkulus').copyWith(semesterId: Value(second.id)),
    );
    await taskRepo.insertTask(taskFixture('t3', 's1-copy'));

    await semesterRepo.deleteSemester(second.id);

    expect(await spaceRepo.getSpaces(includeArchived: true).then(
          (list) => list.any((space) => space.id == 's1-copy'),
        ), isFalse);
    final moved = await taskRepo.getTask('t3');
    expect(moved.spaceId, isNull);
    expect(moved.inbox, isTrue);
  });

  test('deleting the active semester promotes the newest remaining one',
      () async {
    final repo = SemesterRepository(db);
    final first = await repo.activeSemester();
    final second = await repo.createSemester('Genap 2026/2027');
    expect(second.isActive, isTrue);

    await repo.deleteSemester(second.id);
    final semesters = await repo.getSemesters();
    final actives = semesters.where((s) => s.isActive).toList();
    expect(actives, hasLength(1));
    expect(actives.single.id, first!.id);
  });

  test('renaming a semester trims and applies the name', () async {
    final repo = SemesterRepository(db);
    final active = await repo.activeSemester();
    await repo.rename(active!.id, '  Ganjil 2026/2027  ');
    final semesters = await repo.getSemesters();
    expect(semesters.single.name, 'Ganjil 2026/2027');
  });
}
