import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/data/tag_repository.dart';

void main() {
  group('free tags (design section 5.9)', () {
    test('a hash prefix is dropped and the name is lowercased', () {
      expect(normalizeTagName('#Kelompok'), 'kelompok');
      expect(normalizeTagName('  #revisi  '), 'revisi');
      expect(normalizeTagName('beli'), 'beli');
    });

    test('spaces inside a tag collapse into one', () {
      expect(normalizeTagName('  tugas   bersama '), 'tugas bersama');
    });

    test('an empty or hash only input is not a tag', () {
      expect(normalizeTagName('   '), '');
      expect(normalizeTagName('##'), '');
    });
  });
}
