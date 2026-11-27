import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/batch_edit.dart';

void main() {
  test('tag names are normalized like the tag repository', () {
    expect(
      normalizeTagNames([' #Revisi ', 'revisi', 'urgent', 'belajar', '']),
      ['belajar', 'revisi', 'urgent'],
    );
  });

  test('empty edit has no change', () {
    expect(
      const BatchEdit(
        spaceId: null,
        priority: null,
        done: null,
        tagNames: [],
      ).hasChange,
      isFalse,
    );
  });

  test('a single field counts as a change', () {
    expect(
      const BatchEdit(
        spaceId: 's1',
        priority: null,
        done: null,
        tagNames: [],
      ).hasChange,
      isTrue,
    );
  });
}
