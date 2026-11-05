import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/reminders/reminder_service.dart';

/// Design section 5.27: finishing a prerequisite frees the tasks waiting on
/// it, and the first completion sends one soft notice naming the freed
/// task. Completing the same task again must not repeat it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Each test builds its own in-memory AppDatabase on demand; the runtime
  // warning about multiple databases does not apply here.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  const notifications =
      MethodChannel('dexterous.com/flutter/local_notifications');
  const timezone = MethodChannel('lekas/timezone');

  late List<MethodCall> calls;

  setUp(() {
    // On a device the plugin registrant does this; in a test the platform
    // instance has to be registered by hand or every call throws.
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifications, (call) async {
      calls.add(call);
      // The plugin declares `Future<bool>`, so null would be a type error.
      if (call.method == 'initialize') return true;
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezone, (call) async {
      if (call.method == 'getID') return 'Asia/Jakarta';
      return null;
    });
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(notifications, null);
    messenger.setMockMethodCallHandler(timezone, null);
  });

  /// Waits until the plugin channel carries [method], so the whole notice
  /// chain (init, database, localizations, show) gets its event loop turns.
  Future<void> waitFor(String method) async {
    for (var i = 0;
        i < 100 && !calls.any((call) => call.method == method);
        i++) {
      await pumpEventQueue();
    }
  }

  Future<ProviderContainer> makeContainer() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final tasks = container.read(taskRepositoryProvider);
    for (final (id, title) in [
      ('a', 'Laprak Basdat'),
      ('b', 'Praktikum'),
      ('c', 'Baca modul'),
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
    final deps = container.read(taskDepRepositoryProvider);
    await deps.insertTaskDep(TaskDep(taskId: 'a', dependsOn: 'b'));
    await deps.insertTaskDep(TaskDep(taskId: 'a', dependsOn: 'c'));
    return container;
  }

  test('the first completion frees every dependent exactly once', () async {
    final container = await makeContainer();
    final tasks = container.read(taskRepositoryProvider);

    final freed = <String>[];
    final subscription = tasks.justUnblocked.listen(freed.add);
    addTearDown(subscription.cancel);

    // The other prerequisite is still open, so nothing is free yet.
    await tasks.markDone('c');
    await pumpEventQueue();
    expect(freed, isEmpty);

    await tasks.markDone('b');
    await pumpEventQueue();
    expect(freed, ['a']);

    // Marking the finished task again must not repeat the notice.
    await tasks.markDone('b');
    await pumpEventQueue();
    expect(freed, ['a']);
  });

  test('one notice carries the title of the freed task', () async {
    final container = await makeContainer();
    final tasks = container.read(taskRepositoryProvider);
    container.read(unblockNoticeProvider);

    // The notice must wait for the last open prerequisite: finishing only
    // one of the two frees nothing.
    await tasks.markDone('c');
    for (var i = 0; i < 5; i++) {
      await pumpEventQueue();
    }
    expect(calls.where((call) => call.method == 'show'), isEmpty);

    await tasks.markDone('b');
    await waitFor('show');

    final shows = calls.where((call) => call.method == 'show').toList();
    expect(
      shows,
      hasLength(1),
      reason: 'captured plugin calls: ${calls.map((call) => call.method)}',
    );
    // The default language of the app is Indonesian (design section 3).
    final args = Map<Object?, Object?>.from(shows.single.arguments as Map);
    expect(args['title'], 'Sekarang bisa mulai');
    expect(args['body'], 'Laprak Basdat');

    // Marking the finished task again must not repeat the notice.
    await tasks.markDone('b');
    for (var i = 0; i < 20; i++) {
      await pumpEventQueue();
    }
    expect(calls.where((call) => call.method == 'show'), hasLength(1));
  });
}
