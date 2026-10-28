# PROGRESS.md - Lekas (Aplikasi Tugas)

Sumber rancangan: `rancangan baru.md` (bagian 3, 13, 14).
Dipakai AI untuk melanjutkan pembangunan setelah percakapan terputih.
Centang `[x]` tiap fitur setelah: tes lulus, aplikasi berjalan, commit, dan PROGRESS.md diperbarui.

Terakhir diperbarui: Sun Oct 26 2026

---

## Catatan keputusan (baca dulu)

- **`gen-l10n` tetap dipakai.** `rules.md` bagian 8 melarang codegen l10n, tetapi repo ini
  sudah memakai ARB + `generate: true`. Rancangan bagian 8.2 (dua bahasa lewat ARB) menang
  untuk arsitektur; `rules.md` menang untuk gaya kode, commit, dan push. Kunci ARB hidup di
  `lib/l10n/app_id.arb` dan `app_en.arb`, lalu `flutter gen-l10n` dijalankan.
- **Pemeriksaan em/en dash harus membaca berkas sebagai UTF-8.** Pemeriksaan lama memakai
  `Get-Content -Raw` tanpa encoding, sehingga UTF-8 salah dibaca dan em dash di
  `README.md`, `README.id.md`, `PROGRESS.md` dan `ARCHITECTURE.md` luput. Pemeriksaan kini
  memakai `[System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)` dan mencakup
  berkas `*.md`, `*.arb`, `*.dart`, `*.kt`, `*.xml`, `*.yml`, `*.yaml`.
- **Semua tombol sudah beraksi.** Tidak ada lagi `onTap: () {}` / `onPressed: () {}`
  di `lib/features/` (dari 66 placeholder menjadi 0). Setiap tombol kini membuka layar,
  dialog, bottom sheet, atau memanggil repository. Quick Add suara memakai plugin
  `speech_to_text` (izin menambah plugin diberikan pada 26 Okt 2026).
- **Urutan aturan pengingat: jam tenang dulu, lalu kelas.** Bila ujung kelas jatuh di dalam
  jam tenang, hasil kelas yang menang (dibaca ulang lewat `moveOutOfQuietHours`), sehingga
  pengingat tidak pernah mendarat di 22.00-06.00. Pengecualian rancangan 5.21: deadline
  kurang dari 1 jam setelah kelas selesai tidak pernah ditahan.
- **Geser kartu tidak menghapus kartu.** `confirmDismiss` selalu mengembalikan `false`;
  kartu balik ke tempatnya lalu daftar dimuat ulang, supaya tidak ada error
  "dismissed widget still in the tree" saat data berubah lewat stream.
- **Notifikasi gabungan tidak punya tombol aksi per tugas.** `flutter_local_notifications`
  tidak punya grup sistemik, jadi penggabungan (5.21), digest terlambat (5.22) dan ringkasan
  pagi/malam (5.12) dibuat sebagai satu notifikasi berisi daftar judul. Ketuk membuka
  aplikasi; tombol Selesai dan Tunda hanya dipasang saat notifikasi itu berisi tepat satu
  tugas, supaya aksinya tidak menyangkut tugas yang salah. Isinya dibangun ulang tiap sync
  (buka app, boot, ubah tugas), bukan tepat pada jamnya.
- **Ringkasan minggu dijadwalkan Minggu pukul 20.30.** Catatan "Minggu malam" tidak
  menyebut jam; dipakai jam penutup malam (5.12) supaya hanya satu jenis jam malam.
  Isinya dihitung lokal: tugas tepat waktu 7 hari terakhir, matkul terpadat minggu depan,
  dan usia cadangan terakhir (diambil dari `last_backup_at` yang ditulis tiap ekspor).
- **Tugas yang disematkan keluar dari bagiannya.** Daripada disorting ulang di tiap
  bagian, tugas berpindah ke bagian "Disematkan" tersendiri di paling atas layar Hari
  Ini (5.9), sehingga tidak muncul dua kali dan tetap di luar urutan skor.
- **Tag disimpan ternormalisasi** (`#Kelompok` menjadi `kelompok`) supaya tag yang sama
  tidak terpecah; tag yang tidak dipakai tugas mana pun dibersihkan otomatis.
