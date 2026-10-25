# Rancangan Aplikasi Tugas v2: Fase A dan B (Edisi Dirapikan)

Aplikasi Android untuk mencatat tugas dan deadline kuliah, dikerjakan sendiri dengan bantuan AI. Tanpa akun, tanpa cloud, tanpa kolaborasi. Semua data tersimpan di HP.

Dokumen ini adalah penataan ulang v2. Bagian 13 sampai 22 versi sebelumnya (fitur tambahan, perubahan skema, jadwal baru, dua bahasa) sudah dilebur ke dalam alur utama, jadi tidak ada lagi bagian yang berbunyi "ubah bagian 3.1" atau "tambahkan ke skema". Daftar perubahan ada di **Lampiran A**. Hal yang masih perlu kamu putuskan ada di **Lampiran B**.

## Daftar Isi

1. Tujuan, Batasan, dan Aturan Main
2. Pengguna dan Validasi
3. Peta Fitur dan Perkiraan Usaha
4. Fase A: Inti yang Andal
5. Fase A: Fitur Tambahan
6. Fase B: Alat Harian
7. Fase B: Fitur Tambahan
8. Dukungan Dua Bahasa
9. Arsitektur Teknis
10. Skema Database
11. Desain dan Pengalaman
12. Pengujian
13. Jadwal Kerja
14. Cara Bekerja dengan AI
15. Risiko dan Penangkal
16. Gambaran Satu Hari Bersama Aplikasi
- Lampiran A: Daftar Perubahan dari v2 Awal
- Lampiran B: Hal yang Perlu Diputuskan

---

## 1. Tujuan, Batasan, dan Aturan Main

**Nilai jual satu kalimat:** tangkap tugas dari chat dalam 5 detik, otomatis rapi per matkul, dan diingatkan dengan benar.

**Target:** aplikasi Android yang dipakai sendiri dan teman sekelas selama satu semester tanpa kehilangan satu pengingat pun.

**Cakupan inti (Fase A dan B)**

- Wadah (matkul), tugas, skor urgensi, layar Hari Ini, pengingat lokal, mode gelap
- Quick Add dengan parser bahasa Indonesia
- Share dari WhatsApp
- Widget layar utama, kalender bulanan, lampiran sederhana
- Cadangan dan pemulihan data lokal (ekspor dan impor JSON)
- Prediksi nilai dan ringkasan mingguan versi ringan

**Fitur tambahan** (bagian 5 dan 7) diberi label prioritas:

- **[W] Wajib:** ikut jadwal inti, karena memengaruhi cara pakai sehari-hari.
- **[S] Sebaiknya:** dikerjakan bila Wajib sudah stabil.
- **[B] Bonus:** dikerjakan hanya bila ada waktu luang, boleh dibuang tanpa merusak aplikasi.

Semua fitur tambahan memakai mesin yang sama (wadah, tugas, pengingat), jadi sebagian besar hanya tambahan kolom dan layar, bukan sistem baru.

**Aturan emas:** ide baru masuk daftar parkir dulu, bukan langsung dikerjakan.

**Aturan pemotongan:** bila waktu mepet, buang fitur dari bawah tabel prioritas (bagian 3): Bonus dulu, baru Sebaiknya. Aplikasi tetap utuh karena tiap fitur berdiri sendiri.

### Daftar Parkir (satu-satunya)

Ditunda sampai Fase B stabil dan dipakai satu semester penuh. Putuskan dari data pemakaian nyata, bukan dari rencana awal.

- Akun, sinkron cloud, kolaborasi kelompok, push notification server
- Mode Work penuh (Kanban, pelacak waktu klien)
- Tugas berulang dengan RRULE (versi sederhana ada di 5.10)
- Asisten AI, Smart Planner berbasis pembelajaran (versi aturan sederhana ada di 7.6)
- Gamifikasi, model berlangganan Pro, analitik
- Sinkron dua arah dengan Google Calendar

---

## 2. Pengguna dan Validasi

Fokus satu persona dulu: **mahasiswa**. Tugas datang lewat grup WhatsApp, deadline tersebar, dan sering lupa mengumpulkan. Mesin aplikasi tetap dibuat generik (wadah, tugas, tanggal) sehingga mode Work atau mode SMA bisa ditambah nanti tanpa membongkar database.

**Validasi sebelum membangun (1 hari):** tanya 5 sampai 10 teman kelas: "kamu catat tugas di mana sekarang, dan apa yang paling bikin kesal?" Catat jawabannya, lalu cocokkan dengan fitur Fase A dan B. Bandingkan juga dengan Google Tasks, Todoist, dan TickTick untuk tahu apa yang benar-benar beda.

---

## 3. Peta Fitur dan Perkiraan Usaha

Perkiraan hari kerja untuk satu orang paruh waktu dengan bantuan AI, belum termasuk pengujian di HP nyata. Kolom **Tahap** merujuk ke bagian 13. Tanda `*` berarti penempatan atau angka itu usulan penataan, bukan keputusan di v2 awal (lihat Lampiran B).

| Fitur | Bagian | Prioritas | Tahap | Usaha (hari) |
| --- | --- | --- | --- | --- |
| Inbox | 5.1 | W | 1 | 2 |
| Subtugas dan progres | 5.2 | W | 1 | 3 |
| Jadwal kuliah dan Kelas Hari Ini | 5.3 | W | 1 | 5 |
| Tunda cerdas, geser kartu, aksi massal | 5.5 | W | 1 | 3 |
| Tanggal mulai dan pengingat mulai | 5.4 | S | 2 | 2 |
| Riwayat deadline | 5.6 | S | 2 | 2 |
| Ujian dan materi belajar | 5.7 | S | 2 | 2 |
| Ringkasan pagi dan malam | 5.12 | S | 2 | 2 |
| Sampah dan pemulihan | 5.11 | S | 2 | 2 |
| Share dari tangkapan layar (OCR) | 7.3 | S | 4 | 4 |
| Deteksi duplikat dan deadline diundur | 7.5 | S | 4 | 4 |
| Nilai, IPS, IPK, simulator | 7.9 | S | 4 | 5 |
| Rencana belajar ujian | 7.10 | S | 4 | 3 |
| Cadangan otomatis | 7.13 | S | 4 | 3 |
| Share dari aplikasi lain | 7.4 | S | 4* | 1* |
| Timer fokus | 5.8 | S | 5* | 4 |
| Pin, tag, duplikat, templat | 5.9 | S | 5* | 4 |
| Kontak dan tautan kelas | 5.15 | S | 5* | 1 |
| Quick Add suara | 7.1 | S | 5* | 2 |
| Pintasan ikon dan Quick Settings | 7.2 | S | 5* | 2 |
| Saran waktu kosong | 7.6 | S | 5* | 4 |
| Kalender minggu, agenda, ICS | 7.7 | S | 5* | 5 |
| Widget lanjutan | 7.8 | S | 5* | 4 |
| Tugas berulang sederhana | 5.10 | B | 5 | 3 |
| Kunci aplikasi, tema, mode SMA | 5.13, 5.14 | B | 5 | 4 |
| Statistik dan rekap semester | 7.11 | B | 5 | 3 |
| Bagikan sebagai teks, impor CSV | 7.12, 7.14 | B | 5 | 3 |

**Jumlah kasar (dikoreksi):** Wajib 13 hari, Sebaiknya 56 hari, Bonus 13 hari. Di v2 awal tertulis 13, 50, dan 16. Angka Sebaiknya naik karena penjumlahan sebelumnya meleset dan karena "Share dari aplikasi lain" belum ada di tabel. Angka Bonus turun karena penjumlahan sebelumnya meleset.

**Di luar tabel:** rencana inti Fase A dan B (bagian 13) dan dukungan dua bahasa (sekitar 11 sampai 12 hari, tersebar di tiap fitur, lihat bagian 8).

---

## 4. Fase A: Inti yang Andal

### 4.1 Onboarding (target: tugas pertama dalam 2 menit)

1. Pilih bahasa: dua tombol besar "Bahasa Indonesia" dan "English". Bila dilewati, Indonesia dipakai.
2. Pilih jenjang: Kuliah, SMA, atau Personal.
3. Tambah matkul pertama dengan satu kolom nama (kode, dosen, SKS bisa diisi nanti).
4. Langsung masuk ke tambah tugas pertama.
5. Izin notifikasi diminta **saat tugas pertama dengan deadline disimpan**, dengan penjelasan singkat, bukan di awal.

### 4.2 Wadah (matkul)

- Nama, kode, warna (12 pilihan), alias untuk parser, catatan meta (dosen, ruangan, tautan kelas).
- Arsip per semester, bukan hapus, supaya riwayat dan rekap nilai tetap ada.

### 4.3 Tugas

