import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/models.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/data/space_repository.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:lekas/features/spaces/spaces_screen.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// Deleting a space must clean every child it owns (schedule, attendance,
/// notes, grades, checklists, aliases, meta) and move its tasks to the
/// inbox, all in one place. The archived list opens through the Aktif and
/// Arsip segments.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  AppDatabase db() => AppDatabase(NativeDatabase.memory());

  test('the cascade removes children and moves tasks to the inbox', () async {
    final database = db();
    addTearDown(database.close);
    final spaces = SpaceRepository(database);
    final tasks = TaskRepository(database);
    final now = DateTime.now().millisecondsSinceEpoch;
    final space = Space(
      id: 'sp1',
      name: 'Basdat',
      color: 0xFF6366F1,
      kind: 'course',
      archived: false,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
    await spaces.insertSpace(space);
    await tasks.insertTask(Task(
      id: 't1',
      spaceId: 'sp1',
      title: 'Laprak',
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      createdAt: now,
      updatedAt: now,
    ));
    // One child row per table, the way the screens create them.
    await database.into(database.attendance).insert(
          AttendanceCompanion.insert(
            id: 'att1',
            spaceId: 'sp1',
            date: '2026-11-07',
            status: 'present',
            updatedAt: now,
          ),
        );
    await database.into(database.spaceAliases).insert(
          SpaceAliase(spaceId: 'sp1', alias: 'basis data'),
        );
    await spaces.setMeta('sp1', 'kind', 'course');

    await spaces.deleteSpaceCascade('sp1');

    final orphaned = await tasks.getTask('t1');
    expect(orphaned.spaceId, isNull);
    expect(orphaned.inbox, isTrue);

    expect((await database.select(database.attendance).get()), isEmpty);
    expect(
        (await database.select(database.spaceAliases).get()), isEmpty);
    expect(await spaces.getMeta('sp1', 'kind'), isNull);
    await expectLater(spaces.getSpace('sp1'), throwsA(anything));
  });

  testWidgets('the archive segment restores an archived space',
      (tester) async {
    final database = db();
    addTearDown(database.close);
    final spaces = SpaceRepository(database);
    final now = DateTime.now().millisecondsSinceEpoch;
    await spaces.insertSpace(Space(
      id: 'sp1',
      name: 'Arsip test',
      color: 0xFF6366F1,
      kind: 'course',
      archived: true,
      sortOrder: 1024,
      createdAt: now,
      updatedAt: now,
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SpacesScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Archived rows are hidden on the active segment.
    expect(find.text('Arsip test'), findsNothing);

    await tester.tap(find.text('Archive'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Arsip test'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.restore).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    final space = await spaces.getSpace('sp1');
    expect(space.archived, isFalse);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
