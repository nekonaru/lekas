import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/models.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/data/space_repository.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:lekas/features/home/home_shell.dart';
import 'package:lekas/features/settings/settings_screen.dart';
import 'package:lekas/features/spaces/space_detail_screen.dart';
import 'package:lekas/features/spaces/spaces_screen.dart';
import 'package:lekas/features/tasks/attachment_screen.dart';
import 'package:lekas/features/tasks/backup_auto_screen.dart';
import 'package:lekas/features/tasks/duplicate_detection_screen.dart';
import 'package:lekas/features/tasks/dependensi_tugas_screen.dart';
import 'package:lekas/features/tasks/export_gambar_pdf_screen.dart';
import 'package:lekas/features/semester/semester_screen.dart';
import 'package:lekas/features/tasks/import_merge_screen.dart';
import 'package:lekas/features/tasks/mode_demo_screen.dart';
import 'package:lekas/features/tasks/pintasan_ikon_screen.dart';
import 'package:lekas/features/tasks/prediksi_nilai_screen.dart';
import 'package:lekas/features/tasks/saved_filter_screen.dart';
import 'package:lekas/features/tasks/statistik_rekap_screen.dart';
import 'package:lekas/features/tasks/subtask_screen.dart';
import 'package:lekas/features/tasks/tautan_cepat_screen.dart';
import 'package:lekas/features/tasks/target_pribadi_screen.dart';
import 'package:lekas/features/tasks/task_detail_screen.dart';
import 'package:lekas/features/tasks/trash_screen.dart';
import 'package:lekas/features/tasks/tugas_berulang_screen.dart';
import 'package:lekas/features/tasks/non_course_category_screen.dart';
import 'package:lekas/features/tasks/widget_lanjutan_screen.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// The finished feature screens sat behind no menu at all, so their logic was
/// unreachable for a user. These tests open every menu entry and require the
/// right screen to come up: a renamed key, a missing tile or a screen that
/// throws on open fails here instead of hiding behind a dead end.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  /// Answers every plugin method channel with a harmless value, the same way
  /// the start up test does, so a screen that talks to a plugin on open can
  /// still be built in the test environment.
  void stubChannel(String name, {Object? result}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), (call) async => result);
  }

  setUp(() {
    // The warning card on the home screen asks the notification plugin for
    // its permission state; only the plugin registrant installs the platform
    // on a device, so the test installs it here.
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    stubChannel('dexterous.com/flutter/local_notifications', result: true);
    stubChannel('dexterous.com/flutter_local_notifications');
    stubChannel('dexterous.com/flutter_local_notifications_methods');
    stubChannel('dexterous.com/flutter_local_notifications/timezone');
    stubChannel('lekas/platform');
    stubChannel('lekas/boot');
    stubChannel('home_widget');
    stubChannel('android_intent_handler');
    stubChannel('receive_sharing_intent');
    stubChannel('speech_to_text');
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in [
      'dexterous.com/flutter/local_notifications',
      'dexterous.com/flutter_local_notifications',
      'dexterous.com/flutter_local_notifications_methods',
      'dexterous.com/flutter_local_notifications/timezone',
      'lekas/platform',
      'lekas/boot',
      'home_widget',
      'android_intent_handler',
      'receive_sharing_intent',
      'speech_to_text',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(name), null);
    }
  });

  /// Fixed pumps instead of pumpAndSettle: the home screen keeps timers of
  /// its own and a settle loop would wait on them forever.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));
  }

  /// Brings a list tile into view, taps it and lets the push transition run.
  Future<void> tapTile(
    WidgetTester tester,
    Finder tile, {
    required Finder scrollable,
  }) async {
    await tester.scrollUntilVisible(tile, 300, scrollable: scrollable);
    await tester.ensureVisible(tile);
    await settle(tester);
    await tester.tap(tile);
    await settle(tester);
  }

  /// Opens the navigation drawer and taps the entry carrying [label].
  Future<void> openDrawerEntry(WidgetTester tester, String label) async {
    await tester.tap(find.byIcon(Icons.menu));
    await settle(tester);
    await tapTile(
      tester,
      find.text(label),
      scrollable: find
          .descendant(
            of: find.byType(NavigationDrawer),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }

  /// Leaves the screen that was just opened and lands back on the shell.
  Future<void> goBack(WidgetTester tester) async {
    await tester.pageBack();
    await settle(tester);
  }

  /// Switches the shell to the tab carrying [label] on the bottom bar.
  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await settle(tester);
  }

  /// Ends the test on an empty tree so the drift stream subscriptions of the
  /// home screen close during a pump: their zero duration cleanup timer
  /// would otherwise still be pending when the framework checks the timers.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  }

  Widget host(AppDatabase db, Widget home) => ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );

  testWidgets('the drawer opens the finished global tools', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(host(db, const HomeShell()));
    await settle(tester);

    final drawerTools = <String, Type>{
      'Saved Views': SavedFilterScreen,
      'Semester Statistics and Recap': StatistikRekapScreen,
      'Global Quick Links': TautanCepatScreen,
      'Trash': TrashScreen,
    };
    for (final entry in drawerTools.entries) {
      await openDrawerEntry(tester, entry.key);
      expect(
        find.byType(entry.value),
        findsOneWidget,
        reason: '${entry.key} must open ${entry.value}',
      );
      await goBack(tester);
    }

    // The trash entry is the one the design calls "Menu Sampah", so its empty
    // state has to show behind it.
    await openDrawerEntry(tester, 'Trash');
    expect(find.text('Trash is empty.'), findsOneWidget);
    await goBack(tester);

    await disposeTree(tester);
  });

  testWidgets('settings opens the finished setup tools', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(host(db, const HomeShell()));
    await settle(tester);
    await openTab(tester, 'Settings');

    final settingsTools = <String, Type>{
      'Simple Recurring Tasks': TugasBerulangScreen,
      'Duplicate Detection': DuplicateDetectionScreen,
      'Automatic Backup': BackupAutoScreen,
      'Import and Merge': ImportMergeScreen,
      'Export Image and PDF': ExportGambarPDFScreen,
      'Semester': SemesterScreen,
      'Advanced Widgets': WidgetLanjutanScreen,
      'Icon Shortcuts and Quick Settings': PintasanIkonScreen,
      'Demo Mode': ModeDemoScreen,
    };
    final settingsScrollable = find
        .descendant(
          of: find.byType(SettingsScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    for (final entry in settingsTools.entries) {
      // The bottom bar carries a "Semester" label too, so scope every tile
      // lookup to the settings list itself.
      await tapTile(
        tester,
        find.descendant(
          of: find.byType(SettingsScreen),
          matching: find.text(entry.key),
        ),
        scrollable: settingsScrollable,
      );
      expect(
        find.byType(entry.value),
        findsOneWidget,
        reason: '${entry.key} must open ${entry.value}',
      );
      await goBack(tester);
    }

    await disposeTree(tester);
  });

  testWidgets('spaces open the non course creator and grade prediction', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.now().millisecondsSinceEpoch;
    await SpaceRepository(db).insertSpace(
      Space(
        id: 'sp1',
        name: 'Basdat',
        color: 0xFF42A5F5,
        kind: 'course',
        archived: false,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await tester.pumpWidget(host(db, const HomeShell()));
    await settle(tester);
    await openTab(tester, 'Semester');
    await settle(tester);

    // The manage button opens the course list, which carries the category
    // creator for non-course spaces.
    await tester.tap(find.text('Manage Categories'));
    await settle(tester);
    expect(find.byType(SpacesScreen), findsOneWidget);

    // The category action creates an org, project, personal or other space.
    await tester.tap(find.byIcon(Icons.category_outlined));
    await settle(tester);
    expect(find.byType(NonCourseCategoryScreen), findsOneWidget);
    await goBack(tester);

    await tapTile(
      tester,
      find.text('Basdat'),
      scrollable: find
          .descendant(
            of: find.byType(SpacesScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byType(SpaceDetailScreen), findsOneWidget);

    await tapTile(
      tester,
      find.text('Grade Prediction'),
      scrollable: find
          .descendant(
            of: find.byType(SpaceDetailScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byType(PrediksiNilaiScreen), findsOneWidget);
    await goBack(tester);
    await goBack(tester);

    await disposeTree(tester);
  });

  testWidgets(
    'task detail opens attachments, subtasks and the personal target',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime.now().millisecondsSinceEpoch;
      await TaskRepository(db).insertTask(
        Task(
          id: 't1',
          spaceId: 'sp1',
          title: 'Laprak Basdat',
          notes: 'buat ERD',
          deadline: now + 86400000,
          priority: 1,
          status: 'todo',
          isGroup: false,
          pinned: false,
          inbox: false,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await tester.pumpWidget(host(db, const TaskDetailScreen(taskId: 't1')));
      await settle(tester);

      final detailScrollable = find
          .descendant(
            of: find.byType(TaskDetailScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      final detailTools = <String, Type>{
        'Subtasks': SubtaskScreen,
        'Attachments': AttachmentScreen,
        'Task Dependencies': DependensiTugasScreen,
        'Personal Target': TargetPribadiScreen,
      };
      for (final entry in detailTools.entries) {
        await tapTile(
          tester,
          find.text(entry.key),
          scrollable: detailScrollable,
        );
        expect(
          find.byType(entry.value),
          findsOneWidget,
          reason: '${entry.key} must open ${entry.value}',
        );
        await goBack(tester);
      }

      await disposeTree(tester);
    },
  );
}
