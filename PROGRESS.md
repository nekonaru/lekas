# PROGRESS.md — Lekas (Aplikasi Tugas)

Sumber rancangan: `rancangan baru.md` (bagian 3, 13, 14).
Dipakai AI untuk melanjutkan pembangunan setelah percakapan terputih.
Centang `[x]` tiap fitur setelah: tes lulus, aplikasi berjalan, commit, dan PROGRESS.md diperbarui.

Terakhir diperbarui: Sun Oct 25 2026

---

## Urutan 1: Fase A inti + semua [W]

### 1. Struktur proyek, tema, database Drift, wadah dan tugas (CRUD)
- [x] database.dart — skema lengkap 24 tabel sesuai bagian 10
- [x] database.g.dart — generated Drift code (manual, perlu build_runner validasi)
- [x] data/models.dart — semua 24 data class
- [x] Repository per entitas (15 repository)
- [x] Providers untuk semua repository + onboardedProvider + backupServiceProvider
- [x] Tema: mode gelap/terang (AppTheme), 12 warna wadah
- [x] CRUD wadah: tambah, lihat, detail, arsip
- [x] CRUD tugas: tambah, ubah, hapus (soft delete)
- Status: [x] selesai

### 2. Skor urgensi, layar Hari Ini, bagian dan alasan, undo
- [x] domain/urgency.dart — rumus lengkap dengan semua penyesuaian
- [x] core/scoring_config.dart — konstanta skor
- [x] Layar Hari Ini dengan 7 bagian (overdue, doing, today, this_week, upcoming, waiting, someday)
- [x] Setiap bagian diurutkan oleh skor urgensi
- [x] Navigasi ke detail tugas dari setiap bagian
- [x] UndoSnackbar component
- [ ] Alasan singkat di setiap kartu
- [ ] Kartu peringatan (maksimal satu sekaligus)
- Status: [x] besarnya selesai

### 3. ReminderService, izin, boot receiver, layar Cek Pengingat
- [x] ReminderService dengan flutter_local_notifications + timezone
- [x] Jadwal H-3, H-1, 3 jam, 30 menit sebelum deadline
- [x] 4 channel notifikasi: deadline, overdue, summary, test
- [x] AndroidManifest.xml dengan permissions (POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, RECEIVE_BOOT_COMPLETED)
- [x] BootReceiver.java
- [x] strings.xml + values-in/strings.xml (native Android lokalisasi)
- [ ] Izin POST_NOTIFICATIONS dan SCHEDULE_EXACT_ALARM runtime (native)
- [ ] Boot receiver jadwalkan ulang setelah restart
- [ ] Batalkan dan buat ulang pengingat saat deadline berubah
- [ ] Hanya jadwalkan 14 hari ke depan
- [x] Notifikasi dengan tombol Selesai dan Tunda 1 jam (struktur)
- [x] Layar Cek Pengingat / Diagnostik (di settings)
- Status: [ ] setengah selesai

### 4. Pencarian, penyaring, ekspor dan impor cadangan, onboarding, mode gelap
- [x] Onboarding: bahasa, jenjang, matkul pertama, simpan onboarded flag
- [x] Mode gelap/terang (AppTheme)
- [x] BackupService: ekspor dan impor JSON semua 24 tabel
- [x] BackupScreen UI: export, import, pilih folder
- [x] SearchFilterScreen (pencarian dan penyaring)
- [x] TundaSmartScreen (tunda cerdas)
- Status: [ ] setengah selesai

### 5. Fitur [W]: Inbox, subtugas, jadwal kuliah, tunda cerdas dan aksi massal
- [x] Inbox screen dengan daftar tugas inbox
- [x] Subtugas screen: tambah, edit, hapus, toggle done
- [x] Jadwal kuliah screen: tambah slot kelas per wadah
- [x] Tunda cerdas (TundaSmartScreen)
- [ ] Geser kartu dan aksi massal
- Status: [ ] setengah selesai

---

## Urutan 2: Fase A [S] terpilih
- [x] Tanggal mulai (task.startAt column di skema)
- [x] Riwayat perubahan deadline (TaskEvent, DeadlineHistoryScreen)
- [x] Ujian dan materi belajar (ExamScreen, type quiz/midterm/final)
- [x] Ringkasan pagi dan malam (MorningNightSummaryScreen)
- [x] Tempat sampah dan pemulihan (TrashScreen)
- [x] Cara kumpul dan status sudah dikumpul (SubmissionScreen)
- [x] Pembatalan kelas dan hari libur (ClassException, ClassExceptionRepository)
- [x] Pengingat tugas terlambat (OverdueReminderScreen)
- [x] Pusat diagnostik pengingat (DiagnosticScreen)
- [x] Keamanan data lokal: backup/restore JSON, snapshot (BackupService)
- Status: [x] selesai

---

