import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/features/tasks/app_lock_screen.dart';
import 'package:lekas/l10n/app_localizations.dart';
import 'package:lekas/lock/unlock_screen.dart';

/// The app lock gates the app behind a PIN: only the right PIN opens it.
/// Setting a PIN hashes it with a salt; disabling clears every value.
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
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('the right PIN unlocks and the wrong one does not',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    var calls = 0;
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await container.read(lockServiceProvider).setPin('1234');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: UnlockScreen(onUnlock: () => calls++),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '0000');
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('Wrong PIN'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    await tester.pumpAndSettle();
    expect(calls, 1);

    await unmountTree(tester);
  });

  testWidgets('the lock screen enables and disables at its switch',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(host(db, const AppLockScreen()));
    await tester.pumpAndSettle();

    final service = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(service.dispose);

    // Off at first.
    var switches = tester.widgetList<Switch>(find.byType(Switch));
    expect(switches, hasLength(1));
    expect(switches.first.value, isFalse);

    // Turn on with a fresh PIN.
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '1234');
    await tester.enterText(find.byType(TextField).last, '1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(await service.read(lockServiceProvider).isEnabled(), isTrue);

    // Turn it off with the PIN.
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    await tester.pumpAndSettle();
    expect(await service.read(lockServiceProvider).isEnabled(), isFalse);

    await unmountTree(tester);
  });
}
