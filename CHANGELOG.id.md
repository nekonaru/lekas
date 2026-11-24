# Changelog

Semua perubahan penting pada Lekas. Versi terbaru di paling atas.

## v1.24.0

Audit mendalam kedua mengeraskan parser, penyimpanan, dan penyegaran widget; dek kartu belajar kini bisa dibawa sebagai file CSV.

### Fitur baru

- **Dek kartu belajar sebagai CSV.** Setiap dek bisa membagikan pasangan depan/belakangnya sebagai file CSV atau mengimpor kartu dari file tersebut, dengan pratinjau dan batas 500 kartu.

### Perbaikan bug

- **Tanggal mustahil jujur.** "31 februari" dan "tanggal 31" kini dibatasi ke hari terakhir bulan dan meminta konfirmasi, bukan bergulir ke bulan berikutnya; kode ruang pendek tidak lagi memakan huruf kata biasa, dan konflik prioritas tidak tergantung urutan kata.
- **Gagal simpan bisa diulang.** Quick Add dan Share Intake kini melaporkan kegagalan dan tetap bisa dipakai; baris yang sudah tersimpan dicentang ulang supaya percobaan kedua tidak menduplikasi.
- **Data selalu segar.** Detail tugas memuat ulang setelah diedit, widget rumah menggambar ulang setelah kelas, ruang, semester, atau bahasa berubah, onboarding tidak bisa memasukkan ruang pertama dua kali, dan lampiran disalin ke penyimpanan aplikasi sebelum ditautkan.

## v1.23.0

Audit mendalam merapikan alur tugas berulang, pengingat, dan navigasi, sementara pelacak kebiasaan mendapat riwayat 90 hari.

### Fitur baru

- **Grid riwayat kebiasaan.** Layar Kebiasaan menampilkan heatmap 90 hari untuk centangan harian, memakai komponen dan bahasa visual yang sama dengan Statistik Belajar.

### Perbaikan bug

- **Tugas berulang selesai sekali.** `markDone` kini atomik, jadi ketukan cepat tidak menduplikasi kemunculan berikutnya; pengulangan bulanan 31 Januari kini jatuh di 28 Februari, bukan Maret.
- **Pengingat tidak berbunyi untuk tugas selesai.** Snooze di masa depan gugur saat tugas selesai atau dihapus, penghapusan permanen membatalkan alarm, dan pengingat setelah kelas yang masuk jam diam ditunda sampai 06:05.
- **Tidak ada peringatan basi.** Hari Ini menghitung inbox dari aliran tugas langsung, menyegarkan izin notifikasi saat aplikasi dibuka kembali, dan tile drawer menutup drawer tepat sekali.

### Peningkatan

- **Heatmap aktivitas dipakai bersama.** Statistik Belajar dan pelacak kebiasaan memakai satu komponen, dan minggu pertama yang disejajarkan tidak kehilangan hari terawalnya.

## v1.22.0

Aplikasi terasa lebih tenang dan konsisten, dan belajar menyelinap ke alur harian.

### Fitur baru

- **Kartu belajar di Hari Ini.** Banner yang bisa ditutup muncul di Hari Ini saat kartu jatuh tempo, membuka dek dengan satu ketukan.
- **Skor perbandingan mingguan.** Statistik Belajar membandingkan minggu ini dengan minggu lalu lewat delta berwarna untuk menit fokus dan tugas selesai.

### Peningkatan

- **Satu empty state, di mana-mana.** Semua layar kini memakai komponen empty state beranimasi yang sama.
- **Perbaikan kecil a11y.** Tombol-ikon di layar-layar baru mendapat tooltip.

## v1.21.0

Tugas kini bisa bolak-balik ke spreadsheet, tepat di samping jembatan kalender.

### Fitur baru

- **Ekspor Spreadsheet (.csv).** Bagian Data di drawer mendapat layar Spreadsheet: setiap tugas diekspor sebagai baris dengan judul, tipe, deadline, prioritas, status, ruang, bobot, dan tag, siap dibuka di aplikasi spreadsheet mana pun.
- **Impor Spreadsheet (.csv).** Layar yang sama mengimpor CSV dengan kolom title: tag yang dipisah titik koma dibuat saat impor, baris tanpa judul dilewati, dan impor dibatasi 1000 baris dengan pratinjau sebelum apa pun ditulis.

