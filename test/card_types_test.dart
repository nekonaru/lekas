import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/card_types.dart';

void main() {
  test('choices split on semicolons and ignore blanks', () {
    expect(
      parseChoices('A; B ;; C'),
      ['A', 'B', 'C'],
    );
    expect(parseChoices(null), isEmpty);
  });

  test('answer must match a listed option, case-insensitively', () {
    expect(choiceMatches('A; B; C', 'B', ' b '), isTrue);
    expect(choiceMatches('A; B; C', 'D', 'D'), isFalse);
    expect(choiceMatches('A; B', 'B', 'Z'), isFalse);
  });

  test('cloze blank detection uses the four-underscore marker', () {
    expect(hasClozeBlank('Ibu kota Indonesia ____ Jakarta'), isTrue);
    expect(hasClozeBlank('Ibu kota Indonesia Jakarta'), isFalse);
  });
}
