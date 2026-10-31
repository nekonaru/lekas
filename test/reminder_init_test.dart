import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/reminders/reminder_service.dart';

/// `init()` is shared by the start up provider and by the first sync, which
/// no longer wait for each other because the home screen shows immediately.
/// Two parallel runs would open the notification plugin and create the
/// channels twice, so the call is memoized: one underlying run for every
/// caller, and a failed run is forgotten so the next caller retries.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Each test builds its own in-memory AppDatabase on demand; the runtime
  // warning about multiple databases does not apply here.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  /// The channels of the app and of the notifications plugin.
  const channels = <String>[
    'dexterous.com/flutter/local_notifications',
    'lekas/timezone',
    'lekas/platform',
    'lekas/boot',
  ];

  late int initializeCalls;
  late bool failInitialize;

  void stub(String name) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), (call) async {
      if (call.method == 'initialize') {
        initializeCalls++;
        if (failInitialize) {
          throw PlatformException(code: 'plugin-unavailable');
        }
        // The plugin declares `Future<bool>`, so null would be a type error.
        return true;
      }
      if (call.method == 'getID') return 'Asia/Jakarta';
      return null;
    });
  }

  setUp(() {
    initializeCalls = 0;
    failInitialize = false;
    // On a device the plugin registrant does this; in a test the platform
    // instance has to be registered by hand or every call throws.
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    for (final name in channels) {
      stub(name);
    }
  });

  tearDown(() {
    for (final name in channels) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(name), null);
    }
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(
          AppDatabase(NativeDatabase.memory()),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('callers waiting on init share a single plugin start', () async {
    final service = makeContainer().read(reminderServiceProvider);

    await Future.wait([
      service.init(),
      service.init(),
      service.init(),
    ]);
    // An init after the run finished must not open the plugin again.
    await service.init();

    expect(initializeCalls, 1);
  });

  test('a failed init is forgotten so the next caller retries', () async {
    final service = makeContainer().read(reminderServiceProvider);

    failInitialize = true;
    await expectLater(service.init(), throwsA(isA<PlatformException>()));

    failInitialize = false;
    await service.init();
    await service.init();

    // The first run tried once and failed, the retry opened the plugin again
    // and the caller after it reused that successful run.
    expect(initializeCalls, 2);
  });
}
