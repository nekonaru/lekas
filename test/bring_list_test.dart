import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/bring_list.dart';

void main() {
  group('bring list for tomorrow (design section 5.32)', () {
    test('courses without items contribute nothing', () {
      final plan = bringLinePlan(const [[], []]);
      expect(plan.shown, isEmpty);
      expect(plan.hidden, 0);
    });

    test('items keep their course order', () {
      final plan = bringLinePlan(const [
        ['laptop', 'kabel LAN'],
        ['laprak cetak'],
      ]);
      expect(plan.shown, ['laptop', 'kabel LAN', 'laprak cetak']);
      expect(plan.hidden, 0);
    });

    test('a long list is cut and the rest is counted', () {
      final plan = bringLinePlan(const [
        ['a', 'b', 'c'],
        ['d', 'e', 'f', 'g'],
      ]);
      expect(plan.shown, ['a', 'b', 'c', 'd', 'e']);
      expect(plan.hidden, 2);
    });

    test('the limit can be lowered for a test', () {
      final plan = bringLinePlan(const [['a', 'b']], maxItems: 1);
      expect(plan.shown, ['a']);
      expect(plan.hidden, 1);
    });
  });
}
