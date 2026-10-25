# Rancangan Aplikasi Tugas v2: Fase A dan B (Edisi Dirapikan)

Aplikasi Android untuk mencatat tugas dan deadline kuliah, dikerjakan sendiri dengan bantuan AI. Tanpa akun, tanpa cloud, tanpa kolaborasi. Semua data tersimpan di HP.

Dokumen ini adalah penataan ulang v2. Bagian 13 sampai 22 versi sebelumnya (fitur tambahan, perubahan skema, jadwal baru, dua bahasa) sudah dilebur ke dalam alur utama, jadi tidak ada lagi bagian yang berbunyi "ubah bagian 3.1" atau "tambahkan ke skema". Daftar perubahan ada di **Lampiran A**. Hal yang masih perlu kamu putuskan ada di **Lampiran B**. Revisi ketiga menambah 28 fitur baru dan memperkaya beberapa fitur lama (bagian 5.16 sampai 5.33 dan 7.15 sampai 7.24).

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
- Pengingat berbasis lokasi (geofence), aplikasi jam tangan, pengenalan tulisan tangan, berbagi jadwal antarpengguna

---

## 2. Pengguna dan Validasi

Fokus satu persona dulu: **mahasiswa**. Tugas datang lewat grup WhatsApp, deadline tersebar, dan sering lupa mengumpulkan. Mesin aplikasi tetap dibuat generik (wadah, tugas, tanggal) sehingga mode Work atau mode SMA bisa ditambah nanti tanpa membongkar database.

**Validasi sebelum membangun (1 hari):** tanya 5 sampai 10 teman kelas: "kamu catat tugas di mana sekarang, dan apa yang paling bikin kesal?" Catat jawabannya, lalu cocokkan dengan fitur Fase A dan B. Bandingkan juga dengan Google Tasks, Todoist, dan TickTick untuk tahu apa yang benar-benar beda.

**Pilih fitur bersama teman:** setelah itu tunjukkan daftar fitur di bagian 3 ke teman yang sama dan minta masing-masing memilih 5 fitur yang paling mereka butuhkan. Pakai hasilnya untuk menyusun ulang Urutan 4 dan 5. Daftar fitur sudah panjang, dan suara pengguna nyata lebih andal daripada tebakan.

---

## 3. Peta Fitur dan Perkiraan Usaha

Perkiraan hari kerja untuk satu orang paruh waktu dengan bantuan AI, belum termasuk pengujian di HP nyata. Kolom **Urutan** adalah urutan pembangunan (bagian 13), bukan tempat berhenti. Tanda `*` berarti penempatan atau angka itu usulan penataan, bukan keputusan di v2 awal (lihat Lampiran B).

| Fitur | Bagian | Prioritas | Urutan | Usaha (hari) | Asal |
| --- | --- | --- | --- | --- | --- |
| Inbox | 5.1 | W | 1 | 2 | v2 |
| Subtugas dan progres | 5.2 | W | 1 | 3 | v2 |
| Jadwal kuliah dan Kelas Hari Ini | 5.3 | W | 1 | 5 | v2 |
| Tunda cerdas, geser kartu, aksi massal | 5.5 | W | 1 | 3 | v2 |
| Tanggal mulai dan pengingat mulai | 5.4 | S | 2 | 2 | v2 |
| Riwayat deadline | 5.6 | S | 2 | 2 | v2 |
| Ujian dan materi belajar | 5.7 | S | 2 | 2 | diperkaya |
| Ringkasan pagi dan malam | 5.12 | S | 2 | 2 | diperkaya |
| Sampah dan pemulihan | 5.11 | S | 2 | 2 | v2 |
| Cara kumpul dan status dikumpul | 5.16 | S | 2 | 3 | baru |
| Pembatalan kelas dan hari libur | 5.20 | S | 2 | 2 | baru |
| Pengingat tugas terlambat | 5.22 | S | 2 | 1 | baru |
| Pusat diagnostik pengingat | 5.23 | S | 2 | 2 | baru |
| Keamanan data lokal | 5.30 | S | 2 | 2 | baru |
| Share dari tangkapan layar (OCR) | 7.3 | S | 4 | 4 | v2 |
| Deteksi duplikat dan deadline diundur | 7.5 | S | 4 | 4 | v2 |
| Nilai, IPS, IPK, simulator | 7.9 | S | 4 | 5 | v2 |
| Rencana belajar ujian | 7.10 | S | 4 | 3 | v2 |
| Cadangan otomatis | 7.13 | S | 4 | 3 | v2 |
| Share dari aplikasi lain | 7.4 | S | 4* | 1* | v2 |
| Bobot komponen per matkul | 5.18 | S | 4 | 2 | baru |
| Target pribadi | 5.17 | S | 4 | 2 | baru |
| Kehadiran dan batas absen | 5.19 | S | 4 | 4 | baru |
| Senyap saat kelas dan notifikasi tidak berisik | 5.21 | S | 4 | 2 | baru |
| Fokus hari ini (Tiga Besar) | 5.24 | S | 4 | 1 | baru |
| Ganti semester | 5.29 | S | 4 | 2 | baru |
| Saring tersimpan dan pencarian lanjutan | 5.28 | S | 4 | 2 | baru |
| Parser lanjutan (estimasi, prioritas, tag, cara kumpul) | 7.15 | S | 4 | 4 | baru |
| Lampiran dokumen | 7.20 | S | 4 | 2 | baru |
| Skenario nilai "bagaimana jika" | 7.22 | S | 4 | 2 | baru |
| Impor gabung dan pemulihan selektif | 7.23 | S | 4 | 3 | baru |
| Timer fokus | 5.8 | S | 5* | 4 | v2 |
| Pin, tag, duplikat, templat | 5.9 | S | 5* | 4 | v2 |
| Kontak dan tautan kelas | 5.15 | S | 5* | 1 | v2 |
| Quick Add suara | 7.1 | S | 5* | 2 | v2 |
| Pintasan ikon dan Quick Settings | 7.2 | S | 5* | 2 | v2 |
| Saran waktu kosong | 7.6 | S | 5* | 4 | v2 |
| Kalender minggu, agenda, ICS | 7.7 | S | 5* | 5 | v2 |
| Widget lanjutan | 7.8 | S | 5* | 5 | diperkaya |
| Wadah non-matkul | 5.25 | S | 5 | 2 | baru |
| Proyek dan milestone | 5.26 | S | 5 | 5 | baru |
| Quick Add banyak baris dan ulang cepat | 7.16 | S | 5 | 2 | baru |
| Peta beban mingguan | 7.17 | S | 5 | 3 | baru |
| Tugas berulang sederhana | 5.10 | B | 5 | 3 | v2 |
| Kunci aplikasi, tema, mode SMA | 5.13, 5.14 | B | 5 | 4 | v2 |
| Statistik dan rekap semester | 7.11 | B | 5 | 4 | diperkaya |
| Bagikan sebagai teks, impor CSV | 7.12, 7.14 | B | 5 | 3 | v2 |
| Dependensi tugas | 5.27 | B | 5 | 2 | baru |
| Mode demo | 5.31 | B | 5 | 1 | baru |
| Daftar bawaan per matkul | 5.32 | B | 5 | 2 | baru |
| Tautan cepat global | 5.33 | B | 5 | 1 | baru |
| Impor jadwal dari tangkapan layar | 7.18 | B | 5 | 3 | baru |
| Ekspor gambar dan PDF | 7.19 | B | 5 | 3 | baru |
| Catatan pertemuan per matkul | 7.21 | B | 5 | 3 | baru |
| Cadangan terenkripsi | 7.24 | B | 5 | 2 | baru |

Kolom **Asal:** `v2` sudah ada di v2 awal, `baru` ditambahkan di revisi ketiga, `diperkaya` fitur lama yang isi atau usahanya bertambah.

**Jumlah kasar (diperbarui di revisi ketiga):** Wajib 13 hari, Sebaiknya 105 hari, Bonus 31 hari, total **149 hari kerja**. Sebelum revisi ketiga totalnya 82 hari (13, 56, 13). Sebaiknya naik 49 hari dan Bonus naik 18 hari karena 28 fitur baru (20 bertanda S, 8 bertanda B) dan tambahan usaha untuk widget dan statistik. **Tidak ada fitur baru yang dijadikan Wajib**, jadi inti aplikasi tidak tertunda.

