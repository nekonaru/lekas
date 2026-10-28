import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/parser/advanced_extractor.dart';
import 'package:lekas/parser/parser_service.dart';

/// Quick Add parses on every settled keystroke, and shares and voice notes
/// hand the parser whatever they were given. The parser reads a bounded
/// slice of it, so a pasted page becomes a short title instead of a freeze,
/// while the notes keep the original message.
void main() {
  final parser = ParserService.forSpaces(const [
    {'id': 's1', 'name': 'Basis Data', 'code': 'BD', 'aliases': 'basdat'},
  ]);

  test('a pasted page is only read up to the cap', () {
    final input = '${'kata panjang yang diulang ' * 2400}penutup unik';
    expect(input.length, greaterThan(kMaxParsedChars));

    final result = parser.parse(input);

    // The original message survives untouched as the notes.
    expect(result.notes, input.trim());
    expect(result.title, contains('kata panjang'));
    expect(result.title.length, lessThan(kMaxParsedChars));
    // The tail is past the cap, so it never reaches the title.
    expect(result.title, isNot(contains('penutup unik')));
  });

  test('the cap cuts at a word boundary', () {
    final input = 'awal ${'y' * 5000} akhir';

    final result = parser.parse(input);

    expect(result.title, 'awal');
    expect(result.notes, contains('akhir'));
  });

  test('a checklist of hundreds of lines stops at the cap', () {
    final input = [
      for (var i = 0; i < 200; i++) '- pekerjaan nomor $i',
    ].join('\n');

    final out = extractSubtasks(input);

    expect(out.subtasks, hasLength(kMaxSubtasks));
    // The list keeps its order and the first lines are the ones kept.
    expect(out.subtasks.first, 'pekerjaan nomor 0');
    expect(out.subtasks.last, 'pekerjaan nomor ${kMaxSubtasks - 1}');
  });

  test('an ordinary message is not touched by either limit', () {
    final result =
        parser.parse('kumpul berkas senin jam 10 1. satu 2. dua');

    expect(result.title, contains('kumpul berkas'));
    expect(result.subtasks, ['satu', 'dua']);
  });
}
