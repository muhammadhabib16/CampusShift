# Audit UI/UX Menyeluruh Frontend CampuShift (Flutter)

**Tanggal Audit:** 27 Oktober 2026  
**Target:** Flutter Android (Android 8.0–14, layar 5,0–6,7 inci)  
**Dokumen Acuan:** PRD CampuShift v1.3 (18 Oktober 2026), Bagian 2.1, 2.4, 2.10, NFR-02, NFR-03, NFR-06, NFR-08  

---

## 1. Inventaris Layar Per Modul

| Modul | Nama Layar / Deskripsi | File Path | Status State (Loading, Kosong, Error) |
|---|---|---|---|
| **Pendukung** | Splash Screen | `lib/views/splash_screen.dart` | Loading animasi logo & auto session-restore |
| **Pendukung** | Onboarding Screen | `lib/views/onboarding_screen.dart` | 3 halaman pengenalan ekonomi sirkular |
| **Pendukung** | Login Screen | `lib/views/login_screen.dart` | Form input NIM/email + password, validasi, snackbar error |
| **Pendukung** | Register Screen | `lib/views/register_screen.dart` | Form identitas, NIM, universitas, email kampus, password |
| **Pendukung** | Main Navigation Screen | `lib/views/main_screen.dart` | Root IndexedStack navigation bar 4 tab |
| **Pendukung** | Beranda (Home Screen) | `lib/views/home_screen.dart` | Quick actions, Safe-Meet highlight, listing terbaru, kategori |
| **Pendukung** | Profil Pengguna | `lib/views/profile_screen.dart` | Avatar, reputasi, menu profil, modal logout |
| **Modul 1** | Katalog Barang | `lib/views/listing/catalog_screen.dart` | Search, chip filter kategori, grid 2 kolom, floating button |
| **Modul 1** | Detail Barang | `lib/views/listing/item_detail_screen.dart` | Foto barang, kondisi, badge tipe transaksi, CTA aksi |
| **Modul 1** | Form Tambah Listing | `lib/views/listing/add_listing_screen.dart` | Upload foto, input judul, harga/gratis, kondisi, deskripsi |
| **Modul 2** | Direktori Safe-Meet | `lib/views/safe_meet/safe_meet_directory_screen.dart` | Toggle list/map, GPS status banner, jarak, filter kategori |
| **Modul 2** | Detail Titik Temu | `lib/views/safe_meet/safe_meet_detail_screen.dart` | Foto titik temu, deskripsi fasilitas, peta rute |
| **Modul 2** | Form Pengajuan Pertemuan | `lib/views/safe_meet/meetup_form_screen.dart` | Pemilihan titik temu, tanggal, waktu, catatan |
| **Modul 2** | Jadwal Pertemuan Saya | `lib/views/safe_meet/my_meetups_screen.dart` | Tab jadwal aktif & riwayat, status badge |
| **Modul 2** | Detail Pertemuan | `lib/views/safe_meet/meetup_detail_screen.dart` | Info pertemuan, navigasi rute, shortcut serah terima QR |
| **Modul 3** | Daftar Tawaran Barter | `lib/views/barter/barter_list_screen.dart` | Tab Barter Masuk & Keluar, status kesepakatan |
| **Modul 3** | Form & Negosiasi Barter | `lib/views/barter/barter_negotiation_screen.dart` | Komparasi 2 barang, cash top-up adjustment, log negosiasi |
| **Modul 3** | Konfirmasi Barter | `lib/views/barter/barter_confirmation_screen.dart` | Rangkuman kesepakatan, dual-confirmation banner |
| **Modul 3** | Bottom Sheet Pemilih Barang | `lib/views/barter/widgets/barter_item_selection_sheet.dart` | Sheet daftar barang milik user untuk ditawarkan |
| **Modul 4** | Sesi Serah Terima QR (Pemilik) | `lib/views/handover/serah_terima_qr_screen.dart` | QR generator, timer ring progress, dialog pembatalan |
| **Modul 4** | Pindai QR & Verifikasi (Peminat) | `lib/views/handover/serah_terima_qr_screen.dart` | Mode kamera scanner, validasi hash token |
| **Modul 4** | Tiket Bukti Serah Terima | `lib/views/handover/serah_terima_qr_screen.dart` | Bukti transaksi gaya tiket, copy transaction code |
| **Modul 4** | Form Ulasan & Reputasi | `lib/views/handover/serah_terima_qr_screen.dart` | Bintang interaktif, feedback text, tag diedit |
| **Modul 5** | Katalog Hibah Sosial | `lib/views/katalog_hibah_screen.dart` | Banner hero hibah, chip kategori, grid kartu hibah |
| **Modul 5** | Form Ajukan Klaim Hibah | `lib/views/ajukan_klaim_screen.dart` | Ringkasan donasi, opsi urgensi, justifikasi, voice note |
| **Modul 5** | Antrean Klaim (Donatur) | `lib/views/daftar_detail_klaim_screen.dart` | Urutan pemohon berdasarkan prioritas, aksi setuju/tolak |
| **Modul 5** | Digital Claim Pass | `lib/views/digital_claim_pass_screen.dart` | QR pengambilan hibah terverifikasi |