Angka ini jauh melebihi kapasitas satu pembuat paruh waktu bila semuanya dikerjakan. Karena itu Urutan 5 sepenuhnya opsional, aturan pemotongan (bagian 1) adalah pengaman utama, dan validasi bersama teman (bagian 2) dipakai untuk memilih mana yang benar-benar layak dikerjakan.

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

1. **Kelas berikutnya** (kartu ringkas dengan sisa waktu, fitur 5.3), memperhitungkan pembatalan dan perubahan satu kali (5.20).
2. **Fokus hari ini** (maksimal 3 tugas pilihan, fitur 5.24).
3. **Disematkan** (tugas yang di-pin, tampil di luar urutan skor, fitur 5.9).
4. **Terlambat** (diurutkan dari yang paling lama terlambat), dengan tombol cepat "Tandai selesai" atau "Atur ulang".
5. **Hari ini dan besok**, diurutkan skor urgensi.
6. **Sedang dikerjakan** (status Dikerjakan), selalu terlihat, tidak turun.
7. **Hitung mundur ujian** bila kurang dari 14 hari (fitur 5.7).
8. **Minggu ini**, diciutkan secara bawaan.
9. **Menunggu** (tugas yang bergantung pada tugas lain, fitur 5.27), diciutkan.
10. **Kapan-kapan**, diciutkan.

Inbox (fitur 5.1) punya tab sendiri dengan badge angka, bukan bagian di layar ini.

**Agar layar tidak terlalu penuh:** bagian hanya tampil bila ada isinya, dan tiap bagian bisa disembunyikan lewat Pengaturan > Susunan Hari Ini. Kartu peringatan (izin pengingat dicabut, 5.23; minggu padat, 7.17; Inbox menumpuk, 5.1) tampil paling atas, bisa ditutup, dan maksimal satu kartu sekaligus.

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
- Target pribadi ada: komponen U dihitung dari target selesai, bukan dari deadline resmi (5.17).
- Bobot komponen diisi: komponen B memakai bobot efektif (5.18).
- Tugas menunggu tugas lain: tidak ikut diurutkan, karena berada di bagian Menunggu (5.27).

**Pengujian rumus:** siapkan 15 tugas nyata dari semestermu, urutkan manual dulu, lalu bandingkan dengan urutan aplikasi. Ubah konstanta sampai 12 dari 15 cocok.

### 4.6 Mesin Pengingat

**Alur**

1. Tugas disimpan, `ReminderService` menghitung waktu pengingat: H-3, H-1, 3 jam, dan 30 menit sebelum deadline. Tugas berbobot besar mendapat pengingat tambahan, tugas bobot kecil lebih sedikit.
2. Waktu yang sudah lewat dibuang, jam tenang (bawaan 22.00 sampai 06.00) diterapkan, lalu dijadwalkan. Aturan untuk pengingat yang jatuh di jam tenang perlu dipastikan (Lampiran B, poin 1).
3. Deadline diubah atau tugas selesai: pengingat lama dibatalkan lewat `notif_id`, lalu dibuat ulang bila perlu.
4. **Boot receiver** menjadwalkan ulang semua pengingat aktif setelah HP restart atau aplikasi diperbarui.
5. Hanya jadwalkan 14 hari ke depan. Sisanya dijadwalkan ulang oleh tugas harian (Lampiran B, poin 2).
6. Tombol aksi di notifikasi: **Selesai** dan **Tunda 1 jam** (pilihan tunda lengkap ada di 5.5). Perilaku tugas terlambat ada di 5.22, notifikasi berkelompok dan anggaran notifikasi di 5.21, dan diagnostik di 5.23.
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
- **Pengingat kelas:** 30 menit sebelum mulai (bisa dimatikan per matkul). Pembatalan atau perubahan satu kali ada di 5.20, kehadiran di 5.19.
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
- **Mode Minggu Ujian** (opsional, bisa dimatikan): bila ada 2 ujian atau lebih dalam 7 hari, layar Hari Ini menciutkan bagian Minggu ini dan Kapan-kapan, dan menonjolkan jadwal ujian serta progres materinya.

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
- Ringkasan pagi bisa menyertakan jatah absen yang tinggal 1 (5.19) dan tombol "Pilih fokus hari ini" (5.24). Penutup malam bisa menyertakan "Besok bawa: ..." (5.32).

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

### 5.16 Cara kumpul dan status "sudah dikumpul" [S]

Banyak tugas gagal bukan karena belum selesai, tetapi karena salah cara atau salah nama berkas saat mengumpulkan.

- Tiga kolom opsional di "Detail lain": **cara kumpul** (`email`, `lms`, `paper`, `drive`, `other`), **tujuan** (alamat email, nama kelas LMS, ruangan), dan **pola nama berkas** (contoh `{nim}_{nama}_{matkul}_{judul}`).
- Variabel `{nim}` dan `{nama}` diambil dari Pengaturan > Profil (opsional, tersimpan lokal saja). `{matkul}` dan `{judul}` diambil dari tugas.
- Tombol **Salin nama berkas** dan **Salin tujuan**. Untuk cara kumpul email, tombol **Buka email** membuka aplikasi email dengan alamat dan subjek terisi.
- Tombol **Tandai sudah dikumpul** mencatat `submitted_at`. Menandai Selesai pada tugas yang punya cara kumpul menanyakan "Sudah dikumpul?", supaya Selesai tidak berarti sekadar selesai mengerjakan.
- **Cek sebelum kumpul:** subtugas bertanda cek (nama berkas benar, format PDF, lampiran lengkap) yang bisa datang dari templat (5.9).
- Statistik ketepatan waktu (7.11) memakai `submitted_at` bila ada.

### 5.17 Target pribadi [S]

- Selain deadline resmi, tugas boleh punya **target selesai** yang lebih awal. Pengaturan bawaan: 0, 1, atau 2 hari lebih awal, khusus untuk tugas berbobot besar.
- Target memakai kolom `target_at`. Skor urgensi memakai target (bukan deadline) untuk komponen U bila target ada, supaya urutan sesuai niatmu. Pengingat H-3 dan seterusnya tetap dari deadline resmi, ditambah satu pengingat di target.
- Kartu menampilkan "Target Rabu, deadline Jumat". Melewati target tidak memindahkan tugas ke bagian Terlambat, hanya memberi lencana kuning.
- Target harus sebelum deadline. Peta beban mingguan (7.17) memakai target.

### 5.18 Bobot komponen per matkul [S]

- Di detail wadah: tabel komponen penilaian, misalnya UTS 30, UAS 40, Tugas 20, Kuis 10 (kunci `midterm`, `final`, `assignment`, `quiz`, `attendance`, `other`). Peringatan bila jumlahnya bukan 100.
- Jenis tugas dipetakan ke komponen: `quiz` ke `quiz`, `midterm` ke `midterm`, `final` ke `final`, sisanya (`lab_report`, `paper`, `presentation`, `other`) ke `assignment`.
- **Bobot efektif** tugas dihitung saat tampil: bobot yang diisi manual bila ada, bila kosong maka bobot komponen dibagi jumlah tugas pada komponen itu.
- Bobot efektif dipakai untuk komponen B skor urgensi, rekap nilai, prediksi nilai (7.9), dan skenario (7.22). Kolom `weight_percent` di tugas tetap hanya untuk isian manual, tidak ada bobot yang disimpan ganda.

### 5.19 Kehadiran dan batas absen [S]

Banyak kampus mensyaratkan kehadiran minimum untuk ikut ujian akhir, dan jatah absen mudah terlupa.

- Tiap pertemuan kelas (dari slot jadwal, 5.3) bisa dicatat: **Hadir**, **Absen**, **Izin**, **Sakit**. Pencatatan dari kartu Kelas Hari Ini atau dari notifikasi opsional "Isi kehadiran" 10 menit setelah kelas selesai (mati secara bawaan, dinyalakan per matkul).
- Pengaturan per matkul: jumlah pertemuan rencana (bawaan 16), batas absen maksimal dalam persen (bawaan 25, **sesuaikan dengan aturan kampusmu**), dan apakah izin dan sakit dihitung sebagai absen.
- Tampilan per matkul: "Hadir 9 dari 11 pertemuan, sisa jatah absen 2". Peringatan lembut bila sisa jatah tinggal 1 dan peringatan merah (dengan ikon dan teks) bila habis.
- Hari libur dan kelas yang dibatalkan (5.20) tidak dihitung sebagai pertemuan.
- Jatah absen yang tinggal 1 ikut muncul di Ringkasan pagi (5.12).