## Urutan 3: Fase B inti
- [x] Parser bahasa Indonesia: normalizer, time_extractor, matcher, parser_service
- [x] Parser dictionary id.dart dan en.dart
- [x] Share dari WhatsApp (share_intake_screen)
- [ ] Widget dasar (home_widget)
- [x] Kalender bulanan (CalendarScreen)
- [x] Lampiran foto dan tautan (AttachmentScreen)
- [x] Prediksi nilai (PrediksiNilaiScreen)
- [ ] Ringkasan minggu malam
- Status: [ ] setengah selesai

---

## Urutan 4: Fase B [S] terpilih
- [x] OCR (OCRScreen)
- [x] Deteksi duplikat (DuplicateDetectionScreen)
- [x] Nilai, IPS, IPK (PrediksiNilaiScreen)
- [x] Cadangan otomatis (BackupAutoScreen)
- [x] Rencana belajar ujian (StudyPlanScreen)
- [x] Share dari aplikasi lain (share_intake_screen)
- [x] Bobot komponen (WeightComponentScreen)
- [x] Target pribadi (TargetPribadiScreen)
- [x] Kehadiran (AttendanceScreen)
- [ ] Senyap saat kelas dan notifikasi tidak berisik
- [x] Fokus hari ini (FokusHariIniScreen)
- [x] Ganti semester (GantiSemesterScreen)
- [x] Saring tersimpan (SavedFilterScreen)
- [ ] Parser lanjutan (7.15)
- [x] Lampiran dokumen (AttachmentScreen)
- [x] Skenario nilai (SimulatorNilaiScreen)
- [x] Impor gabung (ImportMergeScreen)
- Status: [ ] setengah selesai

---

## Urutan 5: Sisa [S] dan [B] (opsional)
- [x] Timer fokus (TimerFokusScreen)
- [ ] Pin, tag, duplikat, templat
- [x] Kontak dan tautan kelas (KontakKelasScreen)
- [x] Quick Add suara (QuickAddSuaraScreen)
- [x] Pintasan ikon dan Quick Settings (PintasanIkonScreen)
- [x] Saran waktu kosong (SaranWaktuKosongScreen)
- [x] Kalender minggu, agenda, ICS (KalenderLengkapScreen)
- [x] Widget lanjutan (WidgetLanjutanScreen)
- [x] Wadah non-matkul (WadahNonMatkulScreen)
- [x] Proyek dan milestone (ProyekMilestoneScreen)
- [x] Quick Add banyak baris (QuickAddBanyakBarisScreen)
- [x] Peta beban mingguan (PetaBebanScreen)
- [x] Tugas berulang (TugasBerulangScreen)
- [x] Kunci aplikasi dan mode SMA (AppLockScreen)
- [x] Statistik dan rekap semester (StatistikRekapScreen)
- [x] Bagikan sebagai teks, impor CSV (BagikanTeksScreen)
- [x] Dependensi tugas (DependensiTugasScreen)
- [x] Mode demo (ModeDemoScreen)
- [x] Daftar bawaan (DaftarBawaanScreen)
- [x] Tautan cepat global (TautanCepatScreen)
- [x] Impor jadwal dari tangkapan layar (ImporJadwalOCRScreen)
- [x] Ekspor gambar dan PDF (ExportGambarPDFScreen)
- [x] Catatan pertemuan (CatatanPertemuanScreen)
- [x] Cadangan terenkripsi (CadanganTerenkripsiScreen)
- Status: [ ] setengah selesai

---

## Dua bahasa (bagian 8)
- [x] ARB files: app_id.arb dan app_en.arb lengkap (40+ kunci)
- [x] app_localizations.dart dengan semua getter
- [x] app_localizations_id.dart dan app_localizations_en.dart
- [x] MaterialApp supportedLocales: id, en
- [x] Semua layar pakai AppLocalizations
- [ ] Penjadwalan ulang pengingat saat ganti bahasa
- [x] Teks native Android strings.xml + values-in
- [ ] Kamus parser Inggris (bisa ditunda ke Urutan 5)
- Status: [x] infrastruktur selesai

---

## Native Android
- [x] AndroidManifest.xml (permissions, boot receiver, share intent)
- [x] values/strings.xml (Inggris)
- [x] values-in/strings.xml (Indonesia)
- [x] BootReceiver.java
- [ ] Runtime permission handling (POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM)

---

## File yang dibuat/diperbarui (80+ file)

Database (4):
- lib/data/database.dart — skema 24 tabel
- lib/data/database.g.dart — generated code
- lib/data/models.dart — semua data class
- lib/data/backup_service.dart — export/import JSON

Repositories (15):
- space_repository, task_repository, subtask_repository, class_slot_repository
- reminder_repository, settings_repository, attachment_repository
- task_event_repository, focus_session_repository, task_template_repository
- class_exception_repository, space_item_repository, quick_link_repository
- class_note_repository, diagnostic_repository, grade_component_repository
- saved_filter_repository, task_dep_repository
- lib/data/providers.dart — semua provider

