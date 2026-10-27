/// Focus of the day, design section 5.24: at most three tasks, picked for
/// one single day. Unlike a pin, focus expires when the day is over.
library;

/// How many tasks may share today's focus.
const int kMaxFocusTasks = 3;

/// Start of a local day as the milliseconds the `focus_date` column stores.
int startOfDayMs(DateTime day) =>
    DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;

/// Whether a task picked on [focusDate] still counts for [day]. Focus
/// belongs to exactly one day, so yesterday's pick never leaks into today.
bool isFocusOnDay(int? focusDate, DateTime day) {
  if (focusDate == null) return false;
  final start = startOfDayMs(day);
  return focusDate >= start &&
      focusDate < start + const Duration(days: 1).inMilliseconds;
}

/// Whether one more task may join the focus list (design section 5.24).
bool focusHasRoom(int picked) => picked < kMaxFocusTasks;

/// The small celebration of design section 5.24: every picked focus task is
/// finished. An empty focus list is not a celebration.
bool focusAllDone(List<bool> doneFlags) =>
    doneFlags.isNotEmpty && doneFlags.every((done) => done);

/// Yesterday's focus tasks that are still open and still fit into today's
/// focus, for the offer the morning summary makes the next day (design
/// section 5.24: "Lanjutkan 2 tugas kemarin?"). Ids come back in the order
/// they were given and never break the three task limit.
List<String> focusCarryOverIds({
  required DateTime today,
  required Iterable<({String id, int? focusDate, bool done})> tasks,
}) {
  final list = tasks.toList();
  final yesterday = DateTime(today.year, today.month, today.day - 1);
  final takenToday =
      list.where((task) => isFocusOnDay(task.focusDate, today)).length;
  var room = kMaxFocusTasks - takenToday;
  final carry = <String>[];
  if (room <= 0) return carry;
  for (final task in list) {
    if (task.done) continue;
    if (!isFocusOnDay(task.focusDate, yesterday)) continue;
    carry.add(task.id);
    room--;
    if (room == 0) break;
  }
  return carry;
}