- **Kehadiran pakai tabel `attendance` dengan migrasi skema (`schemaVersion` 1 ke 2).**
  Pengaturan per matkul (jumlah pertemuan, batas absen, izin dihitung absen) berupa kolom
  nullable di `spaces`; bawaan kampus (16 pertemuan, 25 persen) diterapkan di kode, bukan di
  skema, supaya baris lama tetap terbaca. Kelas tabelnya bernama `Attendance` sehingga
  baris hasil generate bernama `AttendanceData`.
- **Sakelar notifikasi "Isi kehadiran" tidak dipasang di UI.** Kolom `attend_prompt` sudah
  ada di skema tetapi notifikasi 10 menit setelah kelas belum dibuat; memasang sakelarnya
  sekarang hanya menampilkan pengaturan yang tidak melakukan apa pun.
- **Bagian fokus ditempatkan tepat setelah "Disematkan".** Rancangan menyebutnya di bawah
  kartu "Kelas berikutnya", tetapi layar Hari Ini tidak punya kartu tersebut, jadi fokus
  (per hari) menempel di atas, di bawah pin (permanen). Tugas yang terpilih fokus sekaligus
  pin tampil satu kali di bagian fokus.
- **Tombol notifikasi membuka lewat dua jalur.** Saat aplikasi sedang berjalan, aksi
  menulis `pendingNotificationRouteProvider`; saat aplikasi di latar, isolate plugin
  menulis kunci `pending_route` di tabel settings, dibaca saat aplikasi hidup kembali.
  Payload ringkasan pagi selalu berformat parseable supaya tombolnya diabaikan ketika
  tidak ada tugas tempo hari.
- **Notifikasi "Isi kehadiran" berdiri sendiri di luar anggaran.** Prompt dijadwalkan per
  kelas dengan `kind` tersendiri (`attend`), tidak melewati penggabungan dan anggaran
  notifikasi harian karena menyangkut kehadiran, bukan pengingat tugas. Kelas yang
  selesai di jam tenang (22.00-06.00) tidak memunculkan prompt sama sekali, bukan
  digeser, karena prompt yang digeser akan datang sebelum kelasnya sendiri.
- **Tawaran lanjut fokus berupa tombol terpisah di ringkasan pagi.** Baris
  "Lanjutkan N tugas kemarin?" hanya muncul bila ada fokus kemarin yang belum selesai,
  dan tombol "Lanjutkan" mengerjakannya di latar tanpa membuka layar; tombol
  "Pilih fokus hari ini" tetap ada. Hanya tugas yang terbuka yang dipindahkan, dan
  hasilnya tidak pernah melewati batas 3 tugas.
- **"Besok bawa: ..." menempel pada penutup malam yang sudah ada (5.32).** Baris hanya
  muncul bila penutup malam itu sendiri tampil, yaitu bila ada tugas berdeadline besok
  (aturan 5.12), dan hanya untuk matkul yang besok ada kelas serta punya daftar
  barang. Maksimal 5 judul ditulis, sisanya sebagai "(+N lagi)".
- **Empat widget dibangun native di Android (7.8).** Satu kelas dasar
  (`LekasWidgetProvider`) menggambar tiga daftar dan satu hitung mundur dari data yang
  ditulis Flutter ke SharedPreferences lewat `home_widget`; tombol kotak centang jalan
  di isolate latar dan membalik status tugas, lalu widget digambar ulang. Pembaruan
  terjadi saat data berubah (debounce 400 ms), saat aplikasi kembali ke depan, dan tiap
  30 menit lewat `updatePeriodMillis` Android. Toggle dari widget tidak langsung
  menjadwalkan ulang pengingat; jadwal disinkronkan lagi saat aplikasi dibuka.
- **Uji manual di HP fisik belum dilakukan** (rancangan 14.7): reboot, mode hemat baterai,
  ganti zona waktu, izin alarm ditolak. Layar Cek Pengingat sudah menyediakan tes 1 menit.
- **Parser 7.15 dijalankan sebelum waktu dibaca, kecuali antrian yang harus awal.**
  Urutannya: subtugas dan pola nama berkas (masih di teks mentah supaya baris dan huruf
  asli terjaga), normalisasi, tautan, email, cara kumpul, `@wadah`/`#tag`, estimasi,
  penanda dan kata prioritas, catatan kurung, baru jenis, waktu, mode kerja, wadah, judul.
  Estimasi sengaja diekstrak sebelum time extractor sehingga "estimasi 3 jam" jadi
  perkiraan kerja sementara "3 jam lagi" tetap waktu relatif. Penanda `!` cocok lewat
  regex tersendiri karena `\b` tidak berdiri antara huruf dan tanda baca; bila `@wadah`
  tidak dikenal, tokennya dikembalikan ke judul. Prioritas tinggi dan rendah dalam satu
  kalimat dianggap konflik dan netral sampai pengguna memilih di chip.
