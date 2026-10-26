import '../data/database.dart';

/// One class period of the checked day, already resolved against the
/// exceptions of that date.
typedef ClassWindow = ({DateTime start, DateTime end});

/// Key of a calendar day used by the `class_exceptions.date` column.
String classDateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// Class windows of [spaceId] on [date] (design sections 5.20 and 5.21):
/// cancelled classes drop out, moved classes use their new times.
List<ClassWindow> classWindowsFor({
  required DateTime date,
  required String? spaceId,
  required List<ClassSlot> slots,
  required List<ClassException> exceptions,
}) {
  if (spaceId == null) return const [];

  final key = classDateKey(date);
  final windows = <ClassWindow>[];
  for (final slot in slots) {
    if (slot.spaceId != spaceId || slot.weekday != date.weekday) continue;
    if (slot.deletedAt != null) continue;

    ClassException? change;
    for (final exception in exceptions) {
      if (exception.classSlotId == slot.id &&
          exception.date == key &&
          exception.deletedAt == null) {
        change = exception;
        break;
      }
    }
    if (change != null && change.kind.contains('cancel')) continue;

    var startMin = slot.startMin;
    var endMin = slot.endMin;
    if (change != null) {
      startMin = change.newStartMin ?? startMin;
      endMin = change.newEndMin ?? endMin;
    }
    windows.add((
      start: DateTime(date.year, date.month, date.day, startMin ~/ 60, startMin % 60),
      end: DateTime(date.year, date.month, date.day, endMin ~/ 60, endMin % 60),
    ));
  }
  return windows;
}

/// Holds a reminder that lands in the middle of a class until the class
/// ends (design section 5.21).
///
/// Exception from the design: a reminder whose deadline is less than one
/// hour after the class ends is never held, so a near deadline still wins.
DateTime holdOutOfClass({
  required DateTime fireAt,
  required DateTime? deadline,
  required List<ClassWindow> windows,
}) {
  for (final window in windows) {
    final inside = !fireAt.isBefore(window.start) && fireAt.isBefore(window.end);
    if (!inside) continue;
    if (deadline != null &&
        deadline.difference(window.end) < const Duration(hours: 1)) {
      return fireAt;
    }
    return window.end;
  }
  return fireAt;
}
