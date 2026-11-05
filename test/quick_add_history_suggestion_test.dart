import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/data/subtask_repository.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:lekas/features/quick_add/quick_add_sheet.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// The "saran dari riwayat" chip of design section 7.16: while the typed
/// title resembles an old task, one tap copies that task's subtasks and
/// estimate into the draft. Only old tasks carrying something to copy
/// are ever offered, and a thrown away offer stays gone.
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

  /// Types [text] and waits out the 150 ms parse debounce plus a frame
  /// for the rebuilt chips.
  Future<void> typeAndSettle(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
  }

  Future<void> seedCopyableTask(AppDatabase db) async {
    await TaskRepository(db).insertTask(Task(
      id: 'old',
      title: 'Laprak minggu lalu',
      estimateMinutes: 120,
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      createdAt: 1,
      updatedAt: 1,
    ));
    final subtasks = SubtaskRepository(db);
    await subtasks.insertSubtask(Subtask(
      id: 'st1',
      taskId: 'old',
      title: 'Kumpul ke dosen',
      done: false,
      sortOrder: 0,
      updatedAt: 1,
    ));
    await subtasks.insertSubtask(Subtask(
      id: 'st2',
      taskId: 'old',
      title: 'Cetak laporan',
      done: false,
      sortOrder: 1,
      updatedAt: 1,
    ));
  }

  testWidgets('a similar old title offers its subtasks and estimate',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await seedCopyableTask(db);

    await tester.pumpWidget(host(const QuickAddSheet(), db));
    await settle(tester);

    // Nothing to compare against while the field is empty.
    expect(find.textContaining('Similar to:'), findsNothing);

    await typeAndSettle(tester, 'laprak minggu lalu');
    expect(find.text('Similar to: Laprak minggu lalu'), findsOneWidget);

    // One tap copies both values into the draft as removable chips.
    await tester.tap(find.text('Similar to: Laprak minggu lalu'));
    await settle(tester);
    expect(find.text('Similar to: Laprak minggu lalu'), findsNothing);
    expect(find.text('2 subtasks'), findsOneWidget);
    expect(find.text('Estimate: 2 hours'), findsOneWidget);

    // Saving writes the copied estimate and both copied subtasks. The
    // seeded task is still there, the new one sits beside it.
    await tester.tap(find.text('Add Task'));
    await settle(tester);
    await settle(tester);
    expect(find.byType(QuickAddSheet), findsNothing);

    final saved = await TaskRepository(db).getTasks(includeInbox: true);
    expect(saved, hasLength(2));
    final created = saved.firstWhere((task) => task.id != 'old');
    expect(created.estimateMinutes, 120);
    final savedSubtasks =
        await SubtaskRepository(db).getSubtasks(created.id);
    expect(
      savedSubtasks.map((subtask) => subtask.title),
      ['Kumpul ke dosen', 'Cetak laporan'],
    );

    await disposeTree(tester);
  });

  testWidgets('an old task with nothing to copy is never offered',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await TaskRepository(db).insertTask(Task(
      id: 'plain',
      title: 'Beli buku aksara',
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

    await typeAndSettle(tester, 'beli buku aksara baru');

    expect(find.textContaining('Similar to:'), findsNothing);

    await disposeTree(tester);
  });

  testWidgets('a thrown away offer does not come back', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await seedCopyableTask(db);

    await tester.pumpWidget(host(const QuickAddSheet(), db));
    await settle(tester);

    await typeAndSettle(tester, 'laprak minggu lalu');
    final chip = find.widgetWithText(InputChip, 'Similar to: Laprak minggu lalu');
    expect(chip, findsOneWidget);

    // The delete icon dismisses the offer for this title. InputChip under
    // Material 3 draws Icons.clear, not Icons.cancel like RawChip does.
    await tester.tap(find.descendant(of: chip, matching: find.byIcon(Icons.clear)));
    await settle(tester);
    expect(chip, findsNothing);

    // Even a better match for the same old task stays silent.
    await typeAndSettle(tester, 'laprak minggu lalu banget');
    expect(find.textContaining('Similar to:'), findsNothing);

    await disposeTree(tester);
  });
}
