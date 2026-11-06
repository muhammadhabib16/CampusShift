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

---

## Log #4
- **Tanggal:** 2026-11-06
- **Tujuan penggunaan AI:** Mendiagnosis error "Titik temu resmi belum tersedia di server" saat mengajukan pertemuan COD (Modul 2).
- **Prompt/instruction yang digunakan:** Screenshot layar "Ajukan Pertemuan COD" dengan SnackBar error, disertai pesan "muncul error seperti berikut".
- **Output atau solusi yang dihasilkan:** AI menelusuri asal pesan ke `MeetupRepository.refresh()` (`lib/services/meetup_repository.dart`) dan menemukan bahwa `GET /safe-meet-points` di server produksi mengembalikan daftar kosong. Akar masalahnya ada di backend: tabel `SafeMeetPoint` belum di-seed karena `Dockerfile` hanya menjalankan `npm start`. Solusinya adalah menjalankan `docker exec campusshift-api npx prisma db seed` di homeserver (seed memakai `upsert` sehingga aman diulang).
- **Perubahan yang dilakukan:** Tidak ada perubahan kode pada langkah ini; perbaikan dilakukan dengan menjalankan seed di server.
- **Proses verifikasi/testing:** Mengecek endpoint produksi dengan `curl` (membutuhkan token, sehingga verifikasi akhir dilakukan dari aplikasi setelah seed dijalankan) dan memastikan format respons `{ success, data: [...] }` sudah sesuai dengan parser `Backend.list()`.

---

## Log #5
- **Tanggal:** 2026-11-06
- **Tujuan penggunaan AI:** Merapikan `.gitignore`, menambahkan ikon lonceng notifikasi di app bar, dan memperbaiki tampilan aplikasi yang masih salah atau membingungkan.
- **Prompt/instruction yang digunakan:** "coba update git ignore dll, serta tambahkan icon bell notifikasi di app bar serta perbaiki tampilan aplikasi yang masih salah atau membingungkan."
- **Output atau solusi yang dihasilkan:**
  1. `.gitignore` Flutter ditambah aturan untuk `android/app/.cxx/`, FVM, file sisa merge (`*.orig`, `*.rej`, `*.bak`), dan folder `lib_backup_*/`; folder backup dikecualikan dari `analysis_options.yaml`. `.gitignore` dan `.dockerignore` backend juga diperbarui.
  2. Fitur notifikasi dalam aplikasi: `NotificationCenter` (`lib/services/notification_center.dart`) yang memanggil `GET /sync` setiap 60 detik dan mengubah perubahan status pertemuan, barter, serta klaim hibah dari pihak lain menjadi notifikasi. Status "sudah dibaca" disimpan per akun di SharedPreferences. Ditambah `NotificationBell` (ikon lonceng dengan badge jumlah belum dibaca) di app bar keempat tab dan layar `NotificationsScreen`.
  3. Perbaikan UI: menghapus ±115 kode spesifikasi PRD (BR-xx, FR-xx, AC-xx, N-xx) dari teks yang tampil ke pengguna, mengganti istilah teknis ("Token", "immutable", "npx prisma db seed", "Modul 2/4") dengan bahasa yang mudah dipahami, memperbaiki `StepBanner` agar judul tidak terpotong, mencegah overflow di form pertemuan, serta memperjelas nama menu di halaman Profil.
- **Perubahan yang dilakukan:** Menyesuaikan dua test yang mencari teks lama (`handover_test.dart`, `home_screen_widget_test.dart`) dan menambahkan `ensureVisible` pada `barter_flow_widget_test.dart` karena banner langkah menjadi sedikit lebih tinggi. Folder `lib_backup_racha/` yang sudah terlanjur ter-commit perlu dilepas manual dengan `git rm -r --cached lib_backup_racha` setelah disepakati tim.
- **Proses verifikasi/testing:** Menjalankan `flutter analyze` (tidak ada issue) dan `flutter test` (50 test lulus), lalu mengecek ikon lonceng dan tampilan baru langsung di perangkat Android.

---

## Log #6
- **Tanggal:** 2026-11-06
- **Tujuan penggunaan AI:** Memperbaiki gambar produk yang tidak muncul pada bagian "Barang Terbaru" di Beranda.
- **Prompt/instruction yang digunakan:** Screenshot Beranda dengan kartu barang yang hanya berisi ikon, disertai pertanyaan "kenapa gambar produk tidak muncul di barang terbaru".
- **Output atau solusi yang dihasilkan:** AI menemukan bahwa model `ListingSummary` tidak menyimpan URL foto sama sekali, sehingga kartu Beranda hanya menampilkan ikon kategori (berbeda dengan Katalog yang memakai `photoUrls`). Solusinya: menambahkan field `photoUrl` (foto pertama barang) pada `lib/models/listing_summary.dart` dan menampilkannya dengan `Image.network` di `_buildProductCard` (`lib/views/home_screen.dart`), dengan ikon kategori sebagai fallback saat foto dimuat, gagal dimuat, atau kosong.
- **Perubahan yang dilakukan:** Memastikan URL foto dari backend sudah absolut (dibentuk oleh `toPublicUrl` dari `PUBLIC_BASE_URL`), sehingga variabel tersebut perlu diisi dengan domain publik di `.env` server agar foto dapat diakses dari HP.
- **Proses verifikasi/testing:** `flutter analyze` dan `flutter test` (50 test lulus), kemudian memeriksa kartu "Barang Terbaru" di perangkat setelah build ulang.

---

## Log #7
- **Tanggal:** 2026-11-06
- **Tujuan penggunaan AI:** Memperbaiki error "RIGHT OVERFLOWED BY 20 PIXELS" pada kartu profil (baris Skor Reputasi).
- **Prompt/instruction yang digunakan:** Screenshot halaman Profil dengan garis kuning-hitam overflow, disertai pertanyaan "apa penyebab overflow ini".
- **Output atau solusi yang dihasilkan:** AI menjelaskan bahwa `Row` berisi teks "Skor Reputasi Mahasiswa" dan widget `RatingStars` ("Belum ada ulasan") tanpa `Expanded`/`Flexible`, sehingga tidak bisa menyusut ketika ukuran font sistem HP besar. Solusinya: label dibungkus `Expanded` dan dipersingkat menjadi "Skor Reputasi", `RatingStars` dibungkus `Flexible`, dan teks di dalam `RatingStars` (`lib/shared/widgets/user_avatar.dart`) diberi `Flexible` + `TextOverflow.ellipsis`.
- **Perubahan yang dilakukan:** Memastikan `RatingStars` hanya dipakai di halaman Profil (yang sudah dibungkus `Flexible`), sehingga perubahan tidak memicu error layout di layar lain.
- **Proses verifikasi/testing:** `flutter analyze` dan `flutter test` (50 test lulus), lalu membuka halaman Profil di HP dengan ukuran font sistem besar untuk memastikan overflow sudah hilang.
