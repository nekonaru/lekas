import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/transcript.dart';

void main() {
  test('transcript average skips semesters without grades', () {
    final average = transcriptAverage([
      const TranscriptEntry(
        semesterName: '1',
        average: 80,
        subjectCount: 4,
      ),
      const TranscriptEntry(
        semesterName: '2',
        average: null,
        subjectCount: 4,
      ),
      const TranscriptEntry(
        semesterName: '3',
        average: 90,
        subjectCount: 4,
      ),
    ]);
    expect(average, 85);
  });

  test('no grades anywhere gives no average', () {
    expect(
      transcriptAverage([
        const TranscriptEntry(
          semesterName: '1',
          average: null,
          subjectCount: 0,
        ),
      ]),
      isNull,
    );
  });
}
