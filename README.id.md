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

## ✨ Tentang

**Lekas** adalah aplikasi Android offline-first untuk mahasiswa mencatat tugas dan deadline, rapi per matkul, dengan pengingat lokal yang andal. Tanpa akun, tanpa cloud, tanpa kolaborasi - semua data tersimpan di HP.

## 🎯 Fitur (Fase A & B)

- 📚 **Wadah (matkul)** dengan warna, alias untuk parser Quick Add, catatan (dosen, ruangan, tautan)
- ✅ **Tugas** dengan jenis, deadline, prioritas, status, bobot, estimasi, individu/kelompok
- 📅 **Layar Hari Ini** diurutkan skor urgensi, dengan bagian terlambat/hari ini/minggu ini
- 🔔 **Pengingat lokal** (H-3, H-1, 3 jam, 30 menit) dengan boot receiver dan panduan baterai
- ⚡ **Quick Add** dengan parser bahasa Indonesia/Inggris
- 📲 **Share dari WhatsApp** (teks + OCR tangkapan layar)
- 📆 **Kalender bulanan** dengan titik berwarna per matkul
- 💾 **Cadangan & pemulihan lokal** (ekspor/impor JSON)
- 🌙 **Mode gelap**, dua bahasa (Indonesia bawaan, Inggris pilihan)

## 🛠️ Tumpukan Teknis

Flutter · Drift (SQLite) · Riverpod · flutter_local_notifications · home_widget

## 📄 Lisensi

MIT - lihat [LICENSE](LICENSE).