### Peningkatan

- **Round trip CSV ketat.** Pengutipan, kutip ganda, BOM, dan koma di dalam sel semuanya ditangani, dan CRLF atau LF sama-sama terbaca.

## v1.20.0

Lekas mengerti beberapa cara lagi untuk bilang kapan, dan menunjukkan ke mana waktu belajarmu pergi.

### Fitur baru

- **Parser mengerti frasa periode berikutnya.** "bulan depan" dan "next month" mendarat di tanggal yang sama bulan depan (menyesuaikan bulan pendek), "akhir bulan" dan "end of month" mendarat di tanggal terakhir bulan ini, "akhir bulan depan" dan "end of next month" di tanggal terakhir bulan depan, dan "tahun depan" dan "next year" di tanggal yang sama tahun depan (29 Februari menjadi 28 Februari). Frasa relatifnya meminta konfirmasi.
- **Fokus per mata pelajaran.** Statistik Belajar kini menampilkan lima mata pelajaran teratas berdasarkan menit fokus 14 hari terakhir, dengan batang proporsional terhadap yang tertinggi.

### Perbaikan bug

- **Mengetuk kebiasaan yang benar.** Mengetuk lingkaran mana pun di grid 7 hari dulu meng-toggle hari ini; sekarang mengetuk hari di bawah jari, jadi hari yang terlewat bisa dicentang belakangan.

## v1.19.0

Lekas kini membantu kamu menepati janji kecil juga: pelacak kebiasaan dengan streak, peta aktivitas 90 hari, dan ekspor CSV untuk nilai.

### Fitur baru

- **Pelacak kebiasaan (Kebiasaan).** Centang kebiasaan harian dengan grid 7 hari dan penghitung streak yang memaafkan hari ini yang belum dicentang; entri ada di bagian Belajar pada drawer, dan total mingguan menunjukkan berapa centangan yang berhasil kamu penuhi.
- **Peta aktivitas 90 hari.** Statistik Belajar kini menampilkan grid ala GitHub untuk setiap hari kamu menyelesaikan tugas, dengan legenda dari sedikit ke banyak.
- **Ekspor CSV untuk nilai.** Buku nilai membagikan log nilai mata pelajaran sebagai file CSV (dengan BOM dan pengutipan yang benar), siap dibuka di spreadsheet.

### Peningkatan

- **Skema 8.** Kebiasaan dan centangan kebiasaan bergabung ke database dengan indeksnya sendiri; peningkatan dari rilis lama berjalan otomatis, dan cadangan ikut mengekspor serta mengimpor keduanya.

## v1.18.0

Lekas kini bisa berbicara kalender: ekspor kelas dan tenggat ke file .ics yang bisa dibaca aplikasi kalender mana pun, dan impor kalender kembali menjadi tugas.

### Fitur baru

- **Ekspor Kalender (.ics).** Bagian Data di drawer mendapat layar Kalender (.ics): setiap tugas yang belum selesai menjadi event sehari penuh dan setiap kelas mingguan menjadi event berulang, dibagikan sebagai file yang bisa dibaca aplikasi kalender mana pun.
- **Impor Kalender (.ics).** Layar yang sama mengimpor file .ics ke Lekas: setiap kejadian menjadi tugas di inbox, ditinjau dulu sebelum ditulis, dibatasi 500 kejadian per file.
- **Lencana jatuh tempo.** Baris Kartu Belajar di drawer kini menampilkan lencana langsung dengan jumlah kartu yang jatuh tempo hari ini.

### Peningkatan

- **Pengimpor ketat.** File yang rusak ditolak dengan pesan jelas dan judul yang diimpor dibatasi panjangnya, jadi file jahat tidak bisa membanjiri inbox.

## v1.17.0

Lekas kini punya cerita nilai lengkap untuk pelajar SMA, sementara mode Kuliah tetap persis seperti sebelumnya.

### Fitur baru

