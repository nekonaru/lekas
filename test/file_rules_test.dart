import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/core/file_rules.dart';
import 'package:lekas/core/files_channel.dart';

void main() {
  group('sanitizeFileSegment', () {
    test('trims and collapses whitespace', () {
      expect(sanitizeFileSegment('  Materi   Kuliah  '), 'Materi Kuliah');
    });

    test('flattens reserved characters', () {
      expect(sanitizeFileSegment('a/b\\c:d*e?f"g<h>i|j'), 'a-b-c-d-e-f-g-h-i-j');
    });

    test('strips trailing dots and spaces', () {
      expect(sanitizeFileSegment('modul. '), 'modul');
      expect(sanitizeFileSegment('modul...'), 'modul');
    });

    test('caps long names at 80 chars', () {
      expect(sanitizeFileSegment('x' * 200).length, 80);
    });

    test('returns untitled for empty input', () {
      expect(sanitizeFileSegment('   '), 'untitled');
      expect(sanitizeFileSegment(''), 'untitled');
    });
  });

  group('sanitizeFileName', () {
    test('keeps the extension after cleaning the base', () {
      expect(sanitizeFileName('Modul/Bab.1.pdf'), 'Modul-Bab.1.pdf');
      expect(sanitizeFileName('catatan.docx'), 'catatan.docx');
    });

    test('extension-less names sanitize like a segment', () {
      expect(sanitizeFileName('README'), 'README');
    });
  });

  group('formatFileSize', () {
    test('boundaries are exact', () {
      expect(formatFileSize(512), '512 B');
      expect(formatFileSize(1024), '1 KB');
      expect(formatFileSize(1536), '2 KB');
      expect(formatFileSize(1048576), '1.0 MB');
      expect(formatFileSize(5 * 1048576), '5.0 MB');
      expect(formatFileSize(1073741824), '1.00 GB');
    });
  });

  group('parseFolderEntries', () {
    test('folders come first and sort alphabetically', () {
      final entries = parseFolderEntries([
        {'name': 'zebra.pdf', 'isDirectory': false, 'size': 10, 'mime': 'application/pdf', 'modified': 1},
        {'name': 'beta', 'isDirectory': true, 'size': 0, 'mime': '', 'modified': 1},
        {'name': 'alpha', 'isDirectory': true, 'size': 0, 'mime': '', 'modified': 1},
        {'name': 'apple.png', 'isDirectory': false, 'size': 5, 'mime': 'image/png', 'modified': 1},
      ]);
      expect(entries.map((e) => e.name), ['alpha', 'beta', 'apple.png', 'zebra.pdf']);
    });

    test('garbage rows are tolerated', () {
      expect(parseFolderEntries([null, 42, 'x']), isEmpty);
      expect(parseFolderEntries(const []), isEmpty);
    });
  });

  group('fileIconKind', () {
    test('pdf wins over generic', () {
      expect(fileIconKind('Modul.pdf'), FileIconKind.pdf);
      expect(fileIconKind('PDF.anomali.pdf'), FileIconKind.pdf);
    });
    test('images classify as images', () {
      expect(fileIconKind('photo.JPG'), FileIconKind.image);
      expect(fileIconKind('scan.webp'), FileIconKind.image);
    });
    test('archives classify as archives', () {
      expect(fileIconKind('tugas.zip'), FileIconKind.archive);
      expect(fileIconKind('materi.7z'), FileIconKind.archive);
    });
    test('unknown extensions stay generic', () {
      expect(fileIconKind('firmware.bin'), FileIconKind.generic);
      expect(fileIconKind('noextension'), FileIconKind.generic);
    });
  });
}
