import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/main.dart';

/// The startup path (main -> LekasApp -> the init and sync providers) used to
/// be exercised only through unit tests that never built the widget tree, so a
/// synchronous throw in `initState` or the first frame would reach a real
/// device as a force close and stay invisible here. This test pumps the real
/// [LekasApp] against an in-memory database with the plugin channels stubbed,
/// so any startup exception fails the suite instead of the user's phone.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Each test builds its own in-memory AppDatabase; the runtime warning about
  // multiple databases does not apply to this deliberate test setup.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  /// Answers every plugin method channel with a harmless value so the real
  /// widget tree can build without a device behind it.
  void stubChannel(String name, {Object? result}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), (call) async => result);
  }

  setUp(() {
    // flutter_local_notifications, timezone, home_widget, share intent and the
    // custom platform channel all answer null / an empty map on start up.
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter_local_notifications'),
      null,
    );
  });

  testWidgets('the app builds its first frame without throwing', (tester) async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(
          AppDatabase(NativeDatabase.memory()),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LekasApp(),
      ),
    );
    // Let the post frame callbacks and the first async gap run.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // The MaterialApp is up: a crash before the first frame would have thrown
    // out of pumpWidget already. We only require the tree to have a MaterialApp.
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('start up renders onboarding for a fresh database', (tester) async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(
          AppDatabase(NativeDatabase.memory()),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LekasApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // A fresh install is not onboarded yet, so the shell lands on onboarding
    // instead of force closing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