- **Buku Nilai (SMA).** Mata pelajaran kini punya buku nilai: tambah nilai (label seperti Harian 1 atau UTS, 0-100, tanggal, catatan), lihat rata-rata langsung dengan verdict KKM hijau atau merah, dan atur KKM sesuka hati, langsung dari halaman mata pelajaran. Bobot dari komponen penilaian dipakai bila ada. Mode Kuliah tidak tersentuh.
- **Rapor (SMA).** Mode SMA menambahkan entri Rapor di tab Semester: semua mata pelajaran semester aktif dengan rata-ratanya dan verdict KKM, rata-rata semester di kartu brand, dan satu ketuk untuk membagikan rapor sebagai teks.
- **Contoh data sekolah lebih pintar.** Data contoh sekolah kini menyertakan tiga nilai contoh, jadi buku nilai dan rapor sudah terisi sejak pemakaian pertama.

### Peningkatan

- **Skema 7.** Database kini punya tabel scores dengan indeks per mata pelajaran; peningkatan dari rilis lama berjalan otomatis.
- **Cadangan mencakup buku nilai.** Ekspor dan impor kini membawa nilai-nilai juga.

## v1.16.0

Lekas kini juga jadi teman belajar, dengan kartu flash pengulangan berjeda dan sesi fokus yang benar-benar terukur.

### Fitur baru

- **Kartu belajar.** Entri Kartu Belajar baru di bagian Belajar pada drawer menampilkan deck umum plus satu deck per mata pelajaran, setiap kartu mengikuti jadwal SM-2-nya sendiri: ketuk untuk membalik, beri nilai Lupa, Sulit, atau Mudah, dan kartu kembali persis saat kamu harus mengulasnya.
- **Timer fokus yang nyata.** Mode fokus di Hari Ini kini menjalankan timer 15, 25, atau 45 menit yang mencatat setiap sesi (tabelnya sudah ada, tapi belum pernah ditulis).
- **Statistik Belajar.** Layar baru menampilkan menit fokus hari ini dan 7 hari terakhir, hari beruntun dengan tugas selesai, grafik batang 14 hari, dan total kartumu.

### Peningkatan

- **Cadangan mencakup kartu belajar.** Ekspor dan impor kini membawa kartu belajarmu, jadi pindah HP tidak menghilangkan progres ulasanmu.
- **Skema 6.** Database kini punya tabel kartu belajar dengan indeks pada tanggal jatuh tempo; peningkatan dari rilis lama berjalan otomatis.

## v1.15.0

Lekas hadir dengan Pengaturan yang dibangun ulang dan mode SMA yang lebih dalam pada rilis ini.

### Fitur baru

- **Pengaturan yang dibangun ulang.** Pengaturan kini terbuka dengan header brand (mark, tagline, dan chip versi) dan setiap bagian hidup dalam kartu sendiri dengan ikon berwarna: Tampilan, Pengingat, Cadangan, Alat, Pintasan, Sekolah, Sponsor, dan Tentang.
- **Mode SMA yang lebih dalam.** Mata pelajaran kini punya Kelas (10, 11, atau 12) yang dipilih langsung di form ruang, tampil di halaman mata pelajaran, dan semua label berubah menjadi istilah sekolah (Kelola Mata Pelajaran, Mata Pelajaran Semester Ini) saat jenjang diatur ke SMA.
- **Data contoh untuk SMA.** Data contoh membuat mata pelajaran Matematika dengan tugas gaya sekolah untuk akun SMA.

### Peningkatan

- **Pemilih tema terlokalisasi.** Dialog tema menampilkan Ikuti sistem, Gelap, atau Terang sesuai bahasa aplikasi, bukan nama enum mentah.
- **Tautan sponsor dalam satu kartu.** Baris sponsor kini berada dalam satu kartu dengan gaya yang sama seperti bagian lain, mudah dipindai.

## v1.14.0

Lekas menghadirkan versi yang benar-benar berfungsi untuk tugas berulang, tampilan pencarian tersimpan, dan tautan cepat, plus ekspor yang jujur dan pembaruan list yang lebih ringan, ditambah perbaikan audit.

### Fitur baru

