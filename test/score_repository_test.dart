import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/score_repository.dart';
import 'package:lekas/data/space_repository.dart';
import 'package:uuid/uuid.dart';

/// The grade book stores raw score events; the screen computes the average
/// on the fly. These tests pin the storage contract: order, filter and
/// clamping.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<(AppDatabase, ScoreRepository, String)> seeded() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final spaceId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await SpaceRepository(db).insertSpace(Space(
      id: spaceId,
      name: 'Matematika',
      color: 0xFF6366F1,
      level: 'school',
      kind: 'course',
      archived: false,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    ));
    return (db, ScoreRepository(db), spaceId);
  }

  test('scores come back newest first and are clamped to 0-100', () async {
    final (_, repo, spaceId) = await seeded();
    final day = DateTime(2026, 11, 10, 9);
    await repo.addScore(
      spaceId: spaceId,
      label: 'Harian 1',
      value: 80,
      takenAt: day,
    );
    await repo.addScore(
      spaceId: spaceId,
      label: 'Harian 2',
      value: 120, // clamped to 100
      takenAt: day.add(const Duration(days: 2)),
    );
    final scores = await repo.getScores(spaceId);
    expect(scores.map((s) => s.label), ['Harian 2', 'Harian 1']);
    expect(scores.first.value, 100);
  });

  test('blank notes are stored as null', () async {
    final (_, repo, spaceId) = await seeded();
    await repo.addScore(spaceId: spaceId, label: 'UTS', value: 75, note: '   ');
    final scores = await repo.getScores(spaceId);
    expect(scores.single.note, isNull);
  });

  test('delete removes exactly the target row', () async {
    final (_, repo, spaceId) = await seeded();
    final first = await repo.addScore(spaceId: spaceId, label: 'A', value: 10);
    await repo.addScore(spaceId: spaceId, label: 'B', value: 20);
    await repo.deleteScore(first.id);
    final scores = await repo.getScores(spaceId);
    expect(scores.map((s) => s.label), ['B']);
  });

  test('watchScores emits on write', () async {
    final (_, repo, spaceId) = await seeded();
    final stream = repo.watchScores(spaceId);
    await repo.addScore(spaceId: spaceId, label: 'Harian 1', value: 88);
    final emitted = await stream.first;
    expect(emitted, hasLength(1));
    expect(emitted.single.value, 88);
  });
}
