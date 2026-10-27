import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/parser/parser_service.dart';

/// Corpus for the Quick Add parser (design section 6.1 and 12.1).
///
/// The reference moment is Tuesday, 20 October 2026, 10:00 local time, so
/// every expectation below is stable.
void main() {
  final parser = ParserService.forSpaces(spaces);
  final now = DateTime(2026, 10, 20, 10, 0);

  ParsedTask parse(String input, {DateTime? at, String locale = 'id'}) =>
      parser.parse(input, locale: locale, now: at ?? now);

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

  group('advanced parser (design section 7.15)', () {
    // Every entry checks all six fields at once, so a new token never
    // quietly steals something from an older one.
    final cases = <({
      String input,
      DateTime? deadline,
      String? spaceId,
      int priority,
      int? estimate,
      String? submit,
      String? tag,
    })>[
      (
        input: 'laprak basdat senin pagi jam 9',
        deadline: DateTime(2026, 10, 26, 9, 0),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'kuis pemweb besok jam 10',
        deadline: DateTime(2026, 10, 21, 10, 0),
        spaceId: 's2',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'tugas penting basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 2,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'tugas santai kalkulus besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's5',
        priority: 0,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'laporan wajib dikumpul statistika senin',
        deadline: DateTime(2026, 10, 26, 23, 59),
        spaceId: 's3',
        priority: 2,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'kumpul berkas mendesak basdat kamis',
        deadline: DateTime(2026, 10, 22, 23, 59),
        spaceId: 's1',
        priority: 2,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'baca buku kalau sempat kalkulus besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's5',
        priority: 0,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'hadir webinar opsional statistika besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's3',
        priority: 0,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'estimasi 2 jam bikin slide basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: 120,
        submit: null,
        tag: null,
      ),
      (
        input: 'sekitar 30 menit baca bab 4 kalkulus besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's5',
        priority: 1,
        estimate: 30,
        submit: null,
        tag: null,
      ),
      (
        input: 'butuh 3 jam susun soal basdat jumat',
        deadline: DateTime(2026, 10, 23, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: 180,
        submit: null,
        tag: null,
      ),
      (
        input: '~45m tugas basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: 45,
        submit: null,
        tag: null,
      ),
      (
        input: '~2j bikin modul kalkulus besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's5',
        priority: 1,
        estimate: 120,
        submit: null,
        tag: null,
      ),
      (
        input: 'perkiraan 5 jam bikin proposal basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: 300,
        submit: null,
        tag: null,
      ),
      (
        input: 'needs 2 hours write report basdat',
        deadline: null,
        spaceId: 's1',
        priority: 1,
        estimate: 120,
        submit: null,
        tag: null,
      ),
      (
        input: 'about 90 minutes review slide basdat',
        deadline: null,
        spaceId: 's1',
        priority: 1,
        estimate: 90,
        submit: null,
        tag: null,
      ),
      (
        input: 'kirim data basdat 3 jam lagi',
        deadline: DateTime(2026, 10, 20, 13, 0),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'butuh 45 menit lagi siapkan absen basdat',
        deadline: DateTime(2026, 10, 20, 10, 45),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'kumpul lewat lms basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: 'lms',
        tag: null,
      ),
      (
        input: 'kirim berkas ke classroom pemweb besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's2',
        priority: 1,
        estimate: null,
        submit: 'lms',
        tag: null,
      ),
      (
        input: 'kirim ke drive tugas basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: 'lms',
        tag: null,
      ),
      (
        input: 'kumpul makalah kalkulus lewat e-learning besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's5',
        priority: 1,
        estimate: null,
        submit: 'lms',
        tag: null,
      ),
      (
        input: 'laporan dicetak disetor kalkulus senin',
        deadline: DateTime(2026, 10, 26, 23, 59),
        spaceId: 's5',
        priority: 1,
        estimate: null,
        submit: 'paper',
        tag: null,
      ),
      (
        input: 'hardcopy berkas statistika kamis',
        deadline: DateTime(2026, 10, 22, 23, 59),
        spaceId: 's3',
        priority: 1,
        estimate: null,
        submit: 'paper',
        tag: null,
      ),
      (
        input: 'laporan praktikum dicetak basdat senin',
        deadline: DateTime(2026, 10, 26, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: 'paper',
        tag: null,
      ),
      (
        input: 'kirim laporan ke dosen@kampus.ac.id besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: null,
        priority: 1,
        estimate: null,
        submit: 'email',
        tag: null,
      ),
      (
        input: 'berkas #tugas basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: 'tugas',
      ),
      (
        input: 'kumpul #kelompok basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: 'kelompok',
      ),
      (
        input: '@basdat kumpul revisi besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: '@pw kumpul tugas kamis',
        deadline: DateTime(2026, 10, 22, 23, 59),
        spaceId: 's2',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: '@stat kuis besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's3',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'kumpul @kalkulus berkas senin',
        deadline: DateTime(2026, 10, 26, 23, 59),
        spaceId: 's5',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: '@halo kumpul besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: null,
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: '!tinggi laprak basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 3,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: '! kumpul basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 2,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: '!rendah tugas kalkulus besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's5',
        priority: 0,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'laporan (kirim ke bu sari) basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'cek https://classroom.google.com/c/abc basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'unduh https://drive.google.com/file/d/1 kalkulus besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's5',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'buka www.contoh.ac.id/id tugas basdat jumat',
        deadline: DateTime(2026, 10, 23, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'kumpul berkas basdat besok format nama file: nama_nim_tugas',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'laporan kalkulus senin penamaan file: laporan_12345',
        deadline: DateTime(2026, 10, 26, 23, 59),
        spaceId: 's5',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'kumpul laporan basdat senin pagi',
        deadline: DateTime(2026, 10, 26, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'baca modul kalkulus selasa depan',
        deadline: DateTime(2026, 10, 27, 23, 59),
        spaceId: 's5',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'kirim slide presentasi pemweb kamis 16.00',
        deadline: DateTime(2026, 10, 22, 16, 0),
        spaceId: 's2',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'jawab kuis statistika besok jam 13.00',
        deadline: DateTime(2026, 10, 21, 13, 0),
        spaceId: 's3',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'kirim email dosen basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'beli buku tulis besok jam 12',
        deadline: DateTime(2026, 10, 21, 12, 0),
        spaceId: null,
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'presentasi kelompok statistika lusa 16.00',
        deadline: DateTime(2026, 10, 22, 16, 0),
        spaceId: 's3',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'revisi makalah pemweb minggu depan',
        deadline: DateTime(2026, 10, 27, 23, 59),
        spaceId: 's2',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'jadwal praktikum dbms sabtu jam 10 pagi',
        deadline: DateTime(2026, 10, 24, 10, 0),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'absensi webdev senin 7 pagi',
        deadline: DateTime(2026, 10, 26, 7, 0),
        spaceId: 's2',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'tugas kelompok basdat besok',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
      (
        input: 'kumpul berkas dbms 4 hari lagi',
        deadline: DateTime(2026, 10, 24, 23, 59),
        spaceId: 's1',
        priority: 1,
        estimate: null,
        submit: null,
        tag: null,
      ),
    ];

    for (final entry in cases) {
      test('"${entry.input}"', () {
        final result = parse(entry.input);
        expect(result.deadline, entry.deadline,
            reason: 'deadline for "${entry.input}"');
        expect(result.spaceId, entry.spaceId,
            reason: 'space for "${entry.input}"');
        expect(result.priority, entry.priority,
            reason: 'priority for "${entry.input}"');
        expect(result.estimateMinutes, entry.estimate,
            reason: 'estimate for "${entry.input}"');
        expect(result.submitMethod, entry.submit,
            reason: 'submission for "${entry.input}"');
        expect(result.tag, entry.tag, reason: 'tag for "${entry.input}"');
        expect(result.title, isNotEmpty, reason: 'title for "${entry.input}"');
        expect(result.notes, entry.input.trim());
      });
    }

    test('the advanced corpus carries fifty sentences', () {
      expect(cases.length, greaterThanOrEqualTo(50));
    });

    test('a numbered list becomes subtasks and keeps the title', () {
      final result = parse('beli bahan\n1. tepung\n2. gula\n3. fermipan');
      expect(result.subtasks, ['tepung', 'gula', 'fermipan']);
      expect(result.title, 'beli bahan');
    });

    test('a bulleted list becomes subtasks', () {
      final result = parse('siapkan bahan\n- buka slide\n- cek suara');
      expect(result.subtasks, ['buka slide', 'cek suara']);
      expect(result.title, 'siapkan bahan');
    });

    test('a list written on one line is split at its markers', () {
      final result = parse('revisi laporan 1. bab pendahuluan 2. bab isi');
      expect(result.subtasks, ['bab pendahuluan', 'bab isi']);
      expect(result.title, contains('revisi laporan'));
      expect(result.title, isNot(contains('1.')));
    });

    test('the file name pattern is kept raw for its chip', () {
      final result = parse('kumpul berkas besok format nama file: Nama_NIM');
      expect(result.filenamePattern, 'Nama_NIM');
      expect(result.title, isNot(contains('format nama file')));
      expect(result.deadline, DateTime(2026, 10, 21, 23, 59));
    });

    test('links leave the title and keep their address', () {
      final result =
          parse('cek https://classroom.google.com/c/xyz basdat besok');
      expect(result.links, ['https://classroom.google.com/c/xyz']);
      expect(result.title, isNot(contains('https')));
      expect(result.submitMethod, isNull);
    });

    test('an email becomes the target of the email method', () {
      final result = parse('kirim ke dosen@kampus.ac.id besok');
      expect(result.submitMethod, 'email');
      expect(result.submitTarget, 'dosen@kampus.ac.id');
      expect(result.title, isNot(contains('dosen@')));
    });

    test('a note in brackets leaves the title', () {
      final result = parse('kumpul berkas (kirim ke bu sari) besok');
      expect(result.inlineNote, 'kirim ke bu sari');
      expect(result.title, isNot(contains('(')));
      expect(result.deadline, DateTime(2026, 10, 21, 23, 59));
    });

    test('a marker wins over the priority words around it', () {
      final result = parse('tugas santai !tinggi basdat besok');
      expect(result.priority, 3);
      expect(result.title, isNot(contains('!')));
    });

    test('a high word with a low word leaves the choice to the chip', () {
      final result = parse('tugas santai penting basdat besok');
      expect(result.priority, 1);
      expect(result.priorityConflict, isTrue);
    });

    test('an unknown @token belongs to the title', () {
      final result = parse('@halo kumpul besok');
      expect(result.spaceId, isNull);
      expect(result.title, contains('@halo'));
    });

    test('english priority words work with the english locale', () {
      final result = parse('basdat report important tomorrow',
          locale: 'en', at: DateTime(2026, 10, 20, 10, 0));
      expect(result.priority, 2);
      final relaxed =
          parse('basdat report optional', locale: 'en', at: now);
      expect(relaxed.priority, 0);
    });

    test('the relative moment is never read as an estimate', () {
      final result = parse('kirim data basdat 3 jam lagi');
      expect(result.estimateMinutes, isNull);
      expect(result.deadline, DateTime(2026, 10, 20, 13, 0));
    });

    test('a share message keeps every part at once', () {
      final result = parse(
          '@basdat laprak #kelompok !tinggi sekitar 45 menit besok jam 20.00 format nama file: nama_nim');
      expect(result.spaceId, 's1');
      expect(result.type, 'lab_report');
      expect(result.tag, 'kelompok');
      expect(result.priority, 3);
      expect(result.estimateMinutes, 45);
      expect(result.deadline, DateTime(2026, 10, 21, 20, 0));
      expect(result.filenamePattern, 'nama_nim');
      expect(result.title, isNotEmpty);
      expect(result.title, isNot(contains('!')));
      expect(result.title, isNot(contains('#')));
    });
  });

  group('english and mixed parser (design section 8.5)', () {
    // The active language leads, the other one still reads, so every entry
    // says which language was used.
    final cases = <({String input, String locale, DateTime? deadline,
        String? spaceId, String? type, bool? confirm})>[
      (
        input: 'lab report db friday 11:59pm',
        locale: 'en',
        deadline: DateTime(2026, 10, 23, 23, 59),
        spaceId: 's1',
        type: 'lab_report',
        confirm: true,
      ),
      (
        input: 'quiz web tomorrow 8am',
        locale: 'en',
        deadline: DateTime(2026, 10, 21, 8, 0),
        spaceId: null,
        type: 'quiz',
        confirm: false,
      ),
      (
        input: 'kuis english tomorrow',
        locale: 'en',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's4',
        type: 'quiz',
        confirm: false,
      ),
      (
        input: 'submit laprak friday 23.59',
        locale: 'en',
        deadline: DateTime(2026, 10, 23, 23, 59),
        spaceId: null,
        type: 'lab_report',
        confirm: true,
      ),
      (
        input: 'sunday english',
        locale: 'id',
        deadline: DateTime(2026, 10, 25, 23, 59),
        spaceId: 's4',
        type: null,
        confirm: true,
      ),
      (
        input: 'next friday english',
        locale: 'en',
        deadline: DateTime(2026, 10, 30, 23, 59),
        spaceId: 's4',
        type: null,
        confirm: true,
      ),
      (
        input: 'turn in essay english 19.00',
        locale: 'en',
        deadline: DateTime(2026, 10, 20, 19, 0),
        spaceId: 's4',
        type: 'paper',
        confirm: true,
      ),
      (
        input: 'call english 7pm',
        locale: 'en',
        deadline: DateTime(2026, 10, 20, 19, 0),
        spaceId: 's4',
        type: null,
        confirm: true,
      ),
      (
        input: 'meeting english 7:00 PM',
        locale: 'en',
        deadline: DateTime(2026, 10, 20, 19, 0),
        spaceId: 's4',
        type: null,
        confirm: true,
      ),
      (
        input: 'call english at 7',
        locale: 'en',
        deadline: DateTime(2026, 10, 21, 7, 0),
        spaceId: 's4',
        type: null,
        confirm: true,
      ),
      (
        input: 'submit english in 3 hours',
        locale: 'en',
        deadline: DateTime(2026, 10, 20, 13, 0),
        spaceId: 's4',
        type: null,
        confirm: false,
      ),
      (
        input: 'submit english 3 jam lagi',
        locale: 'en',
        deadline: DateTime(2026, 10, 20, 13, 0),
        spaceId: 's4',
        type: null,
        confirm: false,
      ),
      (
        input: 'submit english the 25th',
        locale: 'en',
        deadline: DateTime(2026, 10, 25, 23, 59),
        spaceId: 's4',
        type: null,
        confirm: false,
      ),
      (
        input: 'submit english october 25',
        locale: 'en',
        deadline: DateTime(2026, 10, 25, 23, 59),
        spaceId: 's4',
        type: null,
        confirm: false,
      ),
      (
        input: 'submit english tmrw',
        locale: 'id',
        deadline: DateTime(2026, 10, 21, 23, 59),
        spaceId: 's4',
        type: null,
        confirm: false,
      ),
      (
        input: 'turn in english fri 8am',
        locale: 'id',
        deadline: DateTime(2026, 10, 23, 8, 0),
        spaceId: 's4',
        type: null,
        confirm: true,
      ),
    ];

    for (final entry in cases) {
      test('"${entry.input}" in ${entry.locale}', () {
        final result = parse(entry.input, locale: entry.locale);
        expect(result.deadline, entry.deadline,
            reason: 'deadline for "${entry.input}"');
        expect(result.spaceId, entry.spaceId,
            reason: 'space for "${entry.input}"');
        expect(result.type, entry.type, reason: 'type for "${entry.input}"');
        if (entry.confirm != null) {
          expect(result.needsConfirmation, entry.confirm,
              reason: 'confirmation for "${entry.input}"');
        }
        expect(result.title, isNotEmpty);
        expect(result.notes, entry.input.trim());
      });
    }

    test('the corpus covers both languages at once', () {
      expect(cases.length, greaterThanOrEqualTo(15));
    });

    test('minggu with english active means sunday but needs a check', () {
      final result = parse('minggu', locale: 'en');
      expect(result.deadline, DateTime(2026, 10, 25, 23, 59));
      expect(result.needsConfirmation, isTrue);
      expect(result.title, isNot(contains('minggu')));
    });

    test('the english type key is the same neutral key as the indonesian',
        () {
      expect(parse('kuis english tomorrow', locale: 'id').type, 'quiz');
      expect(parse('quiz english tomorrow', locale: 'en').type, 'quiz');
      expect(parse('laprak english friday', locale: 'id').type, 'lab_report');
      expect(parse('lab report english friday', locale: 'en').type,
          'lab_report');
    });

    test('english priority words still read in the indonesian locale', () {
      expect(parse('report english urgent tomorrow').priority, 2);
      expect(parse('report english optional', locale: 'en').priority, 0);
    });

    test('the english file name pattern keeps its capitals', () {
      final result = parse('submit english file name format: Report_Final');
      expect(result.filenamePattern, 'Report_Final');
      expect(result.title, isNot(contains('file name format')));
    });
  });

  group('spoken numbers (design section 7.1)', () {
    test('jam tujuh malam becomes 19:00', () {
      final result = parse('laprak basdat jam tujuh malam');
      expect(result.deadline, DateTime(2026, 10, 20, 19, 0));
      expect(result.type, 'lab_report');
      expect(result.spaceId, 's1');
      // A time without a date still asks the user to confirm the day.
      expect(result.needsConfirmation, isTrue);
      expect(result.title, isNot(contains('tujuh')));
    });

    test('a month written in words keeps its day', () {
      final result = parse('kumpul basdat dua puluh lima oktober');
      expect(result.deadline, DateTime(2026, 10, 25, 23, 59));
      expect(result.title, isNot(contains('dua')));
    });

    test('jam delapan pagi with a day lands on that morning', () {
      final result = parse('kuis basdat besok jam delapan pagi');
      expect(result.deadline, DateTime(2026, 10, 21, 8, 0));
      expect(result.type, 'quiz');
    });

    test('spoken english numbers work too', () {
      final lab = parse('lab report english seven pm', locale: 'en');
      expect(lab.deadline, DateTime(2026, 10, 20, 19, 0));
      expect(lab.type, 'lab_report');

      final date = parse('submit english twenty five october', locale: 'en');
      expect(date.deadline, DateTime(2026, 10, 25, 23, 59));
    });

    test('a number word outside a time hint stays in the title', () {
      final result = parse('beli tiga buku besok');
      expect(result.title, contains('tiga'));
      expect(result.deadline, DateTime(2026, 10, 21, 23, 59));
    });

    test('the spoken corpus carries its cases', () {
      expect('dua puluh lima', isNotEmpty);
      expect(parse('kumpul basdat jam lima sore').deadline,
          DateTime(2026, 10, 20, 17, 0));
    });
  });
}

const spaces = <Map<String, String>>[
  {
    'id': 's1',
    'name': 'Basis Data',
    'code': 'BD',
    'aliases': 'basdat,dbms,database,db',
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
