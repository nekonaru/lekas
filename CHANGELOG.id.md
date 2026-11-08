# Changelog

Semua perubahan penting pada Lekas. Versi terbaru di paling atas.

## v1.7.0

Lekas menambahkan kunci aplikasi PIN dan ketuk kalender untuk mengelola tugas harian.

### Fitur baru

- **Kunci aplikasi.** PIN empat sampai enam digit (diatur di Settings, App Lock) mengunci aplikasi setiap kembali ke foreground. Hanya hash ber-salt yang disimpan, sehingga tidak ada PIN yang tersimpan di database. Mengganti dan mematikan selalu meminta PIN saat ini dulu.
- **Aksi hari kalender.** Mengetuk hari mana pun membuka tugas jatuh temponya, yang bisa dicentang dan dikelola massal seperti daftar lainnya. Hari ini ditandai dengan titik yang menandai hari bertugas.

## v1.6.0

Lekas menambahkan pilih massal di semua daftar, seret susun, saklar jenjang, dan tampilan baru.

### Fitur baru

- **Pilih massal di semua daftar.** Tekan lama baris tugas mana pun di Inbox, Tasks, Search, Trash atau Spaces untuk memilihnya dan menjalankan aksi yang sama seperti Today (selesai, prioritas, pindah, hapus) plus pilih semua. Trash menambah pulihkan massal, Spaces menambah arsip massal.
- **Ubah wadah, hapus tugas.** Wadah bisa diganti nama dan diubah dari daftar atau layar detail, tugas bisa dihapus dari layar detail, semuanya dengan urungkan. Spaces dan subtugas juga bisa diseret ke susunan sendiri, tersimpan antar bukaan.
- **Ganti jenjang tanpa reinstall.** Settings punya baris Jenjang (Kuliah/SMA) yang diterapkan ke semua wadah sekaligus. Pilihan jenjang di setup diingat, dan layar detail menampilkannya sebagai label yang jelas.
- **Tampilan baru.** Pita gradasi membawa logo di drawer dan setup, tombol tambah memanjang, daftar kosong memakai satu gaya berilustrasi, dan judul tab berganti dengan transisi silang.

### Perbaikan bug

- **Banner urungkan hilang tepat waktu.** Banner kini tampil sekali selama lima detik, dan banner baru menggantikan yang lama, bukan mengantre di belakangnya.
- **Edit tugas menjaga keadaannya.** Edit tidak lagi membuka kembali tugas yang selesai atau melepas pin tugas terpin, daftar wadah memuat wadah, dan deadline lama tetap bisa dipilih.
- **Backup lama tetap bisa diimpor.** Baris wadah dari backup sebelum v1.6.0 tanpa susunan seret diimpor dengan susunan bawaan.
- **Database lama naik ke schema 4.** Kolom susunan seret wadah dimigrasi dengan bersih: data lama dan indeks terjaga.

## v1.5.1

Lekas menyegarkan ikon aplikasi dari petir ke centang tebal.

### Fitur baru

- **Ikon aplikasi baru.** Petir diganti dengan centang putih tebal di gradasi indigo ke violet yang sama, termasuk ikon launcher, varian bundar dan adaptif, serta logo di dalam aplikasi. Centang tetap jelas pada ukuran kecil.

## v1.5.0

Lekas membawa logo baru, tema yang lebih rapi, dan daftar yang lebih halus dan ringan.

### Fitur baru

- **Logo aplikasi baru.** Petir putih di atas gradasi indigo ke violet kini tampil pada ikon launcher, layar setup dan laci navigasi, dengan varian bundar dan adaptif untuk Android lama dan baru.
- **Tampilan lebih rapi.** Bilah atas, kartu, bilah bawah dan baris tugas berbagi satu tema yang halus: bilah atas yang lebih datar, kartu berbingkai, ikon terisi pada tab yang terbuka, dan titik prioritas berlingkar pada setiap baris tugas.
- **Animasi daftar yang halus.** Kartu di Today dan Inbox memudar dan bergeser masuk dengan jeda singkat, dan layar setup menampilkan penanda langkah yang memanjang. Semua animasi selesai dengan cepat dan tidak meninggalkan lapisan, sehingga gulir tetap ringan.

