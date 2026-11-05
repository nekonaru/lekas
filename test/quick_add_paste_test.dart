import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:lekas/features/quick_add/quick_add_sheet.dart';
import 'package:lekas/features/share_intake/share_intake_screen.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// The Tempel button of design section 7.16: the clipboard is read after
/// the tap, every non-empty line becomes one candidate of the checklist
/// screen from design section 6.2, and nothing is saved without a tap.
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

  testWidgets('every clipboard line becomes one candidate, on tap only',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    var reads = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          reads++;
          return <String, dynamic>{
            'text': 'beli buku a\n\ncetak poster b\n',
          };
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(host(const QuickAddSheet(), db));
    await settle(tester);

    // Opening the sheet must not touch the clipboard (design 7.16).
    expect(reads, 0);

    await tester.tap(find.byIcon(Icons.content_paste));
    await settle(tester);
    await settle(tester);

    expect(reads, 1);
    expect(find.byType(ShareIntakeScreen), findsOneWidget);
    // One candidate per non-empty line, the blank line is dropped.
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('beli buku a'), findsOneWidget);
    expect(find.text('cetak poster b'), findsOneWidget);

    // Back without saving keeps the Quick Add sheet open.
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.byType(ShareIntakeScreen), findsNothing);
    expect(find.byType(QuickAddSheet), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('an empty clipboard answers with a message, no new route',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          return <String, dynamic>{'text': ''};
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(host(const QuickAddSheet(), db));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.content_paste));
    await settle(tester);

    expect(find.byType(ShareIntakeScreen), findsNothing);
    expect(
      find.text('Clipboard is empty. Copy some text first.'),
      findsOneWidget,
    );

    await disposeTree(tester);
  });

  testWidgets('saving the pasted candidates closes the sheet', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          return <String, dynamic>{
            'text': 'beli buku a\ncetak poster b',
          };
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(host(const QuickAddSheet(), db));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.content_paste));
    await settle(tester);
    await settle(tester);

    await tester.tap(find.text('Save Checked'));
    await settle(tester);
    await settle(tester);

    expect(find.byType(QuickAddSheet), findsNothing);
    final tasks = await TaskRepository(db).getTasks(includeInbox: true);
    expect(tasks, hasLength(2));

    await disposeTree(tester);
  });
}