- **Parser dua bahasa membaca dua kamus sekaligus, bahasa aktif lebih dulu (8.5).**
  `_merge` di `ParserService` menaruh entri bahasa aktif di depan, jadi bahasa itu menang
  saat bentrok dan mendapat giliran pertama membaca kata, lalu bahasa lain melengkapi
  kekurangannya; begitu campuran "submit laprak friday 23.59" tetap terbaca di kedua
  locale. `TimeExtractor` kini paham "tomorrow", "next friday", "7pm", "7:00 PM", "at 7",
  "in 3 hours", "october 25", "the 25th", "before 12" dan "next week", dengan aturan lama
  "besok", "jam 7 malam", "jumat depan" tetap berjalan. Kata bentrok "minggu" saat bahasa
  aktif Inggris dibaca sebagai hari Minggu tapi tetap menyalakan chip "perlu dicek", dan
  Quick Add serta share intake mengirim `locale` dari `localeProvider`.
- **Mikrofon Quick Add suara ada di dalam sheet, bukan di layar terpisah (7.1).**
  `QuickAddSheet` mempunyai tombol mikrofon di ujung kolom teks lewat pembungkus
  `VoiceInput` (`lib/voice/voice_input.dart`) yang memakai `speech_to_text` 7.5.0; setiap
  panggilan platform ditangkap menjadi `false`, sehingga perangkat tanpa pengenal suara
  menampilkan pesan `micUnavailable`/`micPermissionDenied` alih-alih kegagalan. Layar
  `QuickAddSuaraScreen` tetap ada sebagai layar bicara: teks dengar masuk ke kolomnya,
  lalu tombol `quickAddMenuLabel` membuka `QuickAddSheet(initialText:)`, dan entri laci
  "Quick Add Suara" membuka layar itu. Angka bicara (7.1) diubah jadi digit hanya bila
  berdempetan petunjuk waktu (`jam|pukul|at|tanggal|tgl`, sebelum nama bulan, sebelum kata
  periode), jadi "beli tiga buku" tetap memakai kata. Karena `SpeechToText.initialize`
  tidak pernah menjawab di lingkungan tes, `test/voice_quick_add_test.dart` memasang
  mock kanal `plugin.csdcorp.com/speech_to_text` yang membalas `false`.
- **Chip 7.15 bisa dibuang dan yang tersimpan hanya yang dipertahankan.** Chip tampil di
  `Wrap` Quick Add dan share intake; membuangnya mencatat id di set `dismissed`, sehingga
  `estimateMinutes`, `submitMethod`, `submitTarget`, `filenamePattern`, `#tag`, subtugas
  dan tautan tidak ikut tersimpan. Tautan menjadi lampiran `kind: 'link'`, `#tag` dinormalisasi
  lewat `TagRepository.setTaskTags`, subtugas disimpan berurutan lewat
  `saveParsedExtras` (`lib/data/parsed_task_extras.dart`). Chip catatan dan chip konflik
  prioritas bersifat informatif; catatan sudah tertulis di kolom `notes` lewat teks asli.

---

## Urutan 1: Fase A inti + semua [W]

### 1. Struktur proyek, tema, database Drift, wadah dan tugas (CRUD)
- [x] database.dart - skema lengkap 24 tabel sesuai bagian 10
- [x] database.g.dart - generated Drift code (divalidasi ulang dengan `build_runner`: hasilnya identik)
- [x] data/models.dart - semua 24 data class
- [x] Repository per entitas (15 repository)
- [x] Providers untuk semua repository + onboardedProvider + backupServiceProvider
- [x] Tema: mode gelap/terang (AppTheme), 12 warna wadah
- [x] CRUD wadah: tambah, lihat, detail, arsip
- [x] CRUD tugas: tambah, ubah, hapus (soft delete)
- Status: [x] selesai