### Peningkatan

- **Unduhan lebih kecil.** Font ikon Cupertino yang tidak digunakan dihapus dan font Inter bawaan disubset ke glif yang dipakai aplikasi, sehingga data font bawaan berkurang lebih dari 1 MB.
- **Daftar lebih ringan.** Baris yang sudah diam mengembalikan child tanpa lapisan opacity tambahan, sehingga daftar yang panjang tetap murah digambar.

## v1.4.2

Lekas memperbaiki layar hitam setelah setup dan membuat pilihan bahasa bereaksi.

### Perbaikan bug

- **Tidak ada lagi layar hitam setelah setup.** Menyelesaikan rangkaian awal menutup route akar, sehingga navigator kosong dan layar hitam di HP asli. Setup kini langsung berpindah ke layar utama di tempat, tanpa frame kosong di antaranya.
- **Pilihan bahasa di setup langsung bereaksi.** Tombol bahasa dan jenjang kini menunjukkan opsi yang dipilih (terisi dengan tanda centang) dengan transisi silang antar status, dan bahasa yang dipilih langsung diterapkan, bukan hanya di langkah terakhir.

## v1.4.1

Lekas memperbaiki crash saat dibuka yang disebabkan penyusut memotong kelas WorkManager.

### Perbaikan bug

- **Tidak ada lagi force close saat dibuka.** Penyusut build release memotong kelas database WorkManager yang Android inisialisasi sebelum frame pertama, sehingga APK release mati begitu dibuka di HP asli sementara build debug tetap jalan. Kelas tersebut kini dijaga, dan aplikasi terbuka normal.

## v1.4.0

Lekas menambahkan preset tema sekali ketuk dan transisi hero ke detail tugas.

### Fitur baru

- **Preset tema.** Satu ketukan menerapkan tampilan utuh: Tengah malam beralih ke indigo gelap, Senja menghangatkan aplikasi dengan oranye, Hutan mendinginkan dengan hijau emerald, dan Bawaan mengembalikan semuanya ke gaya asli.
- **Pratinjau terang dan gelap.** Pemilih warna menunjukkan hasil setiap warna di kedua mode terang sebelum kamu memilihnya, dengan swatch dari palet asli yang dihasilkan.

### Peningkatan

- **Transisi hero.** Membuka tugas dari Today membawa judulnya ke layar detail dan kembali sebagai satu gerakan menyambung.
- **Transisi lebih aman.** Hanya daftar Today yang memakai penerbangan hero, sehingga layar yang bertumpuk tidak pernah bertabrakan pada tag yang sama.

## v1.3.0

Lekas menambahkan warna aksen, empat ukuran font, dan tipografi Inter bawaan.

### Fitur baru

- **Warna aksen.** Pilih warna seluruh aplikasi di Pengaturan: dua belas pilihan plus indigo bawaan, langsung berlaku di semua layar dan kontrol.
- **Ukuran font.** Empat pilihan ukuran teks yang mengalikan skala aksesibilitas HP, jadi pengaturan sistem tetap jalan di bawahnya.
- **Tipografi Inter.** Aplikasi membawa huruf Inter dalam empat ketebalan, memberi judul, kartu dan chip tampilan yang rapi dan khas.

### Peningkatan

- **Tombol tambah sadar gulir.** Tombol tambah bergeser menghilang saat menggulir ke bawah dan kembali pada guliran pertama ke atas.
- **Hitungan seksi.** Setiap judul seksi di Today menampilkan jumlah tugasnya dalam pill kecil.
- **Masuk yang lembut.** Layar Today yang kosong tampil dengan fade dan skala sekali, bukan muncul mendadak.
- **Pembangunan ulang lebih ramping.** Kartu menerima skor urgensi yang sudah dihitung, dan daftar melepas keep alive otomatis.

## v1.2.0

Lekas menyatukan gerakan di antarmuka dan membuat daftar panjang lebih ringan digambar.

