# Panduan Kolaborasi & Aturan Pengembangan Tim (CampuShift)

Dokumen ini berisi aturan main wajib bagi seluruh anggota tim pengembang CampuShift. Tujuannya adalah untuk mencegah *merge conflict*, menjaga kualitas kode, dan memastikan kelancaran integrasi antar kelima modul fungsional.

---

## 1. Aturan Git & Version Control (Mencegah Conflict)
- **Dilarang keras melakukan `push` atau *commit* langsung ke branch `main`!** Branch `main` hanya digunakan untuk versi stabil aplikasi.
- **Gunakan Branch per Modul:** Setiap anggota wajib bekerja di branch modulnya masing-masing.
  - Penamaan branch: `modul-[nama]`, contoh: `modul-habib`.
- **Selalu Tarik Pembaruan (*Pull*) Sebelum Push:** Sebelum membuat *Pull Request* atau *merge*, pastikan branch Anda *up-to-date* dengan branch `main` terbaru menggunakan `git pull origin main`.
- **Komunikasi Saat Merge:** Jika ada perubahan pada file inti (seperti `lib/main.dart` atau `pubspec.yaml`), informasikan ke grup tim agar yang lain bersiap untuk *pull* dan mengatasi *conflict* lokal mereka.

## 2. Kepatuhan Arsitektur (MVVM)
Proyek ini menggunakan pola arsitektur **Model-View-ViewModel (MVVM)**. File harus ditempatkan pada folder yang tepat di dalam direktori `lib/`:
- `views/`: HANYA berisi kode antarmuka UI (Widget). **Dilarang melakukan pemanggilan API (HTTP Request) atau logika bisnis kompleks di sini.**
- `viewmodels/`: Berisi logika state management (Provider/Riverpod/GetX). Tempat untuk menyimpan *state* sementara dan melakukan pemanggilan ke `services/`. **Pisahkan ViewModel antar modul** (misal: `BarterViewModel` jangan dicampur dengan `ListingViewModel`).
- `models/`: Berisi kelas representasi data (Entitas) dan logika serialisasi JSON (misal: `fromJson`, `toJson`).
- `services/`: Berisi kode untuk integrasi ke Backend RESTful API atau *local storage*.

## 3. Aturan Modul & *Low Coupling* (Ketergantungan Rendah)
- **Komunikasi Antar Modul via ID:** Saat modul Anda butuh data dari modul lain (misalnya Modul Barter butuh Barang dari Modul Listing), **oper `ID` (contoh: `itemId`), bukan seluruh objek data**.
- **Hindari Mengubah UI Modul Lain:** Jika aksi di Modul 3 (Habib) membuat barter berstatus Locked, biarkan API Backend yang mengubah status kedua barang menjadi `Reserved` di database. Saat pengguna pindah ke halaman Modul 1, minta halaman tersebut me-refresh datanya dari API. Jangan memaksa *update state* secara *hardcode* menyilang antar layar.
- **Status Barang Hanya Diubah Server:** Status barang (`Available`, `Reserved`, `Completed`, `Archived`) mengikuti tabel aturan status di PRD bagian 2.5 dan siklus status di bagian 2.6. Aplikasi hanya menampilkan status hasil dari API, tidak menghitung atau mengubahnya sendiri.
- **Gunakan Rute Terpusat:** Gunakan sistem *routing* untuk berpindah halaman (misal `Navigator.pushNamed`), dan daftarkan rutenya di file utama atau pengelola rute agar rapi.

## 4. Standar Backend & Integrasi API
- **Kepatuhan Mutlak Non-Firebase:** Sesuai PRD, seluruh penyimpanan data (termasuk Auth dan Foto) **wajib menggunakan RESTful API dan Database Relasional di VPS**. Dilarang menggunakan Firebase (termasuk untuk fungsi Auth).
- **Pengamanan Sesi (JWT):** Saat memanggil *endpoint* API yang bersifat privat (Create, Update, Delete), **wajib** menyertakan JSON Web Token (JWT) pada *Header HTTP* (`Authorization: Bearer <token>`).
- **Penanganan Error (*Error Handling*):** Gunakan `try-catch` saat memanggil API. Selalu tampilkan `SnackBar` atau dialog informatif kepada *user* apabila terjadi *Timeout* atau gagal memuat data. Jangan biarkan aplikasi *crash* (layar merah) atau *loading* tanpa henti.
- **Notifikasi Tanpa FCM:** Semua notifikasi memakai `flutter_local_notifications`. Pilih jenis pemicu sesuai PRD bagian 2.8 (katalog notifikasi di 2.9): **terjadwal lokal** (waktu sudah diketahui perangkat sendiri), **langsung lokal** (setelah aksi di perangkat sendiri berhasil), atau **berbasis sinkronisasi** (event dari pengguna lain, dicek ke server saat aplikasi dibuka/aktif). Jangan menjanjikan notifikasi instan untuk event dari perangkat lain.

## 5. UI/UX & Standar Material 3
- Gunakan komponen **Material Design 3** (seperti `Card`, `ElevatedButton`, `NavigationBar`).
- Gunakan warna *seed color* bawaan (Utama: `#0D9488` / *Teal*) yang sudah diatur di `main.dart` sebagai tema dasar agar seragam antarmodul.
- **Pastikan Tidak Overflow:** Uji modul Anda di emulator/perangkat fisik dengan ukuran layar kecil hingga sedang untuk mencegah munculnya peringatan *pixel overflow* (garis kuning-hitam di layar). Gunakan `SingleChildScrollView` atau `Expanded` dengan bijak.

## 6. Kepatuhan Aturan Tugas (Log AI & Review)
- **Wajib Paham Kode:** Ingatlah bahwa setiap anggota akan dievaluasi kodenya. **Dilarang keras menempel kode (copy-paste) dari ChatGPT/Gemini jika Anda tidak bisa menjelaskan baris demi baris cara kerjanya.**
- **Catat Penggunaan AI (AI Usage Log):** Setiap kali menggunakan AI untuk kode besar atau perbaikan bug, catat di dalam folder `docs/ai_logs/`. Setiap anggota membuat file log-nya sendiri (misal: `habib_log.md`). Gunakan format yang ada di `docs/ai_logs/TEMPLATE.md` untuk mencatat Prompt, Hasil, Modifikasi Anda, dan Testing.

---
*Dengan mematuhi panduan ini, integrasi modul Auth dan kelima modul fungsional (Listing, Safe-Meet & Pertemuan, Barter, Serah Terima QR, dan Hibah) akan berjalan mulus tanpa bentrok di akhir semester.*
