import 'dart:math';
import '../core/scoring_config.dart';

/// Computes the urgency score of a task for sorting inside the Today screen.
/// The score is computed at display time and never stored in the database.
///
/// Base formula:
///   score = (U x uw) + P + (B x bw) + (T x tFactor)
///
///   U = 100 x e^(-hours_left / 48)              (max 100)
///   P = low 0 | medium 10 | high 25
///   B = weight_percent x 0.6                    (max about 30)
///   T = estimate_hours / effective_hours_left   (clamped between 0 and 2)
///
/// Adjustments from the extra features:
/// - Class schedule filled in: class hours are subtracted from effective hours
/// - Subtasks exist: the remaining estimate for T shrinks with the progress
/// - Personal target exists: U uses the target date instead of the deadline
/// - Component weight filled in: B uses the effective weight
/// - Task waits for another task: not sorted (Waiting section)

double urgencyScore({
  required DateTime now,
  DateTime? deadline,
  DateTime? targetAt,
  required int priority, // 0 low 1 med 2 high
  double? weightPercent,
  int? estimateMinutes,
  int? remainingEstimateMinutes,
  double? effectiveHoursAvailable, // effective hours left (from class schedule, etc.)
  double? subtaskProgress, // 0.0 to 1.0
  bool useTargetForUrgency = false,
  double? effectiveWeightPercent, // effective weight from design 5.18
}) {
  // No deadline and no target: score 0
  if (deadline == null && targetAt == null) return 0;

  // Pick the reference time for component U (deadline or target)
  final referenceTime = useTargetForUrgency && targetAt != null ? targetAt : deadline;
  if (referenceTime == null) return 0;

  final hoursLeft = referenceTime.difference(now).inMinutes / 60.0;
  if (hoursLeft <= 0) return 0; // late tasks live in the separate Overdue section

  final u = 100 * exp(-hoursLeft / 48);

  final p = priority == 0
      ? ScoringConfig.pLow
      : priority == 1
          ? ScoringConfig.pMed
          : ScoringConfig.pHigh;

  // Component B: effective weight when available, manual weight otherwise
  final b = (effectiveWeightPercent ?? weightPercent ?? 0) * ScoringConfig.bFactor;

  double t = 0;
  if (estimateMinutes != null && estimateMinutes > 0) {
    // With subtasks, shrink the remaining estimate by the progress made
    final effectiveEstimate = estimateMinutes;
    final remaining = remainingEstimateMinutes ?? effectiveEstimate;
    final remainingAfterProgress = subtaskProgress != null
        ? remaining * (1 - subtaskProgress.clamp(0.0, 1.0))
        : remaining.toDouble();

    final remainingHours = remainingAfterProgress / 60.0;
    final effectiveLeft = (effectiveHoursAvailable ?? max(hoursLeft, 1.0)) *
        ScoringConfig.effectiveHoursPerDay / 24.0;
    final ratio = effectiveLeft <= 0 ? 2.0 : remainingHours / effectiveLeft;
    t = ratio.clamp(0.0, 2.0);
  }

  final uw = ScoringConfig.prioritizeDeadline ? 0.5 : 0.3;
  final bw = ScoringConfig.prioritizeDeadline ? 0.6 : 0.8;
  return (u * uw) + p + (b * bw) + (t * ScoringConfig.tFactor);
}

/// The single factor that dominates a task's score, shown as the short
/// reason under every card (design section 4.4).
enum UrgencyReason {
  overdue,
  dueSoon,
  highPriority,
  heavyWeight,
  tightEstimate,
  timeLeft,
  noDeadline,
}

/// Picks the reason a task sits where it does. The same inputs as
/// [urgencyScore] so the printed reason always matches the sorted order.
UrgencyReason urgencyReason({
  required DateTime now,
  DateTime? deadline,
  required int priority,
  double? weightPercent,
  int? estimateMinutes,
}) {
  if (deadline == null) return UrgencyReason.noDeadline;

  final hoursLeft = deadline.difference(now).inMinutes / 60.0;
  if (hoursLeft <= 0) return UrgencyReason.overdue;
  if (hoursLeft <= 24) return UrgencyReason.dueSoon;
  if ((weightPercent ?? 0) >= 60) return UrgencyReason.heavyWeight;
  if (priority == 2) return UrgencyReason.highPriority;
  if (estimateMinutes != null &&
      estimateMinutes > 0 &&
      estimateMinutes / 60.0 > hoursLeft) {
    return UrgencyReason.tightEstimate;
  }
  return UrgencyReason.timeLeft;
}

/// The screen section where a task should appear, based on status and conditions.
enum TaskSection { today, overdue, doing, upcoming, thisWeek, waiting, someday, inbox }

TaskSection classifySection({
  required DateTime now,
  DateTime? deadline,
  DateTime? targetAt,
  required String status,
  bool isOverdue = false,
  bool isWaiting = false,
  bool isPinned = false,
}) {
  if (status == 'doing') return TaskSection.doing;
  if (isPinned) return TaskSection.today; // pinned tasks show at the top
  if (isOverdue) return TaskSection.overdue;
  if (deadline == null && targetAt == null) return TaskSection.someday;
  if (isWaiting) return TaskSection.waiting;

  final reference = targetAt ?? deadline;
  if (reference == null) return TaskSection.someday;

  final daysLeft = reference.difference(now).inDays;
  if (daysLeft <= 1) return TaskSection.today;
  if (daysLeft <= 7) return TaskSection.thisWeek;
  return TaskSection.upcoming;
}
