<div align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="Lekas logo" width="120" />
  <h1>Lekas: Pencatat Tugas & Deadline untuk Mahasiswa</h1>
  <p><b>Lacak tugas dan deadline mahasiswa secara offline-first,<br/>
  tangkap dari chat dalam 5 detik, sepenuhnya offline.</b></p>

  <a href="https://github.com/nekonaru/lekas/releases"><img src="https://img.shields.io/github/v/release/nekonaru/lekas?style=flat-square&color=blue" alt="Release" /></a>
  <a href="https://github.com/nekonaru/lekas/actions/workflows/build-apk.yml"><img src="https://github.com/nekonaru/lekas/actions/workflows/build-apk.yml/badge.svg" alt="CI" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.47-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square" alt="Status" />
</div>

<br />

[English](README.md) | **Bahasa Indonesia**

> [!NOTE]
> Lekas berjalan sepenuhnya di ponselmu. Tidak ada akun dan tidak ada cloud: setiap layar, pengingat, dan widget membaca database SQLite lokal, jadi aplikasi tetap berfungsi dengan radio dimatikan.

---

## Daftar Isi

- [Tentang](#tentang)
- [Fitur](#fitur)
- [Persyaratan](#persyaratan)
- [Instalasi](#instalasi)
- [Penggunaan](#penggunaan)
- [Bahasa Tampilan](#bahasa-tampilan)
- [Struktur Proyek](#struktur-proyek)
- [Pengembangan](#pengembangan)
- [Pengujian](#pengujian)
- [Keamanan](#keamanan)
- [Continuous Integration](#continuous-integration)
- [FAQ](#faq)
- [Penulis](#penulis)
- [Disclaimer](#disclaimer)
- [Lisensi](#lisensi)

---

## Tentang

**Lekas** adalah aplikasi Android offline-first untuk mahasiswa mencatat tugas dan deadline, tertata per mata kuliah, dengan pengingat lokal yang andal. Tanpa akun, tanpa cloud, tanpa kolaborasi: semuanya tetap di ponselmu.

Ketik satu baris dan parser membaca deadline, mata kuliah, dan prioritasnya. Geser sebuah kartu dan tugas selesai, dengan undo yang siap menunggu. Bagikan pesan dari aplikasi chat dan pesan itu menjadi daftar kandidat tugas sebelum apa pun disimpan.

> _"Deadline-mu, tercatat dalam lima detik, bahkan tanpa internet."_

---

## Fitur

### Pencatatan

| Fitur | Deskripsi |
|-------|-----------|
| **Quick Add** | Satu kolom, teks bahasa Indonesia atau Inggris, chip langsung untuk setiap nilai yang ditebak parser (desain 6.1 dan 7.15) |
| **Voice Quick Add** | Mikrofon di Quick Add dan di layarnya sendiri; angka yang diucapkan seperti "jam tujuh" menjadi deadline |
| **Frasa tanggal alami** | Mengerti bulan depan, akhir bulan, tahun depan beserta versi Inggrisnya, dengan penyesuaian untuk bulan pendek dan tahun kabisat |
| **Share intake** | Teks yang dibagikan dari WhatsApp atau aplikasi apa pun dipecah menjadi kandidat dan diurai sebelum disimpan, tidak ada yang tersimpan otomatis |

### Tugas, Kategori dan Semester

| Fitur | Deskripsi |
|-------|-----------|
| **Kategori** | Wadah bebas bernama apa pun (organisasi, kepanitiaan, komunitas); menyimpan warna, tugas, dan aksi kelolanya sendiri, plus baris tanpa kategori untuk tugas yang belum punya tempat |
| **Mata kuliah** | Wadah terikat semester dengan kehadiran, jadwal kelas yang bisa diedit, daftar bawaan per mata kuliah, prediksi nilai, dan folder berkas sendiri |
| **Mode SMA** | Alih jenjang ke SMA mengubah mata kuliah menjadi mata pelajaran dengan Kelas (10, 11, atau 12) yang dipilih di form ruang, tampil di halaman mata pelajaran, dan memakai istilah sekolah di semua tempat (Kelola Mata Pelajaran, Mata Pelajaran Semester Ini); contoh data berisi Matematika dengan nilai |
| **Buku Nilai (SMA)** | Log nilai per mata pelajaran dengan rata-rata langsung (memakai bobot komponen bila ada), verdict KKM hijau atau merah, dan pengaturan KKM yang bisa diubah |
| **Rapor (SMA)** | Layar Rapor di tab Semester: semua mata pelajaran semester aktif dengan rata-ratanya, verdict KKM, dan jumlah kehadiran, rata-rata semester di atas, serta satu ketuk untuk membagikan rapor sebagai teks |
| **Semester** | Tab semester aktif: hero dengan jumlah mata kuliah, progres tugas, dan lencana terlambat, daftar mata kuliah, semester lain sekali ketuk; buat, ubah nama, aktifkan, dan hapus semester (mata kuliahnya ikut terhapus, tugasnya pindah ke Inbox) |
| **Tugas** | Tipe, deadline, prioritas, status, bobot, estimasi, individu atau kelompok, dengan subtugas, tag, dan lampiran |
| **Filter dan pengelompokan tugas** | Kategori, status (belum selesai atau selesai), dan urutan (deadline terdekat atau terjauh, terbaru dibuat, prioritas tertinggi) dalam satu sheet filter; opsi pengelompokan per kategori dengan jumlah per grup |
| **Cari semua data** | Satu entri di drawer mencari tugas, kartu belajar, kebiasaan, dan mata pelajaran dengan hasil dikelompokkan dan satu ketukan ke layar yang bersangkutan |
| **Refleksi harian** | Rekap akhir hari yang bisa dibagikan: tugas selesai, tugas terlambat, menit fokus, dan kebiasaan |
| **Akurasi estimasi** | Statistik Belajar membandingkan menit yang direncanakan dengan menit fokus yang benar-benar tercatat |
| **Streak belajar** | Satu hari dihitung saat kamu menyelesaikan tugas, menjalankan sesi fokus, atau mencentang kebiasaan |
| **Jeda setelah fokus** | Istirahat lima menit otomatis setelah sesi fokus, dengan tombol lewati |
| **Berkas per mata kuliah** | Modul, catatan, soal, dan arsip di pohon folder sungguhan pada penyimpanan HP; setiap mata kuliah punya subfolder sendiri, terlihat oleh file manager apa pun |
| **Kehadiran per mata kuliah** | Tandai hadir, absen, izin, atau sakit per pertemuan; setiap catatan lama bisa diubah atau dihapus |
| **Daftar bawaan per mata kuliah** | Bisa diedit, diurutkan ulang, dan dicentang per item |
| **Dependensi tugas** | Prasyarat per tugas; tugas yang terblokir menunggu di bagian tersendiri, prasyarat yang selesai mengirim satu pemberitahuan lembut "siap dimulai", dan penyimpanan yang akan membentuk putaran ditolak |
| **Target pribadi dan prediksi nilai** | Tanggal target sebelum deadline, plus prediksi nilai di dalam sebuah space |
| **Inbox dan tempat sampah** | Pencatatan cepat tanpa mata kuliah (baris Tanpa Kategori di tab Kategori), dan tempat sampah yang membuat tugas terhapus tetap bisa dipulihkan |
| **Tugas berulang** | Berulang harian, mingguan, atau bulanan; mencentang selesai di Hari Ini membuat tugas berikutnya dengan ritme yang sama |
| **Tampilan pencarian tersimpan** | Simpan query, kategori, jenis, status, dan urutan sebagai tampilan dan buka kembali dengan satu ketukan dari Tampilan Tersimpan |
| **Tautan cepat** | Tautan buatanmu di drawer ke situs yang biasa kamu buka (portal, e-learning, perpustakaan), tersimpan dan terbuka lewat channel platform |

### Hari Ini dan Fokus

| Fitur | Deskripsi |
|-------|-----------|
| **Layar Hari Ini** | Skor urgensi dengan bagian terlambat, hari ini, menunggu, dan suatu hari nanti, plus snackbar undo; setiap kartu membawa nama kategori atau mata kuliahnya |
| **Aksi cerdas** | Tekan lama untuk pilih banyak dan aksi massal, geser kanan untuk menyelesaikan, geser kiri untuk menunda |
| **Mode fokus** | Maksimal tiga tugas per hari, timer fokus 25/5, dan yang tidak muat dibawa ke hari berikutnya (5.24) |
| **Pelacak kebiasaan** | Kebiasaan: centang kebiasaan harian dengan grid 7 hari, hari libur tekan-lama yang menjaga streak, heatmap centangan 90 hari, pengingat harian opsional dengan jam pilihan, dan total mingguan di bagian Belajar pada drawer |
| **Kartu belajar di Hari Ini** | Banner yang bisa ditutup muncul di Hari Ini saat kartu jatuh tempo |

### Belajar

| Fitur | Deskripsi |
|-------|-----------|
| **Kartu Belajar** | Deck umum plus satu deck per mata pelajaran dengan pengulangan berjeda (SM-2); ketuk untuk membalik, nilai Lupa, Sulit, atau Mudah, jumlah jatuh tempo terlihat per deck, ekspor/impor CSV per deck, dan pengingat ulasan harian opsional |
| **Timer fokus** | Timer 15, 25, atau 45 menit di dalam mode Fokus yang mencatat setiap sesi |
| **Statistik Belajar** | Menit fokus hari ini dan 7 hari terakhir, hari beruntun dengan tugas selesai, grafik batang 14 hari, peta aktivitas 90 hari, fokus per mata pelajaran, dan total kartu |
| **Ekspor CSV nilai** | Bagikan log nilai mata pelajaran sebagai file CSV untuk spreadsheet |
| **Skor perbandingan mingguan** | Statistik Belajar membandingkan minggu ini dengan minggu lalu lewat delta berwarna untuk menit fokus dan tugas selesai |
| **Target belajar mingguan** | Target yang bisa diubah untuk jumlah tugas selesai dan menit fokus, dengan batang progres dari datamu sendiri |

### Kalender dan Kelas

| Fitur | Deskripsi |
|-------|-----------|
| **Kalender** | Grid bulan dengan penanda kelas dan tugas; ketuk hari mana pun untuk melihat agendanya di bawah: kelas dengan jam dan ruang, tugas yang jatuh tempo, satu ketukan ke daftar lengkap atau ke detail tugas |
| **Jadwal kelas** | Jadwal terkelompok per hari dengan entri yang bisa diedit, ruang, dan jenis (kuliah atau praktikum), terhubung dengan penanda kalender |
| **Statistik semester** | Statistik per mata kuliah dan rekap semester di balik drawer |

### Pengingat

| Fitur | Deskripsi |
|-------|-----------|
| **Pengingat lokal** | H-3, H-1, 3 jam, 30 menit, jam tenang pukul 22.00 sampai 06.00, plus ringkasan pagi, malam, dan mingguan |
| **Rangkuman terlambat** | Satu notifikasi per hari pukul 09:00 yang mendaftar setiap tugas yang lewat deadline |
| **Pemeriksa pengingat** | Layar Cek Pengingat menjalankan pemeriksaan yang sama dengan layanan pengingat saat notifikasi terasa hilang |

### Widget

| Fitur | Deskripsi |
|-------|-----------|
| **Empat widget layar utama** | Daftar tugas dengan checkbox, kelas hari ini, hitung mundur ujian, fokus hari ini, disuplai lewat `home_widget` dan diperbarui dengan debounce 400 ms |

### Data dan Cadangan

| Fitur | Deskripsi |
|-------|-----------|
| **Ekspor kalender (.ics)** | Setiap tugas yang belum selesai menjadi event sehari penuh dan setiap kelas mingguan menjadi event berulang; filenya bisa dibuka di Google Calendar, Apple Calendar, Outlook, atau aplikasi apa pun yang membaca .ics |
| **Impor kalender (.ics)** | File .ics berubah menjadi tugas di inbox, ditinjau dulu sebelum diimpor, dibatasi 500 kejadian |
| **Ekspor spreadsheet (.csv)** | Setiap tugas sebagai baris spreadsheet dengan judul, deadline, prioritas, status, ruang, bobot, dan tag |
| **Impor spreadsheet (.csv)** | Impor CSV dengan kolom title; tag yang dipisah titik koma dibuat saat impor, dibatasi 1000 baris |
| **Cadangkan dan pulihkan** | Ekspor dan impor JSON, semuanya disimpan lokal dengan Drift (SQLite) |
| **Impor dan gabung** | Gabungkan cadangan ke database saat ini tanpa kehilangan yang sudah ada |
| **Periksa pembaruan** | Settings menampilkan versi terpasang; ketuk untuk memeriksa rilis terbaru di GitHub. Pemeriksaan senyap sekali sehari berjalan saat membuka aplikasi (bisa dimatikan di Pengaturan) dan hanya berbicara saat ada versi baru |
| **Dukung Lekas** | Tautan sponsor di Pengaturan: GitHub Sponsors, Saweria, SociaBuzz, dan BagiBagi, semua https, semuanya terbuka lewat channel platform |

### Tampilan dan Bahasa

| Fitur | Deskripsi |
|-------|-----------|
| **Antarmuka Indonesia dan Inggris** | Indonesia secara default; ganti ke English di Pengaturan |
| **Pengaturan terkelompok** | Pengaturan terbuka dengan header brand (mark, tagline, chip versi) dan kartu membulat dengan ikon berwarna: Tampilan, Pengingat, Cadangan, Alat, Pintasan, Sekolah, Sponsor, dan Tentang |
| **Tema** | Terang, gelap, atau ikuti sistem |

---

## Persyaratan

| Dependensi | Versi Minimum | Catatan |
|------------|---------------|---------|
| **Flutter** | 3.47 | Channel stable, hanya diperlukan untuk build dari source |
| **JDK** | 17 | Hanya diperlukan untuk build dari source |
| **Android SDK** | API 37 | Hanya diperlukan untuk build dari source |
| **Ponsel atau emulator Android** | Android 7.0 (API 24) | Diperlukan untuk menjalankan aplikasi |

> [!TIP]
> Kalau kamu hanya ingin memakai aplikasinya, kamu tidak perlu Flutter, JDK, atau Android SDK. Unduh APK dari halaman [Releases](https://github.com/nekonaru/lekas/releases).

### Belum pernah memakai terminal? Mulai dari sini

<details>
<summary><b>Cara membuka terminal di Windows</b></summary>

1. Tekan tombol **Windows**, ketik `PowerShell`, lalu tekan **Enter**
2. Jendela biru akan terbuka. Di situlah kamu mengetik perintah
3. Setiap perintah `flutter ...` atau `git ...` di panduan ini diketik di jendela itu, diikuti **Enter**

</details>

---

## Instalasi

### Opsi A: Unduh APK (paling mudah)

1. Buka halaman [Releases](https://github.com/nekonaru/lekas/releases)
2. Unduh APK yang sesuai dengan perangkatmu (`app-arm64-v8a-release.apk` untuk kebanyakan ponsel modern, `app-armeabi-v7a-release.apk` untuk ponsel 32-bit yang lebih lama)
3. Buka di ponselmu, izinkan instalasi dari sumber tidak dikenal jika diminta

> [!IMPORTANT]
> Berikan izin notifikasi saat aplikasi pertama kali memintanya, kalau tidak pengingat, ringkasan, dan rangkuman terlambat tidak bisa muncul. Optimasi baterai juga sebaiknya dibiarkan tanpa batasan untuk Lekas.

### Opsi B: Build dari source (untuk pengembangan / membaca atau mengubah kode)

#### 1. Ambil kode proyek

<details>
<summary><b>Saya sudah menginstal Git</b></summary>

```bash
git clone https://github.com/nekonaru/lekas.git
cd lekas
```

</details>

<details>
<summary><b>Saya belum punya Git</b></summary>

1. Buka halaman repositori di GitHub
2. Klik tombol hijau **`Code`**, pilih **`Download ZIP`**
3. Ekstrak ZIP ke folder pilihanmu
4. Di terminal, masuk ke folder hasil ekstrak, contohnya:

```bash
cd Downloads/lekas-main
```

</details>

#### 2. Instal dependensi dan verifikasi

```bash
flutter pub get
flutter analyze
```

> [!IMPORTANT]
> `flutter analyze` harus melaporkan **No issues found**.

#### 3. Build APK

```bash
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

Kedua APK berada di `build/app/outputs/flutter-apk/`.

---

## Penggunaan

### Pertama kali dibuka

1. Izinkan notifikasi saat diminta
2. Buat sebuah space untuk setiap mata kuliah (warna, kode, alias untuk parser), atau lewati dan lakukan nanti
3. Ketik tugas pertamamu di Quick Add

### Penggunaan sehari-hari

- Ketik secara natural: `laprak basdat besok jam tujuh malam #kelompok` menjadi deadline, mata kuliah, dan tag dengan chip yang bisa kamu hapus
- Bagikan pesan dari aplikasi chat ke Lekas, tinjau kandidatnya, simpan sebagai tugas
- Kerjakan dari **Hari Ini**: bagian teratas daftar adalah yang paling mendesak; geser kanan untuk menyelesaikan, geser kiri untuk menunda, tekan lama untuk pilih banyak
- Selesaikan sebuah prasyarat dan tugas yang menunggunya mendapat satu notifikasi lembut bahwa tugas itu sudah bisa dimulai
- Cek **Kalender**: tampilan bulan, jadwal kuliah, dan presensi hanya satu ketukan drawer jauhnya

---

## Bahasa Tampilan

Antarmuka aplikasi (menu, tombol, pesan, dan pengaturan) tersedia dalam **Bahasa Indonesia** (default) dan **English**.

1. Buka **Pengaturan**
2. Di bawah **Bahasa**, pilih **Indonesia** atau **English**
3. Pilihan disimpan di tabel `settings` dengan key `language` dan membangun ulang seluruh aplikasi lewat `localeProvider`; pengingat, notifikasi, dan parser mengikutinya, jadi parser membaca teks bahasa Inggris saat English dipilih (desain bagian 8.5)

---

## Struktur Proyek

```
lekas/
├── lib/
│   ├── main.dart                 # entry point, provider, MaterialApp
│   ├── core/                     # tema, pembantu tanggal, konstanta skor, komponen bersama
│   ├── data/                     # database Drift, repository, provider Riverpod, cadangan
│   ├── domain/                   # skor urgensi dan aturan fokus
│   ├── features/                 # satu folder per layar (home, today, quick_add, share_intake, ...)
│   ├── l10n/                     # app_id.arb, app_en.arb, dan lokalisasi hasil generate
│   ├── lock/                     # kunci aplikasi: hash PIN, layanan, layar buka kunci
│   ├── parser/                   # normalizer, time extractor, matcher, kamus per bahasa
│   ├── reminders/                # layanan pengingat, kebijakan notifikasi, rangkuman digest
│   └── voice/                    # pembungkus speech di balik Voice Quick Add
├── test/                         # unit dan widget test, satu *_test.dart per area
├── tool/                         # generator logo, subset font, audit glif
├── l10n.yaml                     # konfigurasi lokalisasi
├── .github/
│   └── workflows/
│       ├── build-apk.yml         # CI: build APK terpisah di setiap push ke main
│       └── release.yml           # CI: analyze, test, build, dan publikasikan rilis
├── ARCHITECTURE.md               # struktur dan konvensi
├── CHANGELOG.md                  # catatan rilis dalam bahasa Inggris
├── CHANGELOG.id.md               # catatan rilis dalam Bahasa Indonesia
├── pubspec.yaml
├── LICENSE
├── README.md                     # dokumentasi utama (Inggris)
└── README.id.md                  # dokumentasi (Bahasa Indonesia)
```

---

## Pengembangan

### Menambah string baru untuk pengguna

1. Tambahkan key ke `lib/l10n/app_id.arb` (Indonesia, sebagai template) dan `lib/l10n/app_en.arb` (Inggris)
2. Jalankan `flutter gen-l10n`
3. Gunakan lewat `AppLocalizations.of(context)!.yourKey`

> [!WARNING]
> File `lib/l10n/app_localizations*.dart` dihasilkan otomatis. Jangan diedit manual, ubah file `.arb` lalu jalankan `flutter gen-l10n`.

---

## Pengujian

Verifikasi sebelum setiap push, keduanya harus bersih:

```bash
flutter analyze
flutter test
```

| Pemeriksaan | Syarat |
|-------------|--------|
| `flutter analyze` | Harus melaporkan **No issues found** (nol error, nol warning) |
| `flutter test` | Seluruh suite harus lulus (596 tes) |

Lint ditegakkan lewat `analysis_options.yaml` (flutter_lints plus `prefer_single_quotes`).

---

## Keamanan

Lekas menyimpan data kamu secara lokal: tugas, wadah, pengaturan, dan lampiran berada dalam database SQLite melalui Drift, dan file cadangan yang kamu ekspor berupa JSON polos. Satu-satunya panggilan jaringan yang dilakukan aplikasi adalah pemeriksaan pembaruan opsional ke API publik GitHub, saat kamu ketuk atau sekali sehari saat membuka aplikasi (bisa dimatikan di Pengaturan), yang tidak mengirim apa pun selain permintaannya. Aplikasi tidak membawa SDK analitik, iklan, atau pelaporan crash, dan hanya meminta izin notifikasi, alarm tepat, getaran, mikrofon, dan speech. Kunci aplikasi opsional menyimpan hash SHA-256 ber-salt dari PIN kamu, bukan PIN-nya sendiri.

> [!NOTE]
> Menemukan masalah keamanan? Laporkan lewat rute privat di [`SECURITY.md`](SECURITY.md) supaya bisa diperbaiki sebelum dipublikasikan.

---

## Continuous Integration

| Workflow | Fungsi |
|----------|--------|
| `build-apk.yml` | Build APK terpisah di setiap push ke main |
| `release.yml` | Pada tag `v*`: cocokkan tag dengan versi pubspec, analyze, test, build APK terpisah, lalu publikasikan rilis GitHub dengan catatan dua bahasa yang diambil dari `CHANGELOG.md` |

---

## FAQ

<details>
<summary><b>Apakah Lekas butuh internet?</b></summary>

Tidak. Setiap layar, pengingat, dan widget membaca database SQLite lokal. Internet hanya dipakai jika kamu membagikan teks ke aplikasi dari aplikasi lain, atau oleh speech recognizer saat kamu memakai Voice Quick Add.

</details>

<details>
<summary><b>Di mana datamu?</b></summary>

Di database aplikasi pada ponsel, plus file JSON apa pun yang kamu ekspor ke *Cadangan*.

</details>

<details>
<summary><b>Kenapa pengingatku tidak berbunyi?</b></summary>

Penyebab yang biasa adalah optimasi baterai atau proses latar belakang yang dimatikan. Buka *Cek Pengingat* di drawer, layar itu menjalankan pemeriksaan yang sama dengan layanan pengingat.

</details>

<details>
<summary><b>Bisakah mengetik dalam bahasa Inggris?</b></summary>

Bisa. Parser Quick Add menggabungkan kedua kamus dan bahasa yang aktif menang saat ada konflik, jadi `lab report db friday 11:59pm` dan `laprak basdat jumat 23.59` mendarat di kolom yang sama.

</details>

---

## Penulis

<div align="center">

| [![Nicolas Dwi Dharma](https://github.com/nekonaru.png?size=100)](https://github.com/nekonaru) |
|:---:|
| **Nicolas Dwi Dharma** |
| [github.com/nekonaru](https://github.com/nekonaru) |

</div>

---

## Disclaimer

Lekas adalah proyek open-source independen dan tidak berafiliasi dengan atau didukung oleh Google, WhatsApp, atau Meta. Pengingat, ringkasan, dan widget bergantung pada kebijakan latar belakang Android, jadi optimasi baterai atau proses yang dimatikan bisa menundanya; layar *Cek Pengingat* ada untuk membantumu menemukan penyebabnya.

---

## Lisensi

Didistribusikan di bawah **Lisensi MIT**. Lihat [`LICENSE`](LICENSE) untuk informasi lebih lanjut.