- Judul, catatan, jenis (kuis, laprak, makalah, presentasi, UTS, UAS, lainnya), deadline (boleh kosong, masuk "Kapan-kapan"), prioritas, status (Belum, Dikerjakan, Revisi, Selesai), bobot nilai, estimasi menit, mode individu atau kelompok.
- Hapus memakai **snackbar Undo** (soft delete). Selesai juga bisa di-undo.
- Formulir tambah tugas berupa bottom sheet dengan hanya 3 kolom wajib terlihat: judul, wadah, deadline. Sisanya dilipat di "Detail lain".

### 4.4 Layar Hari Ini

Urutan bagian dari atas ke bawah. Bagian bertanda fitur tambahan baru muncul bila fiturnya sudah dibuat.

1. **Kelas berikutnya** (kartu ringkas dengan sisa waktu, fitur 5.3).
2. **Disematkan** (tugas yang di-pin, tampil di luar urutan skor, fitur 5.9).
3. **Terlambat** (diurutkan dari yang paling lama terlambat), dengan tombol cepat "Tandai selesai" atau "Atur ulang".
4. **Hari ini dan besok**, diurutkan skor urgensi.
5. **Sedang dikerjakan** (status Dikerjakan), selalu terlihat, tidak turun.
6. **Hitung mundur ujian** bila kurang dari 14 hari (fitur 5.7).
7. **Minggu ini**, diciutkan secara bawaan.
8. **Kapan-kapan**, diciutkan.

Inbox (fitur 5.1) punya tab sendiri dengan badge angka, bukan bagian di layar ini.

Setiap kartu menampilkan **alasan singkat** mengapa posisinya di situ, misalnya "deadline 6 jam lagi, bobot 30%". Ini membuat urutan terasa masuk akal dan mudah dipercaya.

### 4.5 Skor Urgensi v2

Skor dipakai hanya untuk mengurutkan di dalam bagian, dan **dihitung saat ditampilkan, tidak disimpan di database**.

```
Skor = (U x 0.5) + P + B + (T x 20)

U = 100 x e^(-jam_tersisa / 48)        (maks 100)
P = rendah 0 | sedang 10 | tinggi 25
B = bobot_persen x 0.6                  (maks sekitar 30)
T = estimasi_jam / jam_efektif_tersisa  (dibatasi 0 sampai 2)
```

**Perubahan dari versi pertama**

- **Terlambat tidak lagi bernilai 999.** Ia punya bagian sendiri, jadi urutannya bermakna.
- **Status Dikerjakan tidak lagi mengurangi skor.** Tugas yang sedang dikerjakan dipisah ke bagiannya sendiri.
- **Jam efektif punya nilai bawaan:** 10 jam produktif per hari, 0 saat tidur (bawaan 23.00 sampai 06.00). Pengguna tidak wajib mengisi jadwal kuliah.
- **T hanya dihitung bila estimasi diisi.** Tanpa estimasi, T = 0, bukan tebakan 60 menit.
- Semua konstanta ditaruh di satu file `scoring_config.dart` supaya mudah disetel setelah dipakai nyata.
- Pengaturan sederhana: "Utamakan deadline" atau "Utamakan nilai" yang hanya mengubah bobot U dan B.

**Penyesuaian dari fitur tambahan** (berlaku setelah fiturnya ada)

- Jadwal kuliah diisi: jam kuliah dikurangkan dari jam efektif (5.3).
- Subtugas ada: estimasi sisa waktu untuk T dikurangi sesuai persentase selesai (5.2).

**Pengujian rumus:** siapkan 15 tugas nyata dari semestermu, urutkan manual dulu, lalu bandingkan dengan urutan aplikasi. Ubah konstanta sampai 12 dari 15 cocok.

### 4.6 Mesin Pengingat

**Alur**

1. Tugas disimpan, `ReminderService` menghitung waktu pengingat: H-3, H-1, 3 jam, dan 30 menit sebelum deadline. Tugas berbobot besar mendapat pengingat tambahan, tugas bobot kecil lebih sedikit.
2. Waktu yang sudah lewat dibuang, jam tenang (bawaan 22.00 sampai 06.00) diterapkan, lalu dijadwalkan. Aturan untuk pengingat yang jatuh di jam tenang perlu dipastikan (Lampiran B, poin 1).
3. Deadline diubah atau tugas selesai: pengingat lama dibatalkan lewat `notif_id`, lalu dibuat ulang bila perlu.
4. **Boot receiver** menjadwalkan ulang semua pengingat aktif setelah HP restart atau aplikasi diperbarui.
5. Hanya jadwalkan 14 hari ke depan. Sisanya dijadwalkan ulang oleh tugas harian (Lampiran B, poin 2).
6. Tombol aksi di notifikasi: **Selesai** dan **Tunda 1 jam** (pilihan tunda lengkap ada di 5.5).
7. Perubahan zona waktu HP memicu penjadwalan ulang.

**Hal Android yang wajib ditangani sejak awal**

- Izin `POST_NOTIFICATIONS` (Android 13 ke atas).
- Izin alarm presisi (`SCHEDULE_EXACT_ALARM`, Android 12 ke atas). Siapkan jalur cadangan bila izin ditolak: alarm tidak presisi dengan peringatan jujur di pengaturan.
- Optimasi baterai per merek (Xiaomi, Oppo, Realme, Samsung). Buat layar **"Cek Pengingat"** di Pengaturan: tombol tes notifikasi 1 menit, status izin, dan panduan mematikan penghemat baterai untuk aplikasi ini.
- Kanal notifikasi terpisah: deadline, tugas terlambat, ringkasan.

### 4.7 Pengaturan dan Hal Dasar Lain

- Mode gelap dan terang, mengikuti sistem.
- Pencarian sederhana di judul dan catatan.
- Penyaring berdasarkan wadah dan jenis (tag ikut bila fitur 5.9 ada).
- **Dua bahasa** (Indonesia bawaan, Inggris pilihan). Semua teks lewat file lokalisasi sejak awal (bagian 8).
- **Ekspor dan impor cadangan JSON** ke penyimpanan HP (pengganti cloud). Penting karena tanpa sinkron, ganti HP berarti kehilangan data. Format berkas mencatat nomor versinya sendiri.

---

## 5. Fase A: Fitur Tambahan

Semua fitur di bagian ini tetap tanpa akun, cloud, atau server.

### 5.1 Inbox: tangkap dulu, rapikan nanti [W]

Masalah nyata: saat kamu sedang di kelas, memilih wadah, jenis, dan jam terasa menghambat.

- Tombol tambah cepat hanya meminta **satu baris teks**. Tugas masuk ke **Inbox** bila wadah atau tanggalnya belum jelas.
- Badge angka di tab Inbox. Layar Inbox menampilkan kartu, satu ketukan untuk melengkapi atau mengubah.
- Inbox yang menumpuk lebih dari 3 hari memicu satu notifikasi lembut: "Ada 4 catatan yang belum dirapikan."
- **Urutan pengerjaan:** di Fase A, Inbox menyimpan teks mentah dan kartunya diisi manual. Chip saran dari parser menyala setelah parser selesai di Fase B (6.1).

### 5.2 Subtugas dan progres [W]

- Checklist di dalam tugas (misalnya laprak: dasar teori, program, screenshot, kesimpulan).
- Cincin progres di kartu tugas. Menyelesaikan semua subtugas menawarkan "Tandai tugas selesai?" tanpa memaksa.
- Subtugas bisa diurutkan dengan geser dan dibuat massal dengan menempel beberapa baris teks.
- Subtugas ikut dihitung di skor: bila progres tinggi, estimasi sisa waktu (komponen T) dikurangi sesuai persentase selesai.

### 5.3 Jadwal kuliah mingguan [W]

Fondasi untuk banyak fitur lain.

- Setiap wadah punya slot kelas: hari, jam mulai, jam selesai, ruangan, jenis (kuliah atau praktikum). Satu matkul boleh punya beberapa slot.
- **Kelas Hari Ini:** kartu di atas layar Hari Ini yang menunjukkan kelas berikutnya dan sisa waktunya.
- **Jam efektif lebih akurat:** jam kuliah otomatis dikurangkan dari jam produktif di rumus skor urgensi, tidak lagi hanya memakai nilai bawaan 10 jam.
- **Pengingat kelas:** 30 menit sebelum mulai (bisa dimatikan per matkul).
- **Deteksi bentrok:** peringatan saat dua slot tumpang tindih atau saat deadline jatuh di tengah jam kelas.
- Pengisian cepat: salin slot dari hari lain. Setelah parser ada (Fase B), bisa juga ketik "basdat senin 08.00 10.30 lab2".

### 5.4 Tanggal mulai dan pengingat "mulai sekarang" [S]

Banyak tugas telat bukan karena lupa deadline, tetapi karena terlambat mulai.

