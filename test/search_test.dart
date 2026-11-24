import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/search.dart';

void main() {
  test('every query token must occur, in any order', () {
    expect(matchesQuery('Kumpul basis data besok', 'basis besok'), isTrue);
    expect(matchesQuery('Kumpul basis data besok', 'besok basis'), isTrue);
    expect(matchesQuery('Kumpul basis data besok', 'basis lusa'), isFalse);
  });

  test('matching is case insensitive and ignores outer spaces', () {
    expect(matchesQuery('Laporan Pemrograman Web', '  WEB laporan '), isTrue);
  });

  test('an empty query never matches', () {
    expect(matchesQuery('anything', ''), isFalse);
    expect(matchesQuery('anything', '   '), isFalse);
  });
}
