/// Grade math for the school (SMA) grade book. Pure functions, testable
/// without a database.
class ScoreLike {
  const ScoreLike({required this.label, required this.value});

  /// The free-form label, e.g. "Harian 1", "UTS", "UAS".
  final String label;

  /// 0 to 100, Indonesian school convention.
  final int value;
}

/// The class-average rule for one subject:
///
/// 1. Scores are first averaged per label (a subject may carry several
///    Ulangan Harian rows; they count as one component).
/// 2. Labels that match a grade component contribute with its weight.
/// 3. If no scored label carries an explicit weight, the result is the
///    plain mean of the per-label means.
///
/// Weights are renormalized over the labels that actually have scores, so
/// a missing component never drags the average down to zero. Returns null
/// when there is nothing to average.
double? averageScore(
  Iterable<ScoreLike> scores,
  Map<String, double> weightsByLabel,
) {
  final perLabel = <String, List<int>>{};
  for (final score in scores) {
    final key = score.label.trim().toLowerCase();
    if (key.isEmpty) continue;
    (perLabel[key] ??= []).add(score.value.clamp(0, 100));
  }
  if (perLabel.isEmpty) return null;

  final labelMeans = <String, double>{
    for (final entry in perLabel.entries)
      entry.key: entry.value.reduce((a, b) => a + b) / entry.value.length,
  };

  double weightOf(String label) {
    final weight = weightsByLabel[label];
    return (weight != null && weight > 0) ? weight : 0;
  }

  final weighted = labelMeans.entries.where((e) => weightOf(e.key) > 0);
  if (weighted.isEmpty) {
    final values = labelMeans.values;
    return values.reduce((a, b) => a + b) / values.length;
  }

  var numerator = 0.0;
  var denominator = 0.0;
  for (final entry in weighted) {
    final weight = weightOf(entry.key);
    numerator += entry.value * weight;
    denominator += weight;
  }
  return numerator / denominator;
}

/// The KKM check used by the grade book and the report card.
bool meetsKkm(double average, int kkm) => average >= kkm;
