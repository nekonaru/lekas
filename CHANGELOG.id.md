# Changelog

Semua perubahan penting pada Lekas. Versi terbaru di paling atas.

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
