/// Habit tracking math: day keys, streaks and weekly rates.
/// Pure functions, testable without a database.
library;

/// The local calendar day as `YYYY-MM-DD`, the storage format of a check.
String dayKeyOf(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Parses a day key back into a local date. Returns null on garbage.
DateTime? dayFromKey(String key) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(key.trim());
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return DateTime(year, month, day);
}

/// The [count]-day window ending at [end], oldest first.
List<String> lastNDayKeys(int count, {required DateTime end}) {
  final last = DateTime(end.year, end.month, end.day);
  return [
    for (var i = count - 1; i >= 0; i--)
      dayKeyOf(last.subtract(Duration(days: i))),
  ];
}

/// The next occurrence of a daily reminder at [hour]: [minute]. When that
/// time has already passed today, the next day is returned so the plugin
/// never gets a past instant.
DateTime nextDailyReminder(DateTime now, int hour, int minute) {
  final candidate = DateTime(now.year, now.month, now.day, hour, minute);
  return candidate.isAfter(now) ? candidate : candidate.add(const Duration(days: 1));
}

/// Counts consecutive days ending today from a set of active day keys.
/// A today that is not active yet does not break the streak: the walk
/// simply starts at yesterday. Ten years is the safety cap.
int countDayStreak(Set<String> days, DateTime today) {
  final last = DateTime(today.year, today.month, today.day);
  var streak = 0;
  var cursor = last;
  if (days.contains(dayKeyOf(cursor))) streak += 1;
  while (true) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(dayKeyOf(cursor))) break;
    streak += 1;
    if (streak > 3650) break;
  }
  return streak;
}

/// Consecutive checked days ending today. A today without a check yet
/// does not break the streak: the count walks back from yesterday.
int habitStreak(
  Iterable<String> checkedDays, {
  required DateTime today,
  Iterable<String> skippedDays = const [],
}) =>
    countDayStreak(
      {
        ...checkedDays,
        // A rest day keeps the chain alive but is not a check-in.
        ...skippedDays,
      },
      today,
    );

/// How many of the last [days] days are checked, out of [days].
int habitWindowCount(
  Iterable<String> checkedDays, {
  required DateTime end,
  required int days,
}) {
  final wanted = lastNDayKeys(days, end: end).toSet();
  return checkedDays.toSet().intersection(wanted).length;
}