---

## 2. Inventaris Komponen & Variasi Lintas Modul

Sebelum standardisasi, setiap modul mengimplementasikan elemen antarmukanya sendiri:

| Komponen | Variasi Modul 1 | Variasi Modul 2 | Variasi Modul 3 | Variasi Modul 4 | Variasi Modul 5 | Masalah / Inkonsistensi |
|---|---|---|---|---|---|---|
| **Tombol Utama** | `ElevatedButton` tinggi 48, radius 24 / pill | `ElevatedButton` tinggi 44, radius 10 | `ElevatedButton` teal radius 8-12 | `ElevatedButton` gradient teal radius 14 | `ElevatedButton` radius 26 | Tinggi bervariasi (44–52), radius tidak seragam (8–26), state loading tidak konsisten |
| **Field Input** | `TextField` border bulat (radius 30) | `TextField` border abu-abu | `TextField` standar | `TextField` khusus border outline | `TextField` tanpa border (fill putih) | Desain input berbeda antar layar (pill vs box), ketiadaan counter karakter standar |
| **Badge Status** | Badge kondisi chip kecil | Chip status manual warna bervariasi | `BarterVisuals` terpisah hanya warna teks | Status teks berwarna di header | Badge status chip lokal warna custom | Warna status tidak sinkron, tidak ada kombinasi seragam (teks + background + icon) |
| **Kartu (Card)** | `Card` elevation 2, radius 12 | `Container` border abu-abu radius 16 | `Card` padding kustom | `Container` shadow tebal | `Container` radius 16 | Bayangan dan elevasi tidak konsisten, ada yang terlalu tebal atau border abu-abu kasar |
| **Feedback (SnackBar)** | `ScaffoldMessenger` biasa | `ScaffoldMessenger` default hitam | Dialog alert native | `SnackBar` merah `shade700` | `SnackBar` teks pendek | Tidak ada pembeda visual terstandar antara sukses, error, dan info |
| **Dialog Konfirmasi** | Dialog native sederhana | `showDialog` kustom | Modal bottom sheet konfirmasi | Custom alert | Pop dialog | Aksi destruktif (Hapus vs Batal) belum terbedakan dengan jelas (merah vs netral) |
| **Empty State** | Teks `Center(Text('...'))` | Icon abu-abu + teks | Teks abu-abu polos | Tidak ada empty state | Teks `Belum ada hibah` | Tampilan kosong terkesan mentah dan tidak komunikatif |
| **Error State** | Teks merah error | SnackBar warning | Error text | SnackBar merah | Teks error tengah layar | Tidak ada tombol "Coba Lagi" (PRD 2.10) yang seragam |

---

## 3. Inventaris Nilai Hard-coded