- **Tugas berulang yang berulang.** Tugas berulang sederhana (harian, mingguan, bulanan) kini membuat tugas berikutnya secara otomatis saat kamu mencentang yang sekarang di Hari Ini; setiap tugas baru memakai ritme yang sama.
- **Tampilan pencarian tersimpan yang berfungsi.** Pencarian kini punya tombol bookmark untuk menyimpan query, kategori, jenis, tag, status, dan urutan saat ini; halaman Tampilan Tersimpan menampilkan daftar dan membuka kembali filter yang persis sama.
- **Tautan cepat yang bisa kamu kelola.** Entri tautan cepat di drawer kini menampilkan tautan buatanmu (tambah dengan tombol +, buka di browser, hapus) alih-alih tiga host kampus palsu bawaan.

### Peningkatan

- **List lebih ringan.** Spaces, semester, jadwal kelas, item ruang, dan tautan cepat kini mengembalikan satu watch stream per query alih-alih yang baru di setiap rebuild, sehingga layar berhenti berlangganan ulang di setiap ketukan.
- **Hari Ini tetap fokus ke tugas yang belum selesai.** Tugas yang sudah selesai hilang dari Hari Ini; mereka tetap ada di daftar tugas dan riwayat selesai.
- **Ringkasan pagi dan malam, kini berguna.** Layar ini menampilkan tugas hari ini, besok, dan yang terlambat dengan centang satu ketukan dan ketukan masuk ke detail tugas.

### Perbaikan bug

- **Lima layar berisiko crash atau freeze saat dialog ditutup.** Pengecekan mounted di impor file, share capture, time picker jadwal kelas, date/time picker form tugas, dan catatan pertemuan semuanya sudah dijaga.
- **Ekspor kini jujur.** Menu "Export Image and PDF" kini "Share Reports" (teks lewat share sheet) dan setiap subtitle menjelaskan apa yang sebenarnya dihasilkan.
- **Menu mati dihapus atau dibuat berfungsi.** Tile "Automatic Backup", "Icon Shortcuts", dan "Advanced Widgets" yang tidak melakukan apa-apa dihapus atau dilebur menjadi seksi Alat dan Pintasan yang nyata di Pengaturan; layar OCR, multi-baris quick add, dan cadangan terenkripsi yang tak pernah dipakai juga dihapus.

## v1.13.0

Lekas kini membuka dengan brand reveal, fitur kelola kategori dan mata kuliah diperdalam, dan ada bagian sponsor di Pengaturan, dengan drawer dan menu yang lebih tenang.

### Fitur baru

- **Brand reveal saat membuka.** Aplikasi kini membuka dengan logo Lekas, wordmark, dan tagline yang memudar di atas gradien brand, lalu larut ke dalam aplikasi.
- **Sponsor dan tentang di Pengaturan.** Bagian dukungan dengan GitHub Sponsors, Saweria, SociaBuzz, dan BagiBagi, plus dialog Tentang dan tautan kode sumber, semuanya terbuka lewat channel platform (https saja).
- **Kelola kategori dan mata kuliah lebih dalam.** Formulir ruang kini mengedit nama, warna, kode, SKS, dan target nilai; baris mata kuliah di tab Semester menawarkan ubah, arsip, dan hapus langsung di tempat; Kategori dan Mata Kuliah menampilkan jumlah tugas belum selesai per baris secara langsung.

### Peningkatan

- **Drawer lebih tenang.** Menu mengelompokkan tugas, data, dan sistem dalam seksi berlabel dengan ikon beraksen tipis, header brand dengan chip versi langsung, dan lencana trash yang menghitung apa yang masih bisa dipulihkan.
- **Empty state lebih halus.** Layar kosong pudar dan membesar dengan cahaya lembut, bukan muncul tiba-tiba.

### Perbaikan bug

- **Intro tidak lagi menelan ketukan.** Splash menghilang setelah reveal-nya, sehingga onboarding dan gerbang kunci di bawahnya menerima ketukan pertama seperti seharusnya.

## v1.12.0

Lekas mengganti tab Inbox dengan tab Kategori, membuat kalender menjadi agenda yang berfungsi nyata, menyimpan berkas mata kuliah di penyimpanan HP, serta mengelola kehadiran dan daftar bawaan per mata kuliah.

### Fitur baru

