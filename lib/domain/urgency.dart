import 'dart:math';
import '../core/scoring_config.dart';

double urgencyScore({
  required DateTime now,
  DateTime? deadline,
  required int priority, // 0 low 1 med 2 high
  double? weightPercent,
  int? estimateMinutes,
  int? remainingEstimateMinutes,
}) {
  if (deadline == null) return 0;
  final hoursLeft = deadline.difference(now).inMinutes / 60.0;
  if (hoursLeft <= 0) return 0; // overdue handled separately
  final u = 100 * exp(-hoursLeft / 48);
  final p = priority == 0
      ? ScoringConfig.pLow
      : priority == 1
          ? ScoringConfig.pMed
          : ScoringConfig.pHigh;
  final b = (weightPercent ?? 0) * ScoringConfig.bFactor;
  double t = 0;
  if (estimateMinutes != null && estimateMinutes > 0) {
    final remainingHours = (remainingEstimateMinutes ?? estimateMinutes) / 60.0;
    final effectiveLeft = max(hoursLeft, 1) * ScoringConfig.effectiveHoursPerDay / 24.0;
    final ratio = effectiveLeft <= 0 ? 2.0 : remainingHours / effectiveLeft;
    t = ratio.clamp(0.0, 2.0);
  }
  final uw = ScoringConfig.prioritizeDeadline ? 0.5 : 0.3;
  final bw = ScoringConfig.prioritizeDeadline ? 0.6 : 0.8;
  return (u * uw) + p + (b * bw) + (t * ScoringConfig.tFactor);
}