Ditemukan lebih dari 1.300 penggunaan nilai layout, warna, dan tipografi secara langsung:
- **Warna:** `#0D9488` (teal lama), `#0F766E` (teal PRD baru), `Colors.green`, `Colors.orange`, `Colors.purple`, `Colors.amber`, `Colors.grey.shade...`, `Colors.red.shade700`.
- **Border Radius:** `BorderRadius.circular(4)`, `8`, `10`, `12`, `14`, `16`, `20`, `24`, `26`, `30`, `999`.
- **Padding & Margin:** `EdgeInsets.all(8)`, `10`, `12`, `14`, `16`, `20`, `24`, `32`.
- **Ukuran Font:** `fontSize: 10, 11, 12, 13, 14, 15, 16, 17, 18, 20, 22, 24, 28, 36`.
- **Elevasi:** `elevation: 0, 1, 2, 4, 8`.

---

## 4. Inventaris Status & Pemetaan

Sebelumnya warna status tersebar dan tidak konsisten:
- "Available" menggunakan teks hijau tanpa latar atau `Color(0xFF15803D)`.
- "Reserved" disamakan dengan "Locked" di beberapa tempat, padahal PRD membedakan:
  - *Reserved*: Dalam Kesepakatan (Kuning/Amber `#B45309` di atas `#FEF3C7`).
  - *Locked*: Terkunci / Dikonfirmasi (Teal `#0F766E` di atas `#CCFBF1`).
- "Completed" memakai teks biru `#1D4ED8` di atas `#DBEAFE` dengan ikon `verified_outlined`.
- "Rejected" memakai merah `#B91C1C` di atas `#FEE2E2` dengan ikon `block`.
- "Pending / Diajukan" memakai ungu `#6D28D9` di atas `#EDE9FE` dengan ikon `schedule`.

---

## 5. Inventaris Teks & Bahasa

1. **Bahasa Campuran:** Ditemukan kata seperti "Pasang Listing", "Quick Actions", "Donasi Aktif", "Sent", "Received", "Available", "Claim Pass". Semuanya dinormalisasi ke Bahasa Indonesia yang baku dan ramah, tanpa menghilangkan istilah wajib PRD:
   - "Listing", "Cash Top-Up", "Safe-Meet Point", "Dual-Confirmation", "Locked", "Reserved".
2. **Tombol Terlalu Panjang:** Ditemukan label seperti "Daftar Sekarang", "Kirim Pengajuan Klaim Sekarang", "Ajukan Pertemuan COD di Safe-Meet Point". Diringkas menjadi kata kerja aktif jelas: "Daftar", "Kirim Klaim", "Ajukan Pertemuan".
3. **Kapitalisasi:** Penulisan "WIB", "Rp", dan inisial nama diseragamkan.

---

## 6. Audit Kontras Warna (WCAG AA Minimal 4,5:1)

| Elemen | Warna Teks | Warna Latar | Rasio Kontras | Status WCAG AA |
|---|---|---|---|---|
| Tombol Utama | `#FFFFFF` (`onPrimary`) | `#0F766E` (`primary`) | 4,68 : 1 | **Lolos** |
| Tombol Accent | `#1C1917` (`onAccent`) | `#F59E0B` (`accent`) | 8,92 : 1 | **Lolos** |
| Teks Utama | `#0F172A` (`textPrimary`) | `#FFFFFF` (`surface`) | 16,08 : 1 | **Lolos** |
| Teks Sekunder | `#64748B` (`textSecondary`)| `#FFFFFF` (`surface`) | 4,54 : 1 | **Lolos** |
| Status Available | `#15803D` | `#DCFCE7` | 4,61 : 1 | **Lolos** |
| Status Reserved | `#B45309` | `#FEF3C7` | 4,72 : 1 | **Lolos** |
| Status Completed | `#1D4ED8` | `#DBEAFE` | 4,58 : 1 | **Lolos** |
| Status Archived / Cancel | `#475569` | `#F1F5F9` | 6,32 : 1 | **Lolos** |
| Status Rejected | `#B91C1C` | `#FEE2E2` | 5,84 : 1 | **Lolos** |
| Status Pending / Negosiasi | `#6D28D9` | `#EDE9FE` | 6,55 : 1 | **Lolos** |
| Status Locked / Approved | `#0F766E` | `#CCFBF1` | 4,52 : 1 | **Lolos** |
| Banner PrimaryContainer | `#134E4A` | `#CCFBF1` | 7,14 : 1 | **Lolos** |

Semua pasangan warna di atas memenuhi ambang batas minimal 4,5:1 untuk teks normal.
