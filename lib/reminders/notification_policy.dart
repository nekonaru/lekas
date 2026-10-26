/// Notification policy (design section 5.21): how loud the reminder ladder
/// is, how reminders that fall close together become one notification, and
/// how many non critical notifications a single day may use.
library;

/// One reminder offset before a deadline (design section 4.6).
class ReminderSpec {
  const ReminderSpec(this.kind, this.offset, {this.deadlineDayOnly = false});

  /// Stable key stored in the reminders table, e.g. `d3`.
  final String kind;

  /// How long before the deadline this reminder fires.
  final Duration offset;

  /// Only used when the reminder lands on the calendar day of the deadline.
  final bool deadlineDayOnly;
}

/// Standard reminder ladder: H-3, H-1, 3 hours, 30 minutes.
const List<ReminderSpec> kReminderSpecs = [
  ReminderSpec('d3', Duration(days: 3)),
  ReminderSpec('d1', Duration(days: 1)),
  ReminderSpec('h3', Duration(hours: 3)),
  ReminderSpec('m30', Duration(minutes: 30)),
];

/// Extra lead time for heavy tasks (weight at or above [kHeavyTaskWeight]).
const ReminderSpec kHeavyTaskSpec = ReminderSpec('d7', Duration(days: 7));
const double kHeavyTaskWeight = 60;

/// The quiet ladder of design 5.21: only H-1 and 3 hours.
const List<ReminderSpec> kCalmSpecs = [
  ReminderSpec('d1', Duration(days: 1)),
  ReminderSpec('h3', Duration(hours: 3)),
];

/// The eager extras of design 5.21: every six hours on the deadline day.
const List<ReminderSpec> kEagerSpecs = [
  ReminderSpec('h6', Duration(hours: 6), deadlineDayOnly: true),
  ReminderSpec('h12', Duration(hours: 12), deadlineDayOnly: true),
  ReminderSpec('h18', Duration(hours: 18), deadlineDayOnly: true),
];

/// How loud the reminders are (design section 5.21).
enum ReminderIntensity { calm, normal, eager }

/// Reads the intensity from its stored setting, defaulting to normal.
ReminderIntensity intensityFromSetting(String? raw) {
  switch (raw) {
    case 'calm':
      return ReminderIntensity.calm;
    case 'eager':
      return ReminderIntensity.eager;
    default:
      return ReminderIntensity.normal;
  }
}

/// The reminder ladder for one intensity (design section 5.21).
List<ReminderSpec> specsForIntensity(
  ReminderIntensity intensity, {
  double? weightPercent,
}) {
  if (intensity == ReminderIntensity.calm) {
    return [...kCalmSpecs];
  }
  final specs = <ReminderSpec>[...kReminderSpecs];
  if (weightPercent != null && weightPercent >= kHeavyTaskWeight) {
    specs.insert(0, kHeavyTaskSpec);
  }
  if (intensity == ReminderIntensity.eager) {
    specs.addAll(kEagerSpecs);
  }
  return specs;
}

/// One reminder the scheduler would like to fire.
class NotificationCandidate {
  const NotificationCandidate({
    required this.key,
    required this.fireAt,
    required this.deadline,
    required this.title,
  });

  /// Row key of the reminder, `<taskId>:<kind>`.
  final String key;
  final DateTime fireAt;
  final DateTime deadline;
  final String title;

  /// Reminders for a deadline up to three hours away are never trimmed
  /// by the budget (design section 5.21).
  bool get critical => deadline.difference(fireAt) <= const Duration(hours: 3);
}

/// One notification that will actually be scheduled. A plan with more than
/// one member is a merged notification, a summary plan collects everything
/// that did not fit into the daily budget.
class PlannedNotification {
  const PlannedNotification({
    required this.fireAt,
    required this.members,
    this.summary = false,
  });

  final DateTime fireAt;
  final List<NotificationCandidate> members;
  final bool summary;

  /// The candidate that owns the notification row.
  NotificationCandidate get lead => members.first;

  bool get merged => members.length > 1;
}

/// Whether an overdue task still belongs in the daily overdue notification
/// (design section 5.22): it is mentioned for at most three days after the
/// deadline, then only the Overdue section and the morning summary show it.
bool countsAsFreshOverdue({required DateTime deadline, required DateTime now}) {
  if (!now.isAfter(deadline)) return false;
  return now.isBefore(deadline.add(const Duration(days: 3)));
}

/// True when both moments fall on the same calendar day.
bool sameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Whether [deadline] lands on [day], used by the morning and evening
/// summaries (design section 5.12).
bool dueOnDay({required DateTime deadline, required DateTime day}) =>
    sameCalendarDay(deadline, day);

/// The next time [hour]:[minute] is still in the future.
DateTime nextMomentAt(DateTime now, int hour, [int minute = 0]) {
  var moment = DateTime(now.year, now.month, now.day, hour, minute);
  if (!moment.isAfter(now)) {
    moment = moment.add(const Duration(days: 1));
  }
  return moment;
}

/// The next 09:00 that is still in the future: when the daily overdue
/// digest fires (design section 5.22).
DateTime nextDigestAt(DateTime now) => nextMomentAt(now, 9);

/// Reminders closer together than this become one notification.
const Duration kMergeWindow = Duration(minutes: 10);

/// Non critical notifications per day before the rest is summarized.
const int kDailyNotificationBudget = 8;

String _dayKey(DateTime moment) =>
    '${moment.year}-${moment.month.toString().padLeft(2, '0')}-${moment.day.toString().padLeft(2, '0')}';

/// Turns raw reminder candidates into the notifications to schedule:
/// reminders within [kMergeWindow] are joined, then every local day may use
/// [budget] non critical notifications and the excess is folded into a single
/// summary (design section 5.21).
List<PlannedNotification> planNotifications(
  Iterable<NotificationCandidate> candidates, {
  int budget = kDailyNotificationBudget,
}) {
  final sorted = candidates.toList()
    ..sort((a, b) => a.fireAt.compareTo(b.fireAt));

  // Merge everything inside a ten minute span into one notification.
  final clusters = <List<NotificationCandidate>>[];
  for (final candidate in sorted) {
    if (clusters.isNotEmpty &&
        candidate.fireAt
                .difference(clusters.last.first.fireAt)
                .abs() <=
            kMergeWindow) {
      clusters.last.add(candidate);
    } else {
      clusters.add([candidate]);
    }
  }

  final kept = <PlannedNotification>[];
  final used = <String, int>{};
  final overflow = <String, List<NotificationCandidate>>{};
  for (final cluster in clusters) {
    final critical = cluster.any((member) => member.critical);
    final day = _dayKey(cluster.first.fireAt);
    final count = used[day] ?? 0;
    if (!critical && count >= budget) {
      overflow.putIfAbsent(day, () => []).addAll(cluster);
      continue;
    }
    if (!critical) used[day] = count + 1;
    kept.add(
      PlannedNotification(
        fireAt: cluster.first.fireAt,
        members: List.unmodifiable(cluster),
      ),
    );
  }

  // Everything over the budget becomes one summary per day.
  for (final day in overflow.keys) {
    final members = overflow[day]!
      ..sort((a, b) => a.fireAt.compareTo(b.fireAt));
    kept.add(PlannedNotification(
      fireAt: members.first.fireAt,
      members: List.unmodifiable(members),
      summary: true,
    ));
  }

  kept.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return kept;
}
