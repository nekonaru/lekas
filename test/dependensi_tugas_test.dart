import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/data/task_dep_repository.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:lekas/features/tasks/dependensi_tugas_screen.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// The screen behind the "Task Dependencies" tile of design section 5.27:
/// it lists the prerequisites of one task, adds another from the picker
/// and refuses a save that would close a loop.
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

  /// Fixed pumps instead of pumpAndSettle: the picker focuses a text field
  /// and its blinking cursor would keep the settle loop busy forever.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));
  }

  /// Unmounts the tree so the drift stream subscriptions close during a
  /// pump instead of leaving their zero duration cleanup timer pending.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  }

  Future<AppDatabase> seededDb() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final tasks = TaskRepository(db);
    for (final (id, title) in [
      ('a', 'Alpha'),
      ('b', 'Bravo'),
      ('c', 'Charlie'),
    ]) {
      await tasks.insertTask(Task(
        id: id,
        title: title,
        priority: 0,
        status: 'todo',
        isGroup: false,
        pinned: false,
        inbox: false,
        createdAt: 1,
        updatedAt: 1,
      ));
    }
    return db;
  }

  testWidgets('a saved prerequisite can be removed again', (tester) async {
    final db = await seededDb();
    await TaskDepRepository(db)
        .insertTaskDep(TaskDep(taskId: 'a', dependsOn: 'b'));

    await tester.pumpWidget(host(db, const DependensiTugasScreen(taskId: 'a')));
    await settle(tester);

    // Bravo waits in front of Alpha: still open, so the radio icon shows.
    expect(find.text('Bravo'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await settle(tester);

    expect(find.text('Bravo'), findsNothing);
    expect(find.text('No prerequisites yet.'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('the picker adds another prerequisite', (tester) async {
    final db = await seededDb();

    await tester.pumpWidget(host(db, const DependensiTugasScreen(taskId: 'a')));
    await settle(tester);
    expect(find.text('No prerequisites yet.'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);

    // The picker offers every other open task, without Alpha itself.
    expect(find.text('Bravo'), findsOneWidget);
    expect(find.text('Charlie'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);

    await tester.tap(find.text('Charlie'));
    await settle(tester);

    expect(find.byType(DependensiTugasScreen), findsOneWidget);
    expect(find.text('Charlie'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('a save that would close a loop is refused', (tester) async {
    final db = await seededDb();
    final deps = TaskDepRepository(db);
    await deps.insertTaskDep(TaskDep(taskId: 'a', dependsOn: 'b'));

    // Bravo already waits for Alpha, so making Alpha wait for Bravo
    // would strand both in a loop.
    await tester.pumpWidget(host(db, const DependensiTugasScreen(taskId: 'b')));
    await settle(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    await tester.tap(find.text('Alpha'));
    await settle(tester);

    expect(
      find.text('That would create a loop. Pick a different task.'),
      findsOneWidget,
    );
    // The picker stays open so the user can pick another task.
    expect(find.byType(TextField), findsOneWidget);
    expect(await deps.getTaskDeps('b'), isEmpty);

    await disposeTree(tester);
  });
}
