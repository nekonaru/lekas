# ARCHITECTURE.md - Lekas (Aplikasi Tugas)

Sumber rancangan: `Rancangan_Aplikasi_Tugas_v2_Dirapikan.md`.

## Tumpukan
Flutter + Dart, Drift (SQLite), Riverpod, flutter_local_notifications + timezone, home_widget, share_plus, file_picker, receive_sharing_intent.

## Struktur folder (lib/)
- core/  tema, konstanta, scoring_config, util tanggal
- data/  tabel Drift, DAO, repository
- domain/  model Task, Space, aturan skor urgensi
- parser/  modul Dart murni (dictionaries/id.dart, en.dart, normalizer, time_extractor, matcher)
- reminders/  ReminderService, boot handler, kanal notifikasi
- features/  today, tasks, spaces, quick_add, share_intake, calendar, settings
- l10n/  app_id.arb, app_en.arb

## Prinsip
- Skor dihitung saat tampil, tidak disimpan.
- Database menyimpan kunci netral, bukan teks terjemahan.
- Waktu disimpan UTC epoch ms, ditampilkan lokal.
- Satu repository per entitas, UI tidak menyentuh DB langsung.
- Teks tampilan lewat AppLocalizations, tidak ada literal di kode.

## Status scaffolding
- Proyek Flutter dibuat, dependensi terpasang, l10n dikonfigurasi.
- Langkah berikutnya: implementasi skema Drift (bagian 10 rancangan), lalu Fase A inti.