### 2. Skor urgensi, layar Hari Ini, bagian dan alasan, undo
- [x] domain/urgency.dart - rumus lengkap dengan semua penyesuaian
- [x] core/scoring_config.dart - konstanta skor
- [x] Layar Hari Ini dengan 7 bagian (overdue, doing, today, this_week, upcoming, waiting, someday)
- [x] Setiap bagian diurutkan oleh skor urgensi
- [x] Navigasi ke detail tugas dari setiap bagian
- [x] UndoSnackbar component
- [x] Alasan singkat di setiap kartu (`urgencyReason`, teks `alasan · bobot · tanggal`)
- [x] Kartu peringatan (maksimal satu sekaligus, bisa ditutup: izin dicabut, Inbox >= 5, minggu padat >= 10)
- [x] Geser kartu (kanan = selesai + undo, kiri = sheet tunda) dan aksi massal lewat long press
- Status: [x] besarnya selesai

### 3. ReminderService, izin, boot receiver, layar Cek Pengingat
- [x] ReminderService dengan flutter_local_notifications + timezone
- [x] Jadwal H-3, H-1, 3 jam, 30 menit sebelum deadline (+ H-7 bila bobot >= 60)
- [x] Reconcile otomatis: DB vs plugin setiap perubahan tugas, saat app dibuka, dan saat resumed
- [x] Jam tenang 22.00 sampai 06.00 digeser ke 21.55, tidak melewati deadline (Lampiran B poin 1)
- [x] Horizon jadwal 14 hari ke depan
- [x] 4 channel notifikasi: deadline, overdue, summary, test
- [x] AndroidManifest.xml dengan permissions (POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, RECEIVE_BOOT_COMPLETED)
- [x] BootReceiver.java: engine Flutter latar belakang, entrypoint `reminderBoot`, handshake `lekas/boot`, timeout 30 detik, `goAsync()`
- [x] LekasPlatformChannel.java: zona waktu (`getID`), buka pengaturan notifikasi dan baterai
- [x] Izin POST_NOTIFICATIONS diminta saat tugas ber-deadline pertama disimpan (task_form_sheet + quick_add)
- [x] Izin alarm presisi: cek `canScheduleExactNotifications()`, fallback inexact, retry bila `zonedSchedule` gagal
- [x] Batalkan dan buat ulang pengingat saat deadline berubah (syncAll)
- [x] Hanya jadwalkan 14 hari ke depan (kScheduleHorizonDays)
- [x] Notifikasi dengan tombol Selesai dan Tunda 1 jam (foreground + background isolate)
- [x] Layar Cek Pengingat / Diagnostik (izin, tes 1 menit, panduan baterai, riwayat tes)
- [ ] Uji manual di HP fisik: reboot, hemat baterai, ganti zona waktu, izin alarm ditolak (rancangan 14.7)
- Status: [x] kode selesai, uji perangkat menunggu manusia

### 4. Pencarian, penyaring, ekspor dan impor cadangan, onboarding, mode gelap
- [x] Onboarding: bahasa, jenjang, matkul pertama, simpan onboarded flag
- [x] Mode gelap/terang (AppTheme)
- [x] Pilih bahasa dan mode tema di Pengaturan (localeProvider + themeModeProvider)
- [x] BackupService: ekspor dan impor JSON semua 24 tabel
- [x] BackupScreen UI: export, import, pilih folder
- [x] SearchFilterScreen (pencarian dan penyaring)
- [x] TundaSmartScreen (tunda cerdas)
- Status: [x] selesai

### 5. Fitur [W]: Inbox, subtugas, jadwal kuliah, tunda cerdas dan aksi massal
- [x] Inbox screen dengan daftar tugas inbox
- [x] Subtugas screen: tambah, edit, hapus, toggle done
- [x] Jadwal kuliah screen: tambah slot kelas per wadah
- [x] Tunda cerdas (TundaSmartScreen): hanya memindahkan pengingat, tidak pernah deadline (5.5)
- [x] Geser kartu dan aksi massal (TaskSection Dismissible + selection bar TodayScreen)
- Status: [x] selesai

---

## Urutan 2: Fase A [S] terpilih
- [x] Tanggal mulai (task.startAt column di skema)
- [x] Riwayat perubahan deadline (TaskEvent, DeadlineHistoryScreen)
- [x] Ujian dan materi belajar (ExamScreen, type quiz/midterm/final)
- [x] Ringkasan pagi dan malam: layar MorningNightSummaryScreen + notifikasi 07.00 dan 20.30 (5.12)
- [x] Tempat sampah dan pemulihan (TrashScreen)
- [x] Cara kumpul dan status sudah dikumpul (SubmissionScreen)
- [x] Pembatalan kelas dan hari libur (ClassException, ClassExceptionRepository)
- [x] Pengingat tugas terlambat: layar OverdueReminderScreen + digest harian 09.00 (5.22)
- [x] Pusat diagnostik pengingat (DiagnosticScreen)
- [x] Keamanan data lokal: backup/restore JSON, snapshot (BackupService)
- Status: [x] selesai

