# ARCHITECTURE.md - Lekas (Aplikasi Tugas)

Sumber rancangan: `rancangan.md` (dokumen lokal, tidak di-commit).

## Tumpukan
Flutter + Dart, Drift (SQLite), Riverpod, flutter_local_notifications + timezone, home_widget, share_plus, file_picker, receive_sharing_intent, speech_to_text.

## Struktur folder (lib/)
- core/  tema + Motion, komponen bersama (TaskCard/section, bulk bar, undo snackbar, logo, empty state, motion)
- data/  tabel Drift schema 4, repository per entitas, providers Riverpod, backup service
- domain/  aturan skor urgensi dan fokus
- lock/  kunci aplikasi: PIN salted SHA-256 (sha256.dart), LockService, layar buka kunci
- parser/  modul Dart murni (normalizer, time_extractor, matcher, kamus id/en)
- reminders/  ReminderService + notifikasi, kebijakan, ringkasan
- voice/  pembungkus speech_to_text untuk Voice Quick Add
- features/  satu folder per layar (home, today, inbox, spaces, calendar, settings, quick_add, tasks, share_intake, onboarding)
- l10n/  app_id.arb (template Indonesia), app_en.arb, hasil gen-l10n
- tool/  skrip generator logo dan subset font, audit glif

## Prinsip
- Skor dihitung saat tampil, tidak disimpan. Urutan wadah dan subtugas ditulis ke sortOrder (schema 4).
- Database menyimpan kunci netral, bukan teks terjemahan.
- Waktu disimpan UTC epoch ms, ditampilkan lokal.
- Satu repository per entitas, UI tidak menyentuh DB langsung.
- Teks tampilan lewat AppLocalizations, tidak ada literal di kode.
- Aksi massal lewat helper bersama (bulk_actions) memakai transaksi Drift dan snackbar urungkan yang sama di semua daftar.
- Snackbar urungkan satu banner dalam satu waktu, ditutup Timer 5 detik (banner dengan action tidak auto-dismiss sendiri).
- Kunci aplikasi menyimpan hanya hash SHA-256 ber-salt (lib/lock/); gerbang dikunci saat kembali ke foreground.
- Backup lama tanpa sortOrder tetap bisa diimpor (backfill 0).

## Status
- Schema 4 (24 tabel + indeks), 455 test, analyze bersih.
- Rilis sampai v1.7.0: logo centang, bulk di semua daftar, reorder wadah dan subtugas, jenjang switcher, redesign tema, kunci aplikasi PIN, aksi hari kalender.
