import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/parser/parser_service.dart';

/// Corpus for the Quick Add parser (design section 6.1 and 12.1).
///
/// The reference moment is Tuesday, 20 October 2026, 10:00 local time, so
/// every expectation below is stable.
void main() {
  final parser = ParserService.forSpaces(spaces);
  final now = DateTime(2026, 10, 20, 10, 0);

  ParsedTask parse(String input, {DateTime? at}) =>
      parser.parse(input, now: at ?? now);

  group('edge cases from the design table', () {
    test('jumat on a Friday means next Friday', () {
      final result = parse('kumpul rabu', at: DateTime(2026, 10, 23, 10, 0));
      expect(result.deadline, DateTime(2026, 10, 28, 23, 59));
    });

    test('jumat depan lands in the next calendar week', () {
      final result = parse('kumpul jumat depan');
      expect(result.deadline, DateTime(2026, 10, 30, 23, 59));
    });

    test('selasa depan from a Tuesday is one week ahead', () {
      final result = parse('rapat selasa depan');
      expect(result.deadline, DateTime(2026, 10, 27, 23, 59));
    });

    test('minggu depan without a day is seven days away', () {
      final result = parse('bayar spp minggu depan');
      expect(result.deadline, DateTime(2026, 10, 27, 23, 59));
    });

    test('minggu alone does not become Sunday', () {
      final result = parse('kerja minggu');
      expect(result.deadline, isNull);
      expect(result.needsConfirmation, isTrue);
    });

    test('hari minggu is Sunday', () {
      final result = parse('libur hari minggu');
      expect(result.deadline, DateTime(2026, 10, 25, 23, 59));
    });

    test('no clock time defaults to 23:59', () {
      final result = parse('kumpul berkas senin');
      expect(result.deadline, DateTime(2026, 10, 26, 23, 59));
    });

    test('jam 7 without a period picks the next future slot and asks', () {
      final result = parse('telepon dosen jam 7');
      expect(result.deadline, DateTime(2026, 10, 21, 7, 0));
      expect(result.needsConfirmation, isTrue);
    });

    test('sebelum jam 12 is noon of the mentioned day', () {
      final result = parse('kumpul rabu sebelum jam 12');
      expect(result.deadline, DateTime(2026, 10, 21, 12, 0));
    });

    test('jam 7 malam is 19:00', () {
      final result = parse('rapat kelompok besok jam 7 malam');
      expect(result.deadline, DateTime(2026, 10, 21, 19, 0));
      expect(result.isGroup, isTrue);
    });

    test('19.00 is accepted as written', () {
      final result = parse('kuis 19.00');
      expect(result.deadline, DateTime(2026, 10, 20, 19, 0));
    });

    test('pukul 23.59 is accepted as written', () {
      final result = parse('kumpul hari ini pukul 23.59');
      expect(result.deadline, DateTime(2026, 10, 20, 23, 59));
    });

    test('tgl rolls into the next month when it already passed', () {
      final future = parse('bayar listrik tgl 25');
      expect(future.deadline, DateTime(2026, 10, 25, 23, 59));
      final passed = parse('bayar listrik tgl 5');
      expect(passed.deadline, DateTime(2026, 11, 5, 23, 59));
      final soon = parse('bayar listrik tgl 28');
      expect(soon.deadline, DateTime(2026, 10, 28, 23, 59));
    });

    test('3 hari lagi is three days from now at 23:59', () {
      final result = parse('selesai bab 3 hari lagi');
      expect(result.deadline, DateTime(2026, 10, 23, 23, 59));
    });

    test('a clock time on its own asks for confirmation', () {
      final result = parse('kirim email jam 22.00');
      expect(result.deadline, DateTime(2026, 10, 20, 22, 0));
      expect(result.needsConfirmation, isTrue);
    });

    test('a past date is not silently dropped', () {
      final result = parse('rapat tgl 5');
      expect(result.deadline, DateTime(2026, 11, 5, 23, 59));
    });
  });

  group('worked examples from the design', () {
    test('laprak basdat jumat 23.59 individu', () {
      final result = parse('laprak basdat jumat 23.59 individu');
      expect(result.type, 'lab_report');
      expect(result.spaceId, 's1');
      expect(result.deadline, DateTime(2026, 10, 23, 23, 59));
      expect(result.isGroup, isFalse);
      expect(result.title, isNot(contains('basdat')));
    });

    test('kuis pemweb besok jam 8', () {
      final result = parse('kuis pemweb besok jam 8');
      expect(result.type, 'quiz');
      expect(result.spaceId, 's2');
      expect(result.deadline, DateTime(2026, 10, 21, 8, 0));
      expect(result.needsConfirmation, isTrue);
    });

    test('bayar listrik tgl 28', () {
      final result = parse('bayar listrik tgl 28');
      expect(result.spaceId, isNull);
      expect(result.type, isNull);
      expect(result.deadline, DateTime(2026, 10, 28, 23, 59));
      expect(result.title, 'bayar listrik');
    });
  });

  group('field extraction', () {
    test('type keywords', () {
      expect(parse('kuis statistika').type, 'quiz');
      expect(parse('laprak kalkulus').type, 'lab_report');
      expect(parse('makalah kalkulus').type, 'paper');
      expect(parse('presentasi basdat').type, 'presentation');
      expect(parse('uts kalkulus').type, 'midterm');
      expect(parse('uas kalkulus').type, 'final');
      expect(parse('laporan praktikum kalkulus').type, 'lab_report');
    });

    test('priority words', () {
      expect(parse('kumpul berkas penting').priority, 2);
      expect(parse('kumpul berkas urgent').priority, 2);
      expect(parse('kumpul berkas santai').priority, 0);
      expect(parse('kumpul berkas rendah').priority, 0);
      expect(parse('kumpul berkas biasa').priority, 1);
    });

    test('work mode words', () {
      expect(parse('tugas kelompok basdat').isGroup, isTrue);
      expect(parse('tugas group basdat').isGroup, isTrue);
      expect(parse('tugas individu basdat').isGroup, isFalse);
      expect(parse('tugas sendiri basdat').isGroup, isFalse);
      expect(parse('tugas kelompok basdat').title, isNot(contains('kelompok')));
    });

    test('space matching by name, code and alias', () {
      expect(parse('kumpul basis data').spaceId, 's1');
      expect(parse('kumpul BD').spaceId, 's1');
      expect(parse('kumpul dbms').spaceId, 's1');
      expect(parse('kumpul pemrograman web').spaceId, 's2');
      expect(parse('kumpul PW').spaceId, 's2');
      expect(parse('kumpul statistika').spaceId, 's3');
      expect(parse('kumpul bahasa inggris').spaceId, 's4');
      expect(parse('kumpul belanja sayur').spaceId, isNull);
    });

    test('short codes do not swallow other words', () {
      // "BD" must not match inside an unrelated word.
      expect(parse('beli kado ulang tahun').spaceId, isNull);
    });

    test('the raw text is kept as notes', () {
      const input = 'laprak basdat jumat 23.59 individu';
      expect(parse(input).notes, input);
    });

    test('an empty title falls back to the space name', () {
      final result = parse('basdat jumat');
      expect(result.title, 'Basis Data');
    });
  });

  group('corpus of classroom sentences', () {
    // Each entry carries the expectation that matters for that sentence.
    final cases = <(String, DateTime?, String?, String?, int, bool?)>[
      ('laporan basdat senin pagi jam 9', DateTime(2026, 10, 26, 9, 0), 's1', null, 1, null),
      ('kuis webdev besok jam 10', DateTime(2026, 10, 21, 10, 0), 's2', 'quiz', 1, null),
      ('kumpul makalah kalkulus 25 oktober', DateTime(2026, 10, 25, 23, 59), 's5', 'paper', 1, null),
      ('presentasi kelompok pemweb rabu 13.00', DateTime(2026, 10, 21, 13, 0), 's2', 'presentation', 1, true),
      ('uts statistika 12 november jam 8 pagi', DateTime(2026, 11, 12, 8, 0), 's3', 'midterm', 1, null),
      ('uas bahasa inggris 15 desember', DateTime(2026, 12, 15, 23, 59), 's4', 'final', 1, null),
      ('bayar spp tgl 28', DateTime(2026, 10, 28, 23, 59), null, null, 1, null),
      ('kirim tugas besar basdat lusa jam 23.59', DateTime(2026, 10, 22, 23, 59), 's1', null, 1, null),
      ('baca bab 4 kalkulus besok', DateTime(2026, 10, 21, 23, 59), 's5', null, 1, null),
      ('perbaikan uts statistika minggu depan', DateTime(2026, 10, 27, 23, 59), 's3', 'midterm', 1, null),
      ('daftar workshop dbms tanggal 3', DateTime(2026, 11, 3, 23, 59), 's1', null, 1, null),
      ('rapat kelompok pemweb kamis 16.00', DateTime(2026, 10, 22, 16, 0), 's2', null, 1, true),
      ('tugas individu statistika selasa depan', DateTime(2026, 10, 27, 23, 59), 's3', null, 1, false),
      ('submit paper english jumat depan jam 9 pagi', DateTime(2026, 10, 30, 9, 0), 's4', 'paper', 1, null),
      ('kumpul berkas penting basdat besok jam 7 malam', DateTime(2026, 10, 21, 19, 0), 's1', null, 2, null),
      ('draft kasihan rendah basdat', null, 's1', null, 0, null),
      ('kuis tengah semester kalkulus senin jam 7.30', DateTime(2026, 10, 26, 7, 30), 's5', 'quiz', 1, null),
      ('praktikum basis data sabtu jam 10 pagi', DateTime(2026, 10, 24, 10, 0), 's1', 'lab_report', 1, null),
      ('revisi makalah pemweb minggu depan', DateTime(2026, 10, 27, 23, 59), 's2', 'paper', 1, null),
      ('scan kartu basdat hari ini', DateTime(2026, 10, 20, 23, 59), 's1', null, 1, null),
      ('beli pulsa besok jam 8 pagi', DateTime(2026, 10, 21, 8, 0), null, null, 1, null),
      ('jawab kuis kalkulus 2 hari lagi', DateTime(2026, 10, 22, 23, 59), 's5', 'quiz', 1, null),
      ('presentasi statistika 5 menit lagi', DateTime(2026, 10, 20, 10, 5), 's3', 'presentation', 1, null),
      ('tugas basdat 6 jam lagi', DateTime(2026, 10, 20, 16, 0), 's1', null, 1, null),
      ('kode praktikum basdat jumat 14.00', DateTime(2026, 10, 23, 14, 0), 's1', 'lab_report', 1, null),
      ('bahasa inggris speaking test 30 november', DateTime(2026, 11, 30, 23, 59), 's4', null, 1, null),
      ('kumpul laporan PW sebelum jam 12', DateTime(2026, 10, 20, 12, 0), 's2', null, 1, null),
      ('agenda ujian kalkulus 20 januari', DateTime( 2027, 1, 20, 23, 59), 's5', null, 1, null),
      ('kuis basdat besok', DateTime(2026, 10, 21, 23, 59), 's1', 'quiz', 1, null),
      ('piket kelas senin 7.00', DateTime(2026, 10, 26, 7, 0), null, null, 1, null),
      ('bayar listrik 3 hari lagi', DateTime(2026, 10, 23, 23, 59), null, null, 1, null),
      ('kumpul data statistika tgl 12', DateTime(2026, 11, 12, 23, 59), 's3', null, 1, null),
      ('laporan kelompok webdev selasa 15.30', DateTime(2026, 10, 27, 15, 30), 's2', null, 1, true),
      ('uts kalkulus minggu depan jam 8 pagi', DateTime(2026, 10, 27, 8, 0), 's5', 'midterm', 1, null),
      ('absen basdat hari ini jam 19.00', DateTime(2026, 10, 20, 19, 0), 's1', null, 1, null),
      ('tugas mandiri statistika kamis', DateTime(2026, 10, 22, 23, 59), 's3', null, 1, false),
      ('kirim tugas pemweb 4 hari lagi', DateTime(2026, 10, 24, 23, 59), 's2', null, 1, null),
      ('libur nasional tgl 17', DateTime(2026, 11, 17, 23, 59), null, null, 1, null),
      ('belajar uts kalkulus sabtu depan', DateTime(2026, 10, 31, 23, 59), 's5', 'midterm', 1, null),
      ('formulir pendaftaran basdat 29 oktober', DateTime(2026, 10, 29, 23, 59), 's1', null, 1, null),
      ('presentasi kelompok statistika 3 november', DateTime(2026, 11, 3, 23, 59), 's3', 'presentation', 1, true),
      ('review makalah bahasa inggris jumat', DateTime(2026, 10, 23, 23, 59), 's4', 'paper', 1, null),
      ('posisi meja kalkulus besok jam 13.00', DateTime(2026, 10, 21, 13, 0), 's5', null, 1, null),
      ('kuis pemweb 1 hari lagi', DateTime(2026, 10, 21, 23, 59), 's2', 'quiz', 1, null),
      ('catatan basdat rabu depan jam 10', DateTime(2026, 10, 28, 10, 0), 's1', null, 1, null),
      ('antar proposal kalkulus lusa', DateTime(2026, 10, 22, 23, 59), 's5', null, 1, null),
      ('jadwal praktikum dbms senin 7 pagi', DateTime(2026, 10, 26, 7, 0), 's1', 'lab_report', 1, null),
      ('kumpul tugas penting pemweb 30 oktober', DateTime(2026, 10, 30, 23, 59), 's2', null, 2, null),
      ('rencana belajar uas kalkulus desember', DateTime(2026, 12, 31, 23, 59), 's5', 'final', 1, null),
      ('kirim slide presentasi basdat kamis 16.00', DateTime(2026, 10, 22, 16, 0), 's1', 'presentation', 1, null),
      ('izin tidak hadir statistika besok', DateTime(2026, 10, 21, 23, 59), 's3', null, 1, null),
      ('evaluasi webdev minggu depan', DateTime(2026, 10, 27, 23, 59), 's2', null, 1, null),
      ('input nilai kalkulus 12 desember', DateTime(2026, 12, 12, 23, 59), 's5', null, 1, null),
      ('peminjaman buku basdat 9 november', DateTime(2026, 11, 9, 23, 59), 's1', null, 1, null),
      ('sesi tanya jawab bahasa inggris selasa 11.00', DateTime(2026, 10, 27, 11, 0), 's4', null, 1, null),
      ('kuis kalkulus besok jam 7.30', DateTime(2026, 10, 21, 7, 30), 's5', 'quiz', 1, null),
      ('setor laporan basdat sebelum jam 12', DateTime(2026, 10, 20, 12, 0), 's1', null, 1, null),
      ('ubah judul makalah pemweb tgl 26', DateTime(2026, 10, 26, 23, 59), 's2', 'paper', 1, null),
      ('ambil sertifikat statistika 8 november', DateTime(2026, 11, 8, 23, 59), 's3', null, 1, null),
      ('try out uts kalkulus 1 november', DateTime(2026, 11, 1, 23, 59), 's5', 'midterm', 1, null),
      ('kirim tugas besar webdev 18 november', DateTime(2026, 11, 18, 23, 59), 's2', null, 1, null),
      ('rapat anggota kelompok dbms besok 20.00', DateTime(2026, 10, 21, 20, 0), 's1', null, 1, true),
      ('unduh soal uas bahasa inggris 3 januari', DateTime( 2027, 1, 3, 23, 59), 's4', 'final', 1, null),
      ('validasi data statistika jumat 15.00', DateTime(2026, 10, 23, 15, 0), 's3', null, 1, null),
      ('praktikum pemweb sabtu 9 pagi', DateTime(2026, 10, 24, 9, 0), 's2', 'lab_report', 1, null),
      ('kumpul kartu basdat 22 oktober', DateTime(2026, 10, 22, 23, 59), 's1', null, 1, null),
      ('belajar kalkulus 8 jam lagi', DateTime(2026, 10, 20, 18, 0), 's5', null, 1, null),
      ('kuis basdat 10 menit lagi', DateTime(2026, 10, 20, 10, 10), 's1', 'quiz', 1, null),
      ('laporan akhir statistika 25 desember', DateTime(2026, 12, 25, 23, 59), 's3', null, 1, null),
      ('agenda kelas bahasa inggris kamis 10.00', DateTime(2026, 10, 22, 10, 0), 's4', null, 1, null),
      ('book keperluan webdev tgl 7', DateTime(2026, 11, 7, 23, 59), 's2', null, 1, null),
      ('olah data kalkulus 2 hari lagi jam 22.00', DateTime(2026, 10, 22, 22, 0), 's5', null, 1, null),
      ('kumpul revisi basdat minggu depan jam 14.00', DateTime(2026, 10, 27, 14, 0), 's1', null, 1, null),
      ('izin sakit statistika hari ini', DateTime(2026, 10, 20, 23, 59), 's3', null, 1, null),
      ('kuis pemweb senin 7 pagi', DateTime(2026, 10, 26, 7, 0), 's2', 'quiz', 1, null),
      ('setor usb basdat 3 hari lagi', DateTime(2026, 10, 23, 23, 59), 's1', null, 1, null),
      ('simulasi uts webdev 5 november', DateTime(2026, 11, 5, 23, 59), 's2', 'midterm', 1, null),
      ('berita acara praktikum basdat jumat', DateTime(2026, 10, 23, 23, 59), 's1', 'lab_report', 1, null),
      ('kirim kliping bahasa inggris 14 november', DateTime(2026, 11, 14, 23, 59), 's4', null, 1, null),
      ('responsi kalkulus rabu 13.00', DateTime(2026, 10, 21, 13, 0), 's5', null, 1, null),
      ('tugas mandiri webdev besok', DateTime(2026, 10, 21, 23, 59), 's2', null, 1, false),
      ('libur hari minggu', DateTime(2026, 10, 25, 23, 59), null, null, 1, null),
      ('kumpul proposal kelompok kalkulus lusa 16.00', DateTime(2026, 10, 22, 16, 0), 's5', null, 1, true),
      ('daftar ulang tgl 30', DateTime(2026, 10, 30, 23, 59), null, null, 1, null),
      ('piket basdat rabu 6.45', DateTime(2026, 10, 21, 6, 45), 's1', null, 1, null),
      ('presentasi statistika besok jam 7 malam', DateTime(2026, 10, 21, 19, 0), 's3', 'presentation', 1, null),
      ('kumpul tugas akhir webdev 21 november', DateTime(2026, 11, 21, 23, 59), 's2', null, 1, null),
      ('cek email kalkulus 1 jam lagi', DateTime(2026, 10, 20, 11, 0), 's5', null, 1, null),
      ('kuis basis data besok jam 13.00', DateTime(2026, 10, 21, 13, 0), 's1', 'quiz', 1, null),
      ('makalah kalkulus 3 hari lagi', DateTime(2026, 10, 23, 23, 59), 's5', 'paper', 1, null),
      ('absensi webdev senin 7 pagi', DateTime(2026, 10, 26, 7, 0), 's2', null, 1, null),
      ('tugas kelompok statistika lusa 16.00', DateTime(2026, 10, 22, 16, 0), 's3', null, 1, true),
      ('presentasi pemweb 10 november', DateTime(2026, 11, 10, 23, 59), 's2', 'presentation', 1, null),
      ('kumpul basdat tgl 21', DateTime(2026, 10, 21, 23, 59), 's1', null, 1, null),
      ('ujian tengah bahasa inggris 9 november jam 8', DateTime(2026, 11, 9, 8, 0), 's4', null, 1, null),
      ('rapat webdev kamis 18.00', DateTime(2026, 10, 22, 18, 0), 's2', null, 1, null),
      ('kirim data kalkulus 5 jam lagi', DateTime(2026, 10, 20, 15, 0), 's5', null, 1, null),
      ('berkas penting pemweb besok', DateTime(2026, 10, 21, 23, 59), 's2', null, 2, null),
      ('jadwal praktikum statistika sabtu 10.00', DateTime(2026, 10, 24, 10, 0), 's3', 'lab_report', 1, null),
      ('tugas rendah basdat', null, 's1', null, 0, null),
      ('kuis bahasa inggris minggu depan', DateTime(2026, 10, 27, 23, 59), 's4', 'quiz', 1, null),
      ('setor lab pemweb 2 hari lagi', DateTime(2026, 10, 22, 23, 59), 's2', null, 1, null),
      ('input nilai basdat 16 november', DateTime(2026, 11, 16, 23, 59), 's1', null, 1, null),
      ('observasi kalkulus rabu 9 pagi', DateTime(2026, 10, 21, 9, 0), 's5', null, 1, null),
      ('kirim slide pemweb 2 hari lagi jam 20.00', DateTime(2026, 10, 22, 20, 0), 's2', null, 1, null),
      ('absen besok jam 12', DateTime(2026, 10, 21, 12, 0), null, null, 1, null),
      ('kumpul berkas dbms 4 hari lagi', DateTime(2026, 10, 24, 23, 59), 's1', null, 1, null),
      ('kursus bahasa inggris 28 november', DateTime(2026, 11, 28, 23, 59), 's4', null, 1, null),
      ('remedial kalkulus senin depan', DateTime(2026, 10, 26, 23, 59), 's5', null, 1, null),
    ];

    for (final entry in cases) {
      final (input, deadline, spaceId, type, priority, isGroup) = entry;
      test('"$input"', () {
        final result = parse(input);
        if (deadline != null) {
          expect(result.deadline, deadline, reason: 'deadline for "$input"');
        } else {
          expect(result.deadline, isNull, reason: 'deadline for "$input"');
        }
        if (spaceId != null) {
          expect(result.spaceId, spaceId, reason: 'space for "$input"');
        }
        if (type != null) {
          expect(result.type, type, reason: 'type for "$input"');
        }
        expect(result.priority, priority, reason: 'priority for "$input"');
        if (isGroup != null) {
          expect(result.isGroup, isGroup, reason: 'mode for "$input"');
        }
        expect(result.title, isNotEmpty, reason: 'title for "$input"');
        expect(result.notes, input.trim());
      });
    }

    test('the corpus covers more than one hundred sentences', () {
      expect(cases.length, greaterThanOrEqualTo(100));
    });
  });
}

const spaces = <Map<String, String>>[
  {
    'id': 's1',
    'name': 'Basis Data',
    'code': 'BD',
    'aliases': 'basdat,dbms,database',
  },
  {
    'id': 's2',
    'name': 'Pemrograman Web',
    'code': 'PW',
    'aliases': 'pemweb,webdev',
  },
  {
    'id': 's3',
    'name': 'Statistika',
    'code': 'STA',
    'aliases': 'stat,statistik',
  },
  {
    'id': 's4',
    'name': 'Bahasa Inggris',
    'code': 'BIG',
    'aliases': 'inggris,english',
  },
  {'id': 's5', 'name': 'Kalkulus', 'code': 'KAL', 'aliases': 'kalkul,calc'},
];