### 5.20 Pembatalan dan perubahan kelas sekali [S]

- Dari kartu Kelas Hari Ini: **Kelas kosong**, **Pindah ruang**, atau **Ganti jam** untuk satu tanggal saja, tanpa mengubah jadwal mingguan (`class_exceptions`).
- Kelas kosong membatalkan pengingat kelas dan pertanyaan kehadiran hari itu, dan membebaskan jam itu dalam hitungan jam efektif dan saran waktu kosong.
- **Hari libur:** tandai satu tanggal sebagai libur untuk semua kelas, atau impor dari ICS kalender akademik (7.7).
- Setelah parser ada (Fase B), kata seperti "kosong", "libur", "tidak ada kuliah", dan "diganti" di pesan share mengusulkan pembatalan. Pengguna yang memutuskan.

### 5.21 Senyap saat kelas dan notifikasi yang tidak berisik [S]

Semakin banyak fitur berarti semakin banyak notifikasi, dan notifikasi berlebihan membuat pengguna mematikan semuanya. Bagian ini menjaga agar itu tidak terjadi.

- **Senyap saat kelas** (opsional): pengingat yang jatuh di tengah jam kelas ditahan sampai kelas selesai. Pengecualian: pengingat deadline kurang dari 1 jam tidak pernah ditahan.
- **Gabung notifikasi:** pengingat dari beberapa tugas dalam rentang 10 menit digabung menjadi satu notifikasi berkelompok ("3 tugas mendekati deadline") dengan daftar di dalamnya.
- **Anggaran notifikasi:** maksimal 8 notifikasi non-kritis per hari (bisa diatur). Pengingat deadline kurang dari 3 jam tidak pernah dipangkas. Kelebihan di atas anggaran digabung ke ringkasan.
- **Intensitas:** Tenang, Normal, Gencar. Tenang: H-1 dan 3 jam. Normal: seperti 4.6. Gencar: ditambah pengingat tiap 6 jam pada hari deadline.
- Aturan untuk pengingat di jam tenang mengikuti keputusan di Lampiran B poin 1.

### 5.22 Pengingat tugas terlambat [S]

Kanal "tugas terlambat" sudah ada di 4.6, tetapi perilakunya belum ditentukan. Aturannya:

- Satu notifikasi per hari (bawaan 09.00) berisi semua tugas terlambat. Setiap tugas muncul maksimal 3 hari berturut-turut, lalu berhenti dan hanya terlihat di bagian Terlambat dan Ringkasan pagi.
- Aksi di notifikasi: **Selesai**, **Atur ulang** (deadline baru), dan **Tunda**.
- Nada tidak menyalahkan (bagian 11). Bisa dimatikan.

### 5.23 Pusat diagnostik pengingat [S]

Perluasan layar Cek Pengingat (4.6) untuk masalah yang paling sulit dilacak: pengingat yang tidak muncul di merek HP tertentu.

- Daftar pengingat terjadwal 14 hari ke depan, status izin (notifikasi dan alarm presisi), status pengecualian penghemat baterai, serta merek dan versi Android.
- **Riwayat tes notifikasi 1 menit:** setelah tes, aplikasi menanyakan "Muncul tepat waktu?" dan mencatat jawabannya.
- Pengingat nyata dicatat `acked_at` bila diketuk atau salah satu tombol aksinya dipakai. **Batasan jujur:** aplikasi tidak bisa memastikan sebuah notifikasi benar-benar tampil di layar, hanya bahwa pengguna berinteraksi dengannya. Pengingat yang lewat tanpa interaksi tidak bisa dibedakan dari yang tidak muncul.
- Tombol **Salin laporan diagnostik**: teks berisi merek, versi Android, status izin, jumlah pengingat terjadwal, dan hasil tes terakhir. Berguna untuk dikirim dari HP teman ke pembuat aplikasi atau ditempel ke AI saat debugging.
- Satu kartu peringatan di layar Hari Ini bila izin dicabut atau penghemat baterai aktif (bisa ditutup).

### 5.24 Fokus hari ini ("Tiga Besar") [S]

- Pilih sampai 3 tugas sebagai fokus hari ini, dari kartu atau dari layar saran di Ringkasan pagi (5.12).
- Bagian "Fokus hari ini" tampil tepat di bawah Kelas berikutnya di layar Hari Ini. Beda dengan pin: pin menetap, fokus hanya berlaku satu hari (`focus_date`).
- Tugas fokus yang belum selesai ditawarkan lagi esok pagi: "Lanjutkan 2 tugas kemarin?"
- Bila ketiganya selesai, tampilkan animasi kecil. Tanpa lencana, skor, atau peringkat.

### 5.25 Wadah non-matkul [S]

- Kolom `kind` pada wadah: `course` (matkul), `organization` (organisasi), `project` (proyek), `personal` (pribadi), `other`.
- Wadah non-matkul tidak punya SKS, nilai, kehadiran, atau komponen bobot. Layar wadahnya menampilkan tugas, catatan, tautan, dan jadwal rapat (slot kelas berjenis `meeting`).
- Berguna untuk organisasi kampus, kepanitiaan, dan kegiatan pribadi supaya tidak bercampur dengan rekap nilai.
- Alias dan parser bekerja seperti biasa.

### 5.26 Proyek dan milestone [S]

- Tugas **induk** dengan **anak** yang punya tenggat sendiri (`parent_id`). Berbeda dari subtugas (5.2) yang hanya berupa centang tanpa tanggal.
- Induk menampilkan progres dari anak yang selesai dan "milestone berikutnya". Anak muncul di layar Hari Ini seperti tugas biasa dengan label nama induk.
- **Rencana mundur:** isi deadline akhir dan pilih templat proyek, aplikasi mengusulkan tanggal tiap milestone sebagai persentase dari waktu yang tersisa. Pengguna mengubah atau menolak.
- Templat proyek disimpan di `task_templates` (kolom `milestones_json`). Contoh laporan akhir: topik, bab 1 sampai 3, bab 4 dan 5, revisi, finalisasi, pengumpulan.
- Menghapus induk menanyakan nasib anak: ikut dihapus atau dilepas menjadi tugas biasa.
- Skor: anak dihitung seperti tugas biasa, induk tidak memiliki skor sendiri.

### 5.27 Dependensi tugas [B]

- Tugas boleh "menunggu" tugas lain (`task_deps`), misalnya laprak menunggu praktikum selesai.
- Tugas yang menunggu tampil di bagian ciut "Menunggu" dan tidak mengirim pengingat mulai (5.4). Pengingat deadline tetap berjalan.
- Saat prasyarat selesai, satu notifikasi lembut: "Sekarang bisa mulai: laprak Basdat."
- Siklus ditolak saat menyimpan.

### 5.28 Saring tersimpan dan pencarian lanjutan [S]

- Gabungkan wadah, jenis, tag, status, rentang tanggal, dan kata kunci menjadi **tampilan tersimpan** (misalnya "Kelompok yang belum mulai", "UAS semester ini") dengan nama dan urutan sendiri (`saved_filters`).
- Tampilan tersimpan muncul sebagai chip di layar Tugas dan bisa dijadikan pintasan ikon (7.2).
- Pencarian global mencakup judul, catatan, subtugas, tag, nama wadah, teks asli pesan share, dan catatan pertemuan bila ada (7.21). Hasil dikelompokkan per jenis. Riwayat pencarian terakhir bisa dihapus.

### 5.29 Ganti semester [S]

- Wizard akhir semester: ringkasan (jumlah tugas selesai, IPS bila nilai akhir terisi), lalu **arsipkan** semua wadah semester lama.
- Buat semester baru: pilih wadah yang disalin (nama, kode, alias, meta, slot kelas, komponen bobot) tanpa tugas dan tanpa nilai, lalu tentukan `period` baru.
- Tugas yang belum selesai di semester lama: biarkan di arsip, pindahkan ke wadah baru, atau hapus.
- `active_period` di Pengaturan menjadi penyaring bawaan. Semester lama tetap bisa dibuka dari Arsip.

