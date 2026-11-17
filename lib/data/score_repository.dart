import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';

/// The SMA grade book: one row per score event, newest first.
class ScoreRepository {
  ScoreRepository(this.db);

  final AppDatabase db;

  Future<Score> addScore({
    required String spaceId,
    required String label,
    required int value,
    String? note,
    DateTime? takenAt,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final score = Score(
      id: const Uuid().v4(),
      spaceId: spaceId,
      label: label.trim(),
      value: value.clamp(0, 100),
      note: note == null || note.trim().isEmpty ? null : note.trim(),
      takenAt: (takenAt ?? DateTime.now()).millisecondsSinceEpoch,
      createdAt: now,
      updatedAt: now,
    );
    await db.into(db.scores).insert(score);
    return score;
  }

  Future<void> updateScore(Score score) async {
    await db.update(db.scores).replace(
          score.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch),
        );
  }

  Future<void> deleteScore(String id) async {
    await (db.delete(db.scores)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteScoresOf(String spaceId) async {
    await (db.delete(db.scores)..where((t) => t.spaceId.equals(spaceId))).go();
  }

  /// Newest first, so the list reads like a grade log.
  Future<List<Score>> getScores(String spaceId) {
    return (db.select(db.scores)
          ..where((t) => t.spaceId.equals(spaceId))
          ..orderBy([(t) => OrderingTerm.desc(t.takenAt)]))
        .get();
  }

  Stream<List<Score>> watchScores(String spaceId) {
    return (db.select(db.scores)
          ..where((t) => t.spaceId.equals(spaceId))
          ..orderBy([(t) => OrderingTerm.desc(t.takenAt)]))
        .watch();
  }
}
