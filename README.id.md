<div align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="Logo Lekas" width="110" />
  <h1>Lekas: Pencatat Tugas & Deadline Mahasiswa</h1>
  <p><b>Tangkap tugas dari chat dalam 5 detik, otomatis rapi per matkul,<br/>
  diingatkan dengan benar, dan sepenuhnya offline.</b></p>

  <a href="https://github.com/nekonaru/lekas/releases"><img src="https://img.shields.io/github/v/release/nekonaru/lekas?style=flat-square&color=blue" alt="Rilis" /></a>
  <a href="https://github.com/nekonaru/lekas/actions/workflows/build-apk.yml"><img src="https://github.com/nekonaru/lekas/actions/workflows/build-apk.yml/badge.svg" alt="CI" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.47-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="Lisensi" />
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square" alt="Status" />
</div>

<br />

[English](README.md) | **Bahasa Indonesia**

> [!NOTE]
> Lekas berjalan sepenuhnya di HP Anda. Tanpa akun, tanpa cloud: setiap layar, pengingat dan widget membaca database SQLite lokal, sehingga aplikasi tetap jalan saat sinyal mati.

---

## Daftar Isi

- [Tentang](#tentang)
- [Fitur](#fitur)
- [Persyaratan](#persyaratan)
- [Instalasi](#instalasi)
- [Cara Pakai](#cara-pakai)
- [Bahasa Tampilan](#bahasa-tampilan)
- [Struktur Proyek](#struktur-proyek)
- [Pengembangan](#pengembangan)
- [Pengujian](#pengujian)
- [Integrasi Berkelanjutan](#integrasi-berkelanjutan)
- [Tanya Jawab](#tanya-jawab)
- [Penulis](#penulis)
- [Penafian](#penafian)
- [Lisensi](#lisensi)

---

## Tentang

**Lekas** adalah aplikasi Android offline-first untuk mahasiswa mencatat tugas dan deadline, rapi per matkul, dengan pengingat lokal yang andal. Tanpa akun, tanpa cloud, tanpa kolaborasi: semuanya tersimpan di HP.

Ketik satu baris, parser membaca deadline, matkul dan prioritas. Geser kartu, tugas selesai, dengan undo yang menunggu. Bagikan pesan dari aplikasi chat dan pesan itu menjadi daftar kandidat tugas sebelum ada yang disimpan.

> _"Deadline Anda, terekam dalam lima detik, bahkan tanpa internet."_

---

## Fitur

### Pencatatan

| Fitur | Deskripsi |
|---------|-------------|
| **Quick Add** | Satu kolom, teks Indonesia atau Inggris, chip langsung untuk setiap nilai yang ditebak parser (bagian 6.1 dan 7.15) |
| **Quick Add suara** | Mikrofon di Quick Add dan di layar tersendiri; angka bicara seperti "jam tujuh" menjadi deadline |
| **Masukan berbagi** | Teks yang dibagikan dari WhatsApp atau aplikasi lain dipecah jadi kandidat lalu diparsing sebelum disimpan, tidak ada yang tersimpan otomatis |

### Tugas dan Wadah

| Fitur | Deskripsi |
|---------|-------------|
| **Wadah** | Matkul dan wadah lain dengan warna, kode, alias untuk parser, plus catatan dosen, ruangan dan tautan |
| **Tugas** | Jenis, deadline, prioritas, status, bobot, estimasi, individu atau kelompok, lengkap dengan subtugas, tag dan lampiran |
| **Dependensi tugas** | Prasyarat per tugas; tugas yang terblokir menunggu di bagiannya sendiri, prasyarat yang selesai mengirim satu notifikasi lembut "siap dimulai", dan penyimpanan yang akan membuat lingkaran ditolak |
| **Target pribadi dan prediksi nilai** | Tanggal target sebelum deadline, plus prediksi nilai di dalam wadah |
| **Inbox dan Sampah** | Tangkapan cepat tanpa matkul, serta Sampah yang menyimpan tugas terhapus agar bisa dikembalikan |

### Hari Ini dan Fokus

| Fitur | Deskripsi |
|---------|-------------|
| **Layar Hari Ini** | Skor urgensi dengan bagian terlambat, hari ini, menunggu dan kapan-kapan, plus snackbar undo |
| **Aksi cerdas** | Tekan lama untuk pilih banyak dan aksi massal, geser kanan untuk selesai, geser kiri untuk menunda |
| **Mode fokus** | Maksimal tiga tugas sehari, timer fokus 25/5, dan sisa yang belum muat dibawa ke hari berikutnya (5.24) |

### Kalender dan Kelas

| Fitur | Deskripsi |
|---------|-------------|
| **Kalender** | Tampilan bulan dan minggu, jadwal kuliah, kehadiran dengan passing grade kampus (5.19) |
| **Statistik semester** | Statistik per matkul dan rekap semester di balik laci |

### Pengingat

| Fitur | Deskripsi |
|---------|-------------|
| **Pengingat lokal** | H-3, H-1, 3 jam, 30 menit, jam tenang 22.00 sampai 06.00, plus ringkasan pagi, malam dan minggu |
| **Ringkasan terlambat** | Satu notifikasi per hari pukul 09.00 berisi semua tugas yang melewati deadline |
| **Pemeriksa pengingat** | Layar Cek Pengingat menjalankan pemeriksaan yang sama dengan layanan pengingat saat notifikasi tampak hilang |

### Widget

| Fitur | Deskripsi |
|---------|-------------|
| **Empat widget layar utama** | Daftar tugas dengan kotak centang, kelas hari ini, hitung mundur ujian, fokus hari ini, diberi data lewat `home_widget` dan disegarkan dengan debounce 400 ms |

### Data dan Cadangan

| Fitur | Deskripsi |
|---------|-------------|
| **Cadangan dan pemulihan** | Ekspor dan impor JSON, semua data disimpan lokal lewat Drift (SQLite) |
| **Impor dan gabung** | Menggabungkan cadangan ke database saat ini tanpa menghapus data yang sudah ada |

### Tampilan dan Bahasa

| Fitur | Deskripsi |
|---------|-------------|
| **Antarmuka Inggris dan Indonesia** | Indonesia sebagai bawaan; ganti ke Inggris di Pengaturan |
| **Tema** | Terang, gelap, atau ikuti sistem |

---

## Persyaratan

| Dependensi | Versi Minimum | Catatan |
|------------|-----------------|-------|
| **Flutter** | 3.47 | Kanal stable, hanya untuk membangun dari kode sumber |
| **JDK** | 17 | Hanya untuk membangun dari kode sumber |
| **Android SDK** | API 37 | Hanya untuk membangun dari kode sumber |
| **HP atau emulator Android** | Android 7.0 (API 24) | Untuk menjalankan aplikasi |

> [!TIP]
> Kalau Anda hanya ingin memakai aplikasinya, Anda tidak butuh Flutter, JDK, atau Android SDK. Unduh APK dari halaman [Releases](https://github.com/nekonaru/lekas/releases) saja.

### Belum pernah membuka terminal? Mulai dari sini

<details>
<summary><b>Cara membuka terminal di Windows</b></summary>

1. Tekan tombol **Windows**, ketik `PowerShell`, lalu tekan **Enter**
2. Jendela biru terbuka. Di situ Anda mengetik perintah
3. Setiap perintah `flutter ...` atau `git ...` di panduan ini diketik di jendela itu, lalu **Enter**

</details>

---

## Instalasi

### Opsi A: Unduh APK (paling mudah)

1. Buka halaman [Releases](https://github.com/nekonaru/lekas/releases)
2. Unduh APK sesuai HP Anda (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama)
3. Buka di HP, izinkan instalasi dari sumber tidak dikenal bila diminta

> [!IMPORTANT]
> Berikan izin notifikasi saat aplikasi meminta, kalau tidak pengingat, ringkasan dan ringkasan terlambat tidak akan muncul. Optimisasi baterai untuk Lekas sebaiknya juga dibiarkan tanpa batasan.

### Opsi B: Bangun dari kode sumber (untuk pengembangan / membaca atau mengubah kode)

#### 1. Ambil kode proyeknya

<details>
<summary><b>Saya sudah punya Git</b></summary>

```bash
git clone https://github.com/nekonaru/lekas.git
cd lekas
```

</details>

<details>
<summary><b>Saya belum punya Git</b></summary>

1. Buka halaman repositori di GitHub
2. Tombol hijau **`Code`**, pilih **`Download ZIP`**
3. Ekstrak ZIP ke folder pilihan Anda
4. Di terminal, masuk ke folder hasil ekstrak, contohnya:

```bash
cd Downloads/lekas-main
```

</details>

#### 2. Pasang dependensi dan verifikasi

```bash
flutter pub get
flutter analyze
```

> [!IMPORTANT]
> `flutter analyze` harus melaporkan **No issues found**.

#### 3. Bangun APK-nya

```bash
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

Dua APK itu tersimpan di `build/app/outputs/flutter-apk/`.

---

## Cara Pakai

### Peluncuran pertama

1. Berikan izin notifikasi saat diminta
2. Buat wadah untuk tiap matkul (warna, kode, alias untuk parser), atau lewati dulu dan kerjakan nanti
3. Ketik tugas pertama Anda di Quick Add

### Pemakaian sehari-hari

- Ketik bebas: `laprak basdat besok jam tujuh malam #kelompok` menjadi deadline, matkul dan tag lewat chip yang bisa dibuang
- Bagikan pesan dari aplikasi chat ke Lekas, periksa kandidatnya, simpan sebagai tugas
- Kerjakan dari **Hari Ini**: bagian paling atas adalah yang paling mendesak; geser kanan untuk selesai, geser kiri untuk menunda, tekan lama untuk pilih banyak
- Selesaikan prasyarat, tugas yang menunggu padanya menerima satu notifikasi lembut bahwa ia boleh dimulai
- Cek **Kalender**: tampilan bulan, jadwal kuliah dan kehadiran berada satu ketukan dari laci

---

## Bahasa Tampilan

Antarmuka aplikasi (menu, tombol, pesan dan pengaturan) tersedia dalam **Bahasa Indonesia** (bawaan) dan **English**.

1. Buka **Pengaturan**
2. Di bagian **Bahasa**, pilih `Indonesia` atau `English`
3. Pilihan disimpan di tabel `settings` dengan kunci `language` dan membangun ulang seluruh aplikasi lewat `localeProvider`; pengingat, notifikasi dan parser mengikutinya, sehingga parser membaca teks Inggris saat bahasa Inggris dipilih (bagian 8.5)

---

## Struktur Proyek

```
lekas/
├── lib/
│   ├── main.dart                 # titik masuk, provider, MaterialApp
│   ├── core/                     # tema, utilitas tanggal, konstanta skor, komponen bersama
│   ├── data/                     # database Drift, repository, provider Riverpod, cadangan
│   ├── domain/                   # skor urgensi dan aturan fokus
│   ├── features/                 # satu folder per layar (home, today, quick_add, share_intake, ...)
│   ├── l10n/                     # app_id.arb, app_en.arb dan lokal hasil generate
│   ├── parser/                   # normalizer, ekstraktor waktu, pencocok, kamus per bahasa
│   ├── reminders/                # layanan pengingat, kebijakan notifikasi, ringkasan berkala
│   └── voice/                    # pembungkus suara di balik Quick Add suara
├── test/                         # tes unit dan widget, satu *_test.dart per area
├── l10n.yaml                     # konfigurasi lokalisasi
├── .github/
│   └── workflows/
│       ├── build-apk.yml         # CI: membangun APK terpisah pada setiap push ke main
│       └── release.yml           # CI: analyze, test, bangun dan menerbitkan rilis
├── ARCHITECTURE.md               # struktur dan konvensi
├── CHANGELOG.md                  # catatan rilis dalam bahasa Inggris
├── CHANGELOG.id.md               # catatan rilis dalam Bahasa Indonesia
├── pubspec.yaml
├── LICENSE
├── README.md                     # dokumentasi utama (bahasa Inggris)
└── README.id.md                  # dokumentasi (Bahasa Indonesia)
```

---

## Pengembangan

### Menambahkan string baru untuk pengguna

1. Tambahkan kuncinya ke `lib/l10n/app_id.arb` (Indonesian, template) dan `lib/l10n/app_en.arb` (Inggris)
2. Jalankan `flutter gen-l10n`
3. Pakai lewat `AppLocalizations.of(context)!.yourKey`

> [!WARNING]
> Berkas `lib/l10n/app_localizations*.dart` adalah hasil generate. Jangan mengeditnya langsung, ubah berkas `.arb` lalu jalankan `flutter gen-l10n`.

---

## Pengujian

Verifikasi sebelum setiap push, keduanya harus bersih:

```bash
flutter analyze
flutter test
```

| Pemeriksaan | Persyaratan |
|-------|-------------|
| `flutter analyze` | Harus melaporkan **No issues found** (nol error, nol peringatan) |
| `flutter test` | Harus lulus suite penuh (428 tes) |

Lint ditegakkan lewat `analysis_options.yaml` (flutter_lints plus `prefer_single_quotes`).

---

## Integrasi Berkelanjutan

| Alur kerja | Tujuan |
|----------|---------|
| `build-apk.yml` | Membangun APK terpisah pada setiap push ke main |
| `release.yml` | Saat tag `v*`: mencocokkan tag dengan versi pubspec, analyze, test, membangun APK terpisah, lalu menerbitkan rilis GitHub dengan catatan dwibahasa dari `CHANGELOG.md` |

---

## Tanya Jawab

<details>
<summary><b>Apakah Lekas butuh internet?</b></summary>

Tidak. Semua layar, pengingat dan widget membaca database SQLite lokal. Internet hanya terpakai saat Anda membagikan teks dari aplikasi lain ke Lekas, atau oleh pengenal suara saat Anda memakai Quick Add suara.

</details>

<details>
<summary><b>Di mana data saya?</b></summary>

Di database aplikasi di HP, ditambah file JSON yang Anda ekspor lewat *Cadangan*.

</details>

<details>
<summary><b>Kenapa pengingat saya tidak berbunyi?</b></summary>

Penyebab umumnya optimisasi baterai atau proses latar yang dihentikan sistem. Buka *Cek Pengingat* di laci, pemeriksaan di sana sama dengan yang dilakukan layanan pengingat.

</details>

<details>
<summary><b>Bisa mengetik dalam bahasa Inggris?</b></summary>

Bisa. Parser Quick Add membaca dua kamus sekaligus dan bahasa aktif menang saat bentrok, sehingga `lab report db friday 11:59pm` dan `laprak basdat jumat 23.59` mendarat di kolom yang sama.

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

## Penafian

Lekas adalah proyek open-source independen dan tidak berafiliasi atau didukung oleh Google, WhatsApp, atau Meta. Pengingat, ringkasan dan widget bergantung pada kebijakan latar Android, sehingga optimisasi baterai atau proses yang dihentikan bisa menundanya; layar *Cek Pengingat* ada untuk membantu Anda menemukan penyebabnya.

---

## Lisensi

Didistribusikan di bawah **Lisensi MIT**. Lihat [`LICENSE`](LICENSE) untuk informasi lebih lanjut.