---

## Urutan 3: Fase B inti
- [x] Parser bahasa Indonesia: normalizer, time_extractor, matcher, parser_service
- [x] Parser dictionary id.dart dan en.dart
- [x] Tes parser: 231 tes lulus, termasuk tabel kasus tepi 6.1, korpus 100+ kalimat, korpus 7.15 berisi 50 kalimat, korpus Inggris/campur 8.5 berisi 16 kalimat dan angka bicara 7.1
- [x] Quick Add tersambung ke parser: chip deadline, wadah, jenis, prioritas, mode kelompok
- [x] Share dari WhatsApp (share_intake_screen): split kalimat, chip koreksi, simpan banyak tugas
- [x] Share intent aktif: intent-filter SEND text/plain + listener `ReceiveSharingIntent` di main.dart
- [x] Widget layar utama (`home_widget`): empat widget di launcher, "Daftar Tugas" (sampai 6 baris), "Kelas Hari Ini", "Hitung Mundur Ujian" dan "Fokus Hari Ini", masing-masing dengan tombol tambah cepat, kotak centang yang bisa ditap langsung, dan pembaruan saat data berubah serta tiap 30 menit
- [x] Kalender bulanan (CalendarScreen)
- [x] Lampiran foto dan tautan (AttachmentScreen)
- [x] Prediksi nilai (PrediksiNilaiScreen)
- [x] Ringkasan minggu malam
- Status: [x] selesai

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
- [x] Kehadiran dan batas absen (AttendanceScreen, 5.19): tabel `attendance` + kolom pengaturan per matkul, `schemaVersion 2` dengan migrasi, layar menampilkan "Hadir X dari Y pertemuan" dan sisa jatah absen dengan peringatan lembut/merah, notifikasi "Isi kehadiran" 10 menit setelah kelas (per matkul, di luar anggaran notifikasi), ekspor-impor cadangan, 9 tes
- [x] Senyap saat kelas (`class_quiet.dart`, pengecualian `class_exceptions`, deadline < 1 jam tidak ditahan; 6 tes)
- [x] Gabung notifikasi (<= 10 menit jadi satu), anggaran 8 per hari dan intensitas Tenang/Normal/Gencar (`notification_policy.dart`, 11 tes)
- [x] Ringkasan pagi 07.00 dan penutup malam 20.30 sebagai notifikasi (5.12, dua sakelar di Pengaturan); ringkasan pagi kini menyertakan jatah absen yang tinggal 1/habis (5.19), tombol "Pilih fokus hari ini" (5.24) serta tawaran lanjut fokus kemarin, dan penutup malam menyebut "Besok bawa: ..." (5.32)
- [x] Ringkasan minggu Minggu malam 20.30: tugas tepat waktu, matkul terpadat minggu depan, usia cadangan terakhir (catatan "Minggu malam", sakelar sendiri)
- [x] Fokus hari ini (FokusHariIniScreen, 5.24): pilih maksimal 3 tugas per hari, bagian "Fokus Hari Ini" di layar Hari Ini, sakelar di detail tugas, tombol di ringkasan pagi, tawaran "Lanjutkan N tugas kemarin?", perayaan kecil saat semua selesai
- [x] Ganti semester (GantiSemesterScreen)
- [x] Saring tersimpan (SavedFilterScreen)
- [x] Parser lanjutan (7.15): `lib/parser/advanced_extractor.dart` membaca subtugas berbutir, pola nama berkas, tautan, alamat email, kata cara kumpul (LMS/kelas maya/drive = `lms`, dicetak/hardcopy = `paper`, alamat email = `email`), token `@wadah` dan `#tag`, penanda `!`/`!tinggi`/`!rendah`, estimasi `~2j`/`~45m`/"estimasi 2 jam", kata prioritas Inggris-Indonesia beserta penanda konflik, serta catatan dalam kurung; hasilnya jadi field baru pada `ParsedTask` dan chip yang bisa dibuang di Quick Add serta share intake
- [x] Lampiran dokumen (AttachmentScreen)
- [x] Skenario nilai (SimulatorNilaiScreen)
- [x] Impor gabung (ImportMergeScreen)
- Status: [x] selesai

