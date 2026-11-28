/// Transcript rollup across semesters. Pure over repository rows.
library;

class TranscriptEntry {
  const TranscriptEntry({
    required this.semesterName,
    required this.average,
    required this.subjectCount,
  });

  final String? semesterName;
  final double? average;
  final int subjectCount;
}

/// Mean of the semester averages that exist; semesters with no numeric
/// final grade are skipped rather than counted as zero.
double? transcriptAverage(Iterable<TranscriptEntry> entries) {
  final values = [
    for (final entry in entries)
      if (entry.average != null) entry.average!,
  ];
  if (values.isEmpty) return null;
  return values.reduce((a, b) => a + b) / values.length;
}
