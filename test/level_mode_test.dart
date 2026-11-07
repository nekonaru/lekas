import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/models.dart';
import 'package:lekas/data/space_repository.dart';

/// Switching the jenjang rewrites every space at once, so there is no need
/// to reinstall or recreate spaces for the labels to agree with the mode.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<SpaceRepository> seeded() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = SpaceRepository(db);
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final id in ['a', 'b']) {
      await repo.insertSpace(
        Space(
          id: id,
          name: 'Space $id',
          color: 0xFF6366F1,
          kind: 'course',
          archived: false,
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    return repo;
  }

  test('setAllLevels rewrites every space', () async {
    final repo = await seeded();
    await repo.setAllLevels('school');
    final spaces = await repo.getSpaces();
    expect(spaces.map((space) => space.level), everyElement('school'));

    await repo.setAllLevels('college');
    final back = await repo.getSpaces();
    expect(back.map((space) => space.level), everyElement('college'));
  });
}
