import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/deep_link.dart';

void main() {
  test('a lekas task link yields the task id', () {
    expect(taskIdFromLink('lekas://task/abc-123'), 'abc-123');
  });

  test('other schemes, hosts and malformed ids never navigate', () {
    expect(taskIdFromLink('https://task/abc'), isNull);
    expect(taskIdFromLink('lekas://other/abc'), isNull);
    expect(taskIdFromLink('lekas://task/'), isNull);
    expect(taskIdFromLink('lekas://task/a b'), isNull);
    expect(taskIdFromLink('not a uri'), isNull);
  });
}
