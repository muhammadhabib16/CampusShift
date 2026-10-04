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
