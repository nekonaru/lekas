/// Grouping for the focus-session log. Pure over repositories' rows.
library;

import '../data/database.dart' show FocusSession;
import 'habits.dart' show dayKeyOf;

class FocusLogDay {
  const FocusLogDay({
    required this.key,
    required this.minutes,
    required this.sessions,
  });

  final String key;
  final int minutes;
  final List<FocusSession> sessions;
}

/// Last [days] calendar days, newest first, with their sessions and total
/// focus minutes. Days with no sessions are omitted.
List<FocusLogDay> groupFocusSessions(
  Iterable<FocusSession> sessions, {
  required DateTime today,
  int days = 14,
}) {
  final byDay = <String, List<FocusSession>>{};
  for (final session in sessions) {
    final key = dayKeyOf(DateTime.fromMillisecondsSinceEpoch(session.startedAt));
    (byDay[key] ??= []).add(session);
  }
  final keys = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final key in keys.take(days))
      FocusLogDay(
        key: key,
        minutes: byDay[key]!.fold<int>(
          0,
          (sum, session) => sum + (session.durationSec / 60).floor(),
        ),
        sessions: byDay[key]!..sort(
          (a, b) => b.startedAt.compareTo(a.startedAt),
        ),
      ),
  ];
}
