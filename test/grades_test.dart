import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/grades.dart';

void main() {
  test('plain average when no scored label carries a weight', () {
    final average = averageScore(
      const [
        ScoreLike(label: 'Harian 1', value: 80),
        ScoreLike(label: 'Harian 2', value: 90),
        ScoreLike(label: 'UTS', value: 60),
      ],
      const {},
    );
    expect(average, closeTo((80 + 90 + 60) / 3, 1e-9));
  });

  test('repeated labels average into one component first', () {
    final average = averageScore(
      const [
        ScoreLike(label: 'Harian 1', value: 80),
        ScoreLike(label: 'Harian 1', value: 100),
        ScoreLike(label: 'UTS', value: 60),
      ],
      const {},
    );
    // Components: Harian 1 = 90, UTS = 60.
    expect(average, closeTo(75, 1e-9));
  });

  test('weighted components renormalize over scored labels', () {
    final average = averageScore(
      const [
        ScoreLike(label: 'UTS', value: 50),
        ScoreLike(label: 'UAS', value: 90),
      ],
      const {'uts': 40, 'uas': 60},
    );
    // (50*40 + 90*60) / 100 = 74
    expect(average, closeTo(74, 1e-9));
  });

  test('labels without a weight are ignored when a weighted label exists', () {
    final average = averageScore(
      const [
        ScoreLike(label: 'UTS', value: 80),
        ScoreLike(label: 'Kuis', value: 20),
      ],
      const {'uts': 100},
    );
    expect(average, 80);
  });

  test('zero and negative weights are treated as absent weights', () {
    final average = averageScore(
      const [
        ScoreLike(label: 'UTS', value: 80),
        ScoreLike(label: 'UAS', value: 100),
      ],
      const {'uts': 0, 'uas': -5},
    );
    // No usable weights, so plain mean of the two means.
    expect(average, 90);
  });

  test('empty or whitespace labels are skipped', () {
    expect(
      averageScore(const [ScoreLike(label: '   ', value: 50)], const {}),
      isNull,
    );
    expect(averageScore(const [], const {}), isNull);
  });

  test('label matching is case and space insensitive', () {
    final average = averageScore(
      const [ScoreLike(label: '  UTS  ', value: 70)],
      const {'uts': 100},
    );
    expect(average, 70);
  });

  test('out-of-range values are clamped to 0-100', () {
    final average = averageScore(
      const [
        ScoreLike(label: 'UTS', value: 150),
        ScoreLike(label: 'UAS', value: -20),
      ],
      const {},
    );
    expect(average, 50);
  });

  test('meetsKkm compares inclusively', () {
    expect(meetsKkm(75.0, 75), isTrue);
    expect(meetsKkm(74.9, 75), isFalse);
  });
}
