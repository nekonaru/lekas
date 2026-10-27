import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/class_exception_repository.dart';
import '../../data/class_slot_repository.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/settings_repository.dart';
import '../../data/space_repository.dart';
import '../../data/task_repository.dart';
import '../../domain/focus.dart';
import '../../domain/widget_data.dart';
import '../../reminders/class_quiet.dart';
import '../../reminders/reminder_service.dart';

/// Class names of the four home screen widgets (design section 7.8). Each
/// one matches a receiver declared in the Android manifest, and
/// `HomeWidget.updateWidget` needs the fully qualified name.
const String kTaskWidgetProvider = 'com.lekas.lekas.TaskListWidgetProvider';
const String kClassWidgetProvider = 'com.lekas.lekas.ClassWidgetProvider';
const String kExamWidgetProvider = 'com.lekas.lekas.ExamWidgetProvider';
const String kFocusWidgetProvider = 'com.lekas.lekas.FocusWidgetProvider';

/// Endless deadline used only to sort tasks without one to the back.
const int _noDeadline = 9223372036854775807;

/// Rebuilds all four widget payloads from [db] and asks Android to redraw
/// them (design section 7.8). Called after every data change and from the
/// widget's own background callback, so both paths show the same numbers.
Future<void> syncHomeWidgets(AppDatabase db, {DateTime? now}) async {
  final moment = now ?? DateTime.now();
  final language = await SettingsRepository(db).getLanguage();
  // Indonesian puts a dot between the hours, English a colon (section 9).
  final separator = language == 'en' ? ':' : '.';

  final tasks = await TaskRepository(db).getTasks(includeInbox: true);
  final spaces = await SpaceRepository(db).getSpaces(includeArchived: false);
  final slots = await ClassSlotRepository(db).getAllClassSlots();
  final exceptions = await ClassExceptionRepository(db).getClassExceptions();
  final spaceNames = {for (final space in spaces) space.id: space.name};

  final byDeadline = [...tasks]
    ..sort((a, b) => (a.deadline ?? _noDeadline).compareTo(b.deadline ?? _noDeadline));

  final taskRows = widgetTaskRows([
    for (final task in byDeadline)
      (id: task.id, title: task.title, done: task.status == 'done'),
  ]);

  final focusRows = widgetFocusRows([
    for (final task in byDeadline)
      if (isFocusOnDay(task.focusDate, moment))
        (id: task.id, title: task.title, done: task.status == 'done'),
  ]);

  final classRows = <({DateTime start, WidgetClassRow row})>[];
  for (final space in spaces) {
    final windows = classWindowDetailsFor(
      date: moment,
      spaceId: space.id,
      slots: slots,
      exceptions: exceptions,
    );
    for (final window in windows) {
      classRows.add((
        start: window.start,
        row: (
          course: space.name,
          room: window.room ?? '',
          time: widgetClassTime(window.start, separator: separator),
        ),
      ));
    }
  }
  classRows.sort((a, b) => a.start.compareTo(b.start));

  final countdown = widgetExamCountdown(
    now: moment,
    exams: [
      for (final task in byDeadline)
        if (task.spaceId != null && task.deadline != null)
          (
            course: spaceNames[task.spaceId] ?? '',
            title: task.title,
            deadline: DateTime.fromMillisecondsSinceEpoch(task.deadline!),
          ),
    ],
  );

  await HomeWidget.saveWidgetData<String>(
    kWidgetTasksKey,
    jsonEncode([
      for (final row in taskRows) _taskRowJson(row),
    ]),
  );
  await HomeWidget.saveWidgetData<String>(
    kWidgetFocusKey,
    jsonEncode([
      for (final row in focusRows) _taskRowJson(row),
    ]),
  );
  await HomeWidget.saveWidgetData<String>(
    kWidgetClassesKey,
    jsonEncode([
      for (final entry in classRows) _classRowJson(entry.row),
    ]),
  );
  await HomeWidget.saveWidgetData<String>(
    kWidgetExamKey,
    countdown == null ? '' : jsonEncode(_examJson(countdown)),
  );

  for (final provider in const [
    kTaskWidgetProvider,
    kClassWidgetProvider,
    kExamWidgetProvider,
    kFocusWidgetProvider,
  ]) {
    await HomeWidget.updateWidget(qualifiedAndroidName: provider);
  }
}

Map<String, Object?> _taskRowJson(WidgetTaskRow row) =>
    {'id': row.id, 'title': row.title, 'done': row.done};

Map<String, Object?> _classRowJson(WidgetClassRow row) =>
    {'course': row.course, 'room': row.room, 'time': row.time};

Map<String, Object?> _examJson(WidgetExamCountdown countdown) => {
      'course': countdown.course,
      'title': countdown.title,
      'days': countdown.days,
    };

/// Tapping a checkbox on a widget (design section 7.8) runs here, in a
/// background isolate: flip the task and redraw the widgets right away.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? data) async {
  if (data == null || data.host != 'toggle') return;
  final taskId = data.queryParameters['id'];
  if (taskId == null || taskId.isEmpty) return;
  WidgetsFlutterBinding.ensureInitialized();

  AppDatabase? db;
  try {
    db = await openAppDatabase();
    final repository = TaskRepository(db);
    final task = await repository.getTask(taskId);
    if (task.status == 'done') {
      await repository.reopenTask(taskId);
    } else {
      await repository.markDone(taskId);
    }
    await syncHomeWidgets(db);
  } catch (error, stack) {
    // A task deleted from the app while the widget still shows it.
    debugPrint('widget toggle failed: $error\n$stack');
  } finally {
    await db?.close();
  }
}

/// Keeps the widgets in step with the data. Task edits arrive often while
/// a form is being typed, so the rebuild waits for a short pause.
final homeWidgetSyncProvider = Provider<void>((ref) {
  Timer? timer;
  ref.onDispose(() => timer?.cancel());
  ref.watch(allTasksProvider).whenData((_) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 400), () {
      unawaited(syncHomeWidgets(ref.read(appDatabaseProvider)).catchError(
        (Object error, StackTrace stack) {
          debugPrint('widget sync failed: $error\n$stack');
        },
      ));
    });
  });
});
