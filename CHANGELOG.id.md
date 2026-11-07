# Changelog

Semua perubahan penting pada Lekas. Versi terbaru di paling atas.

## v1.4.2 - Perbaikan layar hitam setelah setup

### Perbaikan bug

- **Tidak ada lagi layar hitam setelah setup.** Menyelesaikan rangkaian awal menutup route akar, sehingga navigator kosong dan layar hitam di HP asli. Setup kini langsung berpindah ke layar utama di tempat, tanpa frame kosong di antaranya.
- **Pilihan bahasa di setup langsung bereaksi.** Tombol bahasa dan jenjang kini menunjukkan opsi yang dipilih (terisi dengan tanda centang) dengan transisi silang antar status, dan bahasa yang dipilih langsung diterapkan, bukan hanya di langkah terakhir.

### Instalasi / Update

Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan instalasi dari sumber tidak dikenal bila diminta. Minimum Android 7.0 (API 24).

## v1.4.1 - Perbaikan crash saat dibuka pada build release

### Perbaikan bug

- **Tidak ada lagi force close saat dibuka.** Penyusut build release memotong kelas database WorkManager yang Android inisialisasi sebelum frame pertama, sehingga APK release mati begitu dibuka di HP asli sementara build debug tetap jalan. Kelas tersebut kini dijaga, dan aplikasi terbuka normal.

### Instalasi / Update

Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan instalasi dari sumber tidak dikenal bila diminta. Minimum Android 7.0 (API 24).

## v1.4.0 - Preset tema dan transisi hero

### Fitur baru

- **Preset tema.** Satu ketukan menerapkan tampilan utuh: Tengah malam beralih ke indigo gelap, Senja menghangatkan aplikasi dengan oranye, Hutan mendinginkan dengan hijau emerald, dan Bawaan mengembalikan semuanya ke gaya asli.
- **Pratinjau terang dan gelap.** Pemilih warna menunjukkan hasil setiap warna di kedua mode terang sebelum kamu memilihnya, dengan swatch dari palet asli yang dihasilkan.

### Optimisasi

- **Transisi hero.** Membuka tugas dari Today membawa judulnya ke layar detail dan kembali sebagai satu gerakan menyambung.
- **Transisi lebih aman.** Hanya daftar Today yang memakai penerbangan hero, sehingga layar yang bertumpuk tidak pernah bertabrakan pada tag yang sama.

### Instalasi / Update

Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan instalasi dari sumber tidak dikenal bila diminta. Minimum Android 7.0 (API 24).

## v1.3.0 - Warna kustom, ukuran font, dan Inter

### Fitur baru

- **Warna aksen.** Pilih warna seluruh aplikasi di Pengaturan: dua belas pilihan plus indigo bawaan, langsung berlaku di semua layar dan kontrol.
- **Ukuran font.** Empat pilihan ukuran teks yang mengalikan skala aksesibilitas HP, jadi pengaturan sistem tetap jalan di bawahnya.
- **Tipografi Inter.** Aplikasi membawa huruf Inter dalam empat ketebalan, memberi judul, kartu dan chip tampilan yang rapi dan khas.

### Optimisasi

- **Tombol tambah sadar gulir.** Tombol tambah bergeser menghilang saat menggulir ke bawah dan kembali pada guliran pertama ke atas.
- **Hitungan seksi.** Setiap judul seksi di Today menampilkan jumlah tugasnya dalam pill kecil.
- **Masuk yang lembut.** Layar Today yang kosong tampil dengan fade dan skala sekali, bukan muncul mendadak.
- **Pembangunan ulang lebih ramping.** Kartu menerima skor urgensi yang sudah dihitung, dan daftar melepas keep alive otomatis.

### Instalasi / Update

Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan instalasi dari sumber tidak dikenal bila diminta. Minimum Android 7.0 (API 24).

## v1.2.0 - Antarmuka lebih halus dan daftar lebih ringan

### Optimisasi

- **Gerak bersama.** Pindah tab, buka halaman dan aksi kartu kini memakai satu kurva dan durasi yang sama, sehingga semua gerakan terasa tenang dan konsisten.
- **Animasi seleksi.** Menandai tugas dalam mode multi pilih menampilkan centang dengan crossfade di atas titik prioritas, bukan berganti seketika.
- **Permukaan modern.** Kartu, snackbar, dialog, bottom sheet dan kolom form memakai satu bahasa bentuk Material 3, dan semua modal sheet kini punya drag handle.
- **Drawer lebih tenang.** Drawer dibuka dengan header ringkas berlogo, bukan blok abu besar.
- **Layar kosong lebih ramah.** Today yang kosong menampilkan ikon centang berwarna dan judul di tengah, bukan glif abu.
- **Daftar lebih ringan.** Skor urgensi tampil dalam pill kecil, gerak swipe berbentuk rounded seperti kartu, dan tugas terakhir tergulir bebas dari tombol aksi.

### Instalasi / Update

Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan instalasi dari sumber tidak dikenal bila diminta. Minimum Android 7.0 (API 24).

## v1.1.0 - Dependensi tugas dan Quick Add yang lebih pintar

### Fitur baru

- **Dependensi tugas.** Sebuah tugas bisa mewajibkan tugas lain selesai dulu: tugas yang terblokir menunggu di bagiannya sendiri, prasyarat yang selesai mengirim satu pemberitahuan "siap dimulai", dan penyimpanan yang akan membentuk lingkaran ditolak.
- **Layar jadi masuk menu.** Spaces, kalender, statistik, cadangan, trash dan pemeriksa pengingat semuanya bisa dibuka dari drawer dan pengaturan.
- **Tempel papan klip di share intake.** Beberapa baris papan klip menjadi satu kandidat per baris, ditambahkan hanya saat kamu ketuk.
- **Chip ulang di Quick Add.** Satu ketukan menyalin space, jenis dan jam tenggat dari tugas terakhir.
- **Saran tugas serupa.** Judul yang mirip tugas lama menawarkan subtugas dan estimasinya sebagai chip.

