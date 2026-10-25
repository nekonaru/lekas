import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/urgency.dart';

void main() {
  test('urgency score positive for future deadline', () {
    final now = DateTime(2026, 1, 1, 12);
    final dl = now.add(const Duration(hours: 6));
    final s = urgencyScore(now: now, deadline: dl, priority: 2, weightPercent: 30);
    expect(s, greaterThan(0));
  });
  test('no deadline returns 0', () {
    final s = urgencyScore(now: DateTime.now(), deadline: null, priority: 1);
    expect(s, 0);
  });
}