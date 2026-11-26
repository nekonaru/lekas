import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/database.dart';
import 'package:lekas/domain/focus_log.dart';

FocusSession _session(String id, DateTime at, int minutes) => FocusSession(
      id: id,
      taskId: 't1',
      startedAt: at.millisecondsSinceEpoch,
      durationSec: minutes * 60,
    );

void main() {
  test('sessions are grouped by day, newest day first', () {
    final today = DateTime(2026, 11, 27, 12);
    final days = groupFocusSessions(
      [
        _session('a', DateTime(2026, 11, 26, 9), 25),
        _session('b', DateTime(2026, 11, 27, 8), 45),
        _session('c', DateTime(2026, 11, 27, 10), 15),
      ],
      today: today,
    );
    expect(days.map((d) => d.key), ['2026-11-27', '2026-11-26']);
    expect(days.first.minutes, 60);
    expect(days.first.sessions.map((s) => s.id), ['c', 'b']);
  });

  test('empty input gives an empty log', () {
    expect(
      groupFocusSessions(const [], today: DateTime(2026, 11, 27)),
      isEmpty,
    );
  });
}