- **Tab Kategori.** Tab Inbox dihapus; di posisi itu kini Kategori, wadah bebas bernama apa pun (organisasi, kepanitiaan, komunitas), plus baris tanpa kategori di atas daftar untuk tugas yang belum punya tempat.
- **Berkas per mata kuliah.** Setiap mata kuliah menyimpan modul, catatan, soal, dan arsip di dalam pohon folder sungguhan pada penyimpanan HP. Pilih folder sekali; setiap mata kuliah mendapat folder Lekas dengan subfoldernya sendiri; tidak ada berkas yang meninggalkan HP.
- **Tab Semester membawa Mata Kuliah.** Kelola mata kuliah semester aktif dari tab Semester; wadah bebas hidup di bawah Kategori.
- **Kalender menjadi agenda sungguhan.** Jam kelas dan tugas untuk hari yang dipilih tercantum di bawah grid bulan; ketuk entri apa pun atau sel tanggal mana pun, lihat semua tugas pada hari yang sibuk, centang tugas, atau masuk ke mata kuliah.
- **Kehadiran yang lengkap.** Tandai hadir, absen, izin, atau sakit per pertemuan; setiap catatan lama bisa diubah atau dihapus dari layar kehadiran mata kuliahnya.
- **Daftar bawaan per mata kuliah.** Daftar bawaan kini per mata kuliah, bisa diubah, diurutkan ulang, dan dicentang per item.

### Peningkatan

- **Today menampilkan pemiliknya.** Setiap kartu di daftar Today membawa nama kategori atau mata kuliahnya di subtitle.
- **Jadwal kelas bertemu kalender.** Hari-hari ada kelas menyala di grid bulan, dan layar jadwal dibangun ulang menjadi kartu per hari dengan ubah dan hapus langsung.
- **Satu atap per mata kuliah.** Kehadiran, daftar bawaan, jadwal kelas, berkas, dan prediksi nilai semuanya tinggal di layar detail mata kuliah.
- **Bar pilih massal di bawah.** Bar aksi massal berlabuh di bawah, konsisten di Today, Inbox, Kategori, dan Tugas.

### Perbaikan bug

- **Tidak ada lagi crash controller saat menutup dialog.** Controller TextField dibuang setelah animasi keluar selesai, bukan saat frame penutupnya dibongkar.
- **Layar mati dihapus.** Sembilan layar placeholder dan helper kategori lama tidak pernah terhubung ke mana pun dan kini hilang selamanya.

## v1.11.0

Lekas kini bisa memeriksa rilis baru dengan sendirinya: Pengaturan menampilkan versi terpasang, bertanya ke GitHub saat diketuk, dan pemeriksaan senyap sekali sehari berbicara hanya saat APK baru tersedia.

### Fitur baru

- **Periksa pembaruan.** Tile versi di Pengaturan memeriksa rilis GitHub terbaru saat diketuk; saat ada yang lebih baru, tawaran langsung unduh APK arm64 atau halaman rilisnya. Pemeriksaan senyap sekali sehari berjalan saat membuka aplikasi dengan satu snackbar dan tombol Unduh, bisa dimatikan di Pengaturan.
- **Satu permintaan, tidak lebih.** Pemeriksaan adalah GET baca-saja ke API rilis publik GitHub; tidak ada data yang dikirim, tanpa akun, analitik, atau telemetri, dan mematikannya mengembalikan aplikasi sepenuhnya offline seperti sebelumnya.

### Peningkatan

- **Komponen filter bersama.** Sheet filter dan layar pencarian kini memakai komponen chip status dan daftar urutan yang sama, sehingga keduanya tidak bisa melenceng lagi.

## v1.10.0

Lekas mengganti tab Kategori dengan tab Semester, menambahkan sistem filter dan pengelompokan per kategori di daftar tugas, serta memperbaiki bug tata letak pada sheet tugas dan layar tab.

### Fitur baru

