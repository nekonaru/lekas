import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:lekas/features/quick_add/quick_add_sheet.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// Repeat from the last task (design section 7.16): one chip copies the
/// space, the type and the clock time of the previous task so several
/// tasks of the same course can be recorded in a row.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget host(QuickAddSheet sheet, AppDatabase db) => ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: sheet),
        ),
      );

  /// Fixed pumps instead of pumpAndSettle: the sheet holds an autofocused
  /// text field whose blinking cursor would keep the settle loop busy.
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

  String chipLabel(DateTime deadline) {
    final two = deadline.minute.toString().padLeft(2, '0');
    return '${deadline.day}/${deadline.month} '
        '${deadline.hour.toString().padLeft(2, '0')}.$two';
  }

  testWidgets('the repeat chip copies space, type and deadline time',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const previousDeadline = 7;
    const previousMinute = 30;
    await db.into(db.spaces).insert(Space(
          id: 's1',
          name: 'Basdat',
          color: 0xFF2196F3,
          archived: false,
          kind: 'course',
          createdAt: 1,
          updatedAt: 1,
        ));
    await TaskRepository(db).insertTask(Task(
      id: 'old',
      spaceId: 's1',
      title: 'Laprak 1',
      type: 'laprak',
      deadline: DateTime(2026, 1, 10, previousDeadline, previousMinute)
          .millisecondsSinceEpoch,
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      createdAt: 1,
      updatedAt: 1,
    ));

    await tester.pumpWidget(host(const QuickAddSheet(), db));
    await settle(tester);

    expect(find.text('Repeat last task'), findsOneWidget);

    await tester.tap(find.text('Repeat last task'));
    await settle(tester);

    // The space and the type are copied and locked against the parser.
    expect(find.text('Basdat'), findsOneWidget);
    expect(find.text('laprak'), findsOneWidget);

    // The deadline time only shows once a date is parsed: the date comes
    // from the text, the clock time from the previous task.
    await tester.enterText(find.byType(TextField), 'tugas besok');
    await tester.pump(const Duration(milliseconds: 200));

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    expect(
      find.text(chipLabel(DateTime(tomorrow.year, tomorrow.month,
          tomorrow.day, previousDeadline, previousMinute))),
      findsOneWidget,
    );

    await disposeTree(tester);
  });

  testWidgets('no previous task means no repeat chip', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(host(const QuickAddSheet(), db));
    await settle(tester);

    expect(find.text('Repeat last task'), findsNothing);

    await disposeTree(tester);
  });
}
