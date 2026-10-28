import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/parser/advanced_extractor.dart';
import 'package:lekas/parser/parser_service.dart';

/// Cutting used to run one match at a time against a text that had already
/// been tidied, so the offsets of every match behind the cut were stale: a
/// sentence with two `!` markers threw a RangeError and an indented message
/// with two links came back with words glued together.
void main() {
  group('cutting tokens never shifts the rest of the text', () {
    test('two known priority markers both leave the text', () {
      final out =
          extractPriorityMarkers('!tinggi laporan minggu ini !rendah');

      expect(out.seen, isTrue);
      // The first marker decides (design section 7.15).
      expect(out.priority, 3);
      expect(out.remainingText, 'laporan minggu ini');
      expect(out.remainingText, isNot(contains('!')));
    });

    test('a marker behind leading spaces does not throw', () {
      final out = extractPriorityMarkers('  !tinggi kerjakan besok !rendah');

      expect(out.priority, 3);
      expect(out.remainingText, 'kerjakan besok');
      expect(out.remainingText, isNot(contains('!')));
    });

    test('an unknown marker keeps its place in the text', () {
      final out = extractPriorityMarkers('kerja !asap besok !rendah');

      expect(out.seen, isTrue);
      expect(out.priority, 0);
      expect(out.remainingText, contains('!asap'));
      expect(out.remainingText, isNot(contains('!rendah')));
    });

    test('every link is taken even behind leading spaces', () {
      final out =
          extractLinks('  lihat https://a.com/x lalu https://b.com/y');

      expect(out.links, ['https://a.com/x', 'https://b.com/y']);
      expect(out.remainingText, 'lihat lalu');
      expect(out.remainingText, isNot(contains('http')));
    });

    test('trailing punctuation stays out of the link', () {
      final out = extractLinks('baca https://a.com/x. lalu www.b.com/y!');

      expect(out.links, ['https://a.com/x', 'https://www.b.com/y']);
    });

    test('both sides of a priority conflict are removed', () {
      final out = extractPriorityWords(
        'penting sekali santai juga',
        isIndonesian: true,
      );

      expect(out.remainingText, 'sekali juga');
      expect(out.conflict, isTrue);
      expect(out.priority, 1);
    });
  });

  group('the parser survives a sentence with two markers', () {
    final parser = ParserService.forSpaces(const [
      {'id': 's1', 'name': 'Basis Data', 'code': 'BD', 'aliases': 'basdat'},
    ]);

    test('the markers disappear and the first one decides', () {
      final result = parser.parse('!tinggi laporan minggu ini !rendah');

      expect(result.priority, 3);
      expect(result.title, 'laporan minggu ini');
      expect(result.title, isNot(contains('!')));
    });

    test('an indented message with links keeps a readable title', () {
      final result = parser
          .parse('  lihat https://a.com/x lalu https://b.com/y ya');

      expect(result.links, hasLength(2));
      expect(result.title, isNot(contains('http')));
      expect(result.title, contains('lihat'));
    });
  });
}