### 5.30 Keamanan data lokal [S]

Tanpa cloud, database di HP adalah satu-satunya salinan. Fitur ini melindunginya.

- **Snapshot sebelum migrasi:** sebelum Drift menjalankan migrasi skema, berkas database disalin ke folder internal aplikasi (simpan 2 terakhir). Bila migrasi gagal, tawarkan pulihkan dari snapshot, bukan macet berulang.
- **Cek integritas** di Pengaturan (`PRAGMA integrity_check`) dengan hasil yang bisa dibaca dan jalur pulihkan dari snapshot atau cadangan JSON.
- Bila database tidak bisa dibuka saat start, tampilkan layar pemulihan (impor cadangan, mulai baru, salin laporan).
- Cadangan JSON diverifikasi sebelum dianggap berhasil: dibaca ulang dan jumlah barisnya dibandingkan.

### 5.31 Mode demo [B]

- Opsi di onboarding: "Coba dengan data contoh". Aplikasi membuat satu semester contoh (3 matkul, 8 tugas, jadwal) bertanda `is_sample`.
- Tombol "Hapus data contoh" di Pengaturan dan di banner layar Hari Ini. Berguna untuk teman yang baru mencoba dan untuk tangkapan layar.
- Data contoh tidak ikut cadangan.

### 5.32 Daftar bawaan per matkul [B]

- Di detail wadah: daftar barang bawaan (laptop, kabel LAN, laprak cetak) di `space_items`.
- Penutup malam (5.12) menyebut "Besok bawa: ..." bila ada kelas besok yang daftarnya terisi.
- Centang malam hari, dan centang direset otomatis sesudah kelas.

### 5.33 Tautan cepat global [B]

- Daftar tautan bebas (SIAKAD, e-learning kampus, KRS, perpustakaan) di Pengaturan dan satu baris tombol kecil di layar Hari Ini (bisa disembunyikan). Disimpan di `quick_links`.
- Pintasan ikon (7.2) bisa memakai tautan yang dipilih.

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
- Setelah parser lanjutan (7.15) ada, calon tugas juga membawa estimasi, prioritas, cara kumpul, tautan, dan usulan subtugas bila terbaca.

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
- Lampiran berkas dokumen (PDF, Word, presentasi) ada di 7.20.

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
- Widget **Fokus Hari Ini** (5.24): tiga tugas fokus dengan kotak centang.
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
- Tambahan: ketepatan pengumpulan (memakai `submitted_at`, 5.16), akurasi estimasi per jenis tugas (dari timer fokus, 5.8), hari dan jam paling produktif, rekap kehadiran per matkul (5.19), dan tren per minggu.
- Semua angka dihitung lokal dan bisa direset.
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

### 7.15 Parser lanjutan: estimasi, prioritas, tag, cara kumpul [S]

Menambah langkah pipeline 6.1. Dikerjakan setelah parser dasar lulus tesnya.

- **Token singkat:** `@basdat` (wadah), `#kelompok` (tag), `!` atau `!tinggi` (prioritas tinggi), `!rendah`, `~2j` atau `~45m` (estimasi).
- **Estimasi bahasa alami:** "estimasi 2 jam", "sekitar 30 menit". Ungkapan "3 jam lagi" selalu waktu relatif, bukan estimasi.
- **Kata prioritas:** "penting", "urgent", "wajib" jadi tinggi. "santai", "kalau sempat" jadi rendah. Semua tampil sebagai chip yang bisa dikoreksi.
- **Cara kumpul:** alamat email di teks menjadi cara kumpul `email` dengan tujuan alamat itu. Kata "classroom", "e-learning", "LMS", "drive" memilih cara kumpul yang sesuai. "dicetak" atau "hardcopy" memilih `paper`. Tautan di pesan masuk sebagai lampiran tautan.
- **Pola nama berkas:** kalimat setelah "format nama file" atau "penamaan" disimpan mentah sebagai `filename_pattern` dengan chip "cek pola".
- **Subtugas:** daftar bernomor atau berbutir dalam pesan share diusulkan sebagai subtugas.

| Input | Aturan |
| --- | --- |
| `laprak basdat jumat ~3j !tinggi #kelompok` | Estimasi 180 menit, prioritas tinggi, tag kelompok |
| `kerjakan 3 jam lagi` | Waktu relatif (3 jam dari sekarang), bukan estimasi |
| `estimasi 3 jam, kumpul ke dosen@kampus.ac.id` | Estimasi 180 menit, cara kumpul email |
| `kirim lewat classroom sebelum jam 12` | Cara kumpul `lms`, deadline 12.00 |
| `penting banget tapi santai dulu` | Kata bertentangan: chip prioritas "perlu dicek" |

Korpus uji ditambah 50 kalimat. Target akurasi: estimasi 85%, prioritas 80%, cara kumpul 85%.

### 7.16 Quick Add banyak baris dan ulang cepat [S]

- Tombol **Tempel** menerima beberapa baris. Satu baris menjadi satu calon tugas dengan layar centang seperti 6.2. Aplikasi tidak membaca clipboard tanpa ketukan pengguna.
- **Ulangi dari tugas terakhir:** menyalin wadah, jenis, dan jam deadline dari tugas sebelumnya, berguna saat mencatat beberapa tugas matkul yang sama.
- **Saran dari riwayat:** saat mengetik judul yang mirip tugas lama ("laprak minggu lalu"), ketuk untuk menyalin subtugas dan estimasinya.

### 7.17 Peta beban mingguan [S]

- Grafik batang 7 hari dan peta panas 4 minggu: jam estimasi tugas (memakai target pribadi atau deadline) dibandingkan jam efektif tersedia (4.5, 5.3, 5.20).
- Hari yang melebihi 100 persen ditandai merah dengan ikon, bukan hanya warna.
- Bila minggu ini padat, satu kartu di layar Hari Ini: "Rabu 140 persen. Mau mulai salah satu lebih awal?" dengan usulan tugas yang boleh dimajukan (estimasi terisi, tanggal mulai kosong, hari sebelumnya longgar). Pengguna memutuskan.
- Tugas tanpa estimasi tidak dihitung dan layar mencatat "5 tugas belum punya estimasi", supaya angkanya tidak menyesatkan.
- Murni aturan, tanpa AI.

### 7.18 Impor jadwal dari tangkapan layar atau teks portal [B]

- Bagikan tangkapan layar jadwal atau KRS, atau tempel teksnya. OCR (7.3) dan parser jam dan hari menghasilkan calon slot kelas (hari, jam, ruang, nama matkul) dan calon wadah baru.
- Layar pratinjau berupa tabel yang bisa diedit sebelum disimpan. Tidak ada yang disimpan otomatis.
- Format portal berbeda-beda. Sediakan jalur ketik manual dan kumpulkan 10 contoh portal sebagai korpus uji.
- Mengurangi pekerjaan awal mengisi jadwal (5.3), yang mungkin hambatan terbesar bagi pengguna baru.

### 7.19 Ekspor gambar dan PDF [B]

- Bagikan sebagai **gambar**: jadwal minggu, daftar tugas minggu ini, dan rekap semester (7.11).
- Ekspor **PDF**: rekap nilai per matkul, riwayat deadline sebuah tugas (bukti perubahan deadline, 5.6), dan daftar kehadiran (5.19).
- Semuanya dibuat di HP tanpa server. Gambar dari render widget Flutter, PDF dari paket `pdf`. Teks mengikuti bahasa aktif.

### 7.20 Lampiran dokumen [S]

- Selain foto dan tautan (6.5): berkas PDF, dokumen, dan presentasi dari pemilih berkas atau menu Bagikan (misalnya soal tugas dari grup WhatsApp).
- Disimpan di folder aplikasi. Batas bawaan 10 MB per berkas, bisa dinaikkan sampai 25 MB di Pengaturan. Berkas yang lebih besar ditolak dengan pesan jelas dan opsi simpan tautan saja.
- Dibuka lewat aplikasi lain (`open_filex`). Gambar dan PDF punya pratinjau sederhana.
- Ikut cadangan zip. Ukuran total lampiran tampil di Pengaturan, dengan opsi "cadangan tanpa lampiran" agar cadangan tetap kecil.
- Kolom `attachments` mendapat `mime` dan `size_bytes`.

### 7.21 Catatan pertemuan per matkul [B]

