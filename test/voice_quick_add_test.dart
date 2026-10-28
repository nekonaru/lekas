import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/features/quick_add/quick_add_sheet.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// The channel the speech plugin talks over. The test environment answers
/// "no recognizer here" so the sheet falls back to its message instead of
/// waiting for a platform that will never reply.
const MethodChannel _speechChannel =
    MethodChannel('plugin.csdcorp.com/speech_to_text');

/// The deadline chip spelling, exactly as `_deadlineLabel` writes it.
String _chipLabel(DateTime deadline) {
  final two = deadline.minute.toString().padLeft(2, '0');
  return '${deadline.day}/${deadline.month} '
      '${deadline.hour.toString().padLeft(2, '0')}.$two';
}

/// Quick Add with voice (design section 7.1): the microphone sits in the
/// sheet, the recognized text reaches the parser as chips, and a device
/// without a recognizer gets a message instead of a crash.
Widget _host(QuickAddSheet sheet, AppDatabase db) => ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: sheet),
      ),
    );

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_speechChannel, (call) async => false);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_speechChannel, null);
  });

  testWidgets('typed text becomes chips and the microphone answers',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_host(const QuickAddSheet(), db));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'laprak basdat besok');
    // The chips follow the text after the parse debounce (design 7.15).
    await tester.pump(const Duration(milliseconds: 200));

    // The parse result of design section 6.1 shows up as the deadline chip.
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    expect(find.text(_chipLabel(DateTime(tomorrow.year, tomorrow.month,
            tomorrow.day, 23, 59))),
        findsOneWidget);

    // No recognizer is installed in the test environment, so the sheet says
    // so instead of throwing. The host uses the platform locale, so the
    // English wording of the micUnavailable key is spelled out here instead
    // of asking the generated localizations for a locale.
    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.text('Speech recognition is not available on this device.'),
      findsOneWidget,
    );
  });

  testWidgets('the voice screen can hand a sentence over', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_host(
        const QuickAddSheet(initialText: 'kuis pemweb besok jam 8'), db));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, 'kuis pemweb besok jam 8');
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    expect(
        find.text(_chipLabel(DateTime(
            tomorrow.year, tomorrow.month, tomorrow.day, 8, 0))),
        findsOneWidget);
  });
}