- Tugas punya **tanggal mulai opsional**. Bila estimasi diisi dan tanggal mulai kosong, aplikasi menghitung **batas mulai** = deadline dikurangi (estimasi dikali faktor aman, bawaan 1,5).
- Satu pengingat "Waktunya mulai: laprak Basdat (estimasi 3 jam)" dikirim pada batas mulai, di dalam jam produktif dan di luar jam kelas.
- Kartu tugas menampilkan lencana kecil "Mulai paling lambat Rabu 16.00" bila batas mulai sudah dekat.

### 5.5 Tunda cerdas dan aksi cepat [W]

- Dari kartu atau notifikasi: **Tunda** membuka pilihan "1 jam", "Nanti malam 19.00", "Besok pagi 07.00", "Akhir pekan", atau "Pilih waktu".
- Tunda hanya menggeser **pengingat**, bukan deadline. Deadline hanya berubah lewat tombol Ubah Deadline.
- Geser kartu ke kanan untuk selesai, ke kiri untuk tunda (bisa diatur atau dimatikan).
- Ketuk lama untuk **aksi massal**: pilih beberapa tugas lalu ganti wadah, ganti prioritas, selesaikan, atau hapus sekaligus.

### 5.6 Riwayat perubahan deadline [S]

Situasi umum: dosen mengundur atau memajukan deadline lewat chat.

- Setiap perubahan deadline dicatat (deadline lama, baru, waktu, dan catatan opsional seperti "diundur dosen").
- Di detail tugas tampil garis kecil "Deadline diundur 2 kali". Berguna sebagai bukti bila ada perselisihan soal tenggat.
- Perubahan lain yang dicatat: status, selesai atau dibuka kembali, dan penundaan pengingat.

### 5.7 Ujian dan materi belajar [S]

- Tugas berjenis kuis, UTS, atau UAS mendapat tampilan khusus: **hitung mundur hari**, lokasi ruang ujian, dan jam mulai.
- **Daftar materi** memakai subtugas (satu bab atau topik per baris) sehingga progres belajar terlihat sebagai cincin.
- Catatan "yang sering keluar" dan tautan sumber bisa ditulis di catatan tugas.
- Hitung mundur ujian muncul di layar Hari Ini bila kurang dari 14 hari.

### 5.8 Timer fokus [S]

- Tombol mulai di detail tugas: timer 25/5 menit (bisa diatur), berjalan sebagai notifikasi berkelanjutan dan tetap hidup saat layar mati.
- Waktu kerja tercatat per tugas (`focus_sessions`).
- **Estimasi jadi lebih jujur:** setelah tugas selesai, aplikasi membandingkan estimasi dengan waktu nyata, lalu menyarankan koreksi untuk jenis yang sama, misalnya "Laprak biasanya kamu kerjakan 3,5 jam, bukan 2 jam."
- Tidak ada papan peringkat atau tekanan sosial. Hanya statistik pribadi.

### 5.9 Pin, tag, duplikat, dan templat [S]