---

## Urutan 5: Sisa [S] dan [B] (opsional)
- [x] Timer fokus (TimerFokusScreen)
- [x] Pin, tag, duplikat, templat (5.9): bagian "Disematkan" di layar Hari Ini, tag bebas dari detail tugas, duplikat satu ketukan, simpan/buat dari templat, penyaring gabung wadah + jenis + tag
- [x] Kontak dan tautan kelas (KontakKelasScreen)
- [x] Quick Add suara (7.1): mikrofon di `QuickAddSheet` dan di layar `QuickAddSuaraScreen`
  lewat pembungkus `VoiceInput` (`lib/voice/voice_input.dart`, plugin `speech_to_text` 7.5.0);
  hasil dengar ditulis ke kolom teks sambil bicara sehingga parser langsung menampilkan chip,
  layar suara menyerahkan kalimatnya ke sheet lewat `QuickAddSheet(initialText:)`, entri laci
  "Quick Add Suara" membuka layar itu, dan perangkat tanpa pengenal suara mendapat pesan
  `micUnavailable` atau `micPermissionDenied` alih-alih kegagalan
- [x] Pintasan ikon dan Quick Settings (PintasanIkonScreen)
- [x] Saran waktu kosong (SaranWaktuKosongScreen)
- [x] Kalender minggu, agenda, ICS (KalenderLengkapScreen)
- [x] Widget lanjutan (WidgetLanjutanScreen, daftar menu ke empat widget di atas)
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
- [x] Daftar bawaan (DaftarBawaanScreen): daftar per wadah di `space_items`, penutup malam menyebut "Besok bawa: ..." bila ada kelas besok yang daftarannya terisi (maksimal 5 judul, sisanya dihitung)
- [x] Tautan cepat global (TautanCepatScreen)
- [x] Impor jadwal dari tangkapan layar (ImporJadwalOCRScreen)
- [x] Ekspor gambar dan PDF (ExportGambarPDFScreen)
- [x] Catatan pertemuan (CatatanPertemuanScreen)
- [x] Cadangan terenkripsi (CadanganTerenkripsiScreen)
- Status: [x] selesai

---

## Dua bahasa (bagian 8)
- [x] ARB files: app_id.arb dan app_en.arb lengkap (456 kunci pesan per bahasa, id dan en sama; 9 kunci chip 7.15, 3 kunci mikrofon, 1 kunci versi)
- [x] app_localizations.dart dengan semua getter
- [x] app_localizations_id.dart dan app_localizations_en.dart
- [x] MaterialApp supportedLocales: id, en
- [x] Semua layar pakai AppLocalizations (tidak ada teks Indonesia hardcoded di lib/features)
- [x] Penyesuaian bahasa lewat localeProvider (pengingat memakai bahasa dari Pengaturan)
- [x] Teks native Android strings.xml + values-in + values-en (nama dan teks widget)
- [x] Kamus parser en.dart (dasar)
- [x] Parser Inggris setara penuh: `ParserService.parse` membaca kedua kamus sekaligus dengan bahasa aktif lebih dulu (`_merge`), `TimeExtractor` paham "tomorrow", "next friday", "7pm", "7:00 PM", "at 7", "in 3 hours", "october 25", "the 25th", "before 12" dan "next week", kata mode kerja serta kata prioritas dua bahasa, dan Quick Add serta share intake mengirim `locale` dari `localeProvider`; kata bentrok ("minggu" saat bahasa aktif Inggris) tetap dibaca sebagai hari Minggu tapi menyalakan chip "perlu dicek"
- Status: [x] selesai

---

## Native Android
- [x] AndroidManifest.xml (permissions, boot receiver, share intent SEND text/plain)
- [x] values/strings.xml (Inggris)
- [x] values-in/strings.xml (Indonesia)
- [x] BootReceiver.java (engine latar belakang + handshake + goAsync)
- [x] LekasPlatformChannel.java (zona waktu, pengaturan notifikasi, pengaturan baterai)
- [x] MainActivity.kt mendaftarkan LekasPlatformChannel
- [x] Runtime permission handling (POST_NOTIFICATIONS lewat plugin, SCHEDULE_EXACT_ALARM via cek presisi)

---

## File yang dibuat/diperbarui (80+ file)

Database (4):
- lib/data/database.dart - skema 24 tabel
- lib/data/database.g.dart - generated code
- lib/data/models.dart - semua data class
- lib/data/backup_service.dart - export/import JSON

