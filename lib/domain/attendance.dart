/// Attendance and the absence quota of design section 5.19: how many
/// meetings a course planned, how many were attended and how many absences
/// are still allowed before the campus minimum is at risk.
library;

/// Campus defaults of design section 5.19: 16 meetings, 25 percent absent.
const int kDefaultTotalMeetings = 16;
const int kDefaultMaxAbsentPercent = 25;

/// The four marks a class meeting can carry.
const List<String> kAttendanceStatuses = [
  'present',
  'absent',
  'excused',
  'sick',
];

String normalizeAttendanceStatus(String raw) {
  final value = raw.trim().toLowerCase();
  return kAttendanceStatuses.contains(value) ? value : 'present';
}

/// The rollup the per course card and the morning summary show:
/// "attended 9 of 11 meetings, 2 absences left" (design section 5.19).
class AttendanceSummary {
  const AttendanceSummary({
    required this.planned,
    required this.attended,
    required this.absentCount,
    required this.limit,
  });

  /// Meetings planned for the course.
  final int planned;

  /// Meetings marked as present.
  final int attended;

  /// Absences counted against the limit.
  final int absentCount;

  /// How many absences the campus rule still allows.
  final int limit;

  /// Absences still allowed; zero or less means the limit is used up.
  int get remaining => limit - absentCount;

  /// Soft warning: exactly one absence left.
  bool get lastOne => remaining == 1;

  /// Red warning: the allowance is gone.
  bool get exhausted => remaining <= 0;
}

/// Rolls up raw attendance marks into the numbers of design section 5.19.
/// [excusedCountsAbsent] decides whether izin and sakit spend the quota.
AttendanceSummary summarizeAttendance({
  int? totalMeetings,
  int? maxAbsentPercent,
  required bool excusedCountsAbsent,
  required Iterable<String> statuses,
}) {
  final planned =
      (totalMeetings ?? kDefaultTotalMeetings).clamp(1, 10000).toInt();
  final percent =
      (maxAbsentPercent ?? kDefaultMaxAbsentPercent).clamp(0, 100).toInt();
  final limit = planned * percent ~/ 100;

  var attended = 0;
  var absentCount = 0;
  for (final raw in statuses) {
    switch (raw) {
      case 'present':
        attended++;
      case 'absent':
        absentCount++;
      case 'excused':
      case 'sick':
        if (excusedCountsAbsent) absentCount++;
      default:
        break;
    }
  }
  return AttendanceSummary(
    planned: planned,
    attended: attended,
    absentCount: absentCount,
    limit: limit,
  );
}

/// The quota line for one course: null when nothing is tight, otherwise the
/// message key the caller should show with its own count.
String? attendanceAlertKey(AttendanceSummary summary) {
  if (summary.exhausted) return 'exhausted';
  if (summary.lastOne) return 'lastOne';
  return null;
}

/// One line per course for the morning summary when the absence quota is
/// down to its last one or gone (design sections 5.12 and 5.19). Entries
/// whose space name is missing from [spaceNames] are skipped so the
/// notification never shows an empty course name.
List<String> quotaAlertLines(
  Iterable<({String spaceId, int remaining})> tight,
  Map<String, String> spaceNames,
  String Function(String name, int remaining) message,
) {
  final lines = <String>[];
  for (final entry in tight) {
    final name = spaceNames[entry.spaceId];
    if (name == null || name.isEmpty) continue;
    lines.add(message(name, entry.remaining));
  }
  return lines;
}
