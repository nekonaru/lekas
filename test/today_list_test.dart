import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/core/components/task_section.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:lekas/features/tasks/task_detail_screen.dart';
import 'package:lekas/features/today/today_screen.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// The Today body used to be a ListView holding every card of every section,
/// so each rebuild (a selection tap, an undo, a new row) laid the whole list
/// out again. It is now a flat entry list walked by a lazy builder: the same
/// screen, the same sections, but only the cards on screen get built. These
/// checks keep the sections, the multi select tap and the navigation to the
/// detail screen working after that split into TaskSectionHeader and
/// TaskCard.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // One in-memory database per test; the runtime warning about multiple
  // databases does not apply to this deliberate test setup.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() {
    // The permission check of the warning card goes through the plugin
    // platform, which only the plugin registrant installs on a device.
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (call) async => true,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      null,
    );
  });

  Widget host(AppDatabase db) => ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayScreen(),
        ),
      );

  Future<AppDatabase> seededDb() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = TaskRepository(db);
    final today = DateTime.now().add(const Duration(hours: 3));

    await repo.insertTask(Task(
      id: 'pin-1',
      title: 'Pinned task',
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: true,
      inbox: false,
      createdAt: 1,
      updatedAt: 1,
    ));
    await repo.insertTask(Task(
      id: 'due-1',
      title: 'Due task',
      priority: 2,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      deadline: today.millisecondsSinceEpoch,
      createdAt: 1,
      updatedAt: 1,
    ));
    await repo.insertTask(Task(
      id: 'someday-1',
      title: 'Someday task',
      priority: 0,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: false,
      createdAt: 1,
      updatedAt: 1,
    ));
    return db;
  }

  /// Unmounts the tree and advances the clock, so the StreamBuilder of the
  /// screen cancels its subscription and drift's zero duration cache timer
  /// fires before the test ends. `pump()` with no duration only flushes
  /// microtasks, so the clock has to actually move.
  Future<void> unmountTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('sections and cards render from the lazy list', (tester) async {
    final db = await seededDb();

    await tester.pumpWidget(host(db));
    await tester.pumpAndSettle();

    // Three rows: pinned, the task due today, and the one without deadline.
    expect(find.byType(TaskCard), findsNWidgets(3));
    expect(find.text('Pinned task'), findsOneWidget);
    expect(find.text('Due task'), findsOneWidget);
    expect(find.text('Someday task'), findsOneWidget);

    // Their groups keep the order of design section 5.9.
    final titles = tester
        .widgetList<TaskSectionHeader>(find.byType(TaskSectionHeader))
        .map((header) => header.section)
        .toList();
    expect(titles, [TodaySection.pinned, TodaySection.today, TodaySection.someday]);

    await unmountTree(tester);
  });

  testWidgets('a long press selects a card and a tap opens the task',
      (tester) async {
    final db = await seededDb();

    await tester.pumpWidget(host(db));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Due task'));
    await tester.pumpAndSettle();

    // Multi select marks the card with the check icon of design 5.5.
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    // Leaving multi select first: a plain tap then opens the detail screen.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Due task'));
    await tester.pumpAndSettle();

    expect(find.byType(TaskDetailScreen), findsOneWidget);

    await unmountTree(tester);
  });
}