- **Pin:** tugas yang disematkan selalu tampil di atas layar Hari Ini, di luar urutan skor.
- **Tag bebas** (misalnya #kelompok, #revisi, #beli). Penyaring bisa menggabungkan wadah, jenis, dan tag.
- **Duplikat tugas** dengan satu ketukan, berguna untuk laprak mingguan.
- **Templat tugas:** simpan susunan subtugas dan estimasi (misalnya "Laprak" dengan 5 subtugas). Tambah tugas baru dari templat langsung terisi.

### 5.10 Tugas berulang sederhana [B]

Tanpa RRULE. Hanya tiga pola: **harian, mingguan (hari tertentu), bulanan (tanggal tertentu)**.

- Contoh: kuis rutin tiap Kamis, bayar kos tiap tanggal 5.
- Saat satu kemunculan diselesaikan, kemunculan berikutnya dibuat otomatis. Tidak membuat banyak baris di muka.

### 5.11 Tempat sampah dan pemulihan [S]

- Hapus menjadi soft delete. Menu **Sampah** menyimpan 30 hari lalu dibersihkan otomatis oleh tugas harian.
- Wadah yang dihapus membawa tugas di dalamnya. Pulihkan satu per satu atau seluruh wadah.

### 5.12 Notifikasi pagi dan malam [S]

- **Ringkasan pagi** (bawaan 07.00): "Hari ini: 2 kelas, 3 tugas. Paling mendesak: laprak Basdat (deadline 23.59)."
- **Penutup malam** (bawaan 20.30, bisa dimatikan): "Ada 2 tugas besok. Mau cek sekarang?" Hanya tampil bila ada tugas berdeadline besok.
- Keduanya dihitung lokal dari database, tanpa server.

### 5.13 Keamanan lokal dan tampilan [B]

- Kunci aplikasi dengan sidik jari atau PIN (`local_auth`).
- Warna dinamis mengikuti wallpaper (Material You) sebagai pilihan.
- Pilihan ukuran kartu: nyaman atau ringkas.
- Penyembunyi isi notifikasi di layar kunci.

### 5.14 Mode SMA [B]

Mesin yang sama, dengan perbedaan tampilan.

- Istilah berubah: wadah disebut "Mapel", jenis tugas menjadi PR, ulangan harian, praktik, proyek.
- Jadwal pelajaran harian dengan jam pelajaran (bukan jam kuliah).
- Tidak ada SKS dan IPK, diganti rata-rata nilai per mapel.

### 5.15 Kontak cepat dan tautan kelas [S]

- Di detail wadah: tombol "Buka WhatsApp dosen", "Buka tautan kelas" (Google Classroom, LMS kampus, Zoom atau Meet), dan "Salin nomor ruangan".
- Tautan tersimpan di `space_meta` dan dibuka lewat browser atau aplikasi terkait.

---

## 6. Fase B: Alat Harian

### 6.1 Quick Add dengan Parser Bahasa Indonesia

**Pipeline**

1. **Normalisasi:** huruf kecil, rapikan spasi dan tanda baca, perluas singkatan (bsk jadi besok, jmt jadi jumat, mlm jadi malam, lusa, tgl).
2. **Ekstrak waktu** (relatif, nama hari, tanggal, jam).
3. **Ekstrak jenis** (kuis, uts, uas, laprak, presentasi, makalah).
4. **Ekstrak mode** (kelompok, individu, sendiri).
5. **Cocokkan wadah** lewat nama, kode, dan alias.
6. **Sisa teks jadi judul.**
7. **Tampilkan chip yang bisa diketuk untuk koreksi.** Tidak ada tebakan yang disimpan diam-diam.

**Aturan kasus tepi (tulis sebagai tes sebelum kode)**

| Input | Aturan |
| --- | --- |
| "jumat" saat hari ini Jumat | Ambil Jumat minggu depan |
| "jumat depan" | Jumat pada minggu kalender berikutnya |
| "minggu depan" tanpa hari | 7 hari dari sekarang, jam 23.59 |
| "minggu" sendirian | Anggap hari Minggu hanya bila ada kata "hari" atau konteks tanggal, selain itu minta koreksi lewat chip |
| Tanpa jam | Bawaan 23.59 |
| "jam 7" tanpa pagi atau malam | Pilih kemunculan terdekat di masa depan, tandai chip jam sebagai "perlu dicek" |
| "sebelum jam 12" | 12.00 siang pada hari yang disebut |
| "jam 7 malam", "19.00", "pukul 23.59" | Langsung diterima |
| "tgl 25" | Tanggal 25 terdekat di masa depan, lewat bulan bila perlu |
| "3 hari lagi" | Hari ini ditambah 3, jam 23.59 |
| Tanggal yang sudah lewat | Chip ditandai merah dengan pertanyaan "maksudnya bulan depan?" |

**Contoh keluaran**

| Input | Hasil |
| --- | --- |
| `laprak basdat jumat 23.59 individu` | Laprak, Basis Data, Jumat terdekat, 23.59, individu |
| `kuis pemweb besok jam 8` | Kuis, Pemrograman Web, besok 08.00 |
| `bayar listrik tgl 28` | Tanpa wadah matkul, tanggal 28 |

**Peningkatan**

- Aplikasi **belajar alias** dari koreksi: bila kamu mengubah wadah hasil tebakan, tawarkan "jadikan 'dbms' alias Basis Data?".
- Parser berupa modul Dart murni (tanpa Flutter) supaya mudah dites dengan ratusan kalimat.
- **Korpus uji:** kumpulkan 100+ kalimat asli dari grup kelasmu (hapus nama orang) sebelum menulis parser. Target akurasi 90% untuk tanggal dan 80% untuk wadah.
- Dukungan kalimat Inggris dan campuran dijelaskan di 8.5.

### 6.2 Share dari WhatsApp

- Aplikasi muncul di menu Bagikan Android untuk teks.
- Pesan panjang dipecah per kalimat. Kalimat yang mengandung kata kunci deadline ("dikumpul", "paling lambat", "batas", "deadline", "maksimal", "sebelum") diusulkan sebagai calon tugas.
- Layar hasil menampilkan **daftar calon tugas dengan kotak centang**, tiap calon dengan chip yang bisa dikoreksi. Satu pesan bisa menjadi beberapa tugas.
- Teks asli pesan disimpan di catatan tugas supaya syarat pengumpulan tidak hilang.
- Bila tidak ada kalimat berkata kunci, tampilkan seluruh pesan sebagai satu calon dengan judul yang bisa diubah.

### 6.3 Widget Layar Utama

- Ukuran kecil: 3 tugas teratas dari bagian Hari Ini, dengan sisa waktu.
- Ukuran sedang: ditambah tombol tambah cepat yang membuka Quick Add.
- Diperbarui saat tugas berubah dan lewat pembaruan berkala (jangan terlalu sering, hemat baterai).

### 6.4 Kalender

- Tampilan bulanan dengan titik berwarna per wadah, ketuk tanggal untuk melihat daftar hari itu.
- Penanda minggu tersibuk: tandai minggu dengan 3 deadline atau lebih.
- Satu arah saja (aplikasi ke tampilan). Tidak ada sinkron dengan Google Calendar di tahap ini.

### 6.5 Lampiran Sederhana

- Foto (dari kamera atau galeri) dan tautan. Disimpan di folder aplikasi, batas ukuran 10 MB per berkas.
- Dimasukkan ke ekspor cadangan sebagai berkas zip.

### 6.6 Fitur Murah yang Bernilai Tinggi

- **Prediksi nilai:** bila bobot komponen diisi, tampilkan "agar Basis Data minimal B, nilai UAS perlu minimal 72". Hitungan sederhana, cukup satu layar per matkul.
- **Ringkasan Minggu Malam:** satu notifikasi lokal berisi jumlah tugas selesai minggu ini, matkul terpadat minggu depan, dan deadline terdekat. Tanpa AI, hanya hitungan dari database.
- **Rekap nilai per matkul:** daftar skor tugas dan rata-rata berbobot.

---

## 7. Fase B: Fitur Tambahan

### 7.1 Quick Add suara [S]

- Tombol mikrofon di Quick Add memakai pengenalan suara bawaan Android (`speech_to_text`, bahasa Indonesia).
- Hasil teks langsung masuk parser dan tampil sebagai chip. Cocok saat tangan penuh atau di jalan.
- Hasil pengenalan sering salah mengeja angka. Parser perlu menerima "jam tujuh", "dua puluh lima oktober", dan angka dalam kata.

### 7.2 Pintasan cepat [S]

- **Pintasan ikon aplikasi** (tekan lama): Tambah Tugas, Hari Ini, Inbox.
- **Tile Quick Settings:** satu ketukan dari bilah notifikasi membuka Quick Add.
- **Notifikasi tetap opsional** dengan kolom ketik cepat (dimatikan secara bawaan agar tidak mengganggu).

### 7.3 Share dari tangkapan layar (OCR di HP) [S]

Banyak pengumuman datang sebagai gambar atau tangkapan layar.

- Bagikan gambar ke aplikasi. Teks dikenali **di perangkat** (`google_mlkit_text_recognition`, mode Latin, tidak butuh internet).
- Teks hasil OCR masuk pipeline yang sama dengan share teks WhatsApp (6.2): pecah per kalimat, cari kata kunci, usulkan calon tugas.
- Layar hasil menampilkan gambar asli di atas, jadi pengguna bisa memeriksa bila OCR salah baca.
- Gambar asli otomatis dilampirkan ke tugas.
- Batasan jujur: hasil OCR pada tulisan tangan atau foto miring akan buruk. Tampilkan peringatan dan jalur "ketik manual".

### 7.4 Share dari aplikasi lain [S]

- Telegram, email, Google Classroom, dan catatan mengirim teks lewat menu Bagikan yang sama.
- Tautan pengumuman ikut disimpan di tugas sebagai lampiran tautan.

### 7.5 Deteksi duplikat dan perubahan deadline [S]

Salah satu fitur yang paling terasa pintar tanpa memakai AI.

- Saat pesan dibagikan, bandingkan calon tugas dengan tugas yang sudah ada (kemiripan judul, wadah sama, tanggal berdekatan, pencocokan kata sederhana).
- Bila mirip, tampilkan kartu: **"Sepertinya ini tugas yang sudah ada: Laprak Basdat. Deadline di pesan: Sabtu 23.59 (sekarang: Jumat 23.59). Perbarui deadline?"**
- Kata pemicu: "diundur", "dimajukan", "perubahan", "revisi jadwal", "batal".
- Perubahan yang diterima masuk ke riwayat deadline (5.6).
- Pengguna selalu yang memutuskan. Tidak ada pembaruan otomatis.

### 7.6 Saran waktu kosong tanpa AI [S]

Versi ringan dari Smart Planner, murni aturan.

- Aplikasi mencari celah di antara kelas dan jam tidur hari ini dan besok yang panjangnya minimal 60 menit.
- Untuk tiga tugas teratas, tampilkan saran satu baris: "Kamu kosong 14.00 sampai 16.00. Mulai laprak Basdat (sisa estimasi 2 jam)?"
- Ketuk untuk membuat blok fokus (menjadi pengingat dan, bila dipakai, timer fokus).
- Penolakan berulang pada rentang jam tertentu menurunkan saran di jam itu (disimpan sebagai preferensi sederhana, misalnya jangan sarankan setelah 21.00).

### 7.7 Kalender yang lebih lengkap [S]

- Tiga tampilan: **bulan**, **minggu** (kelas dan deadline berdampingan), dan **agenda** (daftar kronologis).
- Warna per wadah, titik penanda jumlah deadline per hari, dan penanda hari ujian.
- **Impor ICS** (berkas kalender akademik kampus atau jadwal dari portal) dan **ekspor ICS** untuk dimasukkan ke Google Calendar secara manual.
- Tetap satu arah: tidak ada sinkron dua arah.

### 7.8 Widget lanjutan [S]

- Widget **Daftar Tugas** (3 sampai 6 baris) dengan kotak centang yang bisa diketuk langsung.
- Widget **Kelas Hari Ini** (jadwal singkat).
- Widget **Hitung Mundur Ujian**.
- Tombol tambah cepat di tiap widget.
- Pembaruan saat data berubah dan setiap 30 menit sebagai cadangan.

### 7.9 Nilai, IPS, dan IPK [S]

- Wadah punya **SKS**, **target nilai huruf**, dan **nilai akhir**.
- Prediksi nilai dari komponen berbobot (UTS, UAS, tugas, kuis) dengan penjelasan: "Agar B, UAS perlu minimal 72."
- **IPS per semester** dan **IPK kumulatif** dihitung otomatis dari nilai akhir dan SKS. Skala nilai bisa diatur (A=4, B=3, dan seterusnya) karena beda kampus beda skala.
- **Simulator target IPK:** "Untuk IPK 3,50 di semester ini, rata-rata kamu butuh B+ di semua matkul."

### 7.10 Rencana belajar ujian otomatis [S]

- Saat tugas ujian dibuat, tawarkan **jadwal belajar**: pengingat H-7, H-3, dan H-1 yang berbunyi "Mulai ulangi bab 1 sampai 3", dibagi sesuai jumlah materi di daftar subtugas.
- Pengguna bisa mengedit atau menolak seluruh rencana. Tidak ada yang dijadwalkan tanpa persetujuan.

### 7.11 Statistik pribadi dan rekap semester [B]

- Persentase tugas tepat waktu, rata-rata selisih antara selesai dan deadline, matkul paling padat, hari paling sibuk.
- Ringkasan akhir semester: total tugas selesai, jam fokus, deadline yang diundur, dan rekap nilai. Bisa dibagikan sebagai gambar teks.
- Tidak ada skor sosial, lencana, atau peringkat.

### 7.12 Bagikan sebagai teks [B]

- Bagikan satu tugas atau daftar minggu ini ke WhatsApp sebagai teks rapi (judul, deadline, catatan, subtugas).
- Berguna untuk kerja kelompok tanpa membuat sistem kolaborasi: "Ini pembagian tugas kita" lalu teman menyalin ke catatan masing-masing.

### 7.13 Cadangan otomatis [S]

- Selain ekspor manual (4.7), aplikasi membuat cadangan JSON dan lampiran mingguan ke **folder yang dipilih pengguna** (lewat pemilih folder Android). Bila folder itu disinkronkan Google Drive atau Syncthing, datamu otomatis aman.
- Simpan 4 cadangan terakhir. Tampilkan tanggal cadangan terakhir di Pengaturan, dan peringatkan bila lebih dari 14 hari.
- Pemulihan menunjukkan pratinjau jumlah wadah dan tugas sebelum menimpa data.

### 7.14 Impor dari aplikasi lain [B]

- Impor CSV sederhana (judul, tanggal, wadah) untuk pindahan dari aplikasi lain atau dari spreadsheet.
- Pemetaan kolom dipilih sendiri oleh pengguna di layar impor.

---

## 8. Dukungan Dua Bahasa (Indonesia Bawaan, Inggris Pilihan)

**Keputusan:** bahasa bawaan aplikasi adalah **Indonesia (`id`)**. Pengguna bisa memilih **Inggris (`en`)** di Pengaturan, berlaku langsung tanpa restart. Aplikasi tidak otomatis mengikuti bahasa sistem HP, kecuali pengguna memilih opsi "Ikuti sistem".

Keputusan ini diambil di awal karena menambah bahasa belakangan berarti menyisir ulang semua layar, pengingat, widget, dan parser.

### 8.1 Prinsip

1. Bahasa Indonesia adalah **bahasa templat**: semua teks ditulis lengkap dalam Indonesia lebih dulu, Inggris menyusul.
2. **Tidak ada teks tampilan yang ditulis langsung di kode.** Semua lewat `AppLocalizations`.
3. **Database menyimpan kunci netral, bukan teks terjemahan.**
4. Mengganti bahasa harus ikut memperbarui pengingat terjadwal, notifikasi berkala, dan widget.
5. Parser Quick Add mengenali kedua bahasa, bahasa aktif diprioritaskan.

### 8.2 Pengaturan Flutter

`pubspec.yaml`:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

`l10n.yaml`:

```yaml
arb-dir: lib/l10n
template-arb-file: app_id.arb
output-localization-file: app_localizations.dart
```

Berkas terjemahan di `lib/l10n/`:

```json
{
  "@@locale": "id",
  "todayTitle": "Hari Ini",
  "tasksCount": "{count} tugas",
  "@tasksCount": { "placeholders": { "count": { "type": "int" } } }
}
```

Berkas `app_en.arb` memakai kunci yang sama dengan isi bahasa Inggris (`"todayTitle": "Today"`).

`MaterialApp`:

```dart
MaterialApp(
  locale: ref.watch(localeProvider),   // bawaan Locale('id')
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
)
```

Pilihan bahasa disimpan di tabel `settings` dengan kunci `language` dan nilai `id`, `en`, atau `system`. `localeProvider` (Riverpod) membaca nilai itu saat start dan memicu `MaterialApp` dibangun ulang saat berubah.

### 8.3 Aturan Data: simpan kunci, bukan teks

Terjemahan hanya terjadi di lapisan tampilan.

| Data | Disimpan di database | Ditampilkan (id / en) |
| --- | --- | --- |
| Jenis tugas | `quiz` | Kuis / Quiz |
| Jenis tugas | `lab_report` | Laprak / Lab report |
| Jenis tugas | `midterm` | UTS / Midterm |
| Jenis tugas | `final` | UAS / Final exam |
| Status | `doing` | Dikerjakan / In progress |
| Prioritas | `2` | Tinggi / High |
| Jenis kelas | `lab` | Praktikum / Lab session |
| Kunci meta | `lecturer` | Dosen / Lecturer |

Akibatnya: tugas yang dibuat saat bahasa Indonesia tetap benar saat bahasa diganti, berkas cadangan tidak bergantung bahasa, dan pencarian atau penyaring tidak terpengaruh. Hanya teks yang diketik pengguna sendiri (judul, catatan, nama matkul) tidak diterjemahkan.

Daftar lengkap kunci netral ada di skema (bagian 10).

### 8.4 Pengingat, Notifikasi, dan Widget

Teks notifikasi dibuat saat penjadwalan, jadi pengingat lama akan tetap berbahasa lama setelah bahasa diganti.

- Saat `language` berubah, `ReminderService` **membatalkan dan menjadwalkan ulang** semua pengingat aktif dengan teks bahasa baru.
- Ringkasan pagi, penutup malam, dan ringkasan mingguan dijadwalkan ulang dengan cara yang sama.
- Widget dipaksa memperbarui tampilannya (`home_widget`) dan nama widget di pemilih widget memakai `strings.xml`.
- Kanal notifikasi Android (deadline, terlambat, ringkasan) mengambil nama dari bahasa saat pertama dibuat. Perbarui namanya lewat pembuatan ulang kanal dengan ID yang sama bila bahasa berubah.
- Contoh teks:

| Kunci | Indonesia | Inggris |
| --- | --- | --- |
| `reminderH1` | "Deadline 1 jam lagi: {title}" | "Due in 1 hour: {title}" |
| `morningSummary` | "Hari ini: {classes} kelas, {tasks} tugas." | "Today: {classes} classes, {tasks} tasks." |
| `snooze1h` | "Tunda 1 jam" | "Snooze 1 hour" |

### 8.5 Parser Quick Add Dua Bahasa

Bagian paling berat dari fitur ini.

**Struktur**

```
parser/
  dictionaries/
    id.dart     # hari, bulan, besok, lusa, singkatan, kata kunci jenis, dll.
    en.dart     # monday, tomorrow, next week, 11pm, midterm, dll.
  normalizer.dart
  time_extractor.dart
  matcher.dart
```

**Aturan pemakaian kamus**

1. Parser memakai **kamus bahasa aktif lebih dulu**, lalu kamus bahasa lain sebagai cadangan. Pengguna yang mengetik campuran ("submit laprak friday 23.59") tetap terbaca.
2. Kata yang bentrok antar bahasa dicatat secara eksplisit. Contoh: "minggu" (Indonesia: Sunday atau week), "sat" (Inggris: Saturday, singkatan), "rabu" tidak bentrok. Bila bentrok, bahasa aktif menang dan chip ditandai "perlu dicek".
3. Format jam menerima keduanya: "jam 7 malam", "19.00", "7pm", "7:00 PM", "at 7".
4. Alias matkul buatan pengguna berlaku untuk kedua bahasa.
5. Jenis tugas dipetakan ke **kunci netral** (8.3), bukan teks, sehingga "kuis" dan "quiz" menghasilkan `quiz` yang sama.

**Kasus tepi tambahan**

| Input | Aturan |
| --- | --- |
| `lab report db friday 11:59pm` | Jenis `lab_report`, wadah cocok alias "db", Jumat terdekat, 23.59 |
| `quiz web tomorrow 8am` | Jenis `quiz`, besok 08.00 |
| `kuis web tomorrow` | Campuran, tetap terbaca: `quiz`, besok 23.59 |
| `sunday` saat bahasa aktif Indonesia | Tetap dikenali sebagai hari Minggu |
| `minggu` saat bahasa aktif Inggris | Chip "perlu dicek" (hari Minggu atau minggu depan) |
| `next friday` | Jumat pada minggu kalender berikutnya (sama dengan "jumat depan") |

**Strategi bertahap bila waktu mepet:** rilis awal dengan parser Indonesia saja, dan bahasa Inggris hanya untuk tampilan. Kamus Inggris ditambahkan di akhir Fase B tanpa mengubah antarmuka parser, karena kamus sudah dipisah per berkas.

### 8.6 Format Tanggal, Angka, dan Satuan

- Semua tanggal dan jam ditampilkan lewat `intl` (`DateFormat.yMMMEd(locale)`, `DateFormat.Hm(locale)`), tidak disusun dengan string manual.
- Panggil `initializeDateFormatting()` saat start.
- Hari pertama minggu: Senin di kedua bahasa agar konsisten, bisa diatur untuk kalender.
- Format 24 jam bawaan di kedua bahasa, dengan opsi 12 jam di Pengaturan.
- Pluralisasi memakai fitur ICU di berkas ARB (`{count, plural, ...}`), karena bahasa Inggris membedakan satu dan banyak, sedangkan Indonesia tidak.

### 8.7 Teks Native Android

- `android/app/src/main/res/values/strings.xml`: Inggris (cadangan).
- `android/app/src/main/res/values-in/strings.xml`: Indonesia (Android memakai kode lama `in`, bukan `id`).
- Isi: nama aplikasi, label widget, pintasan ikon (Tambah Tugas, Hari Ini, Inbox), nama tile Quick Settings, dan deskripsi izin.
- Nama aplikasi yang tampil di peluncur mengikuti bahasa **sistem**, bukan pilihan di dalam aplikasi. Ini keterbatasan Android, cukup dicatat di Pengaturan agar pengguna tidak bingung.

### 8.8 Pemilih Bahasa di Aplikasi

- **Onboarding:** langkah pertama (4.1).
- **Pengaturan:** Bahasa dengan tiga pilihan: Indonesia, English, Ikuti sistem.
- Perubahan langsung terlihat. Tampilkan satu snackbar "Pengingat diperbarui" setelah penjadwalan ulang selesai.
- Pilihan bahasa ikut diekspor di berkas cadangan JSON, tetapi saat impor aplikasi menanyakan apakah bahasa ikut dipulihkan.

### 8.9 Alur Kerja Penerjemahan

1. Tulis semua teks baru langsung di `app_id.arb`.
2. Jalankan `flutter gen-l10n` dan pastikan kompilasi lulus.
3. Terjemahkan ke `app_en.arb` (AI cocok untuk ini). Periksa istilah akademik secara manual: laprak menjadi lab report, UTS menjadi midterm, UAS menjadi final exam, SKS menjadi credits, dosen menjadi lecturer, matkul menjadi course.
4. Aktifkan `untranslated-messages-file` di `l10n.yaml` supaya kunci yang belum diterjemahkan tercatat.
5. Pemeriksaan sebelum rilis: `grep -rn "Text('" lib/features` dan `grep -rn 'Text("' lib/features` harus kosong, tanda tidak ada teks yang ditulis langsung di kode.

### 8.10 Perkiraan Usaha

| Pekerjaan | Fase | Usaha (hari) |
| --- | --- | --- |
| Struktur ARB, pemilih bahasa, `localeProvider` | A | 1 sampai 2 |
| Menulis semua teks lewat `AppLocalizations` (tambahan kecil per layar) | A dan B | 3 (tersebar) |
| Terjemahan Inggris dan pemeriksaan istilah | A dan B | 3 (tersebar) |
| Penjadwalan ulang pengingat dan widget saat ganti bahasa | A | 1 |
| Teks native Android (`strings.xml`) | A | 0,5 |
| Kamus parser Inggris, tes, dan kasus campuran | B | 3 |

Total sekitar 11 sampai 12 hari kerja. Sebagian besar tersebar di tiap fitur sehingga terasa kecil bila disiplin sejak hari pertama. Kerja yang tertinggal dan menumpuk belakangan akan jauh lebih mahal.

---

## 9. Arsitektur Teknis

**Tumpukan yang disarankan**

- Flutter dan Dart
- Drift (SQLite) untuk database lokal
- Riverpod untuk state management
- `flutter_local_notifications` plus penjadwalan zona waktu (`timezone`)
- `receive_sharing_intent` untuk menerima teks dan gambar dari menu Bagikan
- `home_widget` untuk widget
- `share_plus` dan `file_picker` untuk ekspor dan impor
- Paket tambahan sesuai fitur: `speech_to_text` (7.1), `google_mlkit_text_recognition` (7.3), `local_auth` (5.13)

**Struktur folder**

```
lib/
  core/        # tema, konstanta, scoring_config, util tanggal
  data/        # tabel Drift, DAO, repository
  domain/      # model Task, Space, aturan skor urgensi
  parser/      # modul Dart murni
    dictionaries/   # id.dart, en.dart
    normalizer.dart
    time_extractor.dart
    matcher.dart
  reminders/   # ReminderService, boot handler, kanal notifikasi
  features/
    today/
    tasks/
    spaces/
    quick_add/
    share_intake/
    calendar/
    settings/
  l10n/        # app_id.arb, app_en.arb
```

**Prinsip**

- Logika skor dan parser tidak boleh bergantung pada Flutter, supaya bisa dites cepat.
- Satu repository per entitas, UI tidak menyentuh database langsung.
- Waktu selalu disimpan sebagai UTC epoch dan ditampilkan lokal.
- Teks tampilan tidak pernah ditulis langsung di kode (bagian 8).

---

## 10. Skema Database

Aplikasi belum dirilis, jadi seluruh perubahan dari fitur tambahan sudah digabung langsung ke **skema versi pertama**. Semua kolom jenis, status, dan kunci hanya memuat **kunci netral** (bagian 8.3).

```sql
CREATE TABLE spaces (
  id TEXT PRIMARY KEY,           -- UUID
  name TEXT NOT NULL,
  code TEXT,
  color INTEGER NOT NULL,
  level TEXT,                    -- college | school | personal
  period TEXT,                   -- contoh: Ganjil 2026/2027
  sks INTEGER,                   -- SKS (jumlah kredit)
  target_grade TEXT,
  final_grade TEXT,
  archived INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);

CREATE TABLE space_aliases (
  space_id TEXT NOT NULL REFERENCES spaces(id),
  alias TEXT NOT NULL,
  PRIMARY KEY (space_id, alias)
);

CREATE TABLE space_meta (
  space_id TEXT NOT NULL REFERENCES spaces(id),
  key TEXT NOT NULL,             -- lecturer | room | link
  value TEXT,
  PRIMARY KEY (space_id, key)
);

CREATE TABLE tasks (
  id TEXT PRIMARY KEY,           -- UUID
  space_id TEXT REFERENCES spaces(id),   -- NULL untuk Inbox atau tugas tanpa wadah
  title TEXT NOT NULL,
  notes TEXT,
  type TEXT,                     -- quiz | lab_report | paper | presentation | midterm | final | other
  deadline INTEGER,              -- UTC epoch ms, NULL = kapan-kapan
  start_at INTEGER,              -- tanggal mulai opsional
  priority INTEGER DEFAULT 1,    -- 0 rendah, 1 sedang, 2 tinggi
  status TEXT DEFAULT 'todo',    -- todo | doing | revision | done
  weight_percent REAL,
  score_obtained REAL,           -- nilai yang didapat (untuk rekap)
  estimate_minutes INTEGER,
  is_group INTEGER DEFAULT 0,
  pinned INTEGER DEFAULT 0,
  inbox INTEGER DEFAULT 0,       -- 1 = masih di Inbox
  repeat_kind TEXT,              -- none | daily | weekly | monthly
  repeat_every INTEGER,          -- hari dalam pekan atau tanggal dalam bulan
  source_text TEXT,              -- pesan asli bila dari share
  created_at INTEGER NOT NULL,
  completed_at INTEGER,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);

CREATE INDEX idx_tasks_space_deadline ON tasks(space_id, deadline);
CREATE INDEX idx_tasks_status_deadline ON tasks(status, deadline);

CREATE TABLE subtasks (
  id TEXT PRIMARY KEY,
  task_id TEXT NOT NULL REFERENCES tasks(id),
  title TEXT NOT NULL,
  done INTEGER DEFAULT 0,
  sort_order INTEGER DEFAULT 0,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);

CREATE TABLE class_slots (
  id TEXT PRIMARY KEY,
  space_id TEXT NOT NULL REFERENCES spaces(id),
  weekday INTEGER NOT NULL,      -- 1 Senin sampai 7 Minggu
  start_min INTEGER NOT NULL,    -- menit sejak 00.00
  end_min INTEGER NOT NULL,
  room TEXT,
  kind TEXT DEFAULT 'lecture',   -- lecture | lab
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);

CREATE TABLE tags (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE task_tags (
  task_id TEXT NOT NULL REFERENCES tasks(id),
  tag_id TEXT NOT NULL REFERENCES tags(id),
  PRIMARY KEY (task_id, tag_id)
);

CREATE TABLE attachments (
  id TEXT PRIMARY KEY,
  task_id TEXT NOT NULL REFERENCES tasks(id),
  kind TEXT NOT NULL,            -- image | link
  path_or_url TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE TABLE reminders (
  id TEXT PRIMARY KEY,
  task_id TEXT REFERENCES tasks(id),          -- NULL untuk pengingat kelas
  class_slot_id TEXT REFERENCES class_slots(id),
  fire_at INTEGER NOT NULL,
  kind TEXT,                     -- d3 | d1 | h3 | m30 | start | study | class | snooze
                                 -- (d = hari sebelum deadline, h = jam, m = menit)
  notif_id INTEGER NOT NULL,
  fired INTEGER DEFAULT 0
);

CREATE TABLE task_events (
  id TEXT PRIMARY KEY,
  task_id TEXT NOT NULL REFERENCES tasks(id),
  kind TEXT NOT NULL,            -- deadline_changed | status_changed | snoozed | reopened
  old_value TEXT,
  new_value TEXT,
  note TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE focus_sessions (
  id TEXT PRIMARY KEY,
  task_id TEXT NOT NULL REFERENCES tasks(id),
  started_at INTEGER NOT NULL,
  duration_sec INTEGER NOT NULL
);

CREATE TABLE task_templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT,
  estimate_minutes INTEGER,
  subtasks_json TEXT             -- daftar judul subtugas
);

CREATE TABLE parser_prefs (
  key TEXT PRIMARY KEY,          -- contoh: reject_after_hour, learned_alias
  value TEXT
);

CREATE TABLE settings (
  key TEXT PRIMARY KEY,          -- contoh: language (id | en | system)
  value TEXT
);
```

**Catatan**

- Kolom `score` tidak ada: skor dihitung saat tampil.
- Tabel `sync_queue` dan kolom `sync_status` tidak ada karena belum ada sinkron. UUID, `updated_at`, dan `deleted_at` dipertahankan supaya sinkron bisa ditambah nanti tanpa migrasi besar.
- Alias dipisah ke tabel sendiri supaya pencarian parser lebih rapi daripada teks dipisah koma.
- **Inbox** tidak butuh tabel baru: tugas dengan `inbox = 1` dan `space_id` kosong.
- **Ujian** memakai tabel `tasks` dengan `type` `quiz`, `midterm`, atau `final`. Materi belajar memakai `subtasks`. Tidak perlu tabel ujian terpisah.
- Nilai komponen untuk prediksi memakai `weight_percent` dan `score_obtained` di `tasks`.
- Wajib pakai **migrasi Drift yang bernomor** sejak versi pertama, supaya pembaruan aplikasi tidak menghapus data.
- Impor dan ekspor cadangan harus menyertakan semua tabel, dan **versi format berkas cadangan dicatat di dalam berkas** supaya cadangan lama tetap bisa dibaca.

---

## 11. Desain dan Pengalaman

- **Warna:** satu warna aksen, 12 warna wadah, status terlambat merah, hampir kuning, selesai hijau. Status tidak hanya dibedakan warna, ada ikon dan teks.
- **Komponen inti:** TaskCard, SpaceChip, DeadlineBadge, PriorityDot, BottomSheetForm, EmptyState, UndoSnackbar.
- **Jarak** kelipatan 4, area ketuk minimal 48 dp, mendukung pembesaran font sistem, label TalkBack.
- **Gerak** 150 sampai 250 ms, centang selesai dengan animasi kecil dan getar ringan.
- **Empty state ramah:** "Belum ada tugas hari ini. Nikmati waktumu, atau rencanakan besok?"
- **Microcopy tidak menyalahkan:** "Tugas ini sudah lewat deadline. Mau tandai selesai atau atur ulang?"

---

## 12. Pengujian

### 12.1 Inti (Fase A dan B)

| Area | Cara uji |
| --- | --- |
| Parser | Unit test dari 100+ kalimat asli kelasmu, ditambah tabel kasus tepi di 6.1 |
| Skor urgensi | Unit test: terlambat, tanpa deadline, deadline 1 menit lagi, estimasi kosong, jam efektif nol |
| Pengingat | Uji manual di HP nyata: setelah restart, mode hemat baterai, ganti zona waktu, izin alarm ditolak |
| Merek HP | Minta teman memakai Xiaomi, Oppo, Realme, Samsung selama 1 minggu dan lapor pengingat yang tidak muncul |
| Cadangan | Ekspor, hapus aplikasi, pasang ulang, impor, bandingkan jumlah data |
| Migrasi | Pasang versi lama, isi data, pasang versi baru, pastikan data utuh |
| Performa | Isi 3.000 tugas buatan, pastikan layar Hari Ini tetap lancar di HP RAM 3 GB |
| Aksesibilitas | TalkBack, font terbesar, mode gelap |

### 12.2 Fitur tambahan

| Area | Cara uji |
| --- | --- |
| Jadwal kuliah | Unit test bentrok slot, slot melewati tengah malam, dan perhitungan jam efektif |
| Batas mulai | Test dengan estimasi kosong, deadline lampau, dan estimasi lebih panjang dari waktu tersisa |
| Deteksi duplikat | 30 pasang pesan (sama, mirip, berbeda) dan ukur salah tebak |
| OCR | 20 tangkapan layar pengumuman asli, catat persentase kalimat yang terbaca benar |
| Timer fokus | Layar mati, aplikasi ditutup paksa, HP restart saat timer berjalan |
| Cadangan otomatis | Folder dihapus atau izin dicabut, tampilkan pesan jelas dan jangan gagal diam-diam |
| Impor ICS | Berkas dari Google Calendar, portal kampus, dan zona waktu berbeda |
| IPK | Bandingkan hasil dengan perhitungan manual dua semester |
| Aksi massal | 200 tugas terpilih sekaligus, pastikan tidak macet dan undo tetap bekerja |

### 12.3 Dua bahasa

| Area | Cara uji |
| --- | --- |
| Penjadwalan ulang | Buat 5 tugas dengan pengingat, ganti bahasa, pastikan teks notifikasi berikutnya berbahasa baru |
| Data netral | Buat tugas di bahasa Indonesia, ganti ke Inggris, ekspor lalu impor, pastikan jenis dan status tetap benar |
| Parser | Korpus uji dua set (Indonesia dan Inggris) ditambah 30 kalimat campuran, target akurasi tanggal 90% |
| Panjang teks | Periksa tombol dan chip tidak terpotong di bahasa Inggris dan font terbesar |
| Widget | Ganti bahasa, pastikan widget memperbarui teks tanpa harus dihapus dan dipasang ulang |
| Format | Bandingkan format tanggal dan jam di kedua bahasa, termasuk mode 12 jam |
| Cadangan | Impor cadangan dari bahasa lain, pastikan opsi bahasa bekerja sesuai pilihan |
| Aksesibilitas | TalkBack di kedua bahasa, label terbaca dengan pelafalan yang benar |

---

## 13. Jadwal Kerja

Perkiraan total **16 sampai 20 minggu** paruh waktu (bukan 10 minggu seperti rencana inti awal), **belum termasuk dua bahasa** (sekitar 11 sampai 12 hari, bagian 8.10). Urutan di bawah dirancang supaya selalu ada titik berhenti yang aman.

### Tahap 1: Fase A inti + semua [W] (sekitar 7 minggu)

Rincian lima minggu inti:

- Minggu 1: struktur proyek, tema, database Drift, wadah dan tugas (CRUD).
- Minggu 2: skor urgensi, layar Hari Ini, bagian dan alasan, undo.
- Minggu 3: ReminderService, izin, boot receiver, layar Cek Pengingat.
- Minggu 4: uji pengingat di HP nyata, perbaikan, pencarian, penyaring.
- Minggu 5: ekspor dan impor cadangan, onboarding, mode gelap, rapikan.

Sekitar dua minggu berikutnya untuk fitur [W]: Inbox, subtugas, jadwal kuliah, tunda cerdas dan aksi massal.

**Titik berhenti 1:** pakai sendiri 1 minggu penuh. Lanjut hanya bila tidak ada pengingat yang hilang.

### Tahap 2: Fase A [S] terpilih (sekitar 2 minggu)

Tanggal mulai, riwayat deadline, ujian, ringkasan pagi dan malam, tempat sampah.

### Tahap 3: Fase B inti (sekitar 5 minggu)

- Minggu B1: kumpulkan korpus kalimat, tulis tes parser.
- Minggu B2: parser waktu dan wadah sampai tes lulus, UI chip (Inbox mulai mendapat saran parser).
- Minggu B3: share dari WhatsApp dan layar calon tugas.
- Minggu B4: widget dasar dan kalender bulanan.
- Minggu B5: lampiran, prediksi nilai, ringkasan minggu malam, uji teman 1 minggu.

**Titik berhenti 2:** uji dengan 5 teman selama 1 minggu.

### Tahap 4: Fase B [S] terpilih (sekitar 4 sampai 6 minggu)

OCR, deteksi duplikat dan perubahan deadline, nilai dan IPK, cadangan otomatis, rencana belajar ujian, share dari aplikasi lain.

### Tahap 5: Sisa [S] dan semua [B] (hanya bila waktu dan semangat masih ada)

Timer fokus, pin dan tag, kontak kelas, suara, pintasan, saran waktu kosong, kalender lengkap, widget lanjutan, tugas berulang, kunci aplikasi dan mode SMA, statistik, bagikan teks dan impor CSV.

**Definisi selesai tiap tahap:** dipakai nyata minimal 1 minggu oleh pembuatnya tanpa kehilangan satu pengingat pun.

**Aturan pemotongan** (bagian 1): buang urut dari bawah tabel prioritas bila waktu mepet.

---

## 14. Cara Bekerja dengan AI agar Tidak Macet

1. Simpan `ARCHITECTURE.md` berisi struktur folder, keputusan penting, skema database, dan aturan (misalnya "skor tidak disimpan", "database hanya menyimpan kunci netral"). Tempel di awal tiap sesi baru.
2. **Satu fitur per sesi.** Selesaikan, jalankan, commit, baru lanjut.
3. Commit kecil dan sering di GitHub. Bila AI merusak sesuatu, kembali ke commit terakhir yang baik.
4. Minta AI menulis tes sebelum atau bersama kode, terutama untuk parser dan skor.
5. Sebelum mengubah bagian lama, minta AI menjelaskan dulu apa yang akan disentuh.
6. Sisihkan waktu khusus untuk debugging pengingat di HP nyata, karena itu bagian yang tidak bisa diuji AI.

---

## 15. Risiko dan Penangkal

| Risiko | Penangkal |
| --- | --- |
| Scope melebar | Daftar parkir, aturan satu fitur per sesi, aturan pemotongan |
| Pengingat hilang di merek tertentu | Layar Cek Pengingat, uji dini di HP teman |
| Parser salah tebak lalu pengguna kehilangan kepercayaan | Chip yang bisa dikoreksi, tidak ada penyimpanan diam-diam |
| Data hilang karena ganti HP atau pasang ulang | Ekspor dan impor cadangan, pengingat cadangan berkala |
| Kode berantakan setelah banyak iterasi | ARCHITECTURE.md, tes, commit kecil |
| Kehilangan motivasi | Titik berhenti jelas: Fase A saja sudah aplikasi yang berguna |
| Pekerjaan terjemahan menumpuk di akhir | Tulis teks lewat lokalisasi sejak hari pertama, grep sebelum rilis (8.9) |

---

## 16. Gambaran Satu Hari Bersama Aplikasi

Gambaran ini memakai fitur dari seluruh tahap, jadi sebagian baru nyata di Tahap 3 sampai 5.

**07.00** Notifikasi pagi: "Hari ini 2 kelas, 3 tugas. Paling mendesak: laprak Basdat (deadline 23.59)." Di widget terlihat Kelas Hari Ini.

**09.40** Di kelas, dosen menyebut kuis Pemweb besok. Kamu membuka Quick Add, menekan mikrofon, dan berkata "kuis pemweb besok jam delapan". Chip muncul: Kuis, Pemrograman Web, besok 08.00. Satu ketukan menyimpan.

**12.15** Grup kelas mengirim tangkapan layar pengumuman. Kamu bagikan ke aplikasi. OCR mengenali dua kalimat deadline, dan aplikasi mencatat bahwa salah satunya sepertinya mengubah deadline tugas yang sudah ada. Kamu menyetujui, dan riwayat deadline mencatat "diundur".

**14.00** Saran waktu kosong: "Kamu kosong sampai 16.00. Mulai laprak Basdat?" Kamu menyalakan timer fokus 25 menit.

**20.30** Penutup malam: "Ada 2 tugas besok." Kamu menunda satu pengingat ke pagi hari dan tidur tenang.

**Minggu malam** Ringkasan mingguan: tugas tepat waktu, matkul terpadat minggu depan, dan satu kartu cadangan: "Cadangan terakhir 6 hari lalu."

---

## Lampiran A: Daftar Perubahan dari v2 Awal

**Struktur**

- Bagian 13 sampai 22 dilebur ke alur utama. Bagian 22.11 ("Dampak pada Skema dan Bagian Lain") dihapus karena semua dampaknya sudah diterapkan langsung: langkah bahasa di onboarding (4.1), baris bahasa di 4.7, kamus parser terpisah (8.5 dan 9), pengujian bahasa (12.3), dan folder `l10n/` (9).
- Tiga daftar parkir (bagian 1, 12, 21) menjadi satu.
- Tiga jadwal (bagian 9, 18, dan usaha di 22.12) menjadi satu di bagian 13 dan 3.
- Tiga tabel pengujian (bagian 8, 19, 22.10) menjadi satu bagian 12 dengan tiga kelompok.
- Penomoran fitur tambahan sekarang berurutan per fase (5.x untuk Fase A, 7.x untuk Fase B).

**Isi yang disesuaikan**

- **Skema:** perintah `ALTER TABLE` digabung ke `CREATE TABLE` (aplikasi belum rilis). Kolom `inbox` ditambahkan karena sebelumnya hanya disebut di catatan. Nilai jenjang, jenis kelas, jenis pengingat, dan kunci meta diseragamkan ke kunci netral Inggris sesuai aturan 8.3.
- **Konflik nama kunci yang diperbaiki:** jenis kelas di skema `praktikum` tetapi di 22.3 `lab` (sekarang `lab`, dan `kuliah` menjadi `lecture`). Kunci meta `dosen` menjadi `lecturer`. Kunci meta `sks` dihapus karena SKS sudah menjadi kolom `spaces.sks`.
- **Tabel `reminders`:** `task_id` menjadi boleh kosong dan ditambah `class_slot_id`, karena pengingat kelas (5.3) tidak punya tugas. Jenis pengingat `start`, `study`, dan `class` ditambahkan untuk fitur 5.4, 7.10, dan 5.3.
- **Layar Hari Ini (4.4):** urutan digabung dengan tambahan dari fitur lain (kartu kelas, pin, hitung mundur ujian). Posisi hitung mundur ujian di antara "Sedang dikerjakan" dan "Minggu ini" adalah penempatan saya karena sebelumnya hanya tertulis "muncul di layar Hari Ini".
- **Inbox dan parser (5.1):** Inbox [W] ada di Fase A, tetapi saran dari parser baru ada di Fase B. Saya tulis eksplisit bahwa Inbox Fase A berisi teks mentah dan saran parser menyala belakangan.
- **Jadwal kuliah (5.3):** pengisian lewat ketikan "basdat senin 08.00..." ditandai baru bisa setelah parser ada.
- **Usaha:** total fitur dikoreksi (Sebaiknya 50 menjadi 56, Bonus 16 menjadi 13). "Share dari aplikasi lain" (7.4) ditambahkan ke tabel dengan perkiraan 1 hari.
- **Tahap:** kolom Tahap ditambahkan ke tabel prioritas supaya setiap fitur punya tempat di jadwal. Fitur [S] yang tidak disebut di jadwal lama ditempatkan di Tahap 5 (bertanda `*`).
- Perbaikan kecil: "Tampilan tersibuk" menjadi "Penanda minggu tersibuk" (6.4), rumus batas mulai di 5.4 ditulis dengan tanda kurung supaya tidak ambigu, dan jenis tugas `quiz` dan `final` ditambahkan ke tabel kunci netral.

**Tidak diubah:** semua keputusan produk, rumus skor, aturan parser, daftar fitur, dan isi tiap fitur.

---

## Lampiran B: Hal yang Perlu Diputuskan

1. **Pengingat di jam tenang.** Deadline bawaan 23.59 dan jam tenang 22.00 sampai 06.00, sehingga pengingat "30 menit sebelum" (sekitar 23.29) selalu jatuh di jam tenang, begitu juga pengingat 1 jam. Tentukan aturannya: digeser ke sebelum jam tenang, dikecualikan bila deadline kurang dari 1 jam, atau digabung ke satu notifikasi sebelum jam tenang. Selain itu, jam tidur untuk skor (23.00 sampai 06.00, bagian 4.5) dan jam tenang notifikasi (22.00 sampai 06.00) berbeda. Sengaja atau perlu disamakan?
2. **Penjadwalan 14 hari ke depan.** Di 4.6 tertulis "dijadwalkan ulang oleh tugas harian saat aplikasi dibuka". Bila aplikasi tidak dibuka lebih dari 14 hari, pengingat yang jauh bisa tidak pernah terjadwal. Pertimbangkan tugas latar periodik (misalnya WorkManager) selain pemicu saat aplikasi dibuka, karena target utamamu adalah tidak kehilangan satu pengingat pun.
3. **Dua bahasa dan beban waktu.** Pilihan Inggris menambah sekitar 11 sampai 12 hari dan tidak ada di estimasi 16 sampai 20 minggu. Pengguna utamamu teman sekelas berbahasa Indonesia. Pertimbangkan: kerjakan infrastrukturnya sekarang (ARB, kunci netral, tanpa teks di kode, sekitar 3 sampai 4 hari) dan tunda terjemahan Inggris serta kamus parser Inggris ke Tahap 5. Strategi bertahap di 8.5 sudah mengarah ke sini.
4. **Penempatan fitur bertanda `*` di tabel bagian 3.** Timer fokus, pin dan tag, kontak kelas, suara, pintasan, saran waktu kosong, kalender lengkap, dan widget lanjutan tidak punya tahap di v2 awal. Cek apakah Tahap 5 sudah sesuai keinginanmu, atau ada yang mau dinaikkan.
5. **Izin dan layanan Android yang perlu dicek dokumentasinya.** Dua fitur punya risiko di versi Android baru: alarm presisi (`SCHEDULE_EXACT_ALARM`, sepengetahuan saya tidak diberikan otomatis pada Android 14 ke atas untuk aplikasi baru) dan timer fokus yang "tetap hidup saat layar mati" (butuh foreground service dengan tipe yang sesuai). Estimasi 4 hari untuk timer fokus mungkin terlalu kecil. Periksa dokumentasi Android terbaru sebelum mengerjakan keduanya.
6. **Cadangan otomatis lebih awal?** Tanpa cloud, kehilangan data adalah risiko terbesar bagi pengguna. Cadangan manual JSON sudah ada di Tahap 1, tetapi cadangan otomatis (7.13) baru di Tahap 4. Bila ingin lebih aman, naikkan ke Tahap 2.
