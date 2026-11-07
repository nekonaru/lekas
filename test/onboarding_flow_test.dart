import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/features/home/home_shell.dart';
import 'package:lekas/features/onboarding/onboarding_screen.dart';
import 'package:lekas/main.dart';

/// Finishing the first run used to pop the root route: the navigator went
/// empty and the user saw a black screen on a real device (reported on
/// v1.4.1). The language choice also looked dead because it never changed
/// anything visible before the last setup step. This walks the whole first
/// run on a fresh database and requires the shell to be on screen at the end.
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

  /// Boots the real app against a fresh database and waits for the start up
  /// frame plus the first async gap, like the app start up test does.
  Future<ProviderContainer> pumpFreshApp(WidgetTester tester) async {
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
    return container;
  }

  /// Ends the test on an empty tree so the drift stream subscriptions of the
  /// home screen close during a pump: their zero duration cleanup timer
  /// would otherwise still be pending when the framework checks the timers.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  }

  testWidgets('the language choice answers back right away', (tester) async {
    final container = await pumpFreshApp(tester);

    // A fresh install opens in Indonesian: the default choice is the filled
    // one and the other choice stays outlined.
    expect(find.text('Pilih Bahasa'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Bahasa Indonesia'),
        matching: find.byType(ElevatedButton),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.text('English'),
        matching: find.byType(OutlinedButton),
      ),
      findsOneWidget,
    );

    // Tapping English flips the choice and switches the whole screen at once.
    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Choose Language'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('English'),
        matching: find.byType(ElevatedButton),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.text('Indonesian'),
        matching: find.byType(OutlinedButton),
      ),
      findsOneWidget,
    );

    // And back to Indonesian, the value every later launch reads.
    await tester.tap(find.text('Indonesian'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pilih Bahasa'), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Bahasa Indonesia'),
        matching: find.byType(ElevatedButton),
      ),
      findsOneWidget,
    );
    expect(
      await container.read(settingsRepositoryProvider).getLanguage(),
      'id',
    );
  });

  testWidgets('finishing setup lands on the shell, not a black screen',
      (tester) async {
    final container = await pumpFreshApp(tester);

    expect(find.byType(OnboardingScreen), findsOneWidget);

    // Step 0 to the first space form.
    await tester.tap(find.text('Mulai'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TextField), findsNWidgets(2));

    // Finish the run. This used to pop the root route and leave an empty
    // navigator behind, which showed up as a black screen on the device.
    await tester.tap(find.text('Simpan & Lanjut'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);

    final settings = container.read(settingsRepositoryProvider);
    expect(await settings.get('onboarded'), 'true');
    expect(await settings.getLanguage(), 'id');

    await disposeTree(tester);
  });
}