- **Tab Semester.** Tab Kategori kini menjadi Semester: hero semester aktif dengan jumlah mata kuliah, progres tugas, dan lencana terlambat, daftar mata kuliah di bawahnya, dan semester lain sekali ketuk. Buat, ubah nama, aktifkan, dan hapus semester semuanya di sana; space yang sudah ada membawa periodenya, yang menjadi semesternya saat upgrade.
- **Filter kategori tugas.** Daftar tugas bisa memfilter berdasarkan kategori, status (belum selesai atau selesai), dan urutan (deadline terdekat, deadline terjauh, terbaru dibuat, prioritas tertinggi) lewat satu sheet bersama; Search & Filter juga mendapat kontrol status dan urutan yang sama.
- **Kelompokkan per kategori.** Daftar tugas bisa beralih antara daftar datar dan grup per kategori, dengan jumlah per grup, sehingga tugas satu mata kuliah berkumpul.
- **Inbox bisa dicari.** Pencarian global kini menyertakan tugas Inbox; tugas yang tercatat di sana terlihat oleh semua pencarian.

### Peningkatan

- **Satu app bar per tab.** Header ganda di setiap tab dihapus; shell yang memegang bar tunggal, mode pilih pindah ke action bar bawah, dan navigasi bulan serta label hari pada kalender kini berada di body.
- **Sheet tugas muat di layar.** Sheet tambah tugas bisa digulir, menepi dari keyboard, dan kontrol prioritasnya tombol segmen selebar layar; bar deadline kehilangan ikon silang melayang, diganti tombol berlabel.
- **Desain flat yang lebih tenang.** Banner izin notifikasi berada di permukaan lembut, bukan kartu merah gelap; label deadline dan prioritas memakai gaya seksi.

### Perbaikan bug

- **Sheet tambah tugas tidak lagi meluap** dengan label panjang atau layar kecil; bar prioritas tidak lagi keluar tepi.
- **Tombol tambah ganda.** Hari Ini dan shell sama-sama punya aksi tambah; punya shell dihapus, tombol mengambang tetap ada.
- **Cadangan aman untuk semester.** Cadangan dari versi sebelum ini diperbaiki saat import: tabel semester yang kosong atau tanpa flag aktif mendapat semester aktif bawaan, sehingga tab Semester tidak pernah terbuka kosong.

## v1.9.0

Lekas mengganti nama wadah menjadi kategori, menambahkan deadline dengan jam, meminta izin notifikasi, dan memperhalus tema flat brand.

### Fitur baru

- **Kategori di semua tempat.** Seluruh aplikasi kini menyebut mata kuliah dan wadah sebagai kategori dalam bahasa Inggris dan kategori dalam bahasa Indonesia, di teks, test, dan dokumen.
- **Deadline dengan jam.** Tugas bisa membawa deadline lengkap dengan jam, dipilih lewat chip pada bar deadline, sehingga pengingat bisa berbunyi tepat pada menitnya.
- **Izin notifikasi diminta sekali.** Setelah setup, Lekas meminta izin notifikasi dan alarm tepat saat pertama dibuka, sehingga pengingat benar-benar bisa berbunyi; flag tersimpan di settings dan dialog sistem tidak muncul di setiap pembukaan.

### Peningkatan

- **Tema flat brand.** Kartu, chip, tombol, dan snackbar memakai radius dan palet yang sama: warna primer indigo, container yang lembut, kartu tanpa garis tepi, skala tipografi yang lebih rapi.

## v1.8.0

Lekas menambahkan daftar wadah yang diarsipkan, hapus wadah permanen, seksi drawer berkelompok, dan skala spacing yang lebih rapi.

### Fitur baru

- **Daftar wadah arsip.** Tab Wadah beralih antara Aktif dan Arsip dengan kontrol tersegmentasi. Baris arsip menunggu di sana dengan pulihkan sekali ketuk atau hapus permanen, dan tampilan kosong menjelaskan fungsi daftar ini.
- **Hapus wadah permanen.** Menu titik-tiga di setiap wadah, daftar arsip, dan layar detail kini menawarkan hapus dengan dialog konfirmasi: jadwal, presensi, catatan, komponen nilai, dan checklist-nya ikut terhapus, dan tugasnya pindah ke Inbox, bukan hilang.
- **Drawer berkelompok.** Drawer datar kini dikelompokkan menjadi seksi berlabel: tugas dulu, lalu alat data (cadangan dan pemeriksa pengingat), kemudian tata kelola.

### Peningkatan

- **Satu skala spacing.** Padding dan margin mengikuti kelipatan empat lewat tema, kartu memakai satu radius, dan skala tipografi eksplisit di kedua mode.

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