Repositories (15):
- space_repository, task_repository, subtask_repository, class_slot_repository
- reminder_repository, settings_repository, attachment_repository
- task_event_repository, focus_session_repository, task_template_repository
- class_exception_repository, space_item_repository, quick_link_repository
- class_note_repository, diagnostic_repository, grade_component_repository
- saved_filter_repository, task_dep_repository
- lib/data/providers.dart - semua provider

Domain & Core (5):
- lib/domain/urgency.dart - skor urgensi lengkap
- lib/core/scoring_config.dart - konstanta skor
- lib/core/theme.dart - tema gelap/terang
- lib/core/date_util.dart - utilitas tanggal
- lib/core/components/undo_snackbar.dart - snackbar undo
- lib/core/components/task_section.dart - bagian layar Hari Ini

Parser (5):
- lib/parser/normalizer.dart - normalisasi teks
- lib/parser/time_extractor.dart - ekstraksi waktu
- lib/parser/matcher.dart - pencocokan wadah
- lib/parser/parser_service.dart - parser gabungan
- lib/parser/dictionaries/id.dart, en.dart - kamus bahasa

Reminders (1):
- lib/reminders/reminder_service.dart - jadwal notifikasi

UI Screens (40+):
- lib/main.dart - onboarding flow
- lib/features/home/home_shell.dart - navigasi dengan drawer
- lib/features/today/today_screen.dart - 7 bagian, urgency
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

Native Android (5):
- android/app/src/main/AndroidManifest.xml
- android/app/src/main/res/values/strings.xml
- android/app/src/main/res/values-in/strings.xml
- android/app/src/main/java/com/lekas/lekas/BootReceiver.java
- android/app/src/main/java/com/lekas/lekas/LekasPlatformChannel.java

Tracking:
- PROGRESS.md

---

## Verifikasi terakhir (28 Okt 2026)

1. `flutter gen-l10n` - sukses, 459 kunci pesan per bahasa
2. `flutter analyze` - 0 issue (termasuk `prefer_single_quotes: true`)
3. `flutter test` - 383 tes lulus (parser dasar, lanjutan 7.15, Inggris/campur 8.5 dan
   angka bicara 7.1, penulis ekstra parser, widget Quick Add suara, versi pubspec,
   pengingat, kebijakan notifikasi dan ringkasan, urgensi, tag, duplikat, templat, pin,
   kehadiran, fokus, daftar bawaan, widget, indeks skema, sinkronisasi pengingat,
   pemotongan token parser, batas parser)
4. `flutter build apk --split-per-abi` - sukses, 19.8 MB (armeabi-v7a) + 22.1 MB (arm64)
5. `database.g.dart` divalidasi dengan `dart run build_runner build`: hasil identik
6. Placeholder `onTap: () {}` / `onPressed: () {}` di `lib/features/` - 0 tersisa
7. Push ke `main` dan CI GitHub Actions hijau

## Audit pasca-rilis (28 Okt 2026)

Dua subagent memb seluruh `lib/` dan `test/`. Temuan diperbaiki bertahap, satu
perubahan logis per commit, semua CI hijau:

- `60d6c64` `fix: stop soft deletes from wiping row data` - `softDeleteTask` memakai
  `replace()` yang membangun ulang baris dari nol sehingga notes, deadline dan space
  hilang saat pindah ke Sampah. Kini hanya kolom `deleted_at`/`updated_at` yang ditulis;
  `watchTrash`/`deletePermanently` menempel di sampah asli; `countInbox` memakai COUNT(*).
- `5418f06` `fix: harden backup import, manifest and notifications` - impor backup
  kini tervalidasi (manifest + skema), receiver backup jadi privat, `allowBackup=false`,
  visibilitas notifikasi privat, lampiran di batas 10 MB, guard `snapshot.data!`.
- `5945049` `perf: add schema 3 indexes for list queries` - 19 `@TableIndex` dihitung
  dari `EXPLAIN QUERY PLAN` nyata; `test/index_test.dart` mengunci tiap rencana query.
- `8a38bd1` `perf: reconcile reminders once per write burst` - `reminderSyncProvider`
  kini `ref.listen(fireImmediately: true)` + debounce 400 ms + fingerprint FNV-1a;
  jawaban izin alarm presisi ditanya sekali per run; baris reminder + `notif_id_seq`
  bergerak dalam satu transaksi; 6 panggilan `syncAll()` ganda di TodayScreen dihapus.
