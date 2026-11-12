import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/data/models.dart';
import 'package:lekas/data/providers.dart';
import 'package:lekas/data/task_repository.dart';
import 'package:lekas/features/tasks/task_form_sheet.dart';
import 'package:lekas/l10n/app_localizations.dart';

/// Editing a task used to rebuild it fresh with status todo, so a done or
/// pinned task silently reopened and unpinned. The edit path now copies the
/// task and only touches the edited fields.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Widget host(AppDatabase db, Task task) => ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TaskFormSheet(task: task),
          ),
        ),
      );

  testWidgets('editing keeps status, pin and group state', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.now().millisecondsSinceEpoch;
    final task = Task(
      id: 't1',
      title: 'Old title',
      priority: 1,
      status: 'done',
      isGroup: true,
      pinned: true,
      inbox: false,
      createdAt: now,
      updatedAt: now,
      completedAt: now,
    );
    await TaskRepository(db).insertTask(task);

    await tester.pumpWidget(host(db, task));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'New title');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final saved = await TaskRepository(db).getTask('t1');
    expect(saved.title, 'New title');
    expect(saved.status, 'done');
    expect(saved.pinned, isTrue);
    expect(saved.isGroup, isTrue);
    expect(saved.completedAt, now);
  });
}
