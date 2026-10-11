# AI Usage Log - Muhammad Habib

Log ini digunakan untuk mencatat setiap penggunaan AI (ChatGPT, Gemini, Copilot, dll) selama pengembangan modul. Sesuai aturan, Anda harus memahami kode yang dihasilkan AI.

---

## Log #1
- **Tanggal:** 2026-10-04
- **Tujuan penggunaan AI:** Evaluasi Keamanan Backend Campusshift, Validasi Input, dan perbaikan Bug UI/State.
- **Prompt/instruction yang digunakan:** "Evaluasi Keamanan Backend Campusshift" beserta bantuan perbaikan pada repository/modul Habib.
- **Output atau solusi yang dihasilkan:** AI membantu mengevaluasi keamanan sistem (khususnya validasi input dan integrasi backend), memberikan saran perbaikan pada `validators.dart`, `item_repository.dart`, dan penyesuaian pada UI Screen (`login_screen.dart`, `home_screen.dart`, dll).
- **Perubahan yang dilakukan:** Menambahkan/memperbaiki fungsi validasi di `lib/utils/validators.dart`, mengupdate fungsi data pada `lib/data/item_repository.dart`, dan menyelaraskan penanganan error/state di berbagai screen (`catatan_form_screen.dart`, `detail_screen.dart`, `not_found_screen.dart`, `state_views.dart`).
- **Proses verifikasi/testing:** Menjalankan aplikasi untuk memastikan seluruh routing berjalan baik setelah pengecekan (git switch branch), input pada form dapat tervalidasi dengan baik, dan tidak ada bug/error yang muncul di layar akibat data yang tidak valid.

---

## Log #2
- **Tanggal:** 2026-10-04
- **Tujuan penggunaan AI:** Mengimplementasikan *Workflow* lengkap (Input, State, Validation, Feedback, Navigation) pada Modul Barter.
- **Prompt/instruction yang digunakan:** "sekarang coba implementasikan logikanya, buat yang bagian modul habib agar dia setidaknya bisa melakukan satu workflow lengkap. seperti di gambar"
- **Output atau solusi yang dihasilkan:** AI mengimplementasikan alur logika pengiriman proposal barter di `barter_negotiation_screen.dart`, mengintegrasikan validasi form (`FormState`), *loading indicator*, `SnackBar` (Feedback), dan navigasi `Navigator.pop()`.
- **Perubahan yang dilakukan:** 
  1. Menambahkan form dan validasi (angka negatif/kosong) pada `barter_negotiation_screen.dart`.
  2. Memperbaiki *bug* pada `home_screen.dart` (pengiriman variabel `context` untuk memunculkan *bottom sheet*).
  3. Memperbaiki *overflow* layout pada `home_screen.dart`.
- **Proses verifikasi/testing:** Menjalankan `flutter run` di emulator/perangkat asli. Mengetes tombol *Kirim Penawaran* dengan nilai kosong untuk memicu *error* validasi, serta memasukkan nilai benar untuk melihat *feedback* (*loading* & *SnackBar*) yang berakhir dengan navigasi otomatis.

---

## Log #3
- **Tanggal:** 2026-10-11
- **Tujuan penggunaan AI:** Merevisi PRD dan timeline proyek berdasarkan umpan balik dosen (scope terlalu luas, notifikasi tidak konsisten dengan batasan teknis, role pengguna belum jelas).
- **Prompt/instruction yang digunakan:** "coba pahami isi prd project mobile ini dan keseluruhan konteks project mobile ini", lalu "ada sedikit koreksi atau feedback terkait prd dari dosen saya, coba kamu sesuaikan lagi prd nya dan update prd agar lebih sesuai dengan saran. dan masih pas untuk pembagian tugas kepada 5 orang" (disertai screenshot umpan balik dosen), dan "okeh coba update timelinenya dan update juga file yang perlu diupdate".
- **Output atau solusi yang dihasilkan:**
  1. `docs/prd.md` v1.1: fokus pada satu masalah utama (kepercayaan dalam pengalihan barang bekas), jual/barter/hibah dijadikan tiga jalur dalam satu alur inti, definisi peran Pemilik Barang & Peminat, label prioritas [W]/[O], mekanisme notifikasi (terjadwal, langsung, berbasis sinkronisasi), aturan status barang terpusat, dan tabel pembagian modul.
  2. `CampuShift_Timeline_v4.xlsx` (pengganti v3): tugas backend & Flutter disesuaikan dengan PRD v1.1, pembagian backend Bayu/Habib diseimbangkan.
  3. `docs/TEAM_GUIDELINES.md`: aturan status barang hanya diubah server dan aturan jenis pemicu notifikasi.
- **Perubahan yang dilakukan:** (diisi setelah review tim — misalnya penyesuaian nama kampus pilot, stack backend final, atau pembagian tugas yang disepakati)
- **Proses verifikasi/testing:** Membandingkan setiap poin umpan balik dosen dengan tabel "Tindak Lanjut Umpan Balik Dosen" di PRD, memastikan setiap anggota tetap memiliki ≥ 4 fungsionalitas, 1 entitas CRUD, dan 1 notifikasi, serta memeriksa ulang tanggal setiap bar pada Gantt chart timeline v4.