- `8af82ff` `perf: commit bulk task edits in one transaction` - seleksi massal,
  `duplicateTask`, `createFromTemplate`, carry over fokus dan `saveParsedExtras` kini
  satu transaksi (dulu satu fsync per baris, dan kegagalan di tengah meninggalkan
  salinan setengah jadi).
- `c995b52` `fix: cut every token against the original text` - bug nyata: dua penanda
  `!tinggi ... !rendah` membuat RangeError (offset geser setelah potongan), dan dua
  tautan berspasi awal mengacak judul jadi "lihat ht alu". Pemotongan kini satu pass
  maju atas teks asli.
- `9759b9f` `perf: bound the parser on pasted input` - parser membaca paling banyak
  4000 karakter (dipotong di batas kata; notes tetap pesan asli) dan daftar subtask
  berhenti di 50 item.
- `be020cd` `perf: settle search and quick add before parsing` - pencarian menunggu
  250 ms dan query task/tag di-memo sampai filter berubah (dulu satu baca DB baru per
  ketikan); Quick Add parse 150 ms setelah karakter terakhir, tombol simpan selalu
  flush parse atas isi kolom saat itu.
- `01fab77` `perf: watch today tasks and sort by one score pass` - badan TodayScreen
  mengikuti stream `watchTasks` (tanpa spinner ulang tiap interaksi), skor urgensi
  dihitung sekali per tugas (dulu dua kali per pasangan), `DateFormat` di-cache per
  locale.

Keputusan: **izin `INTERNET` dipertahankan** di manifest. `speech_to_text`
membutuhkannya untuk menghubungi layanan pengenalan Android; aplikasi tetap
offline-first karena tidak ada panggilan jaringan milik Lekas sendiri.

## Rilis v1.0.0 (27 Okt 2026)

- Tag `v1.0.0` (annotated) pada commit hijau `6ae95ab`, sesuai aturan rancangan/rules
  bagian 12: menandai hanya setelah CI hijau.
- `.github/workflows/release.yml` (baru) berjalan pada push tag `v*`: cocokkan tag dengan
  `version:` di `pubspec.yaml`, jalankan `flutter analyze` dan `flutter test`, bangun
  `flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64`,
  susun catatan rilis dua bahasa dari header `## vX.Y.Z - ...` di `CHANGELOG.md` dan
  `CHANGELOG.id.md` (seksi `### ` dipromosikan jadi `## `), lalu terbitkan dengan
  `gh release create --verify-tag` beserta dua APK.
- Rilis `Lekas v1.0.0 - First public release` terbit dengan aset
  `app-arm64-v8a-release.apk` (22 MB) dan `app-armeabi-v7a-release.apk` (19.8 MB).
- Catatan rilis persis bentuk rules bagian 5: Inggris lalu Indonesia, pemisah
  `<br>` / `---` / `<br>`, empat seksi, tanpa em/en dash.
- `CHANGELOG.md` dan `CHANGELOG.id.md` (baru) memakai `## v1.0.0` lalu empat seksi yang
  sama, versi terbaru di paling atas.
- `README.md` dan `README.id.md` ditulis ulang ke 11 bagian kanonik rules bagian 4
  (About, Features berupa tabel, Requirements, Installation, Usage, Display Language,
  Project Structure, Testing, FAQ, Author, License) dengan pemilih bahasa di baris pertama.
- Deskripsi repo dan topik diperbarui sesuai rules bagian 2 dan 3: "Track student tasks
  and deadlines offline-first (Flutter, Android), capture them from chat in 5 seconds,
  fully offline." plus topik `dart`, `indonesia`, `offline`.
- Baris versi di Pengaturan memakai `appVersion` (`lib/core/constants.dart`), dijaga oleh
  `test/version_test.dart` agar selalu sama dengan `version:` di `pubspec.yaml`.

## Masalah terbuka (perlu native Android / Flutter)

- Uji manual pengingat di HP fisik (reboot, hemat baterai, ganti zona waktu, izin ditolak)
- Uji Quick Add suara di HP fisik: izin mikrofon, pengenalan suara bawaan Android, dan hasil
  ucapan yang salah menulis angka
- Isi digest terlambat dan ringkasan pagi, malam serta minggu diperbarui saat sync (buka app, boot, ubah tugas), bukan tepat pada jamnya
