import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/models.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:lekas/features/calendar/calendar_screen.dart';
import 'package:lekas/features/calendar/day_tasks_screen.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// Tapping a calendar day lists only that day's due tasks, so the grid
/// leads somewhere instead of ending at a dot.
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

  Future<void> unmountTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  }

  testWidgets('tapping a day opens only that day’s tasks', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = TaskRepository(db);
    final now = DateTime.now();
    final today10 = DateTime(now.year, now.month, now.day, 10);
    final tomorrow10 = today10.add(const Duration(days: 1));
    await repo.insertTask(Task(
      id: 'due-today',
      title: 'Due today',
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      deadline: today10.millisecondsSinceEpoch,
      createdAt: 1,
      updatedAt: 1,
    ));
    await repo.insertTask(Task(
      id: 'due-tomorrow',
      title: 'Due tomorrow',
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      deadline: tomorrow10.millisecondsSinceEpoch,
      createdAt: 1,
      updatedAt: 1,
    ));

    await tester.pumpWidget(host(db, const CalendarScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.text('${today10.day}').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(DayTasksScreen), findsOneWidget);
    expect(find.text('Due today'), findsOneWidget);
    expect(find.text('Due tomorrow'), findsNothing);

    // Select and bulk delete the row entirely from the list.
    await tester.longPress(find.text('Due today'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('1 selected'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Due today'), findsNothing);

    // Drive the banner and stream timers out before unmounting.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await unmountTree(tester);
  });
}
