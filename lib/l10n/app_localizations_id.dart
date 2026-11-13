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
  String get spacesTitle => 'Kategori';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get quickAddHint => 'Tambah tugas cepat...';

  @override
  String get pasteAction => 'Tempel';

  @override
  String get clipboardEmpty => 'Papan klip kosong. Salin teks dulu.';

  @override
  String get repeatLastTask => 'Ulangi tugas terakhir';

  @override
  String historySuggestion(String title) {
    return 'Mirip: $title';
  }

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
  String get addSpace => 'Tambah Kategori';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get spaceName => 'Nama kategori';

  @override
  String get spaceCode => 'Kode (opsional)';

  @override
  String get taskTitle => 'Judul Tugas';

  @override
  String get taskNotes => 'Catatan';

  @override
  String get taskContainer => 'Kategori';

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
  String get addFirstSpace => 'Tambah Kategori Pertama';

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
  String get spaceNameLabel => 'Nama Kategori';

  @override
  String inboxCount(int count) {
    return '$count catatan belum dirapikan.';
  }

  @override
  String get reminderIn7Days => 'Deadline 7 hari lagi';

  @override
  String get reminderIn3Days => 'Deadline 3 hari lagi';

  @override
  String get reminderIn1Day => 'Deadline besok';

  @override
  String get reminderIn3Hours => 'Deadline 3 jam lagi';

  @override
  String get reminderIn30Minutes => 'Deadline 30 menit lagi';

  @override
  String get reminderSnoozed => 'Pengingat ditunda 1 jam';

  @override
  String get testNotificationTitle => 'Tes pengingat';

  @override
  String get testNotificationBody =>
      'Bila kamu membaca ini, pengingat berfungsi.';

  @override
  String get testNotification => 'Tes notifikasi 1 menit';

  @override
  String get notifPermission => 'Izin notifikasi';

  @override
  String get exactAlarmPermission => 'Izin alarm presisi';

  @override
  String get batteryOptimization => 'Penghemat baterai';

  @override
  String get statusGranted => 'Diizinkan';

  @override
  String get statusDenied => 'Ditolak';

  @override
  String get statusUnknown => 'Tidak diketahui';

  @override
  String get openSystemSettings => 'Buka pengaturan sistem';

  @override
  String get testHistory => 'Riwayat tes';

  @override
  String get batteryGuide =>
      'Beberapa merek seperti Xiaomi, Oppo, Realme, dan Samsung menahan notifikasi aplikasi di latar belakang. Matikan penghemat baterai untuk Lekas supaya pengingat selalu sampai.';

  @override
  String get reminderCheckHint =>
      'Jalankan tes di bawah, lalu lihat apakah notifikasi masuk dalam satu menit.';

  @override
  String get permissionExplain =>
      'Lekas butuh izin notifikasi supaya pengingat deadline sampai ke HP-mu.';

  @override
  String get allow => 'Izinkan';

  @override
  String get notNow => 'Nanti';

  @override
  String get backupTitle => 'Cadangan Data';

  @override
  String exportedTo(String path) {
    return 'Diekspor ke: $path';
  }

  @override
  String importedTasks(int count) {
    return 'Diimpor: $count tugas';
  }

  @override
  String get exportFailed => 'Ekspor gagal. Coba lagi.';

  @override
  String get importFailed => 'Impor gagal. Data yang ada tidak diubah.';

  @override
  String get recordNotFound => 'Data tidak ditemukan.';

  @override
  String attachmentTooBig(int limit) {
    return 'File terlalu besar. Maksimal $limit MB.';
  }

  @override
  String get autoBackupFolder => 'Pilih Folder Cadangan Otomatis';

  @override
  String get autoBackupFolderHint => 'Untuk cadangan mingguan otomatis';

  @override
  String folderPicked(String path) {
    return 'Folder: $path';
  }

  @override
  String get shareAsTextTitle => 'Bagikan sebagai Teks';

  @override
  String get taskDependenciesTitle => 'Dependensi Tugas';

  @override
  String get taskDependenciesBody => 'Tugas yang menunggu tugas lain selesai.';

  @override
  String get noDependenciesYet => 'Belum ada prasyarat.';

  @override
  String get addPrerequisiteLabel => 'Tambah prasyarat';

  @override
  String get searchTaskLabel => 'Cari tugas';

  @override
  String get noOtherTasks => 'Belum ada tugas lain.';

  @override
  String get dependencyCycleError =>
      'Itu akan membuat lingkaran. Pilih tugas lain.';

  @override
  String get taskUnblockedTitle => 'Sekarang bisa mulai';

  @override
  String get importScheduleOcrTitle => 'Impor Jadwal dari Tangkapan Layar';

  @override
  String get weeklyLoadMapTitle => 'Peta Beban Mingguan';

  @override
  String get projectMilestoneTitle => 'Proyek dan Milestone';

  @override
  String get freeTimeSuggestionTitle => 'Saran Waktu Kosong';

  @override
  String get gradeSimulatorTitle => 'Simulator Nilai';

  @override
  String get examStudyPlanTitle => 'Rencana Belajar Ujian';

  @override
  String get taskListTitle => 'Daftar Tugas';

  @override
  String get taskListBody => 'Daftar tugas.';

  @override
  String get encryptedBackupTitle => 'Cadangan Terenkripsi';

  @override
  String get enableBackupEncryption => 'Aktifkan Enkripsi Cadangan';

  @override
  String get backupEncryptionMethod => 'AES-GCM dengan kata sandi';

  @override
  String get passwordWarning => 'Peringatan';

  @override
  String get passwordLostWarning =>
      'Kata sandi yang hilang berarti cadangan tidak bisa dibuka.';

  @override
  String get voiceQuickAddTitle => 'Quick Add Suara';

  @override
  String get voiceQuickAddHint => 'Tekan mikrofon untuk berbicara tugas';

  @override
  String get startRecording => 'Mulai Rekaman';

  @override
  String get defaultChecklistTitle => 'Daftar Bawaan per Matkul';

  @override
  String get checklistLaptop => 'Laptop';

  @override
  String get checklistLanCable => 'Kabel LAN';

  @override
  String get checklistPrintReport => 'Laprak Cetak';

  @override
  String get demoModeTitle => 'Mode Demo';

  @override
  String get trySampleData => 'Coba dengan Data Contoh';

  @override
  String get trySampleDataSubtitle => '3 matkul, 8 tugas, jadwal contoh';

  @override
  String get deleteSampleData => 'Hapus Data Contoh';

  @override
  String get deleteSampleDataSubtitle => 'Hapus semua data contoh';

  @override
  String get appLockTitle => 'Kunci Aplikasi';

  @override
  String get appLockOn => 'Aktif';

  @override
  String get appLockOff => 'Nonaktif';

  @override
  String get changePinLabel => 'Ubah PIN';

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinConfirmLabel => 'Konfirmasi PIN';

  @override
  String get pinMismatch => 'PIN tidak sama';

  @override
  String get pinTooShort => 'Pakai 4 sampai 6 digit';

  @override
  String get wrongPin => 'PIN salah';

  @override
  String get unlockLabel => 'Buka';

  @override
  String get unlockTitle => 'Buka Lekas';

  @override
  String get levelLabel => 'Jenjang';

  @override
  String get enableAppLock => 'Aktifkan Kunci Aplikasi';

  @override
  String get appLockMethod => 'Sidik jari atau PIN';

  @override
  String get schoolModeTheme => 'Tema Mode SMA';

  @override
  String get schoolModeThemeSubtitle => 'Ubah terminologi ke SMA';

  @override
  String get iconShortcutsTitle => 'Pintasan Ikon dan Quick Settings';

  @override
  String get appIconShortcut => 'Pintasan Ikon Aplikasi';

  @override
  String get appIconShortcutSubtitle =>
      'Tekan lama ikon peluncur: Tambah Tugas, Hari Ini, Inbox';

  @override
  String get quickSettingsTile => 'Tile Quick Settings';

  @override
  String get quickSettingsTileSubtitle =>
      'Satu ketukan dari bilah notifikasi membuka Quick Add';

  @override
  String get optionalPersistentNotification => 'Notifikasi Tetap Opsional';

  @override
  String get optionalPersistentNotificationSubtitle =>
      'Kolom ketik cepat (dimatikan bawaan)';

  @override
  String get globalQuickLinksTitle => 'Tautan Cepat Global';

  @override
  String get quickLinkSiakad => 'SIAKAD';

  @override
  String get quickLinkELearning => 'E-Learning Kampus';

  @override
  String get quickLinkLibrary => 'Perpustakaan';

  @override
  String get simpleRecurringTasksTitle => 'Tugas Berulang Sederhana';

  @override
  String get repeatDaily => 'Harian';

  @override
  String get repeatDailySubtitle => 'Setiap hari';

  @override
  String get repeatWeekly => 'Mingguan';

  @override
  String get repeatWeeklySubtitle => 'Hari tertentu setiap minggu';

  @override
  String get repeatMonthly => 'Bulanan';

  @override
  String get repeatMonthlySubtitle => 'Tanggal tertentu setiap bulan';

  @override
  String get duplicateDetectionTitle => 'Deteksi Duplikat';

  @override
  String get duplicateDetectionItemSubtitle =>
      'Deteksi duplikat untuk tugas ini';

  @override
  String get semesterStatsTitle => 'Statistik dan Rekap Semester';

  @override
  String get onTimePercentage => 'Persentase Tepat Waktu';

  @override
  String get busiestCourse => 'Matkul Terpadat';

  @override
  String get attendanceRecap => 'Rekap Kehadiran';

  @override
  String get weeklyTrend => 'Tren Per Minggu';

  @override
  String get exportImagePdfTitle => 'Ekspor Gambar dan PDF';

  @override
  String get exportWeekSchedule => 'Ekspor Jadwal Minggu';

  @override
  String get exportWeekScheduleSubtitle => 'Gambar jadwal minggu ini';

  @override
  String get exportTaskList => 'Ekspor Daftar Tugas';

  @override
  String get exportTaskListSubtitle => 'Gambar daftar tugas minggu ini';

  @override
  String get exportGradeRecap => 'Ekspor Rekap Nilai';

  @override
  String get exportGradeRecapSubtitle => 'PDF rekap nilai per matkul';

  @override
  String get exportDeadlineHistory => 'Ekspor Riwayat Deadline';

  @override
  String get exportDeadlineHistorySubtitle => 'PDF bukti perubahan deadline';

  @override
  String get advancedWidgetsTitle => 'Widget Lanjutan';

  @override
  String get widgetTaskListSubtitle => '3-6 baris dengan kotak centang';

  @override
  String get widgetTodayClasses => 'Kelas Hari Ini';

  @override
  String get widgetTodayClassesSubtitle => 'Jadwal singkat';

  @override
  String get widgetExamCountdown => 'Hitung Mundur Ujian';

  @override
  String get widgetExamCountdownSubtitle => 'Countdown ke ujian berikutnya';

  @override
  String get widgetTodayFocus => 'Fokus Hari Ini';

  @override
  String get widgetTodayFocusSubtitle =>
      'Tiga tugas fokus dengan kotak centang';

  @override
  String get todayFocusTitle => 'Fokus Hari Ini';

  @override
  String get ocrScreenshotTitle => 'OCR Tangkapan Layar';

  @override
  String get chooseScreenshot => 'Pilih Tangkapan Layar';

  @override
  String get chooseScreenshotSubtitle => 'Pilih gambar untuk diekstrak teksnya';

  @override
  String extractedFile(String path) {
    return 'Diekstrak: $path';
  }

  @override
  String get ocrLimitations => 'Batasan OCR';

  @override
  String get ocrLimitationsSubtitle =>
      'Hasil OCR pada tulisan tangan atau foto miring akan buruk.';

  @override
  String get gradePredictionTitle => 'Prediksi Nilai';

  @override
  String get noGradeComponents => 'Belum ada komponen penilaian.';

  @override
  String weightPercentLabel(String percent) {
    return 'Bobot: $percent%';
  }

  @override
  String get autoBackupTitle => 'Cadangan Otomatis';

  @override
  String get weeklyBackup => 'Cadangan Mingguan';

  @override
  String get weeklyBackupSubtitle => 'Cadangan otomatis ke folder yang dipilih';

  @override
  String backupFolderPicked(String path) {
    return 'Folder cadangan: $path';
  }

  @override
  String get keepLast4Backups => 'Simpan 4 Cadangan Terakhir';

  @override
  String get keepLast4BackupsSubtitle =>
      'Cadangan lebih lama akan dihapus otomatis';

  @override
  String get warnOlderThan14Days => 'Peringatan Bila > 14 Hari';

  @override
  String get warnOlderThan14DaysSubtitle =>
      'Peringatkan bila cadangan terakhir lebih dari 14 hari';

  @override
  String get deadlineHistoryTitle => 'Riwayat Deadline';

  @override
  String get emptyDeadlineHistory => 'Belum ada riwayat perubahan deadline.';

  @override
  String deadlineChangeLabel(String oldValue, String newValue) {
    return '$oldValue → $newValue';
  }

  @override
  String get mergeImportTitle => 'Impor Gabung';

  @override
  String get importAndMergeBackup => 'Impor dan Gabung Cadangan';

  @override
  String get importAndMergeBackupSubtitle =>
      'Gabungkan data dari cadangan dengan data saat ini';

  @override
  String mergedTasks(int count) {
    return 'Digabung: $count tugas';
  }

  @override
  String actionFailed(String error) {
    return 'Gagal: $error';
  }

  @override
  String get multiLineQuickAddTitle => 'Quick Add Banyak Baris';

  @override
  String get pasteMultipleLinesLabel =>
      'Tempel beberapa baris (satu baris = satu tugas)';

  @override
  String tasksWillBeCreated(int count) {
    return '$count tugas akan dibuat';
  }

  @override
  String get createTasks => 'Buat Tugas';

  @override
  String get trashTitle => 'Sampah';

  @override
  String get emptyTrash => 'Sampah kosong.';

  @override
  String deletedAtLabel(String date) {
    return 'Dihapus: $date';
  }

  @override
  String get restoreLabel => 'Pulihkan';

  @override
  String get deletePermanentlyLabel => 'Hapus permanen';

  @override
  String get deletePermanentlyBody =>
      'Tugas ini hilang selamanya dan tidak bisa dibatalkan.';

  @override
  String get attachmentsTitle => 'Lampiran';

  @override
  String get classContactsLinksTitle => 'Kontak dan Tautan Kelas';

  @override
  String get lecturerLabel => 'Dosen / Pengajar';

  @override
  String get roomLabel => 'Ruangan';

  @override
  String get classLinkLabel => 'Tautan Kelas';

  @override
  String get openLecturerWhatsApp => 'Buka WhatsApp Dosen';

  @override
  String get copyRoomNumber => 'Salin Nomor Ruangan';

  @override
  String get examStudyMaterialsTitle => 'Ujian dan Materi Belajar';

  @override
  String get noExamsYet => 'Belum ada ujian.';

  @override
  String daysRemaining(int days) {
    return '$days hari lagi';
  }

  @override
  String get examNoDeadline => 'Kapan-kapan';

  @override
  String get quizLabel => 'Kuis';

  @override
  String get midtermLabel => 'UTS';

  @override
  String get finalExamLabel => 'UAS';

  @override
  String get morningNightSummaryTitle => 'Ringkasan Pagi dan Malam';

  @override
  String get todaySummary => 'Ringkasan Hari Ini';

  @override
  String get todayTasksLabel => 'Tugas hari ini';

  @override
  String get tomorrowTasksLabel => 'Tugas besok';

  @override
  String get overdueTasksLabel => 'Tugas terlambat';

  @override
  String get summaryScheduleNote =>
      'Ringkasan pagi dikirim pukul 07.00\nPenutup malam dikirim pukul 20.30';

  @override
  String get searchFilterTitle => 'Pencarian dan Penyaring';

  @override
  String get searchTitleOrNotesLabel => 'Cari judul atau catatan';

  @override
  String get filterLabel => 'Penyaring';

  @override
  String get filterSubtitle => 'Kategori, status, urutan';

  @override
  String get newSemester => 'Semester Baru';

  @override
  String get semesterPeriodExample => 'Contoh: Ganjil 2026/2027';

  @override
  String get deleteLabel => 'Hapus';

  @override
  String get createNewSemester => 'Buat Semester Baru';

  @override
  String get snoozeReminderTitle => 'Tunda Pengingat';

  @override
  String get pickSnoozeTimeLabel => 'Pilih waktu tunda:';

  @override
  String get oneHourLabel => '1 jam';

  @override
  String get tonight7pmLabel => 'Nanti malam 19.00';

  @override
  String get tomorrow7amLabel => 'Besok pagi 07.00';

  @override
  String get weekendLabel => 'Akhir pekan';

  @override
  String get pickTimeLabel => 'Pilih waktu';

  @override
  String get meetingNotesTitle => 'Catatan Pertemuan';

  @override
  String get noteTitleLabel => 'Judul catatan';

  @override
  String get noteBodyLabel => 'Isi catatan';

  @override
  String get noMeetingNotesYet => 'Belum ada catatan pertemuan.';

  @override
  String get untitledNote => 'Tanpa judul';

  @override
  String get submissionMethodTitle => 'Cara Kumpul';

  @override
  String get submissionMethodLabel => 'Cara Kumpul';

  @override
  String get submitMethodPaper => 'Kertas / Hard Copy';

  @override
  String get othersLabel => 'Lainnya';

  @override
  String get submitTargetLabel => 'Tujuan (email, kelas LMS, ruangan)';

  @override
  String get filenamePatternLabel => 'Pola Nama Berkas';

  @override
  String componentWeightTitle(String spaceName) {
    return 'Bobot Komponen - $spaceName';
  }

  @override
  String get weightPercentFieldLabel => 'Bobot (%)';

  @override
  String weightTotalMustBe100(String total) {
    return 'Total bobot: $total%, harus 100%';
  }

  @override
  String get assignmentLabel => 'Tugas';

  @override
  String get attendanceLabel => 'Kehadiran';

  @override
  String get subtasksTitle => 'Subtugas';

  @override
  String get noSubtasksYet => 'Belum ada subtugas.';

  @override
  String get editSubtaskTitle => 'Edit Subtugas';

  @override
  String get personalTargetTitle => 'Target Pribadi';

  @override
  String get targetCompletionDate => 'Target Selesai';

  @override
  String get notSetYet => 'Belum diatur';

  @override
  String get attendanceTitle => 'Kehadiran';

  @override
  String get presentLabel => 'Hadir';

  @override
  String get remainingAbsenceQuota => 'Sisa Jatah Absen';

  @override
  String get markLabel => 'Tandai';

  @override
  String get absentLabel => 'Absen';

  @override
  String get excusedLabel => 'Izin';

  @override
  String get sickLabel => 'Sakit';

  @override
  String get shareIntakeTitle => 'Tugas dari Bagikan';

  @override
  String get shareIntakeHint =>
      'Centang kalimat yang mau dibuat tugas, lalu koreksi lewat chip.';

  @override
  String get shareNoCandidates =>
      'Tidak ada kalimat yang cocok. Simpan sebagai satu tugas.';

  @override
  String get saveSelected => 'Simpan yang Dicentang';

  @override
  String savedTasksCount(int count) {
    return 'Tersimpan: $count tugas';
  }

  @override
  String get savedViewsTitle => 'Tampilan Tersimpan';

  @override
  String get saveViewTitle => 'Simpan Tampilan';

  @override
  String get viewNameLabel => 'Nama tampilan';

  @override
  String get overdueTaskReminderTitle => 'Pengingat Tugas Terlambat';

  @override
  String get noOverdueTasks => 'Tidak ada tugas terlambat.';

  @override
  String overdueDaysLabel(int days, String deadline) {
    return 'Terlambat $days hari. Deadline: $deadline';
  }

  @override
  String get resetDeadlineLabel => 'Atur ulang';

  @override
  String priorityBadgeLabel(String value) {
    return 'Prioritas $value';
  }

  @override
  String deadlineAtLabel(String value) {
    return 'Deadline: $value';
  }

  @override
  String estimateMinutesLabel(int minutes) {
    return 'Estimasi: $minutes menit';
  }

  @override
  String subtaskProgressLabel(int done, int total) {
    return 'Subtugas ($done/$total)';
  }

  @override
  String get addLabel => 'Tambah';

  @override
  String get reopenTooltip => 'Buka kembali';

  @override
  String get markDoneTooltip => 'Tandai selesai';

  @override
  String get addSubtaskTitle => 'Tambah Subtugas';

  @override
  String get subtaskTitleHint => 'Judul subtugas';

  @override
  String get statusTodo => 'Belum';

  @override
  String get statusDoing => 'Dikerjakan';

  @override
  String get statusRevision => 'Revisi';

  @override
  String get taskModeGroup => 'Kelompok';

  @override
  String get emptyInboxNote => 'Belum ada catatan.';

  @override
  String get noNotesLabel => 'Tanpa catatan';

  @override
  String get previousMonth => 'Bulan sebelumnya';

  @override
  String get nextMonth => 'Bulan berikutnya';

  @override
  String get quickAddMenuLabel => 'Tambah Tugas Cepat';

  @override
  String get smartSnoozeLabel => 'Tunda Cerdas';

  @override
  String get morningNightSummaryShort => 'Ringkasan Pagi/Malam';

  @override
  String get overdueTasksMenuLabel => 'Tugas Terlambat';

  @override
  String get exportBackupShort => 'Ekspor Cadangan';

  @override
  String get importBackupShort => 'Impor Cadangan';

  @override
  String get emptySpaces => 'Belum ada kategori.';

  @override
  String spaceCodeValue(String value) {
    return 'Kode: $value';
  }

  @override
  String spaceLevelValue(String value) {
    return 'Jenjang: $value';
  }

  @override
  String spacePeriodValue(String value) {
    return 'Semester: $value';
  }

  @override
  String spaceSksValue(String value) {
    return 'SKS: $value';
  }

  @override
  String spaceTargetGradeValue(String value) {
    return 'Target Nilai: $value';
  }

  @override
  String get classScheduleTitle => 'Jadwal Kelas';

  @override
  String get tasksMenuLabel => 'Tugas';

  @override
  String get componentWeightLabel => 'Bobot Komponen';

  @override
  String get defaultChecklistShort => 'Daftar Bawaan';

  @override
  String get startTimeLabel => 'Jam Mulai (HH:MM)';

  @override
  String get endTimeLabel => 'Jam Selesai (HH:MM)';

  @override
  String get emptyClassSchedule => 'Belum ada jadwal kelas.';

  @override
  String get monday => 'Senin';

  @override
  String get tuesday => 'Selasa';

  @override
  String get wednesday => 'Rabu';

  @override
  String get thursday => 'Kamis';

  @override
  String get friday => 'Jumat';

  @override
  String get saturday => 'Sabtu';

  @override
  String get sunday => 'Minggu';

  @override
  String get welcomeSubtitle =>
      'Lekas membantumu mencatat tugas dan deadline kuliah.';

  @override
  String get enterFirstCourseSubtitle => 'Masukkan nama kategori pertama kamu.';

  @override
  String get firstCourseFallback => 'Kategori Pertama';

  @override
  String get allLabel => 'Semua';

  @override
  String get typeLabReport => 'Laprak';

  @override
  String get typePaper => 'Makalah';

  @override
  String get typePresentation => 'Presentasi';

  @override
  String get emptyTaskList => 'Belum ada tugas.';

  @override
  String get typeLabel => 'Jenis';

  @override
  String get attachmentFileMissing => 'File tidak ada di perangkat ini.';

  @override
  String get openLabel => 'Buka';

  @override
  String get noDuplicateFound => 'Tidak ada duplikat untuk tugas ini.';

  @override
  String get saved => 'Tersimpan';

  @override
  String get copiedToClipboard => 'Disalin ke papan klip';

  @override
  String get noStatsDataYet => 'Belum ada data untuk statistik ini.';

  @override
  String attendanceSavedToday(String status) {
    return 'Kehadiran hari ini: $status';
  }

  @override
  String get featureNotAvailable => 'Fitur ini belum tersedia.';

  @override
  String get enabledLabel => 'Aktif';

  @override
  String get disabledLabel => 'Nonaktif';

  @override
  String spaceCreated(String name) {
    return 'Kategori dibuat: $name';
  }

  @override
  String get deleted => 'Dihapus';

  @override
  String get sampleDataRemoved => 'Data contoh dihapus';

  @override
  String get sectionOverdue => 'Terlambat';

  @override
  String get sectionDoing => 'Sedang Dikerjakan';

  @override
  String get sectionToday => 'Hari Ini dan Besok';

  @override
  String get sectionThisWeek => 'Minggu Ini';

  @override
  String get sectionUpcoming => 'Mendatang';

  @override
  String get sectionWaiting => 'Menunggu';

  @override
  String get sectionSomeday => 'Kapan-kapan';

  @override
  String get reasonOverdue => 'Lewat deadline';

  @override
  String reasonDueInHours(int hours) {
    return '$hours jam lagi';
  }

  @override
  String get reasonHighPriority => 'Prioritas tinggi';

  @override
  String get reasonTightEstimate => 'Perkiraan waktu mepet';

  @override
  String reasonTimeLeft(int hours) {
    return 'Sisa $hours jam';
  }

  @override
  String get reasonNoDeadline => 'Tanpa deadline';

  @override
  String reasonWeight(String percent) {
    return 'bobot $percent%';
  }

  @override
  String get warningTitle => 'Peringatan';

  @override
  String get warningPermissionRevoked =>
      'Izin pengingat dicabut. Ketuk untuk membuka pengaturan.';

  @override
  String warningInboxPile(int count) {
    return 'Inbox menumpuk: $count tugas tanpa kategori. Ketuk untuk membereskan.';
  }

  @override
  String warningBusyWeek(int count) {
    return 'Minggu padat: $count tugas jatuh tempo. Ketuk untuk melihat.';
  }

  @override
  String get closeLabel => 'Tutup';

  @override
  String selectedCount(int count) {
    return '$count dipilih';
  }

  @override
  String get selectAllLabel => 'Pilih semua';

  @override
  String get reorderLabel => 'Ubah urutan';

  @override
  String get archiveLabel => 'Arsipkan';

  @override
  String get archiveActive => 'Aktif';

  @override
  String get archiveArchive => 'Arsip';

  @override
  String get archiveEmptyText =>
      'Tidak ada kategori yang diarsipkan di sini. Saat kamu mengarsip sebuah kategori, kategori itu menunggu di sini, dan bisa kamu pulihkan atau hapus permanen.';

  @override
  String get deleteSpaceTitle => 'Hapus kategori';

  @override
  String get deleteSpaceBody =>
      'Ini menghapus kategori beserta jadwal, presensi, catatan, komponen nilai, dan checklist. Tugasnya pindah ke Inbox. Tindakan ini tidak bisa dibatalkan.';

  @override
  String get spaceRestored => 'Kategori dipulihkan';

  @override
  String get drawerSectionTasks => 'Tugas';

  @override
  String get drawerSectionData => 'Data';

  @override
  String get drawerSectionSystem => 'Sistem';

  @override
  String get editSpaceTitle => 'Ubah kategori';

  @override
  String get taskDeletedUndo => 'Tugas dihapus';

  @override
  String tasksRestored(int count) {
    return '$count tugas dipulihkan';
  }

  @override
  String spacesArchivedUndo(int count) {
    return '$count kategori diarsipkan';
  }

  @override
  String get taskCompletedUndo => 'Tugas diselesaikan';

  @override
  String tasksDeletedUndo(int count) {
    return '$count tugas dihapus';
  }

  @override
  String bulkUpdated(int count) {
    return '$count tugas diperbarui';
  }

  @override
  String snoozeSet(String time) {
    return 'Pengingat ditunda ke $time';
  }

  @override
  String get reminderIn6Hours => 'Deadline 6 jam lagi';

  @override
  String get reminderIn12Hours => 'Deadline 12 jam lagi';

  @override
  String get reminderIn18Hours => 'Deadline 18 jam lagi';

  @override
  String groupedReminderTitle(int count) {
    return '$count tugas mendekati deadline';
  }

  @override
  String get summaryReminderTitle => 'Ringkasan pengingat';

  @override
  String summaryReminderBody(int count) {
    return '$count pengingat digabung ke ringkasan ini';
  }

  @override
  String get reminderIntensity => 'Intensitas pengingat';

  @override
  String get intensityCalm => 'Tenang: H-1 dan 3 jam';

  @override
  String get intensityNormal => 'Normal: H-3, H-1, 3 jam, 30 menit';

  @override
  String get intensityEager => 'Gencar: ditambah tiap 6 jam di hari deadline';

  @override
  String get notificationBudget => 'Anggaran notifikasi harian';

  @override
  String budgetPerDay(int count) {
    return '$count notifikasi per hari';
  }

  @override
  String overdueDigestBody(int count) {
    return '$count tugas melewati deadline. Ketuk untuk melihat daftarnya.';
  }

  @override
  String get overdueReminderToggle => 'Satu notifikasi per hari pukul 09.00';

  @override
  String get morningSummaryNotificationTitle => 'Ringkasan pagi';

  @override
  String morningSummaryMostUrgent(String title, String time) {
    return 'Paling mendesak: $title (deadline $time)';
  }

  @override
  String get summaryMorningToggle => 'Dikirim pukul 07.00';

  @override
  String get eveningSummaryTitle => 'Penutup malam';

  @override
  String eveningSummaryBody(int count) {
    return 'Ada $count tugas besok. Mau cek sekarang?';
  }

  @override
  String get summaryEveningToggle => 'Dikirim pukul 20.30 bila ada tugas besok';

  @override
  String get weeklySummaryTitle => 'Ringkasan minggu';

  @override
  String weeklySummaryOnTime(int count) {
    return '$count tugas selesai tepat waktu minggu ini.';
  }

  @override
  String weeklySummaryBusiest(String name, int count) {
    return 'Matkul terpadat minggu depan: $name ($count tugas).';
  }

  @override
  String weeklySummaryBackup(int days) {
    return 'Cadangan terakhir $days hari lalu.';
  }

  @override
  String get summaryWeeklyToggle => 'Minggu malam pukul 20.30';

  @override
  String get tagsLabel => 'Tag';

  @override
  String get tagsHint => 'Pisahkan dengan koma, misalnya revisi, kelompok';

  @override
  String get editTagsTitle => 'Ubah tag';

  @override
  String get sectionPinned => 'Disematkan';

  @override
  String get pinTaskLabel => 'Sematkan di atas layar Hari Ini';

  @override
  String get duplicateTask => 'Duplikat tugas';

  @override
  String get duplicatedToast => 'Salinan tugas dibuat';

  @override
  String get taskTemplatesTitle => 'Templat Tugas';

  @override
  String get emptyTemplates =>
      'Belum ada templat. Buka detail tugas lalu pilih Simpan sebagai templat.';

  @override
  String templateSummary(int subtasks, int minutes) {
    return '$subtasks subtugas, estimasi $minutes menit';
  }

  @override
  String templateSubtaskCount(int count) {
    return '$count subtugas';
  }

  @override
  String get saveAsTemplate => 'Simpan sebagai templat';

  @override
  String get templateNameLabel => 'Nama templat';

  @override
  String get templateUsedToast => 'Tugas baru dibuat dari templat';

  @override
  String get templateSavedToast => 'Templat disimpan';

  @override
  String attendanceProgress(int attended, int planned) {
    return 'Hadir $attended dari $planned pertemuan';
  }

  @override
  String attendanceLimitNote(int percent, int limit) {
    return 'Batas absen $percent persen, jatah terpakai $limit';
  }

  @override
  String attendanceRemaining(int count) {
    return 'Sisa jatah absen $count';
  }

  @override
  String get attendanceLastOne => 'Sisa jatah absen tinggal satu. Hati-hati.';

  @override
  String get attendanceExhausted =>
      'Jatah absen habis, kehadiranmu sudah di batas kampus.';

  @override
  String get totalMeetingsLabel => 'Jumlah pertemuan rencana';

  @override
  String get absentLimitLabel => 'Batas absen maksimal (persen)';

  @override
  String get excusedCountsLabel => 'Izin dan sakit dihitung absen';

  @override
  String morningSummaryQuotaLast(String name) {
    return 'Jatah absen $name tinggal 1, hati-hati hari ini.';
  }

  @override
  String morningSummaryQuotaOut(String name) {
    return 'Jatah absen $name sudah habis.';
  }

  @override
  String get chooseFocusAction => 'Pilih fokus hari ini';

  @override
  String get pickFocusLabel => 'Pilih tugas';

  @override
  String get focusLimitToast => 'Fokus hari ini sudah penuh, maksimal 3 tugas';

  @override
  String get focusAllDoneMsg => 'Semua tugas fokus hari ini selesai.';

  @override
  String get focusEmpty => 'Belum ada fokus hari ini. Pilih sampai 3 tugas.';

  @override
  String get focusRemoveTooltip => 'Keluarkan dari fokus';

  @override
  String get attendPromptTitle => 'Isi kehadiran';

  @override
  String attendPromptBody(String name) {
    return 'Kelas $name selesai 10 menit lalu.';
  }

  @override
  String get attendPromptAction => 'Isi sekarang';

  @override
  String get attendPromptToggle => 'Notifikasi Isi kehadiran';

  @override
  String get attendPromptToggleHint => 'Muncul 10 menit setelah kelas selesai';

  @override
  String continueFocusQuestion(int count) {
    return 'Lanjutkan $count tugas fokus kemarin?';
  }

  @override
  String get continueFocusAction => 'Lanjutkan';

  @override
  String eveningBringLine(String items) {
    return 'Besok bawa: $items';
  }

  @override
  String eveningBringMore(Object count) {
    return '(+$count lagi)';
  }

  @override
  String chipEstimateHours(int hours) {
    return 'Estimasi: $hours jam';
  }

  @override
  String get chipSubmitLms => 'Kumpul lewat LMS';

  @override
  String get chipSubmitEmail => 'Kumpul lewat email';

  @override
  String get chipSubmitPaper => 'Kumpul dicetak';

  @override
  String chipFilename(String pattern) {
    return 'Cek pola: $pattern';
  }

  @override
  String chipSubtasks(int count) {
    return '$count subtugas';
  }

  @override
  String chipLinks(int count) {
    return '$count tautan';
  }

  @override
  String chipNote(String note) {
    return 'Catatan: $note';
  }

  @override
  String get chipPriorityConflict => 'Prioritas campur';

  @override
  String get micUnavailable =>
      'Pengenalan suara tidak tersedia di perangkat ini.';

  @override
  String get micPermissionDenied =>
      'Izin mikrofon diperlukan untuk Quick Add suara.';

  @override
  String get voiceListening => 'Mendengarkan...';

  @override
  String get appVersionLabel => 'Versi aplikasi';

  @override
  String get accentColor => 'Warna aksen';

  @override
  String get fontSize => 'Ukuran font';

  @override
  String get fontSmall => 'Kecil';

  @override
  String get fontNormal => 'Normal';

  @override
  String get fontLarge => 'Besar';

  @override
  String get fontXlarge => 'Sangat besar';

  @override
  String get colorDefault => 'Bawaan';

  @override
  String get previewLight => 'Terang';

  @override
  String get previewDark => 'Gelap';

  @override
  String get presetMidnight => 'Tengah malam';

  @override
  String get presetSunset => 'Senja';

  @override
  String get presetForest => 'Hutan';

  @override
  String get semesterTitle => 'Semester';

  @override
  String get semesterActiveLabel => 'Semester Aktif';

  @override
  String get semesterOtherLabel => 'Semester Lain';

  @override
  String courseCount(int count) {
    return '$count mata kuliah';
  }

  @override
  String openTasksCount(int count) {
    return '$count tugas';
  }

  @override
  String tasksDoneOf(int done, int total) {
    return '$done dari $total tugas selesai';
  }

  @override
  String semesterOverdue(int count) {
    return '$count terlambat';
  }

  @override
  String get manageCoursesLabel => 'Kelola Mata Kuliah';

  @override
  String get courseListTitle => 'Mata Kuliah Semester Ini';

  @override
  String get makeActiveLabel => 'Jadikan Aktif';

  @override
  String get noSemesterTitle => 'Belum ada semester';

  @override
  String get noSemesterBody =>
      'Buat semester pertamamu untuk mengelompokkan mata kuliah.';

  @override
  String get semesterCreated => 'Semester dibuat';

  @override
  String get semesterDeleted => 'Semester dihapus';

  @override
  String get semesterDeleteTitle => 'Hapus Semester?';

  @override
  String get semesterDeleteBody =>
      'Semua kategori di semester ini dihapus beserta jadwal, catatan, nilai dan absensinya. Tugasnya pindah ke Kotak Masuk. Tindakan ini tidak bisa dibatalkan.';

  @override
  String get editSemesterLabel => 'Ubah nama semester';

  @override
  String get clearDeadline => 'Hapus';

  @override
  String get resetLabel => 'Atur Ulang';

  @override
  String get statusLabel => 'Status';

  @override
  String get pendingLabel => 'Belum Selesai';

  @override
  String get doneLabel => 'Selesai';

  @override
  String get sortLabel => 'Urutkan';

  @override
  String get sortDeadlineAsc => 'Deadline terdekat dulu';

  @override
  String get sortDeadlineDesc => 'Deadline terjauh dulu';

  @override
  String get sortCreatedDesc => 'Terbaru dibuat dulu';

  @override
  String get sortPriorityHighFirst => 'Prioritas tertinggi dulu';

  @override
  String get groupByCategory => 'Kelompokkan per kategori';

  @override
  String get listViewLabel => 'Daftar';

  @override
  String get noFilterMatch => 'Tidak ada tugas yang cocok dengan filter ini.';

  @override
  String get noCategoryFallback => 'Tanpa kategori';

  @override
  String get tapToCheckUpdates => 'Ketuk untuk memeriksa versi terbaru';

  @override
  String get autoUpdateCheckTitle => 'Periksa pembaruan otomatis';

  @override
  String get autoUpdateCheckSubtitle =>
      'Sekali sehari saat membuka aplikasi; tidak mengirim data';

  @override
  String get updateAvailableTitle => 'Pembaruan tersedia';

  @override
  String updateAvailableBody(String version) {
    return 'Lekas $version sudah ada. Unduh dan pasang APK terbaru agar aplikasi selalu paling baru.';
  }

  @override
  String updateAvailableShort(String version) {
    return 'Pembaruan tersedia: $version';
  }

  @override
  String get updateDownload => 'Unduh';

  @override
  String get updateLater => 'Nanti';

  @override
  String appUpToDate(String version) {
    return 'Kamu memakai versi terbaru ($version)';
  }

  @override
  String get updateCheckFailed =>
      'Tidak bisa memeriksa pembaruan. Periksa koneksi internet.';

  @override
  String get kategoriTitle => 'Kategori';

  @override
  String get addCategory => 'Kategori Baru';

  @override
  String get categoryNameLabel => 'Nama kategori';

  @override
  String get kategoriEmpty =>
      'Belum ada kategori. Buat untuk organisasi, kepanitiaan, komunitas, atau apa pun.';

  @override
  String get uncategorizedInfo => 'Tugas tanpa kategori tersimpan di sini';

  @override
  String get mataKuliahTitle => 'Mata Kuliah';

  @override
  String get addCourse => 'Mata Kuliah Baru';

  @override
  String get bringItemLabel => 'Bawaan';

  @override
  String get addBringItem => 'Tambah bawaan';

  @override
  String get editBringItem => 'Ubah bawaan';

  @override
  String get bringItemDeleted => 'Bawaan dihapus';

  @override
  String emptyBringList(String name) {
    return 'Belum ada bawaan untuk $name.';
  }

  @override
  String get broughtLabel => 'Sudah dibawa';

  @override
  String get attendanceHistory => 'Riwayat';

  @override
  String get attendanceHistoryEmpty => 'Belum ada catatan kehadiran.';

  @override
  String get editAttendanceRecord => 'Ubah catatan';

  @override
  String get deleteAttendanceRecord => 'Hapus catatan?';

  @override
  String get deleteAttendanceRecordBody =>
      'Catatan kehadiran ini akan dihapus.';

  @override
  String get attendanceRecordDeleted => 'Catatan dihapus';

  @override
  String get attendanceNoteLabel => 'Catatan (opsional)';

  @override
  String get dateLabel => 'Tanggal';

  @override
  String get editLabel => 'Ubah';

  @override
  String get weekdayLabel => 'Hari';

  @override
  String get classKindLabel => 'Jenis';

  @override
  String get kindLecture => 'Kuliah';

  @override
  String get kindLab => 'Praktikum';

  @override
  String get classScheduleHint =>
      'Kuliah dan praktikum beserta jam dan ruangnya';

  @override
  String get addClassSlot => 'Tambah Jadwal';

  @override
  String get editClassSlot => 'Ubah Jadwal';

  @override
  String get deleteClassSlot => 'Hapus Jadwal?';

  @override
  String get deleteClassSlotBody => 'Jadwal ini akan dihapus.';

  @override
  String get classTimeOrderError => 'Jam selesai harus setelah jam mulai.';

  @override
  String get monShort => 'Sen';

  @override
  String get tueShort => 'Sel';

  @override
  String get wedShort => 'Rab';

  @override
  String get thuShort => 'Kam';

  @override
  String get friShort => 'Jum';

  @override
  String get satShort => 'Sab';

  @override
  String get sunShort => 'Min';

  @override
  String get agendaTitle => 'Agenda';

  @override
  String get agendaEmpty => 'Tidak ada kelas atau tugas pada hari ini.';

  @override
  String get seeAllTasks => 'Lihat semua';

  @override
  String get filesLabel => 'Berkas';

  @override
  String get filesSetupTitle => 'Simpan berkas di penyimpanan HP';

  @override
  String get filesSetupBody =>
      'Lekas menyimpan modul, catatan, soal, dan arsip di folder pada penyimpanan HP kamu, bukan di dalam aplikasi. Pilih folder untuk menyimpannya.';

  @override
  String get pickFilesFolder => 'Pilih folder';

  @override
  String get filesImportFailed =>
      'Berkas tidak bisa diimpor. Pilih folder lagi atau coba berkas lain.';

  @override
  String get newFolderLabel => 'Folder baru';

  @override
  String get folderNameLabel => 'Nama folder';

  @override
  String get folderAlreadyExists => 'Folder dengan nama itu sudah ada.';

  @override
  String get deleteFolder => 'Hapus folder?';

  @override
  String get deleteFile => 'Hapus berkas?';

  @override
  String get deleteFolderBody => 'Semua isi folder akan dihapus.';

  @override
  String get filesOpenFailed =>
      'Tidak ada aplikasi di HP ini yang bisa membuka berkas ini.';

  @override
  String get renameFolder => 'Ubah nama folder';

  @override
  String get renameFile => 'Ubah nama berkas';

  @override
  String get importFileLabel => 'Impor berkas';

  @override
  String get filesOpenInFileManager =>
      'Berkas tersimpan di penyimpanan HP; kelola bebas dengan file manager apa pun.';

  @override
  String get folderEmpty => 'Folder ini kosong.';

  @override
  String get folderLabel => 'Folder';

  @override
  String get fileImported => 'Berkas diimpor';

  @override
  String get filesSurviveDeletion =>
      'Berkas tertinggal di penyimpanan HP dan tidak terhapus saat mata kuliah dihapus.';

  @override
  String get unableToCreateFolder => 'Folder tidak bisa dibuat';

  @override
  String get permissionLostFolder =>
      'Akses ke folder yang dipilih hilang; pilih ulang';

  @override
  String get filesOpFailed => 'Itu tidak berhasil';
}