- Catatan per pertemuan: tanggal, nomor pertemuan, topik, isi, dan foto papan tulis (lampiran). Templat singkat: topik, hal penting, tugas yang disebut, pertanyaan.
- Dari catatan, satu ketukan **jadikan tugas** atau **jadikan materi ujian** (judul bab menjadi subtugas pada tugas ujian, 5.7).
- Daftar catatan per matkul diurutkan menurut tanggal. Pencarian global mencakup isinya (5.28).
- Bukan aplikasi catatan penuh: teks biasa tanpa format kaya, supaya ringan dan mudah ikut cadangan.

### 7.22 Skenario nilai "bagaimana jika" [S]

- Di layar prediksi nilai (7.9): geser nilai untuk komponen yang belum ada (misalnya UAS 60, 70, 80) dan lihat proyeksi nilai akhir serta hurufnya.
- Tampilkan **nilai minimal yang dibutuhkan** untuk tiap target huruf, dan tandai target yang sudah mustahil dengan bahasa yang tidak menyalahkan ("Target A sulit dicapai, B+ masih mungkin").
- Memakai bobot komponen (5.18) dan skala nilai kampus (7.9). Kehadiran ikut dihitung bila punya bobot.
- Satu skenario favorit bisa disimpan per matkul. Hitungan sederhana, lokal.

### 7.23 Impor gabung dan pemulihan selektif [S]

- Dua mode impor cadangan: **Timpa** (seperti sebelumnya) dan **Gabung**. Gabung memakai UUID dan `updated_at`: item baru ditambahkan, item yang sudah ada mengambil versi yang lebih baru, dan penghapusan (`deleted_at`) mengikuti versi yang lebih baru.
- Pratinjau sebelum diterapkan: "12 tugas baru, 3 diperbarui, 1 konflik".
- **Konflik** (kedua sisi berubah sejak cadangan): tampilkan keduanya dan pengguna memilih.
- **Pulihkan selektif:** pilih satu wadah atau satu tugas dari cadangan tanpa menyentuh yang lain.
- Berguna saat ganti HP (data baru sudah terlanjur dimasukkan di HP baru) atau memakai dua HP. Ini bukan sinkron otomatis.
- Syarat: semua tabel yang dicadangkan punya UUID, `updated_at`, dan `deleted_at`. Tabel penghubung digabung sebagai gabungan himpunan.

### 7.24 Cadangan terenkripsi [B]

- Opsi kata sandi untuk berkas cadangan (enkripsi AES-GCM, kunci diturunkan dari kata sandi dengan fungsi turunan kunci standar).
- Peringatan jelas saat diaktifkan: kata sandi yang hilang berarti cadangan tidak bisa dibuka, dan tidak ada pemulihan kata sandi.
- Cadangan otomatis (7.13) memakai opsi yang sama. Berkas memiliki header berisi versi format dan parameter kunci.
- Berguna karena cadangan memuat nama dosen, tautan kelas, catatan pertemuan, dan lampiran.

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
| Cara kumpul | `lms` | LMS / LMS |
| Cara kumpul | `paper` | Kertas / Hard copy |
| Kehadiran | `excused` | Izin / Excused |
| Kehadiran | `sick` | Sakit / Sick |
| Jenis wadah | `organization` | Organisasi / Organization |
| Pengecualian kelas | `cancelled` | Kelas kosong / Cancelled |
| Pengecualian kelas | `holiday` | Libur / Holiday |

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
  kind TEXT DEFAULT 'course',    -- course | organization | project | personal | other
  total_meetings INTEGER,        -- pertemuan rencana untuk kehadiran (bawaan 16)
  max_absent_percent INTEGER,    -- batas absen, bawaan 25 (sesuaikan aturan kampus)
  excused_counts_absent INTEGER DEFAULT 0,  -- izin dan sakit dihitung absen
  attend_prompt INTEGER DEFAULT 0,          -- notifikasi "Isi kehadiran"
  is_sample INTEGER DEFAULT 0,   -- data contoh (mode demo)
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
  target_at INTEGER,             -- target selesai pribadi (sebelum deadline)
  submit_method TEXT,            -- email | lms | paper | drive | other
  submit_target TEXT,            -- alamat email, nama kelas LMS, ruangan
  filename_pattern TEXT,         -- contoh: {nim}_{nama}_{matkul}_{judul}
  submitted_at INTEGER,          -- kapan ditandai sudah dikumpul
  focus_date INTEGER,            -- tanggal fokus hari ini (yyyymmdd lokal)
  parent_id TEXT REFERENCES tasks(id),   -- induk (proyek), NULL = tugas biasa
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
  kind TEXT DEFAULT 'lecture',   -- lecture | lab | meeting
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
  kind TEXT NOT NULL,            -- image | link | file
  path_or_url TEXT NOT NULL,
  mime TEXT,
  size_bytes INTEGER,
  created_at INTEGER NOT NULL
);

CREATE TABLE reminders (
  id TEXT PRIMARY KEY,
  task_id TEXT REFERENCES tasks(id),          -- NULL untuk pengingat kelas
  class_slot_id TEXT REFERENCES class_slots(id),
  fire_at INTEGER NOT NULL,
  kind TEXT,                     -- d3 | d1 | h3 | m30 | target | start | study | class | attend | overdue | snooze
                                 -- (d = hari sebelum deadline, h = jam, m = menit)
  notif_id INTEGER NOT NULL,
  fired INTEGER DEFAULT 0,
  acked_at INTEGER               -- diketuk atau tombol aksi dipakai (5.23)
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
  subtasks_json TEXT,            -- daftar judul subtugas
  milestones_json TEXT           -- milestone proyek (judul dan persen waktu), 5.26
);

CREATE TABLE grade_components (
  space_id TEXT NOT NULL REFERENCES spaces(id),
  key TEXT NOT NULL,             -- midterm | final | assignment | quiz | attendance | other
  weight_percent REAL NOT NULL,
  PRIMARY KEY (space_id, key)
);

CREATE TABLE attendance (
  id TEXT PRIMARY KEY,
  space_id TEXT NOT NULL REFERENCES spaces(id),
  slot_id TEXT REFERENCES class_slots(id),
  date TEXT NOT NULL,            -- tanggal lokal 'YYYY-MM-DD'
  status TEXT NOT NULL,          -- present | absent | excused | sick
  note TEXT,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  UNIQUE (slot_id, date)
);

CREATE TABLE class_exceptions (
  id TEXT PRIMARY KEY,
  slot_id TEXT REFERENCES class_slots(id),   -- NULL untuk libur semua kelas
  date TEXT NOT NULL,            -- tanggal lokal 'YYYY-MM-DD'
  kind TEXT NOT NULL,            -- cancelled | moved | room_changed | holiday
  new_start_min INTEGER,
  new_end_min INTEGER,
  new_room TEXT,
  note TEXT,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);

CREATE TABLE task_deps (
  task_id TEXT NOT NULL REFERENCES tasks(id),
  depends_on_id TEXT NOT NULL REFERENCES tasks(id),
  PRIMARY KEY (task_id, depends_on_id)
);

CREATE TABLE saved_filters (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  query_json TEXT NOT NULL,      -- wadah, jenis, tag, status, rentang tanggal, kata kunci
  sort_order INTEGER DEFAULT 0,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);

CREATE TABLE space_items (
  id TEXT PRIMARY KEY,
  space_id TEXT NOT NULL REFERENCES spaces(id),
  title TEXT NOT NULL,           -- barang bawaan
  sort_order INTEGER DEFAULT 0,
  checked_on TEXT,               -- tanggal lokal terakhir dicentang
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);

CREATE TABLE quick_links (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  url TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);

CREATE TABLE class_notes (
  id TEXT PRIMARY KEY,
  space_id TEXT NOT NULL REFERENCES spaces(id),
  meeting_no INTEGER,
  date TEXT,                     -- tanggal lokal 'YYYY-MM-DD'
  title TEXT,
  body TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);

