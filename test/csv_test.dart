import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/csv.dart';

void main() {
  test('a simple document parses into rows and cells', () {
    expect(
      parseCsv('a,b,c\n1,2,3\n'),
      [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
      ],
    );
  });

  test('CRLF and LF endings both parse', () {
    expect(
      parseCsv('a,b\r\n1,2\r\n'),
      [
        ['a', 'b'],
        ['1', '2'],
      ],
    );
  });

  test('the BOM is stripped', () {
    expect(
      parseCsv('\uFEFFa,b\n'),
      [
        ['a', 'b'],
      ],
    );
  });

  test('quoted cells keep commas, quotes and newlines intact', () {
    expect(
      parseCsv('title,note\n"Laporan, final","line one\nline two ""quoted"""\n'),
      [
        ['title', 'note'],
        ['Laporan, final', 'line one\nline two "quoted"'],
      ],
    );
  });

  test('round trip through csvRow recovers the cells', () {
    final original = [
      ['title', 'tags', 'note'],
      ['Kumpul, laporan', ';revisi;kelompok', 'first "draft"\nthen review'],
      ['', '', ''],
    ];
    final document = original.map(csvRow).join();
    final parsed = parseCsv(document);
    // The trailing newline must not fabricate a phantom row.
    expect(parsed, hasLength(3));
    expect(parsed[0], original[0]);
    expect(parsed[1], original[1]);
    expect(parsed[2], ['', '', '']);
  });

  test('a lone newline inside a quoted cell round-trips', () {
    final cell = 'bar\nbaz, qux';
    final parsed = parseCsv(csvRow(['x', cell]));
    expect(parsed.single[1], cell);
  });

  test('numbers and empty cells round-trip untouched', () {
    final parsed = parseCsv(csvRow(['plain', '123', '0', '']));
    expect(parsed.single, ['plain', '123', '0', '']);
  });

  test('escapeCsvCell only quotes when required', () {
    expect(escapeCsvCell('plain'), 'plain');
    expect(escapeCsvCell('has,comma'), '"has,comma"');
    expect(escapeCsvCell('has"quote'), '"has""quote"');
    expect(escapeCsvCell('has\nnewline'), '"has\nnewline"');
  });
}
