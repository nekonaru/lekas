import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/flashcard_repository.dart';
import 'package:lekas/data/space_repository.dart';
import 'package:uuid/uuid.dart';

/// The flashcard repository owns the SM-2 scheduling writes; these tests
/// pin the due-count contract the deck list and the review screen rely on.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<(AppDatabase, FlashcardRepository, String)> seeded() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final spaces = SpaceRepository(db);
    final spaceId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await spaces.insertSpace(Space(
      id: spaceId,
      name: 'Biologi',
      color: 0xFF6366F1,
      level: 'school',
      kind: 'course',
      archived: false,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    ));
    return (db, FlashcardRepository(db), spaceId);
  }

  test('new cards are due immediately and show up in summaries', () async {
    final (_, repo, spaceId) = await seeded();
    await repo.addCard(front: 'Fotosintesis?', back: 'Di kloroplas', spaceId: spaceId);
    await repo.addCard(front: 'Ibu kota?', back: 'Jakarta');

    final decks = await repo.summaries();
    expect(decks.length, 2);
    final general = decks.where((d) => d.spaceId == null).single;
    final subject = decks.where((d) => d.spaceId == spaceId).single;
    expect(general.total, 1);
    expect(subject.total, 1);
    expect(general.due, 1);
    expect(subject.due, 1);
  });

  test('dueCards only returns overdue and today, most overdue first', () async {
    final (_, repo, spaceId) = await seeded();
    final card = await repo.addCard(front: 'a', back: 'b', spaceId: spaceId);
    final all = await repo.cardsOf(spaceId);
    expect(all, hasLength(1));
    final due = await repo.dueCards(spaceId);
    expect(due.map((c) => c.id), contains(card.id));
  });

  test('reviewing with good quality moves the due date forward', () async {
    final (_, repo, spaceId) = await seeded();
    final card = await repo.addCard(front: 'a', back: 'b', spaceId: spaceId);
    await repo.reviewCard(card, 5);
    await repo.reviewCard(
      (await repo.cardsOf(spaceId)).single,
      5,
    );
    final after = (await repo.cardsOf(spaceId)).single;
    expect(after.repetitions, 2);
    expect(after.intervalDays, 6);
    expect(after.dueAt, greaterThan(DateTime.now().millisecondsSinceEpoch));
  });

  test('reviewing with fail quality rebooks for tomorrow and adds a lapse', () async {
    final (_, repo, _) = await seeded();
    final card = await repo.addCard(front: 'a', back: 'b');
    await repo.reviewCard(card, 1);
    final after = (await repo.cardsOf(null)).single;
    expect(after.repetitions, 0);
    expect(after.intervalDays, 1);
    expect(after.lapses, 1);
  });

  test('soft-deleted cards disappear from decks and due lists', () async {
    final (_, repo, spaceId) = await seeded();
    final card = await repo.addCard(front: 'a', back: 'b', spaceId: spaceId);
    await repo.deleteCard(card.id);
    expect(await repo.cardsOf(spaceId), isEmpty);
    expect(await repo.dueCards(spaceId), isEmpty);
    expect((await repo.totals()).total, 0);
  });
}
