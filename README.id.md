<div align="center">

# 📝 Lekas: Pencatat Tugas & Deadline Mahasiswa

**Tangkap tugas dari chat dalam 5 detik, otomatis rapi per matkul, diingatkan dengan benar.**

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?style=flat-square&logo=flutter&logoColor=white)
![Release](https://img.shields.io/github/v/release/nekonaru/lekas?style=flat-square&color=blue)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)
![CI](https://github.com/nekonaru/lekas/actions/workflows/build-apk.yml/badge.svg)

</div>

[English](README.md) | **Bahasa Indonesia**

## 📖 Tentang

**Lekas** adalah aplikasi Android offline-first untuk mahasiswa mencatat tugas dan deadline, rapi per matkul, dengan pengingat lokal yang andal. Tanpa akun, tanpa cloud, tanpa kolaborasi: semuanya tersimpan di HP.

Ketik satu baris, parser membaca deadline, matkul dan prioritas. Geser kartu, tugas selesai, dengan undo yang menunggu. Aplikasi tetap jalan saat sinyal mati.

## ✨ Fitur

| Fitur | Deskripsi |
| --- | --- |
| 📚 Wadah | Matkul dan wadah lain dengan warna, kode, alias untuk parser, plus catatan dosen, ruangan dan tautan |
| ✅ Tugas | Jenis, deadline, prioritas, status, bobot, estimasi, individu atau kelompok, lengkap dengan subtugas dan tag |
| ⚡ Quick Add | Satu kolom, teks Indonesia atau Inggris, chip langsung untuk setiap nilai yang ditebak parser (bagian 6.1 dan 7.15) |
| 🎙️ Quick Add suara | Mikrofon di Quick Add dan di layar tersendiri, angka bicara seperti "jam tujuh" menjadi deadline |
| 🔔 Pengingat lokal | H-3, H-1, 3 jam, 30 menit, jam tenang 22.00 sampai 06.00, plus ringkasan pagi, malam dan minggu |
| 📅 Layar Hari Ini | Skor urgensi dengan bagian terlambat, hari ini dan minggu ini, plus snackbar undo |
| 📲 Masukan berbagi | Teks yang dibagikan dari WhatsApp atau aplikasi lain dipecah jadi kandidat lalu diparsing sebelum disimpan |
| 🗓️ Kalender | Tampilan bulan dan minggu, jadwal kuliah, kehadiran dengan passing grade kampus (5.19) |
| 🎯 Mode fokus | Maksimal tiga tugas sehari, timer fokus, sisa tugas dibawa ke hari berikutnya (5.24) |
| 🏠 Widget | Empat widget Android yang diberi data lewat `home_widget`, disegarkan dengan debounce 400 ms |
| 💾 Cadangan | Ekspor dan impor JSON, semua data disimpan lokal lewat Drift (SQLite) |
| 🌙 Tampilan | Mode gelap dan dua bahasa, Indonesia bawaan, Inggris sebagai pilihan |

## 🛠️ Persyaratan

- Android 7.0 (API 24) atau lebih baru untuk memasang APK.
- Flutter 3.47.0 dengan Dart 3.13 untuk membangun dari kode sumber.
- JDK 17 dan Android SDK platform 37 untuk build Gradle.
- Sekitar 100 MB di HP untuk aplikasi beserta database dan lampirannya.

## 📥 Instalasi

### Opsi A: APK

Unduh APK sesuai HP dari halaman [Releases](https://github.com/nekonaru/lekas/releases) (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan instalasi dari sumber tidak dikenal bila diminta.

### Opsi B: Bangun dari kode sumber

```bash
git clone https://github.com/nekonaru/lekas.git
cd lekas
flutter pub get
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

Dua APK itu tersimpan di `build/app/outputs/flutter-apk/`.

## 🚀 Cara Pakai

1. **Quick Add**: buka laci, ketuk *Quick Add Suara* untuk mikrofon atau *Tambah Tugas Cepat* untuk papan ketik.
2. **Ketik bebas**: `laprak basdat besok jam tujuh malam #kelompok` menjadi deadline, matkul dan tag lewat chip yang bisa dibuang.
3. **Bagikan dari chat**: bagikan pesan WhatsApp ke Lekas, periksa kandidatnya, simpan sebagai tugas.
4. **Kerjakan dari Hari Ini**: bagian paling atas adalah yang paling mendesak; geser kanan untuk selesai, geser kiri untuk menunda, tekan lama untuk pilih banyak.
5. **Cek kalender**: tampilan bulan, jadwal kuliah dan kehadiran berada satu ketukan dari laci.

## 🌐 Bahasa Tampilan

Indonesia adalah bahasa bawaan. Buka *Pengaturan*, ketuk *Bahasa*, lalu pilih `Indonesia` atau `English`. Pilihan disimpan di tabel `settings` dengan kunci `language` dan membangun ulang seluruh aplikasi lewat `localeProvider`; pengingat, notifikasi dan parser mengikutinya, sehingga parser membaca teks Inggris saat bahasa Inggris dipilih (bagian 8.5).

## 📂 Struktur Proyek

```text
lib/
  core/          tema, utilitas tanggal, konstanta skor, komponen bersama
  data/          database Drift, repository, provider Riverpod, cadangan
  domain/        skor urgensi dan aturan fokus
  features/      satu folder per layar (home, today, quick_add, share_intake, ...)
  l10n/          app_id.arb, app_en.arb dan lokal hasil generate
  parser/        normalizer, ekstraktor waktu, pencocok, kamus per bahasa
  reminders/     layanan pengingat, kebijakan notifikasi, ringkasan berkala
  voice/         pembungkus suara di balik Quick Add suara
test/            tes unit dan widget, satu *_test.dart per area
```

## 🧪 Pengujian

```bash
flutter analyze   # 0 issues
flutter test      # 325 tests
```

CI menjalankan keduanya pada setiap push ke `main` dan membangun APK terpisah, sehingga badge hijau di halaman [Actions](https://github.com/nekonaru/lekas/actions) berarti artefak rilis berhasil dibuat.

## ❓ Tanya Jawab

**Apakah Lekas butuh internet?** Tidak. Semua layar, pengingat dan widget membaca database lokal. Internet hanya terpakai saat Anda membagikan teks dari aplikasi lain ke Lekas.

**Di mana data saya?** Di database aplikasi di HP, ditambah file JSON yang Anda ekspor lewat *Cadangan*.

**Kenapa pengingat saya tidak berbunyi?** Penyebab umumnya optimisasi baterai atau proses latar yang dihentikan sistem. Buka *Cek Pengingat* di laci, pemeriksaan di sana sama dengan yang dilakukan layanan pengingat.

**Bisa mengetik dalam bahasa Inggris?** Bisa. Parser Quick Add membaca dua kamus sekaligus dan bahasa aktif menang saat bentrok, sehingga `lab report db friday 11:59pm` dan `laprak basdat jumat 23.59` mendarat di kolom yang sama.

## ✍️ Penulis

**Nicolas Dwi Dharma** ([@nekonaru](https://github.com/nekonaru))

## 📄 Lisensi

MIT. Lihat [LICENSE](LICENSE).
