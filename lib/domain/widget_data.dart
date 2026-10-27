/// What the home screen widgets show (design section 7.8): four small
/// payloads built from the same data the app itself uses, each written as
/// JSON under one of the keys below so the Android side can read them back.
library;

/// Preference keys read by the widget providers, shared with the Kotlin
/// side in `android/.../LekasWidgets.kt`.
const String kWidgetTasksKey = 'widget_tasks';
const String kWidgetClassesKey = 'widget_classes';
const String kWidgetExamKey = 'widget_exam';
const String kWidgetFocusKey = 'widget_focus';

/// The task list widget shows three to six lines (design section 7.8).
const int kWidgetTaskRows = 6;

/// The focus widget always shows the three focus slots of design 5.24.
const int kWidgetFocusRows = 3;

/// One row of the task list or focus widget.
typedef WidgetTaskRow = ({String id, String title, bool done});

/// One row of the classes widget.
typedef WidgetClassRow = ({String course, String room, String time});

/// The single number of the exam countdown widget.
typedef WidgetExamCountdown = ({String course, String title, int days});

/// The open rows of the task list, in the order they arrive, at most
/// [maxRows] of them: a finished task has no business on the home screen.
List<WidgetTaskRow> widgetTaskRows(
  Iterable<WidgetTaskRow> rows, {
  int maxRows = kWidgetTaskRows,
}) =>
    rows.where((row) => !row.done).take(maxRows).toList();

/// Today's focus rows, done ones included so their checkbox reads checked
/// (design section 5.24 keeps at most three).
List<WidgetTaskRow> widgetFocusRows(
  Iterable<WidgetTaskRow> rows, {
  int maxRows = kWidgetFocusRows,
}) =>
    rows.take(maxRows).toList();

/// Start time of a class row. The dot and the colon simply follow the
/// language of the app, which shows 24 hours in both (design section 9).
String widgetClassTime(DateTime start, {String separator = '.'}) {
  final hour = start.hour.toString().padLeft(2, '0');
  final minute = start.minute.toString().padLeft(2, '0');
  return '$hour$separator$minute';
}

/// The nearest exam still ahead: its course, the title of the deadline and
/// how many calendar days are left, 0 for today. Nothing ahead means no
/// countdown at all, and the widget shows its empty text instead.
WidgetExamCountdown? widgetExamCountdown({
  required Iterable<({String course, String title, DateTime deadline})> exams,
  required DateTime now,
}) {
  ({String course, String title, DateTime deadline})? nearest;
  for (final exam in exams) {
    if (exam.deadline.isBefore(now)) continue;
    if (nearest == null || exam.deadline.isBefore(nearest.deadline)) {
      nearest = exam;
    }
  }
  if (nearest == null) return null;
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(
      nearest.deadline.year, nearest.deadline.month, nearest.deadline.day);
  return (
    course: nearest.course,
    title: nearest.title,
    days: due.difference(today).inDays,
  );
}