### Perbaikan bug

- **Buka ulang dari layar detail.** Membuka ulang tugas selesai dari halaman detailnya berfungsi lagi.
- **Drawer tertutup sebelum navigasi.** Membuka layar dari drawer utama tidak lagi meninggalkan drawer di belakangnya.
- **Tombol kembali di trash.** Layar trash bisa ditutup dengan panah kembali seperti layar lain.

### Instalasi / Update

Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan instalasi dari sumber tidak dikenal bila diminta. Minimum Android 7.0 (API 24).

## v1.0.1 - Perbaikan stabilitas dan kecepatan

### Optimisasi

- **Layar utama lebih dulu.** Aplikasi kini langsung menggambar layar utama dan mengisi jadwal pengingat di belakangnya, bukan selalu membuka dengan spinner.
- **Hanya kartu terlihat yang dibangun.** Daftar Hari Ini menata satu kartu pada satu waktu, sehingga daftar panjang tetap lancar dan setiap tap tidak lagi membangun ulang seluruh layar.
- **Satu stream per kueri.** Setiap panggilan watch memakai ulang satu stream kueri yang sama, sehingga spinner berkedip berhenti dan database tidak dikueri ulang tiap render.

### Perbaikan bug

- **Tidak crash setelah update.** Penerima reboot dan update aplikasi kini mencatat kegagalan reschedule pengingat sebagai log, alih-alih mematikan seluruh aplikasi.
- **Wadah yang dihapus tidak menjatuhkan filter.** Mencari saat wadah yang difilter dihapus kini tetap membuka daftar, bukan melempar error.
- **Hapus permanen ikut membersihkan.** Menghapus tugas selamanya juga menghapus subtugas, tag, lampiran, pengingat dan baris anak lainnya.
- **Tanggal terbaca di daftar tugas.** Subjudul menampilkan tanggal terformat, bukan stempel waktu mentah sampai milidetik.
- **Detail tugas bisa digulir.** Layar detail menggulir di layar pendek dan landscape, dan badge panjang membungkus alih-alih keluar tepi.
- **Keterlambatan dihitung per hari penuh.** Tugas tempo kemarin menampilkan "1 hari telat", bukan "0".
- **Start up selamat dari rute rusak.** Rute yang gagal dibaca saat awal kini jatuh ke layar utama, bukan crash.
- **Tulisan lambat tak menyentuh layar tertutup.** Tiga pemilih di Pengaturan dan Quick Add kini berhenti setelah layarnya hilang.

### Instalasi / Update

Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan instalasi dari sumber tidak dikenal bila diminta. Minimum Android 7.0 (API 24).

## v1.0.0 - Rilis publik pertama

### Fitur baru

- **Parser Quick Add.** Satu baris teks Indonesia atau Inggris menjadi deadline, matkul, prioritas, tag, subtugas, estimasi dan tautan, semuanya tampil sebagai chip yang boleh dipertahankan atau dibuang (bagian 6.1 dan 7.15).
- **Quick Add suara.** Mikrofon duduk di Quick Add dan di layar tersendiri, dan angka bicara seperti "jam tujuh malam" menjadi deadline (bagian 7.1).
- **Pengingat lokal.** H-3, H-1, 3 jam dan 30 menit sebelum deadline, jam tenang 22.00 sampai 06.00, plus ringkasan pagi, malam dan minggu (bagian 5.4 dan 5.22).
- **Layar Hari Ini.** Skor urgensi dengan bagian terlambat, hari ini dan minggu ini, geser kanan untuk selesai dengan undo, geser kiri untuk menunda, tekan lama untuk pilih banyak (bagian 5.2 dan 5.6).
- **Masukan berbagi.** Teks yang dibagikan dari WhatsApp atau aplikasi lain dipecah jadi kandidat lalu diparsing sebelum menjadi tugas (bagian 6.2).
- **Empat widget layar utama.** Hitung mundur ujian, daftar hari ini, tombol tambah cepat dan kelas berikutnya, semua lewat `home_widget` (bagian 7.8).
- **Kehadiran dan fokus.** Presensi kelas dengan passing grade kampus, peringatan kuota izin, dan mode fokus maksimal tiga tugas sehari (bagian 5.19 dan 5.24).
- **Dua bahasa dan mode gelap.** Indonesia bawaan, Inggris sebagai pilihan, baik di antarmuka maupun di parser (bagian 8).

### Optimisasi

- **Ringkasan dibangun saat sync.** Ringkasan pagi, malam dan minggu diperbarui saat aplikasi dibuka, HP menyala atau tugas berubah, bukan menunggu timer.
- **Penyegaran widget diredam.** Debounce 400 ms plus periode 30 menit menjaga peluncur tetap ringan sementara data tetap segar.
- **Anggaran notifikasi.** Anggaran notifikasi harian dan jam tenang menjaga HP tidak berdering semalaman.

### Perbaikan bug

- **Liburan mengosongkan seluruh hari.** Hari libur nasional kini melewati semua kelas pada hari itu, bukan hanya slot pertama.
- **Nama bulan menyimpan tanggalnya.** "25 oktober" dan "october 25" mendarat di tanggal 25, bukan jatuh ke akhir bulan.

### Instalasi / Update

Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan instalasi dari sumber tidak dikenal bila diminta. Minimum Android 7.0 (API 24).
