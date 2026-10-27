# AI Usage Log - Modul 5: Hibah & Klaim Berbasis Kebutuhan
**Nama Mahasiswa:** Muhammad Racha Ardiwinata (2411522020)  
**Modul:** Modul 5 – Hibah & Klaim Berbasis Kebutuhan (`modul-racha`)  

---

## Log 1: Pembaruan Arsitektur MVVM & Siklus CRUD Klaim Sesuai PRD v1.4
1. **Tujuan Penggunaan AI:**  
   Menyesuaikan model, service, viewmodel, dan layar UI Modul 5 dari spesifikasi PRD lama ke PRD v1.4 terbaru (pemisahan operasi Delete permanen untuk klaim `Pending` dan Cancel untuk klaim `Approved`, validasi justifikasi 100–1.000 karakter, kuota maksimal 3 klaim aktif, serta pengurutan antrean donatur berbasis urgensi).

2. **Prompt / Instruction yang Digunakan:**  
   *"Bantu saya memperbarui kode Modul 5 (Hibah & Klaim) pada aplikasi Flutter CampuShift dengan arsitektur MVVM agar mematuhi FR-23 s.d. FR-28, BR-27 s.d. BR-32, serta AC-27 s.d. AC-31 pada PRD v1.4 tanpa menggunakan Firebase."*

3. **Output atau Solusi yang Dihasilkan:**  
   - Model `GrantClaim` dan `SocialGrant` dengan serialisasi JSON, perhitungan prioritas urgensi (`Mendesak`, `Sedang`, `Rendah`), dan status sesuai Tabel 2.6 PRD.
   - `GrantClaimService` dan `GrantClaimViewModel` yang mengimplementasikan CRUD lengkap (`createClaim`, `fetchMyClaims`, `fetchQueueForItem`, `updatePendingClaim`, `deletePendingClaim`, `cancelApprovedClaim`, `approveClaim`, `rejectClaim`).
   - `GrantNotificationService` berbasis sinkronisasi untuk *Claim Status Alert* (N-06) dan *Pickup Reminder* (N-07).

4. **Perubahan yang Dilakukan Mahasiswa:**  
   - Menyesuaikan kompatibilitas *getter* pada `GrantClaim` dan `SocialGrant` agar tetap terintegrasi dengan `home_screen.dart` dan `main_screen.dart` yang sudah di-merge tim.
   - Menambahkan penghitung karakter langsung (*live counter*) pada `AjukanKlaimScreen` dan menonaktifkan tombol kirim ketika karakter kurang dari 100 (AC-27).
   - Mengubah alur `DigitalClaimPassScreen` agar mengikuti aturan *Out of Scope* PRD v1.4 (diarahkan ke jadwal pertemuan Modul 2 via `claim_id` dan `item_id`).

5. **Proses Verifikasi / Testing:**  
   - Diuji menggunakan skenario **AC-27** (input justifikasi 80 karakter -> tombol kirim nonaktif & pesan validasi tampil).
   - Diuji menggunakan skenario **AC-28** (klaim `Rendah` dibuat lebih dulu, klaim `Mendesak` dibuat belakangan -> klaim `Mendesak` tampil di urutan #1 antrean donatur).
   - Diuji menggunakan skenario **AC-29** (Donatur menyetujui 1 klaim -> klaim terpilih `Approved`, klaim lain otomatis `Rejected`, status barang menjadi `Reserved`, dan notifikasi N-06 muncul saat sinkronisasi).
   - Diuji menggunakan skenario **AC-30 & AC-31** (klaim `Pending` berhasil disunting dan dihapus permanen; klaim `Approved` menolak disunting dan hanya menampilkan opsi Batalkan).
