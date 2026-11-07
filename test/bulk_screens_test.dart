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
import 'package:lekas/features/inbox/inbox_screen.dart';
import 'package:lekas/features/spaces/spaces_screen.dart';
import 'package:lekas/features/tasks/trash_screen.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// Every list can now long press to select and bulk manage: Inbox, Tasks,
/// Search, Trash and Spaces all share the Today action bar. These checks
/// open one list each, select a row and run its bulk action.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Widget host(AppDatabase db, Widget home) => ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      );

  /// Drives the snackbar and stream timers out, then unmounts so the
  /// drift subscription closes before the database does.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  }

  testWidgets('inbox long press selects and bulk delete works', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = TaskRepository(db);
    final now = DateTime.now().millisecondsSinceEpoch;
    await repo.insertTask(Task(
      id: 'i1',
      title: 'Inbox one',
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: true,
      createdAt: now,
      updatedAt: now,
    ));
    await tester.pumpWidget(host(db, const InboxScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Inbox one'), findsOneWidget);
    await tester.longPress(find.text('Inbox one'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Inbox one'), findsNothing);
    // Direct table read instead of a stream future: the test would wait on
    // an emission that only a pump can deliver.
    final row = await (db.select(db.tasks)
          ..where((t) => t.id.equals('i1')))
        .getSingle();
    expect(row.deletedAt, isNotNull);

    await settle(tester);
  });

  testWidgets('trash bulk restore brings a task back', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = TaskRepository(db);
    final now = DateTime.now().millisecondsSinceEpoch;
    await repo.insertTask(Task(
      id: 'd1',
      title: 'Gone one',
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      createdAt: now,
      updatedAt: now,
    ));
    await repo.softDeleteTask('d1');

    await tester.pumpWidget(host(db, const TrashScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.longPress(find.text('Gone one'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.restore).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Gone one'), findsNothing);
    final row = await (db.select(db.tasks)
          ..where((t) => t.id.equals('d1')))
        .getSingle();
    expect(row.deletedAt, isNull);

    await settle(tester);
  });

  testWidgets('spaces long press selects and bulk archive works',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = SpaceRepository(db);
    final now = DateTime.now().millisecondsSinceEpoch;
    await repo.insertSpace(Space(
      id: 'sp1',
      name: 'Basdat',
      color: 0xFF6366F1,
      kind: 'course',
      archived: false,
      createdAt: now,
      updatedAt: now,
    ));

    await tester.pumpWidget(host(db, const SpacesScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.longPress(find.text('Basdat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.archive).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Basdat'), findsNothing);
    final space = await repo.getSpace('sp1');
    expect(space.archived, isTrue);

    await settle(tester);
  });
}
