import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/core/components/undo_snackbar.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// The undo banner must leave on its own after five seconds, and a new
/// banner must replace the old one instead of queueing behind it.
void main() {
  Widget host() => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(builder: (context) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () => UndoSnackbar.show(context, 'First', () {}),
                  child: const Text('first'),
                ),
                ElevatedButton(
                  onPressed: () => UndoSnackbar.show(context, 'Second', () {}),
                  child: const Text('second'),
                ),
              ],
            );
          }),
        ),
      );

  testWidgets('an undo banner lives for five seconds', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('first'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.duration, const Duration(seconds: 5));

    // Drive time through the five second lifetime and its exit.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a new banner replaces the old one instead of queueing',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('first'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('First'), findsOneWidget);
    await tester.tap(find.text('second'));
    // The old banner plays its exit while the new one enters.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    // Flush the five second close timers before the test ends.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  });
}