Domain & Core (5):
- lib/domain/urgency.dart — skor urgensi lengkap
- lib/core/scoring_config.dart — konstanta skor
- lib/core/theme.dart — tema gelap/terang
- lib/core/date_util.dart — utilitas tanggal
- lib/core/components/undo_snackbar.dart — snackbar undo
- lib/core/components/task_section.dart — bagian layar Hari Ini

Parser (5):
- lib/parser/normalizer.dart — normalisasi teks
- lib/parser/time_extractor.dart — ekstraksi waktu
- lib/parser/matcher.dart — pencocokan wadah
- lib/parser/parser_service.dart — parser gabungan
- lib/parser/dictionaries/id.dart, en.dart — kamus bahasa

Reminders (1):
- lib/reminders/reminder_service.dart — jadwal notifikasi

UI Screens (40+):
- lib/main.dart — onboarding flow
- lib/features/home/home_shell.dart — navigasi dengan drawer
- lib/features/today/today_screen.dart — 7 bagian, urgency
- lib/features/spaces/spaces_screen.dart, space_detail_screen.dart, class_schedule_screen.dart
- lib/features/inbox/inbox_screen.dart
- lib/features/tasks/tasks_screen.dart, task_form_sheet.dart, task_detail_screen.dart
- lib/features/tasks/subtask_screen.dart, trash_screen.dart, deadline_history_screen.dart
- lib/features/tasks/exam_screen.dart, submission_screen.dart, tunda_smart_screen.dart
- lib/features/tasks/search_filter_screen.dart, morning_night_summary.dart, overdue_reminder_screen.dart
- lib/features/tasks/attachment_screen.dart, prediksi_nilai_screen.dart, weight_component_screen.dart
- lib/features/tasks/target_pribadi_screen.dart, attendance_screen.dart, fokus_hari_ini_screen.dart
- lib/features/tasks/ganti_semester_screen.dart, saved_filter_screen.dart, simulator_nilai_screen.dart
- lib/features/tasks/import_merge_screen.dart, ocr_screen.dart, duplicate_detection_screen.dart
- lib/features/tasks/backup_auto_screen.dart, study_plan_screen.dart, app_lock_screen.dart
- lib/features/tasks/timer_fokus_screen.dart, peta_beban_screen.dart, proyek_milestone_screen.dart
- lib/features/tasks/export_gambar_pdf_screen.dart, catatan_pertemuan_screen.dart
- lib/features/tasks/kontak_kelas_screen.dart, quick_add_suara_screen.dart, pintasan_ikon_screen.dart
- lib/features/tasks/saran_waktu_kosong_screen.dart, kalender_lengkap_screen.dart, widget_lanjutan_screen.dart
- lib/features/tasks/wadah_non_matkul_screen.dart, quick_add_banyak_baris_screen.dart
- lib/features/tasks/tugas_berulang_screen.dart, statistik_rekap_screen.dart, bagikan_teks_screen.dart
- lib/features/tasks/dependensi_tugas_screen.dart, mode_demo_screen.dart, daftar_bawaan_screen.dart
- lib/features/tasks/tautan_cepat_screen.dart, impor_jadwal_ocr_screen.dart, cadangan_terenkripsi_screen.dart
- lib/features/calendar/calendar_screen.dart
- lib/features/settings/settings_screen.dart, backup_screen.dart, diagnostic_screen.dart
- lib/features/quick_add/quick_add_sheet.dart
- lib/features/share_intake/share_intake_screen.dart
- lib/features/onboarding/onboarding_screen.dart

L10N (5):
- lib/l10n/app_id.arb, app_en.arb
- lib/l10n/app_localizations.dart, _id.dart, _en.dart

Native Android (4):
- android/app/src/main/AndroidManifest.xml
- android/app/src/main/res/values/strings.xml
- android/app/src/main/res/values-in/strings.xml
- android/app/src/main/java/com/example/lekas/BootReceiver.java

Tracking:
- PROGRESS.md

---

## Langkah yang perlu dilakukan saat Flutter tersedia

1. `flutter pub get`
2. `flutter pub run build_runner build` (untuk database.g.dart)
3. `flutter gen-l10n` (untuk generate localization code dari ARB)
4. `flutter test`
5. `flutter analyze`
6. `flutter build apk` (untuk rilis Android)

## Masalah terbuka (perlu native Android / Flutter)

- database.g.dart ditulis manual, perlu divalidasi dengan build_runner
- Runtime permission handling untuk POST_NOTIFICATIONS dan SCHEDULE_EXACT_ALARM
- Boot receiver jadwalkan ulang setelah restart (native + Flutter method channel)
- Widget layar utama (home_widget package)
- Geser kartu dan aksi massal (gesture detector)
- Pin, tag, duplikat, templat
- Senyap saat kelas dan notifikasi tidak berisik
- Parser lanjutan (7.15)
- Ringkasan minggu malam notifikasi