### Peningkatan

- **Gerak bersama.** Pindah tab, buka halaman dan aksi kartu kini memakai satu kurva dan durasi yang sama, sehingga semua gerakan terasa tenang dan konsisten.
- **Animasi seleksi.** Menandai tugas dalam mode multi pilih menampilkan centang dengan crossfade di atas titik prioritas, bukan berganti seketika.
- **Permukaan modern.** Kartu, snackbar, dialog, bottom sheet dan kolom form memakai satu bahasa bentuk Material 3, dan semua modal sheet kini punya drag handle.
- **Drawer lebih tenang.** Drawer dibuka dengan header ringkas berlogo, bukan blok abu besar.
- **Layar kosong lebih ramah.** Today yang kosong menampilkan ikon centang berwarna dan judul di tengah, bukan glif abu.
- **Daftar lebih ringan.** Skor urgensi tampil dalam pill kecil, gerak swipe berbentuk rounded seperti kartu, dan tugas terakhir tergulir bebas dari tombol aksi.

## v1.1.0

Lekas menambahkan dependensi tugas dan Quick Add yang lebih pintar, plus menyerahkan layar jadi ke menu.

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

## v1.0.1

Lekas langsung membuka layar utama, meringankan daftar Today, dan memperbaiki sejumlah crash pasca update.

### Peningkatan

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

## v1.0.0

Lekas merilis versi publik pertamanya dengan Quick Add, pengingat offline, Today, widget, dan dukungan dua bahasa.

### Fitur baru

- **Parser Quick Add.** Satu baris teks Indonesia atau Inggris menjadi deadline, matkul, prioritas, tag, subtugas, estimasi dan tautan, semuanya tampil sebagai chip yang boleh dipertahankan atau dibuang (bagian 6.1 dan 7.15).
- **Quick Add suara.** Mikrofon duduk di Quick Add dan di layar tersendiri, dan angka bicara seperti "jam tujuh malam" menjadi deadline (bagian 7.1).
- **Pengingat lokal.** H-3, H-1, 3 jam dan 30 menit sebelum deadline, jam tenang 22.00 sampai 06.00, plus ringkasan pagi, malam dan minggu (bagian 5.4 dan 5.22).
- **Layar Hari Ini.** Skor urgensi dengan bagian terlambat, hari ini dan minggu ini, geser kanan untuk selesai dengan undo, geser kiri untuk menunda, tekan lama untuk pilih banyak (bagian 5.2 dan 5.6).
- **Masukan berbagi.** Teks yang dibagikan dari WhatsApp atau aplikasi lain dipecah jadi kandidat lalu diparsing sebelum menjadi tugas (bagian 6.2).
- **Empat widget layar utama.** Hitung mundur ujian, daftar hari ini, tombol tambah cepat dan kelas berikutnya, semua lewat `home_widget` (bagian 7.8).
- **Kehadiran dan fokus.** Presensi kelas dengan passing grade kampus, peringatan kuota izin, dan mode fokus maksimal tiga tugas sehari (bagian 5.19 dan 5.24).
- **Dua bahasa dan mode gelap.** Indonesia bawaan, Inggris sebagai pilihan, baik di antarmuka maupun di parser (bagian 8).

### Peningkatan

- **Ringkasan dibangun saat sync.** Ringkasan pagi, malam dan minggu diperbarui saat aplikasi dibuka, HP menyala atau tugas berubah, bukan menunggu timer.
- **Penyegaran widget diredam.** Debounce 400 ms plus periode 30 menit menjaga peluncur tetap ringan sementara data tetap segar.
- **Anggaran notifikasi.** Anggaran notifikasi harian dan jam tenang menjaga HP tidak berdering semalaman.

### Perbaikan bug

- **Liburan mengosongkan seluruh hari.** Hari libur nasional kini melewati semua kelas pada hari itu, bukan hanya slot pertama.
- **Nama bulan menyimpan tanggalnya.** "25 oktober" dan "october 25" mendarat di tanggal 25, bukan jatuh ke akhir bulan.