CREATE TABLE diagnostics (
  id TEXT PRIMARY KEY,
  kind TEXT NOT NULL,            -- test_1min | permission_check | battery_check
  created_at INTEGER NOT NULL,
  result TEXT,                   -- ok | late | missing
  note TEXT
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
- **Tanggal kalender** (`attendance.date`, `class_exceptions.date`, `class_notes.date`, `space_items.checked_on`) disimpan sebagai teks tanggal lokal `YYYY-MM-DD`. Ini pengecualian dari aturan UTC epoch karena yang dimaksud adalah hari di kalender, bukan titik waktu. `focus_date` memakai bilangan `yyyymmdd` dengan alasan yang sama.
- **Dihitung, tidak disimpan:** bobot efektif tugas (5.18), status "menunggu" (dari `task_deps`, 5.27), progres proyek (dari anak, 5.26), sisa jatah absen (dari `attendance`, 5.19), dan beban mingguan (7.17).
- **Impor gabung (7.23):** tabel dengan UUID, `updated_at`, dan `deleted_at` digabung berdasarkan versi terbaru. Tabel penghubung (`space_aliases`, `space_meta`, `task_tags`, `task_deps`, `grade_components`) digabung sebagai himpunan.
- **Data contoh** (`spaces.is_sample = 1`) tidak ikut cadangan.
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
| Cara kumpul | Pola nama berkas dengan variabel kosong, alamat email tidak valid, Selesai lalu "sudah dikumpul" |
| Target pribadi | Target setelah deadline ditolak, target terlewat, deadline diubah setelah target diisi |
| Bobot komponen | Jumlah bobot bukan 100, komponen tanpa tugas, tugas dengan dan tanpa bobot manual |
| Kehadiran | Batas absen pada 16 pertemuan, izin dihitung atau tidak, kelas kosong tidak dihitung |
| Pengecualian kelas | Kelas kosong membatalkan pengingat, libur menutup semua kelas satu hari, ganti jam melewati tengah malam |
| Notifikasi tidak berisik | 10 pengingat dalam 10 menit menjadi satu, deadline di bawah 3 jam tidak pernah digabung atau dipangkas, anggaran harian |
| Senyap saat kelas | Pengingat di tengah kelas ditahan, deadline di bawah 1 jam tidak ditahan, kelas dibatalkan melepas penahanan |
| Pengingat terlambat | Berhenti setelah 3 hari berturut-turut, tugas selesai di tengah, deadline diubah membatalkan |
| Diagnostik | Izin dicabut, penghemat baterai aktif, hasil tes 1 menit, laporan terbaca oleh manusia dan AI |
| Fokus hari ini | Ganti hari, tugas fokus selesai atau dihapus, batas 3 |
| Proyek dan dependensi | Hapus induk (ikut hapus atau dilepas), rencana mundur dengan deadline sangat dekat, siklus dependensi ditolak |
| Tampilan tersimpan | Filter yang wadahnya diarsipkan atau tag-nya dihapus |
| Ganti semester | Salin wadah tanpa tugas, tiga pilihan untuk tugas belum selesai, `active_period` berubah |
| Snapshot dan integritas | Migrasi sengaja digagalkan, berkas database dirusak, pulihkan dari snapshot |
| Parser lanjutan | 50 kalimat tambahan, "3 jam lagi" melawan "estimasi 3 jam", email dan tautan dalam pesan |
| Peta beban | Tugas tanpa estimasi, minggu libur, jam efektif nol |
| Lampiran dokumen | Berkas 11 MB dan 25 MB, nama berkas aneh, cadangan dengan dan tanpa lampiran |
| Impor gabung | Dua HP dengan data berbeda, konflik dua sisi, item dihapus di satu sisi, `updated_at` sama |
| Cadangan terenkripsi | Kata sandi salah, berkas rusak sebagian, impor lintas versi format |
| Impor jadwal | 10 contoh portal, OCR salah baca jam |

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

## 13. Urutan Pembangunan (Satu Alur Berkelanjutan)

Aplikasi dibangun sebagai **satu alur kerja panjang tanpa jeda per sesi atau per tahap**. Urutan di bawah hanya menentukan dependensi (apa harus ada lebih dulu), **bukan tempat berhenti**. Setelah satu fitur selesai, pembangun langsung lanjut ke fitur berikutnya.

Perkiraan kasar paruh waktu setelah revisi ketiga: Urutan 1 sekitar 7 minggu, Urutan 2 sekitar 4 minggu, Urutan 3 sekitar 5 minggu, dan Urutan 4 sekitar 9 sampai 11 minggu. Jadi sampai akhir Urutan 4 sekitar **25 sampai 27 minggu**, **belum termasuk dua bahasa** (sekitar 11 sampai 12 hari, bagian 8.10). Urutan 5 menambah sekitar 14 minggu dan sepenuhnya opsional. Angka ini hanya untuk perencanaan manusia. Pembangun tidak menunggu kalender.

Kolom **Urutan** di bagian 3 merujuk ke daftar ini: fitur urutan 1 dikerjakan sebelum urutan 2, dan seterusnya.

### Urutan 1: Fase A inti + semua [W]

1. Struktur proyek, tema, database Drift, wadah dan tugas (CRUD).
2. Skor urgensi, layar Hari Ini, bagian dan alasan, undo.
3. ReminderService, izin, boot receiver, layar Cek Pengingat.
4. Pencarian, penyaring, ekspor dan impor cadangan, onboarding, mode gelap.
5. Fitur [W]: Inbox, subtugas, jadwal kuliah, tunda cerdas dan aksi massal.

### Urutan 2: Fase A [S] terpilih

Tanggal mulai, riwayat deadline, ujian, ringkasan pagi dan malam, tempat sampah, cara kumpul (5.16), pembatalan kelas dan libur (5.20), pengingat tugas terlambat (5.22), pusat diagnostik pengingat (5.23), dan keamanan data lokal (5.30).

Bila ingin memangkas, urutan prioritas di sini: keamanan data lokal (5.30) dan pusat diagnostik (5.23) dikerjakan lebih dulu karena paling dekat dengan target "tanpa kehilangan satu pengingat pun".

### Urutan 3: Fase B inti

1. Korpus kalimat dan tes parser (ditulis sebelum parser).
2. Parser waktu dan wadah sampai tes lulus, UI chip, saran parser di Inbox.
3. Share dari WhatsApp dan layar calon tugas.
4. Widget dasar dan kalender bulanan.
5. Lampiran, prediksi nilai, ringkasan minggu malam.

### Urutan 4: Fase B [S] terpilih

OCR, deteksi duplikat dan perubahan deadline, nilai dan IPK, cadangan otomatis, rencana belajar ujian, share dari aplikasi lain, bobot komponen (5.18), target pribadi (5.17), kehadiran (5.19), senyap saat kelas dan notifikasi tidak berisik (5.21), fokus hari ini (5.24), ganti semester (5.29), saring tersimpan (5.28), parser lanjutan (7.15), lampiran dokumen (7.20), skenario nilai (7.22), dan impor gabung (7.23).

Urutan di dalam Urutan 4: bobot komponen (5.18) sebelum nilai (7.9) dan skenario (7.22), jadwal kuliah (5.3) sebelum kehadiran (5.19), dan parser dasar (6.1) sebelum parser lanjutan (7.15).

### Urutan 5: Sisa [S] dan semua [B]

Timer fokus, pin dan tag, kontak kelas, suara, pintasan, saran waktu kosong, kalender lengkap, widget lanjutan, wadah non-matkul (5.25), proyek dan milestone (5.26), Quick Add banyak baris (7.16), peta beban mingguan (7.17), tugas berulang, kunci aplikasi dan mode SMA, statistik, bagikan teks dan impor CSV, dependensi tugas (5.27), mode demo (5.31), daftar bawaan (5.32), tautan cepat (5.33), impor jadwal dari tangkapan layar (7.18), ekspor gambar dan PDF (7.19), catatan pertemuan (7.21), dan cadangan terenkripsi (7.24).

### Pemeriksaan oleh manusia (berjalan paralel, tidak memblokir)

- Setelah urutan 1 selesai: pakai sendiri minimal 1 minggu sambil pembangunan terus berjalan.
- Setelah urutan 3 selesai: minta 5 teman mencoba selama 1 minggu, termasuk yang memakai Xiaomi, Oppo, Realme, dan Samsung.
- Laporan masalah masuk ke daftar perbaikan di `PROGRESS.md` (bagian 14). **Laporan pengingat yang hilang diprioritaskan di atas fitur baru**, karena itu target utama aplikasi. Selain itu, pembangunan tidak berhenti menunggu hasil uji.

### Kapan satu fitur dianggap selesai

Tes lulus, aplikasi berjalan tanpa error, perubahan sudah di-commit, dan `PROGRESS.md` diperbarui. Tidak ada syarat menunggu pemakaian nyata sebelum lanjut ke fitur berikutnya.

**Aturan pemotongan** (bagian 1): bila waktu mepet, buang urut dari bawah tabel prioritas.

---

## 14. Cara Bekerja dengan AI (Satu Alur Berkelanjutan)

Tujuannya agar AI pembangun tidak berhenti di tiap fitur atau tiap sesi, dan tetap bisa melanjutkan sendiri bila percakapan terpotong atau konteksnya hilang.

1. **Dua berkas penuntun di repo**, dibaca AI di awal dan diperbarui AI sendiri:
   - `ARCHITECTURE.md`: struktur folder, keputusan penting, skema database, dan aturan (misalnya "skor tidak disimpan", "database hanya menyimpan kunci netral").
   - `PROGRESS.md`: daftar centang seluruh fitur dari tabel bagian 3 menurut urutan bagian 13, ditambah daftar masalah terbuka. AI mencentang tiap fitur yang selesai dan membaca berkas ini untuk tahu harus lanjut dari mana.
2. **Kerjakan berurutan tanpa jeda.** Selesai satu fitur (tes lulus, aplikasi jalan, commit), langsung mulai fitur berikutnya. Tidak perlu menunggu perintah, persetujuan, atau pesan "lanjut".
3. **Berhenti hanya bila benar-benar terhalang**, yaitu:
   - butuh keputusan yang tercantum di Lampiran B,
   - butuh akun, kunci, atau izin yang hanya manusia bisa berikan,
   - butuh uji di HP fisik yang memang menghalangi langkah berikutnya,
   - tes tetap gagal setelah tiga upaya perbaikan yang berbeda.

   Dalam kasus itu, catat hambatannya di `PROGRESS.md`, lalu **lanjut ke fitur lain yang tidak bergantung** padanya. Jangan berhenti total.
4. **Commit kecil dan sering.** Bila ada yang rusak, kembali ke commit terakhir yang baik.
5. **Tes ditulis bersama kode**, terutama untuk parser dan skor.
6. **Sebelum mengubah bagian lama**, tulis di pesan commit apa yang disentuh dan alasannya. Tidak perlu menunggu persetujuan.
7. **Pengingat di HP nyata** tidak bisa diuji AI. AI menyiapkan layar Cek Pengingat dan daftar langkah uji, manusia menjalankannya dan melapor, AI memasukkan temuan ke `PROGRESS.md` dan terus melanjutkan pekerjaan lain sambil menunggu.

**Prompt pembuka (tempel sekali di awal, dan lagi hanya bila percakapan baru):**

```
Baca ARCHITECTURE.md, PROGRESS.md, dan dokumen rancangan lengkap.
Bangun seluruh fitur secara berurutan sesuai bagian 13, mulai dari fitur
pertama yang belum dicentang di PROGRESS.md. Jangan berhenti di antara
fitur dan jangan minta persetujuan untuk lanjut. Setelah tiap fitur:
jalankan tes, commit, perbarui PROGRESS.md, lalu langsung kerjakan fitur
berikutnya. Berhenti hanya bila terhalang oleh hal yang tercantum di
bagian 14 poin 3, dan bila itu terjadi, catat di PROGRESS.md lalu
lanjutkan ke fitur lain yang tidak bergantung.
```

---

## 15. Risiko dan Penangkal

| Risiko | Penangkal |
| --- | --- |
| Scope melebar | Daftar parkir, urutan pembangunan yang tetap, aturan pemotongan |
| Pengingat hilang di merek tertentu | Layar Cek Pengingat, uji dini di HP teman |
| Parser salah tebak lalu pengguna kehilangan kepercayaan | Chip yang bisa dikoreksi, tidak ada penyimpanan diam-diam |
| Data hilang karena ganti HP atau pasang ulang | Ekspor dan impor cadangan, pengingat cadangan berkala |
| Kode berantakan atau arah hilang setelah banyak iterasi | ARCHITECTURE.md, PROGRESS.md, tes, commit kecil |
| Kehilangan motivasi | Urutan 1 saja sudah aplikasi yang berguna, jadi hasil pakai nyata muncul lebih awal |
| Pekerjaan terjemahan menumpuk di akhir | Tulis teks lewat lokalisasi sejak hari pertama, grep sebelum rilis (8.9) |
| Terlalu banyak fitur untuk satu pembuat | Label W, S, B, Urutan 5 opsional, aturan pemotongan, pilih fitur bersama teman (bagian 2) |
| Notifikasi berlebihan membuat pengguna mematikan semuanya | Anggaran notifikasi, gabung notifikasi, intensitas (5.21) |
| Layar Hari Ini terlalu penuh | Bagian hanya tampil bila berisi dan bisa disembunyikan, satu kartu peringatan sekaligus (4.4) |
| Cadangan membengkak karena lampiran dan catatan | Cadangan tanpa lampiran, ukuran total di Pengaturan (7.20) |
| Database rusak saat migrasi | Snapshot sebelum migrasi, cek integritas, layar pemulihan (5.30) |

---

## 16. Gambaran Satu Hari Bersama Aplikasi

Gambaran ini memakai fitur dari seluruh tahap, jadi sebagian baru nyata di Urutan 3 sampai 5.

**07.00** Notifikasi pagi: "Hari ini 2 kelas, 3 tugas. Paling mendesak: laprak Basdat (deadline 23.59)." Di widget terlihat Kelas Hari Ini.

**09.40** Di kelas, dosen menyebut kuis Pemweb besok. Kamu membuka Quick Add, menekan mikrofon, dan berkata "kuis pemweb besok jam delapan". Chip muncul: Kuis, Pemrograman Web, besok 08.00. Satu ketukan menyimpan.

**10.30** Notifikasi "Isi kehadiran: Basdat" muncul setelah kelas. Kamu mengetuk Hadir. Di layar matkul tertulis "sisa jatah absen 3".

**12.15** Grup kelas mengirim tangkapan layar pengumuman. Kamu bagikan ke aplikasi. OCR mengenali dua kalimat deadline, dan aplikasi mencatat bahwa salah satunya sepertinya mengubah deadline tugas yang sudah ada. Kamu menyetujui, dan riwayat deadline mencatat "diundur".

**14.00** Saran waktu kosong: "Kamu kosong sampai 16.00. Mulai laprak Basdat?" Kamu menyalakan timer fokus 25 menit.

**17.00** Kartu peringatan di layar Hari Ini: "Kamis 130 persen." Kamu memajukan satu laprak ke besok sore, lalu memilih tiga tugas fokus untuk besok.

**20.30** Penutup malam: "Ada 2 tugas besok." Kamu menunda satu pengingat ke pagi hari dan tidur tenang.

**Minggu malam** Ringkasan mingguan: tugas tepat waktu, matkul terpadat minggu depan, dan satu kartu cadangan: "Cadangan terakhir 6 hari lalu."

---

## Lampiran A: Daftar Perubahan dari v2 Awal

**Struktur**

- Bagian 13 sampai 22 dilebur ke alur utama. Bagian 22.11 ("Dampak pada Skema dan Bagian Lain") dihapus karena semua dampaknya sudah diterapkan langsung: langkah bahasa di onboarding (4.1), baris bahasa di 4.7, kamus parser terpisah (8.5 dan 9), pengujian bahasa (12.3), dan folder `l10n/` (9).
- Tiga daftar parkir (bagian 1, 12, 21) menjadi satu.
- Tiga jadwal (bagian 9, 18, dan usaha di 22.12) menjadi satu urutan pembangunan di bagian 13 dan 3.
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
- **Urutan:** kolom Urutan ditambahkan ke tabel prioritas supaya setiap fitur punya tempat di jadwal. Fitur [S] yang tidak disebut di jadwal lama ditempatkan di Urutan 5 (bertanda `*`).
- Perbaikan kecil: "Tampilan tersibuk" menjadi "Penanda minggu tersibuk" (6.4), rumus batas mulai di 5.4 ditulis dengan tanda kurung supaya tidak ambigu, dan jenis tugas `quiz` dan `final` ditambahkan ke tabel kunci netral.

**Revisi kedua (tanpa pembagian sesi kerja):**

- Bagian 13 "Jadwal Kerja" menjadi "Urutan Pembangunan (Satu Alur Berkelanjutan)". Pembagian tahap, minggu, dan "titik berhenti" tidak lagi berfungsi sebagai tempat berhenti. Pemakaian sendiri 1 minggu dan uji 5 teman tetap ada, tetapi berjalan paralel dan tidak menghalangi pembangunan.
- Satu pengecualian yang sengaja dipertahankan: laporan pengingat hilang diprioritaskan di atas fitur baru. Hapus bila kamu tidak mau ada prioritas apa pun.
- Bagian 14 ditulis ulang: aturan "satu fitur per sesi" dihapus, ditambah `PROGRESS.md` supaya AI bisa melanjutkan sendiri, daftar kondisi berhenti yang sempit, dan prompt pembuka siap tempel.
- Baris risiko di bagian 15 disesuaikan.

**Revisi ketiga (pengembangan dan pengayaan fitur):**

- **28 fitur baru.** Fase A (5.16 sampai 5.33): cara kumpul dan status dikumpul, target pribadi, bobot komponen, kehadiran dan batas absen, pembatalan kelas dan libur, notifikasi tidak berisik, pengingat tugas terlambat, pusat diagnostik pengingat, fokus hari ini, wadah non-matkul, proyek dan milestone, dependensi tugas, saring tersimpan, ganti semester, keamanan data lokal, mode demo, daftar bawaan, dan tautan cepat global. Fase B (7.15 sampai 7.24): parser lanjutan, Quick Add banyak baris, peta beban mingguan, impor jadwal dari tangkapan layar, ekspor gambar dan PDF, lampiran dokumen, catatan pertemuan, skenario nilai, impor gabung, dan cadangan terenkripsi.
- **Fitur lama diperkaya:** Mode Minggu Ujian (5.7), ringkasan pagi dan malam (5.12), widget Fokus Hari Ini (7.8), statistik tambahan (7.11), share WhatsApp dan lampiran (6.2, 6.5), pembatalan satu kali di jadwal kuliah (5.3), dan perilaku kanal tugas terlambat yang sebelumnya hanya disebut namanya (4.6, 5.22).
- **Layar Hari Ini (4.4)** bertambah bagian Fokus hari ini dan Menunggu, serta aturan agar layar tidak terlalu penuh. **Skor urgensi (4.5)** mendapat tiga penyesuaian (target pribadi, bobot efektif, tugas menunggu). Rumus dasarnya tidak berubah.
- **Skema (bagian 10):** 9 tabel baru, kolom baru di `spaces`, `tasks`, `attachments`, `reminders`, dan `task_templates`, serta aturan tanggal kalender sebagai teks lokal. Kunci netral baru ditambahkan ke tabel 8.3.
- **Tabel prioritas (bagian 3)** dibangun ulang dengan kolom Asal. Usaha total naik dari 82 menjadi 149 hari kerja. Tidak ada fitur baru yang berlabel Wajib.
- **Pengujian (12.2)** ditambah baris untuk semua fitur baru. **Urutan (13)** dan **risiko (15)** disesuaikan. Bagian 2 menambahkan langkah memilih fitur bersama teman, dan daftar parkir ditambah beberapa ide yang sengaja ditunda.
- Di antara fitur baru, ada ide yang sengaja **tidak** dimasukkan karena melanggar batasan tanpa akun dan tanpa server atau terlalu berat: pengingat berbasis lokasi, aplikasi jam tangan, dan berbagi jadwal antarpengguna (semuanya di daftar parkir).

**Tidak diubah:** semua keputusan produk, rumus skor, aturan parser, daftar fitur, dan isi tiap fitur.

---

## Lampiran B: Hal yang Perlu Diputuskan

1. **Pengingat di jam tenang.** Deadline bawaan 23.59 dan jam tenang 22.00 sampai 06.00, sehingga pengingat "30 menit sebelum" (sekitar 23.29) selalu jatuh di jam tenang, begitu juga pengingat 1 jam. Tentukan aturannya: digeser ke sebelum jam tenang, dikecualikan bila deadline kurang dari 1 jam, atau digabung ke satu notifikasi sebelum jam tenang. Selain itu, jam tidur untuk skor (23.00 sampai 06.00, bagian 4.5) dan jam tenang notifikasi (22.00 sampai 06.00) berbeda. Sengaja atau perlu disamakan?
2. **Penjadwalan 14 hari ke depan.** Di 4.6 tertulis "dijadwalkan ulang oleh tugas harian saat aplikasi dibuka". Bila aplikasi tidak dibuka lebih dari 14 hari, pengingat yang jauh bisa tidak pernah terjadwal. Pertimbangkan tugas latar periodik (misalnya WorkManager) selain pemicu saat aplikasi dibuka, karena target utamamu adalah tidak kehilangan satu pengingat pun.
3. **Dua bahasa dan beban waktu.** Pilihan Inggris menambah sekitar 11 sampai 12 hari dan tidak ada di estimasi 16 sampai 20 minggu. Pengguna utamamu teman sekelas berbahasa Indonesia. Pertimbangkan: kerjakan infrastrukturnya sekarang (ARB, kunci netral, tanpa teks di kode, sekitar 3 sampai 4 hari) dan tunda terjemahan Inggris serta kamus parser Inggris ke Urutan 5. Strategi bertahap di 8.5 sudah mengarah ke sini.
4. **Penempatan fitur bertanda `*` di tabel bagian 3.** Timer fokus, pin dan tag, kontak kelas, suara, pintasan, saran waktu kosong, kalender lengkap, dan widget lanjutan tidak punya tahap di v2 awal. Cek apakah Urutan 5 sudah sesuai keinginanmu, atau ada yang mau dinaikkan.
5. **Izin dan layanan Android yang perlu dicek dokumentasinya.** Dua fitur punya risiko di versi Android baru: alarm presisi (`SCHEDULE_EXACT_ALARM`, sepengetahuan saya tidak diberikan otomatis pada Android 14 ke atas untuk aplikasi baru) dan timer fokus yang "tetap hidup saat layar mati" (butuh foreground service dengan tipe yang sesuai). Estimasi 4 hari untuk timer fokus mungkin terlalu kecil. Periksa dokumentasi Android terbaru sebelum mengerjakan keduanya.
6. **Cadangan otomatis lebih awal?** Tanpa cloud, kehilangan data adalah risiko terbesar bagi pengguna. Cadangan manual JSON sudah ada di Urutan 1, tetapi cadangan otomatis (7.13) baru di Urutan 4. Bila ingin lebih aman, naikkan ke Urutan 2.
7. **Aturan kehadiran kampus.** Batas absen (bawaan 25 persen) dan cara menghitung izin dan sakit berbeda tiap kampus dan kadang tiap dosen. Cek aturan kampusmu sebelum menetapkan nilai bawaan di 5.19.
8. **Anggaran notifikasi.** Nilai bawaan 8 notifikasi non-kritis per hari (5.21) hanyalah tebakan. Tentukan setelah dipakai nyata, dan putuskan apakah intensitas "Gencar" memang diperlukan.
9. **Data pribadi di Profil.** Pola nama berkas (5.16) memakai NIM dan nama dari Pengaturan > Profil. Putuskan apakah kolom ini disimpan di database biasa, ikut cadangan, dan ikut cadangan terenkripsi (7.24) atau dikecualikan dari cadangan.
10. **Tambahan 49 hari Sebaiknya dan 18 hari Bonus.** Total fitur kini 149 hari kerja. Putuskan fitur baru mana yang benar-benar masuk Urutan 4 dan mana yang dipindah ke Urutan 5 setelah memilih bersama teman (bagian 2). Usul saya: pertahankan di Urutan 4 hanya keamanan data (5.30), diagnostik (5.23), bobot komponen (5.18), kehadiran (5.19), dan parser lanjutan (7.15), karena paling dekat dengan masalah nyata mahasiswa dan target aplikasi.
11. **Foreground service dan penyimpanan.** Lampiran dokumen (7.20), cadangan otomatis ke folder pilihan (7.13), dan cadangan terenkripsi (7.24) bergantung pada izin penyimpanan dan folder (Storage Access Framework) yang berbeda antar versi Android. Periksa dokumentasi Android terbaru sebelum mengerjakan.
