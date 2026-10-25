// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get todayTitle => 'Hari Ini';

  @override
  String tasksCount(int count) {
    return '$count tugas';
  }

  @override
  String get inboxTitle => 'Inbox';

  @override
  String get spacesTitle => 'Wadah';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get quickAddHint => 'Tambah tugas cepat...';

  @override
  String get emptyToday =>
      'Belum ada tugas hari ini. Nikmati waktumu, atau rencanakan besok?';

  @override
  String get undo => 'Urungkan';

  @override
  String get done => 'Selesai';

  @override
  String get snooze1h => 'Tunda 1 jam';

  @override
  String morningSummary(int classes, int tasks) {
    return 'Hari ini: $classes kelas, $tasks tugas.';
  }

  @override
  String get addSpace => 'Tambah Wadah';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get spaceName => 'Nama wadah';

  @override
  String get spaceCode => 'Kode (opsional)';

  @override
  String get taskTitle => 'Judul Tugas';

  @override
  String get taskNotes => 'Catatan';

  @override
  String get taskContainer => 'Wadah';

  @override
  String get taskDeadline => 'Deadline';

  @override
  String get taskPriority => 'Prioritas';

  @override
  String get priorityLow => 'Rendah';

  @override
  String get priorityMedium => 'Sedang';

  @override
  String get priorityHigh => 'Tinggi';

  @override
  String get pickDate => 'Pilih tanggal';

  @override
  String get addTask => 'Tambah Tugas';

  @override
  String get editTask => 'Edit Tugas';

  @override
  String get taskDetail => 'Detail Tugas';

  @override
  String get language => 'Bahasa';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get exportBackup => 'Ekspor Cadangan JSON';

  @override
  String get importBackup => 'Impor Cadangan JSON';

  @override
  String get checkReminder => 'Cek Pengingat';

  @override
  String get welcome => 'Selamat Datang';

  @override
  String get addFirstSpace => 'Tambah Matkul Pertama';

  @override
  String get start => 'Mulai';

  @override
  String get back => 'Kembali';

  @override
  String get saveContinue => 'Simpan & Lanjut';

  @override
  String get finish => 'Selesai';

  @override
  String get chooseLanguage => 'Pilih Bahasa';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get english => 'English';

  @override
  String get chooseLevel => 'Pilih Jenjang';

  @override
  String get college => 'Kuliah';

  @override
  String get school => 'SMA';

  @override
  String get spaceNameLabel => 'Nama Matkul';

  @override
  String inboxCount(int count) {
    return '$count catatan belum dirapikan.';
  }
}
