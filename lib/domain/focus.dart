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
