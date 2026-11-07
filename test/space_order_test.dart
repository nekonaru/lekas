import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/models.dart';
import 'package:lekas/data/space_repository.dart';

/// The spaces list has a manual drag order: a drag writes stepped sort
/// orders and the list reopens in exactly that sequence.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('the drag order persists and sorts the list', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = SpaceRepository(db);
    final now = DateTime.now().millisecondsSinceEpoch;
    // Inserted out of alpha order on purpose: before any drag the tie
    // breaker is the name, after the drag the written order wins.
    for (final (id, name) in [('a', 'Zebra'), ('b', 'Alpha')]) {
      await repo.insertSpace(
        Space(
          id: id,
          name: name,
          color: 0xFF6366F1,
          kind: 'course',
          archived: false,
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    expect((await repo.getSpaces()).map((space) => space.id), ['b', 'a']);

    await repo.setSpaceOrder(['a', 'b']);
    final ordered = await repo.getSpaces();
    expect(ordered.map((space) => space.id), ['a', 'b']);
    expect(ordered.first.sortOrder, lessThan(ordered.last.sortOrder));
    expect(ordered.first.sortOrder, 1024);
  });
}
