# PROGRESS REPORT 1
## Mobile Programming — CampuShift (Kelompok 3)

- **Proyek**: CampuShift - Aplikasi Mobile Pengalihan Barang Bekas Antar Mahasiswa yang Aman dan Tepercaya
- **Anggota**:
  - Muhammad Racha Ardiwinata (2411522020) — Modul 5: Hibah & Klaim
  - Bayu Mutawakkil (2411522023) — Modul 2: Safe-Meet Point & Pertemuan
  - Muhammad Habib (2411522024) — Modul 3: Barter & Cash Top-Up
  - Naufal Baihaqi Zachwan (2411522025) — Modul 1: Listing & Kondisi Fisik
  - Fadel Muhammad (2411522029) — Modul 4: Serah Terima QR & Reputasi
- **Mata Kuliah**: Mobile Programming
- **Tanggal Laporan**: 18 Oktober 2026
- **Repository**: github.com/muhammadhabib16/CampusShift
- **Acuan Kode**: `main` 287efa5 · `modul-naufal` 0deea1a · `modul-bayu` f3d8713 · `modul-fadel` add87a0 · `modul-racha` ebe610d

### Ringkasan

Laporan ini menggambarkan kondisi aplikasi pada **18 Oktober 2026**, berdasarkan kode di branch `main` dan branch modul tiap anggota. Acuan spesifikasinya adalah PRD v1.3 (`docs/prd/prd.md`). Ringkasnya:

- Fondasi aplikasi sudah berjalan di `main`: splash, onboarding, registrasi dan login yang **terhubung ke backend**, navigasi bawah 4 tab, serta alur pengajuan barter (Modul 3) dengan validasi, *loading state*, dan umpan balik.
- Dua modul berkembang paling jauh di branch masing-masing. Modul 2 (Bayu) memiliki alur titik temu dan jadwal pertemuan lengkap dengan peta dan GPS. Modul 4 (Fadel) memiliki layar QR serah terima dengan pembuatan dan pembatalan sesi token, serta unit test yang lulus.
- Modul 1 (Naufal) dan Modul 5 (Racha) sudah memiliki struktur MVVM dan layar-layarnya (Modul 1: katalog, detail, dan tambah listing dengan kamera), tetapi belum dirangkai ke navigasi aplikasi. Modul 5 juga masih mengikuti PRD versi lama.
- Branch `main`, `modul-bayu`, `modul-fadel`, dan `modul-racha` lolos `flutter analyze` tanpa masalah; `modul-naufal` tanpa error tetapi masih memiliki 21 temuan ringan. Tim sudah melakukan code audit dan tiga refactoring yang dapat ditelusuri di riwayat commit.

| Bagian | Branch | Status | Data |
|---|---|---|---|
| Pendukung: Autentikasi & Profil | `main` | Sebagian berjalan | Login & registrasi ke backend; profil masih statis |
| M1 Listing & Kondisi Fisik (Naufal) | `modul-naufal` | Berjalan (UI & MVVM), belum dirangkai & belum di-merge | API `/api/items` (backend belum tersedia) |
| M2 Safe-Meet Point & Pertemuan (Bayu) | `modul-bayu` | Berjalan, belum di-merge | Lokal (data contoh di aplikasi) |
| M3 Barter & Cash Top-Up (Habib) | `main` | Berjalan (UI & alur pengajuan) | Dummy di aplikasi |
| M4 Serah Terima QR & Reputasi (Fadel) | `modul-fadel` | Berjalan, belum di-merge | API dengan cadangan mode lokal |
| M5 Hibah & Klaim (Racha) | `modul-racha` | Kode awal, belum terintegrasi | Klien API (belum dirangkai) |

## 1. Progress Aplikasi

### 1.1 Gambaran Umum

Aplikasi dibangun dengan Flutter (Android) dan pola MVVM (`views/`, `viewmodels/`, `models/`, `services/`). Setiap anggota mengerjakan modulnya di branch `modul-[nama]`, lalu menggabungkannya ke `main` melalui Pull Request. Sampai laporan ini dibuat, yang sudah tergabung di `main` adalah modul pendukung (autentikasi), Modul 3, dan dokumen proyek. Modul 1, 2, 4, dan 5 masih berada di branch masing-masing.

Kualitas kode diperiksa pada saat laporan dibuat:

| Branch | `flutter analyze` | Test |
|---|---|---|
| `main` | No issues found | — |
| `modul-naufal` | 21 temuan: 0 error, 1 warning, 20 info (lihat audit A9) | — |
| `modul-bayu` | No issues found | — |
| `modul-fadel` | No issues found | 5 test lulus (`test/handover_test.dart`) |
| `modul-racha` | No issues found | — |

### 1.2 Fitur & Screen yang Sudah Selesai

**Modul Pendukung — Autentikasi & Navigasi (`main`)**

| Screen / Fitur | Interaksi, State & Navigasi | Data |
|---|---|---|
| Splash Screen | Animasi *fade* + *scale*, otomatis pindah ke Onboarding setelah 3 detik | — |
| Onboarding | Slide halaman, tombol lanjut ke Login | — |
| Registrasi | Form NIM, nama, email, kata sandi; validasi field kosong; *loading*; pesan dari server ditampilkan via SnackBar; kembali ke Login bila sukses | `POST /api/auth/register` |
| Login | Validasi field kosong, *loading*, pesan gagal/sukses; token JWT dan data pengguna disimpan dengan `shared_preferences`; pindah ke MainScreen | `POST /api/auth/login` |
| MainScreen | Navigasi bawah 4 tab (Beranda, Katalog, Barter, Profil) dengan `IndexedStack` sehingga state tiap tab tetap terjaga | — |

**Modul 3 — Barter & Cash Top-Up (Habib, `main`)**

| Screen / Fitur | Interaksi, State & Navigasi | Data |
|---|---|---|
| Pilih Barang untuk Barter (bottom sheet) | Muncul saat barang di Beranda diketuk; memilih satu barang sendiri dengan `RadioGroup`; tombol Konfirmasi Pilihan menuju form negosiasi | Dummy |
| Form Tawaran & Negosiasi | Input nominal cash top-up dengan validasi (kosong/negatif ditolak), *loading state* saat mengirim, SnackBar sukses, lalu kembali ke layar sebelumnya | Simulasi pengiriman |
| Daftar Tawaran (tab Barter) | Daftar tawaran beserta status | Dummy |
| Konfirmasi Kesepakatan | Tampilan "Asset Terkunci" dan tombol Setuju & Kunci Kesepakatan; layar sudah ada tetapi **belum dibuka dari layar mana pun** | Dummy |

**Modul 1 — Listing & Kondisi Fisik (Naufal, `modul-naufal`)**

| Screen / Fitur | Interaksi, State & Navigasi | Data |
|---|---|---|
| Tambah Listing | Foto diambil langsung dari kamera (`image_picker`, `ImageSource.camera`) dengan kompresi `imageQuality: 70`; validasi minimal 2 foto (maksimal 3), judul minimal 5 karakter, deskripsi minimal 20 karakter; pilihan kategori, tipe Jual/Hibah (harga otomatis Rp0 untuk Hibah), opsi Terbuka untuk Barter, dan kondisi; *loading state* dan SnackBar galat | `POST /api/items` (multipart foto) |
| Katalog | Pencarian kata kunci, filter kategori dan tipe listing, *loading* dan pesan galat; mengetuk barang membuka detail | `GET /api/items` |
| Detail Barang | Foto, informasi barang, label Terbuka Barter; tombol Tukar (Barter), Ajukan COD Temu, atau Ajukan Klaim sesuai tipe (navigasi ke modul lain masih TODO) | Dari katalog |
| Arsitektur | `ItemModel`, `ItemService` (token JWT di header), `ItemViewModel` (`ChangeNotifier` + `provider`) | — |

**Modul 2 — Safe-Meet Point & Pertemuan (Bayu, `modul-bayu`)**

| Screen / Fitur | Interaksi, State & Navigasi | Data |
|---|---|---|
| Direktori Titik Temu | 5 titik temu COD resmi di sekitar kampus Unand dalam bentuk daftar dan peta visual (`flutter_map`, tile OpenStreetMap, dipusatkan ke area Unand); lokasi pengguna dari GPS (`geolocator`) dengan penanganan izin ditolak/GPS mati; jarak dihitung dengan formula Haversine dan diurutkan dari yang terdekat (kembali ke urutan nama bila lokasi tidak tersedia) | Lokal |
| Detail Titik Temu | Informasi jam operasional, patokan, dan fitur keamanan; tombol Buka Rute ke Google Maps (dengan cadangan `geo:` dan peta web) | Lokal |
| Form Ajukan/Ubah Pertemuan | Memilih titik temu dan waktu dengan validasi waktu minimal 1 jam dan maksimal 14 hari ke depan | Lokal |
| Pertemuan Saya & Detail Pertemuan | Daftar pertemuan; aksi konfirmasi, tolak (dengan alasan), batalkan, dan hapus; peta lokasi pertemuan | Lokal (`MeetupRepository`) |

**Modul 4 — Serah Terima QR & Reputasi (Fadel, `modul-fadel`)**

| Screen / Fitur | Interaksi, State & Navigasi | Data |
|---|---|---|
| Serah Terima QR (FR-17) | Membuat sesi token acak sekali pakai berlaku 5 menit dan menampilkannya sebagai QR (`qr_flutter`); hitung mundur per detik; cek status token berkala setiap 3 detik; membatalkan sesi QR (Delete) | `POST /api/handover/...` dengan JWT; otomatis memakai mode lokal bila server tidak aktif |
| Akses ke layar QR | Dari menu Profil dan dari daftar tawaran barter. Tombol Setuju & Kunci Kesepakatan di layar konfirmasi barter juga sudah diarahkan ke layar ini (layar konfirmasinya sendiri belum terhubung ke alur). | — |
| Unit & widget test | Pengujian masa berlaku token 5 menit, Create, Delete, cek status, dan render layar | 5/5 lulus |

**Modul 5 — Hibah & Klaim (Racha, `modul-racha`)**

| Komponen | Isi | Status |
|---|---|---|
| Model | `SocialGrant`, `GrantClaim` (urgensi Mendesak/Sedang/Rendah) dengan `fromJson`/`toJson` | Ada |
| Service | `ApiClient` (token disuntikkan agar *low coupling*), `SocialGrantService`, `GrantClaimService`, `GrantNotificationService` (`flutter_local_notifications`) | Ada, belum dirangkai ke server |
| ViewModel | `SocialGrantViewModel`, `GrantClaimViewModel` (`ChangeNotifier`), termasuk validasi justifikasi minimal 100 karakter | Ada |
| Screen | Katalog Hibah, Ajukan Klaim, Daftar/Detail Klaim, Digital Claim Pass | Ada, belum dapat dibuka dari aplikasi |

### 1.3 Fitur & Screen yang Masih Dalam Proses atau Belum Dikerjakan

| Modul | Masih Dalam Proses | Belum Dikerjakan |
|---|---|---|
| Pendukung | Profil masih menampilkan data statis | Auto-login dengan token tersimpan; logout yang menghapus token; edit profil + foto kamera |
| M1 (Naufal) | Merangkai modul ke aplikasi: `ItemViewModel` belum didaftarkan sebagai Provider di `main.dart`, tab Katalog di `main` masih "Segera Hadir", dan navigasi ke Tambah Listing masih dikomentari | Filter rentang harga, sunting & hapus listing, halaman Barang Saya, Listing Stale Alert, mode data lokal selama backend Items belum siap; merge ke `main` |
| M2 (Bayu) | Koneksi ke backend (data masih di `MeetupRepository` lokal; pengguna login masih ditulis langsung di kode) | Meeting Reminder (notifikasi terjadwal); merge ke `main` |
| M3 (Habib) | Pemisahan UI dan logika ke Model–Service–ViewModel | Menghubungkan layar konfirmasi ke alur, koneksi backend, dual-confirmation antar dua akun, asset locking, hapus/batal tawaran, Barter Alert |
| M4 (Fadel) | Integrasi dengan server sungguhan (saat ini dapat memakai mode lokal) | Pemindai QR (`mobile_scanner`) dan verifikasi, riwayat & bukti serah terima, ulasan & reputasi, Handover Success Alert; merge ke `main` |
| M5 (Racha) | Penyesuaian ke PRD v1.3 | Merangkai Provider & navigasi di aplikasi; koneksi backend; menghapus Digital Claim Pass dan rekaman suara (di luar scope PRD v1.3); memakai listing Hibah dari M1 |

### 1.4 Flow Utama yang Sudah Dapat Berjalan

| Flow | Branch | Langkah | Prasyarat |
|---|---|---|---|
| **A. Masuk aplikasi** | `main` | Splash → Onboarding → Registrasi akun → Login → MainScreen dengan 4 tab | Backend autentikasi berjalan (emulator mengakses `10.0.2.2`) |
| **B. Pengajuan barter** | `main` | Beranda → ketuk barang → pilih barang sendiri → Konfirmasi Pilihan → isi cash top-up → validasi → *loading* → SnackBar sukses → kembali | Sudah login |
| **C. Titik temu & pertemuan** | `modul-bayu` | Beranda → Direktori Titik Temu (peta + jarak GPS) → detail titik → Ajukan Pertemuan → Pertemuan Saya → detail → konfirmasi/tolak/batal/hapus → Buka Rute | Izin lokasi (opsional; tanpa izin daftar tetap tampil) |
| **D. Sesi QR serah terima** | `modul-fadel` | Profil → Serah Terima QR → token & hitung mundur 5 menit → status dicek berkala → batalkan atau buat ulang sesi | Berjalan dengan atau tanpa backend (mode lokal) |

Panduan demo langsung: jalankan backend autentikasi, lalu `flutter run` pada emulator Android. Gunakan branch sesuai kolom di atas untuk masing-masing flow. Layar Modul 1 dan Modul 5 sudah ada di branch masing-masing, tetapi belum dapat dibuka dari alur aplikasi sampai dirangkai ke navigasi.

### 1.5 Pekerjaan Berikutnya

| Prioritas | Pekerjaan | PJ | Target |
|---|---|---|---|
| 1 | Merge `modul-bayu` dan `modul-fadel` ke `main` melalui PR secara berurutan, lalu menyelesaikan konflik di `home_screen.dart` | Bayu, Fadel, Habib | 20 Okt |
| 2 | Menyatukan alamat server (base URL dan port) ke satu konfigurasi bersama | Bayu, Habib | 20 Okt |
| 3 | Merangkai Modul 1 ke aplikasi (Provider di `main.dart`, tab Katalog, navigasi Tambah Listing) dan menyiapkan mode data lokal selama backend Items belum siap, karena Items menjadi dasar seluruh jalur transaksi | Naufal (backend Items: Bayu) | 22 Okt |
| 4 | Melengkapi autentikasi: auto-login, logout menghapus token, profil dari data akun | Semua | 22 Okt |
| 5 | Menyesuaikan Modul 5 ke PRD v1.3 dan merangkainya ke navigasi aplikasi | Racha | 25 Okt |
| 6 | Model–Service–ViewModel Modul 3, lalu koneksi API barter | Habib | 26 Okt |
| 7 | Pemindai QR, Meeting Reminder, dan notifikasi tiap modul | Fadel, Bayu, semua | Sesuai timeline (s.d. 11 Nov) |

## 2. Kendala & Solusi

| No. | Masalah | Penyebab | Solusi | Hasil | Status |
|---|---|---|---|---|---|
| 1 | Dosen menilai scope PRD awal terlalu luas, notifikasi belum konsisten dengan batasan teknis, dan peran pengguna belum jelas | PRD v1.0 memasukkan marketplace, peta persebaran, barter, hibah, QR terenkripsi, dan notifikasi instan sekaligus | PRD direvisi menjadi v1.1–v1.3: satu masalah utama dengan tiga jalur dalam satu alur, peran Pemilik/Peminat, notifikasi tiga jenis pemicu, prioritas [W]/[O], dan fitur yang tidak esensial dipangkas | Setiap anggota tetap memegang satu modul dengan CRUD dan notifikasi, tetapi beban kerja lebih realistis | Selesai |
| 2 | Notifikasi antar pengguna tidak dapat dikirim instan | Proyek dilarang memakai Firebase/FCM, sedangkan `flutter_local_notifications` hanya berjalan di perangkat sendiri | Notifikasi dibedakan menjadi terjadwal lokal, langsung lokal, dan berbasis sinkronisasi (aplikasi memeriksa server saat aktif) | Desain notifikasi sesuai batasan teknis dan sudah tercatat di PRD 2.8 | Selesai (desain), implementasi berjalan |
| 3 | Aplikasi gagal dikompilasi setelah modul autentikasi digabung ke `main`: `Target of URI doesn't exist: 'services/auth_service.dart'` | Layar login/registrasi dibuat ketika file layar masih di `lib/`; setelah restrukturisasi MVVM file pindah ke `lib/views/`, sehingga path import relatif menjadi salah | Import diperbaiki menjadi `../services/auth_service.dart` dan import yang tidak terpakai dihapus (commit 786ef00) | `flutter analyze` dari 4 error menjadi "No issues found" | Selesai |
| 4 | Peringatan API usang pada pemilihan barang barter (`groupValue`/`onChanged` pada `Radio`) | API tersebut dinyatakan *deprecated* sejak Flutter 3.32 | Dimigrasi ke `RadioGroup` (lihat refactoring R2) | Peringatan hilang, perilaku tetap sama | Selesai |
| 5 | Login bergantung pada backend dan alamat server berbeda untuk tiap lingkungan (emulator, web, HP fisik) | Emulator Android mengakses komputer lewat `10.0.2.2`, web lewat `localhost`, sedangkan HP fisik memerlukan IP jaringan atau `adb reverse` | Bayu menambahkan deteksi platform dengan `kIsWeb`; Fadel menambahkan mode lokal di `HandoverService` agar layar tetap dapat diuji saat server mati | Pengembangan UI tidak terhambat server; namun ditemukan port yang belum seragam (lihat audit A2) | Sebagian, dilanjutkan |
| 6 | Modul saling bergantung, sementara API Items (Modul 1) belum tersedia | Seluruh jalur transaksi membutuhkan `item_id` dari Modul 1; layar Modul 1 sudah memanggil `/api/items`, tetapi backend-nya belum dibuat | Setiap modul dikembangkan dengan data lokal/dummy (Bayu: repository lokal, Fadel: mode lokal, Habib: data dummy), sehingga pengerjaan berjalan paralel | Modul 2, 3, dan 4 dapat didemonstrasikan tanpa menunggu API Items | Berjalan; integrasi menunggu API Items |
| 7 | Modul 5 masih memuat fitur yang sudah dikeluarkan dari scope (Digital Claim Pass, rekaman suara dengan paket `record`) | Modul dikerjakan 5 Oktober, sebelum revisi PRD (11–13 Oktober) | Penyesuaian ke PRD v1.3: fitur tersebut dihapus dan barang hibah memakai listing Modul 1 | — | Direncanakan |
| 8 | Dua branch mengubah file yang sama (`home_screen.dart` di `modul-bayu` dan `modul-fadel`); `modul-fadel` juga menyentuh layar barter untuk integrasi | Titik masuk fitur ditempatkan di Beranda/Profil oleh beberapa anggota | Merge dilakukan berurutan lewat PR dan dikoordinasikan di grup sesuai TEAM_GUIDELINES | — | Direncanakan (prioritas 1) |

## 3. Code Audit & Refactoring

### 3.1 Metode Audit
Audit dilakukan pada 13–18 Oktober 2026 terhadap `main` dan seluruh branch modul dengan cara:
1. Menjalankan `flutter analyze` dan test di setiap branch.
2. Memeriksa kepatuhan terhadap arsitektur MVVM dan aturan *low coupling* di `docs/panduan/TEAM_GUIDELINES.md`.
3. Mencari kode berulang, file yang terlalu panjang, nilai konfigurasi yang tersebar, dan ketidaksesuaian dengan PRD v1.3.

### 3.2 Temuan Audit

| ID | Temuan | Lokasi | Dampak | Tindak Lanjut |
|---|---|---|---|---|
| A1 | Data dummy dan logika (validasi, simulasi kirim) berada langsung di dalam View tanpa ViewModel | `home_screen.dart` baris 301; `barter_list_screen.dart` baris 54; `barter_item_selection_sheet.dart` baris 23; `barter_negotiation_screen.dart` | Melanggar MVVM, sulit dihubungkan ke API, dan sulit diuji | Refactoring Modul 3 ke Model–Service–ViewModel |
| A2 | Alamat server ditulis berulang di beberapa service dengan port berbeda | `auth_service.dart` (`main`: 3000, `modul-bayu`: 5000); `handover_service.dart` (3000); `item_service.dart` (3000) | Koneksi gagal setelah branch digabung | Satu konfigurasi/`ApiClient` bersama (dapat memakai `ApiClient` dari Modul 5 sebagai dasar) |
| A3 | `AuthService` mengurus panggilan HTTP sekaligus penyimpanan token, dan mengembalikan `Map` alih-alih model | `lib/services/auth_service.dart` | Tanggung jawab bercampur, rawan salah ketik kunci | Pisahkan penyimpanan sesi dan tambahkan model `User` |
| A4 | File layar sangat panjang | `serah_terima_qr_screen.dart` (1.623 baris), `safe_meet_directory_screen.dart` (721), `meetup_form_screen.dart` (602) | Sulit dibaca dan dijelaskan saat code review | Dipecah menjadi widget-widget kecil |
| A5 | Logout hanya berpindah ke Login tanpa menghapus token; `isLoggedIn()` tidak dipakai | `profile_screen.dart` baris 130 | Tidak memenuhi AC-A3/AC-A4 PRD | Perbaikan bug (bukan refactoring) |
| A6 | Pengguna login ditulis langsung di repository | `meetup_repository.dart` (`currentUserId = 1`) | Belum memakai sesi login sesungguhnya | Ambil dari sesi Modul Pendukung |
| A7 | Fitur di luar scope PRD v1.3 | `modul-racha`: paket `record` (mikrofon), Digital Claim Pass | Bertentangan dengan batasan hardware PRD | Lihat Kendala No. 7 |
| A8 | Struktur folder belum MVVM, import rusak, API usang, `context` dipakai setelah sheet ditutup | `lib/`, `login_screen.dart`, `register_screen.dart`, `barter_item_selection_sheet.dart` | Kode sulit dikembangkan, error kompilasi, peringatan analyzer | **Sudah di-refactor**: R1–R3 di bawah |
| A9 | Temuan analyzer di Modul 1: import tidak terpakai, API usang (`Radio.groupValue`/`onChanged`, `DropdownButtonFormField.value`, `Switch.activeColor`, `withOpacity`), dan `if` tanpa kurung kurawal | `modul-naufal`: `item_service.dart`, `item_viewmodel.dart`, `add_listing_screen.dart`, `catalog_screen.dart`, `item_detail_screen.dart` | Peringatan analyzer dan risiko saat Flutter diperbarui | Diperbaiki dengan pola yang sama seperti R2 (`RadioGroup`) dan `withValues()` sebelum merge |

### 3.3 Refactoring yang Sudah Dilakukan (Before–After)

#### R1. Restrukturisasi Folder ke Pola MVVM (commit 93fdca4)

**Masalah:** semua layar berada langsung di `lib/` bercampur dengan `main.dart`. Tidak ada tempat yang jelas untuk ViewModel, model, dan service, padahal TEAM_GUIDELINES mewajibkan MVVM.

**Sebelum:**

```
lib/
├── main.dart              // import 'splash_screen.dart';
├── home_screen.dart
├── login_screen.dart
├── main_screen.dart
├── onboarding_screen.dart
├── profile_screen.dart
├── register_screen.dart
└── splash_screen.dart
```

**Sesudah:**

```
lib/
├── main.dart              // import 'views/splash_screen.dart';
└── views/                 // hanya kode UI
    ├── home_screen.dart
    ├── login_screen.dart
    ├── main_screen.dart
    ├── onboarding_screen.dart
    ├── profile_screen.dart
    ├── register_screen.dart
    └── splash_screen.dart
```

**Alasan dan hasil:** isi file layar tidak diubah (hanya dipindahkan), sehingga fungsi aplikasi tetap sama. Lapisan UI kini terpisah, dan struktur ini menjadi dasar folder berikutnya: `services/` (integrasi API, PR #2) serta subfolder per modul seperti `views/barter/` dan `views/safe_meet/`. Setelah restrukturisasi, import relatif di layar autentikasi sempat salah alamat dan diperbaiki di commit 786ef00 (Kendala No. 3).

#### R2. Migrasi Pemilihan Barang dari `Radio` Usang ke `RadioGroup` (commit 786ef00)

**Masalah:** setiap `Radio` menyimpan sendiri `groupValue` dan `onChanged`, yang sudah *deprecated* sejak Flutter 3.32. `flutter analyze` menampilkan peringatan, dan logika perubahan pilihan tersebar di setiap item.

**Sebelum (`barter_item_selection_sheet.dart`):**

```dart
ListView.separated(
  itemBuilder: (context, index) {
    ...
    Radio<int>(
      value: index,
      groupValue: _selectedIndex,          // deprecated
      onChanged: (value) {                 // deprecated, ditulis di setiap item
        setState(() {
          _selectedIndex = value!;
        });
      },
      activeColor: const Color(0xFF0D9488),
    ),
  },
)
```

**Sesudah:**

```dart
RadioGroup<int>(
  groupValue: _selectedIndex,              // state pilihan dikelola di satu tempat
  onChanged: (value) {
    setState(() {
      _selectedIndex = value!;
    });
  },
  child: ListView.separated(
    itemBuilder: (context, index) {
      ...
      Radio<int>(
        value: index,                      // item hanya mendeklarasikan nilainya
        activeColor: const Color(0xFF0D9488),
      ),
    },
  ),
)
```

**Alasan dan hasil:** perilaku pemilihan barang tetap sama, tetapi pengelolaan pilihan kini berada di satu tempat (`RadioGroup`), item lebih sederhana, dan peringatan analyzer hilang.

#### R3. Navigasi Aman dari Bottom Sheet dan Pembersihan Import (commit 786ef00)

**Masalah:** setelah `Navigator.pop(context)` menutup bottom sheet, `context` milik sheet tersebut dipakai lagi untuk `Navigator.push`. `context` itu sedang dilepas dari pohon widget, sehingga berpotensi error. Selain itu ada import yang tidak terpakai.

**Sebelum:**

```dart
import 'barter_confirmation_screen.dart';   // tidak terpakai (barter_negotiation_screen.dart)
import 'main_screen.dart';                  // tidak terpakai (register_screen.dart)

onPressed: () {
  Navigator.pop(context); // Close sheet
  Navigator.push(
    context,                                // context sheet yang sudah ditutup
    MaterialPageRoute(builder: (context) => const BarterNegotiationScreen()),
  );
},
```

**Sesudah:**

```dart
onPressed: () {
  // Ambil Navigator sebelum sheet ditutup, karena context sheet tidak lagi aktif setelah pop
  final navigator = Navigator.of(context);
  navigator.pop(); // Close sheet
  navigator.push(
    MaterialPageRoute(builder: (context) => const BarterNegotiationScreen()),
  );
},
```

**Alasan dan hasil:** alur tetap sama (sheet tertutup lalu form negosiasi terbuka), tetapi tidak lagi bergantung pada `context` yang sudah tidak aktif. Import yang tidak dipakai dihapus sehingga ketergantungan antar file lebih jelas.

### 3.4 Refactoring Berikutnya (Berdasarkan Temuan Audit)
- **A1 → Modul 3 ke MVVM:** data dan validasi dipindahkan dari View ke `BarterDeal` (model), `BarterService` (API/mock), dan `BarterViewModel`.
- **A2 → Konfigurasi server bersama:** satu `ApiClient` untuk base URL, header JWT, dan batas waktu request, dipakai semua service.
- **A3 → Pemisahan `AuthService`:** penyimpanan sesi dipisah dan model `User` ditambahkan.
- **A4 → Pemecahan layar panjang:** `serah_terima_qr_screen.dart` dan layar Modul 2 dipecah menjadi widget kecil.

## 4. Koordinasi Tim

### 4.1 Pembagian Pekerjaan

| Anggota | Modul Flutter | Backend | Tanggung Jawab Tambahan |
|---|---|---|---|
| Naufal Baihaqi Zachwan | M1 Listing & Kondisi Fisik | — | UI autentikasi (bersama) |
| Bayu Mutawakkil | M2 Safe-Meet Point & Pertemuan | Ya (Items, Meetups, Handover & Reviews) | Integrasi autentikasi ke backend |
| Muhammad Habib | M3 Barter & Cash Top-Up | Ya (Safe-Meet, Barter, Claims, sinkronisasi) | Repository, PRD, timeline, panduan tim, review & merge PR |
| Fadel Muhammad | M4 Serah Terima QR & Reputasi | — | UI autentikasi (bersama) |
| Muhammad Racha Ardiwinata | M5 Hibah & Klaim | — | AuthService (bersama) |

Rincian jadwal dan to-do tiap anggota ada di `docs/perencanaan/CampuShift_Timeline_v4.xlsx`.

### 4.2 Progress dan Kontribusi Masing-Masing Anggota
Kontribusi diambil dari riwayat commit repository per 18 Oktober 2026.

| Anggota | Bukti Kontribusi (commit) | Progress |
|---|---|---|
| Bayu Mutawakkil | 881fe16, 2c3a16b (splash, onboarding, login, register); e635b5f (integrasi login & register dengan backend, PR #2); 4289fb5, 72b4cbc (pembaruan AuthService & layar autentikasi); f3d8713 (Modul 2: 5 layar safe-meet, model, `LocationService`, `MapsLauncherService`, `HaversineHelper`, `MeetupRepository`) | Modul 2 paling lengkap, belum terhubung backend dan belum di-merge |
| Muhammad Habib | 44dee78 (inisialisasi repository); 93fdca4 (restrukturisasi MVVM & folder docs); 9c8ad1c, fa3f845, 786ef00 (Modul 3, perbaikan integrasi & refactoring); fe3ab62, 287efa5 (PRD v1.1, timeline v4, README); merge PR #3 dan #4 | Modul 3: UI dan alur pengajuan berjalan di `main`; MVVM dan backend berikutnya |
| Fadel Muhammad | add87a0 (Modul 4 FR-17: model token, `HandoverService` dengan mode lokal, layar Serah Terima QR, 5 test, integrasi dari Profil dan layar barter) | FR-17 selesai di branch, FR-18 s.d. FR-21 berikutnya |
| Muhammad Racha Ardiwinata | ebe610d (Modul 5: 2 model, `ApiClient`, 3 service, 2 ViewModel, 4 layar) | Struktur MVVM ada; perlu disesuaikan ke PRD v1.3 dan dirangkai ke aplikasi |
| Naufal Baihaqi Zachwan | 0deea1a, 18 Okt (Modul 1: `ItemModel`, `ItemService` dengan GET katalog dan POST listing multipart, `ItemViewModel`, serta 3 layar: Katalog, Detail Barang, Tambah Listing dengan kamera dan validasi BR-01 s.d. BR-03) | UI dan MVVM inti selesai di branch; belum dirangkai ke aplikasi dan backend Items belum tersedia |

### 4.3 Cara Tim Berkoordinasi
- **Branch per modul dan Pull Request.** Setiap anggota bekerja di `modul-[nama]`, dan perubahan masuk ke `main` hanya lewat PR: #2 (integrasi autentikasi, Bayu), #3 (revisi PRD & timeline, Habib), #4 (Modul 3, Habib).
- **Satu acuan bersama.** PRD v1.3 (`docs/prd/prd.md`) menjadi acuan requirement, aturan bisnis, siklus status, dan pembagian CRUD tiap modul. Timeline v4 berisi to-do per anggota.
- **Aturan kolaborasi tertulis.** `docs/panduan/TEAM_GUIDELINES.md` mengatur penamaan branch, larangan push langsung ke `main`, MVVM, komunikasi antar modul lewat ID, perubahan status barang hanya oleh server, dan kewajiban AI Usage Log.
- **Penanganan pekerjaan yang saling berkaitan:**
  1. *Revisi PRD (11–13 Okt):* setelah umpan balik dosen, pembagian modul disesuaikan bersama (misalnya listing Hibah dipindah ke Modul 1 dan profil reputasi ke Modul 4) dan dibagikan lewat PR #3.
  2. *Integrasi autentikasi:* layar autentikasi dari Bayu digabung lewat PR #2; error import setelah penggabungan diperbaiki Habib di 786ef00.
  3. *Integrasi Modul 3 → Modul 4:* Fadel menyambungkan daftar tawaran barter dan tombol Setuju & Kunci Kesepakatan ke layar Serah Terima QR, sesuai urutan alur barter → serah terima. Layar konfirmasi barter (Modul 3) masih perlu dihubungkan ke alur oleh Habib.
  4. *Titik integrasi dari Modul 1:* layar Detail Barang milik Naufal sudah menyediakan tombol menuju Modul 3 (Tukar/Barter), Modul 2 (Ajukan COD Temu), dan Modul 5 (Ajukan Klaim); navigasinya disambungkan setelah modul-modul tersebut di-merge.
  5. *Ketergantungan data:* sambil menunggu API Items, setiap modul memakai data lokal/dummy dengan bentuk data yang sama seperti rancangan PRD agar mudah diganti ke API.

### 4.4 Catatan Koordinasi untuk Tahap Berikutnya
- Modul 1 baru masuk pada 18 Oktober dan belum dirangkai ke aplikasi, padahal menjadi dasar seluruh jalur transaksi. Perangkaian dan backend Items perlu didahulukan.
- `modul-naufal` juga mengubah file di `docs/` (PDF PRD), sehingga perlu diselaraskan dengan dokumen terbaru di `main` saat merge.
- `modul-bayu` dan `modul-fadel` perlu segera di-merge supaya konflik di `home_screen.dart` tidak membesar.
- Alamat server perlu disepakati satu (port dan base URL) sebelum integrasi.
- AI Usage Log baru tersedia untuk Habib (`docs/ai_logs/habib_logs.md`). Anggota lain perlu membuat log masing-masing, dan refactoring di commit 786ef00 perlu dicatat di log Habib.

## Lampiran A: Bukti Aplikasi Berjalan

Bukti utama berupa **rekaman layar per modul** (link video) yang menunjukkan interaksi, perubahan state, dan navigasi, dilengkapi tangkapan layar. Rekaman Pendukung memakai login asli ke backend. Rekaman modul lain boleh memakai tombol *mode uji* (masuk tanpa server, hanya tersedia saat debug) agar demo lebih cepat, dan hal ini disebutkan di kolom keterangan.

| No. | Modul / Alur | Yang Ditunjukkan | Branch | Bentuk & Link |
|---|---|---|---|---|
| 1 | Pendukung: masuk aplikasi (Flow A) | Splash → Onboarding → Registrasi → login asli ke backend → MainScreen; pesan saat login gagal | `main` | Video + tangkapan layar Login — [link video] |
| 2 | M3 Barter: pengajuan barter (Flow B) | Pilih barang sendiri → top-up dikosongkan (pesan validasi) → isi benar → *loading* → SnackBar → kembali; tab Barter | `main` | Video + tangkapan layar form negosiasi — [link video] |
| 3 | M1 Listing | Tambah Listing: foto kamera, simpan dengan 1 foto ditolak, validasi judul/deskripsi; Katalog: pencarian, filter, pesan galat saat server belum tersedia; Detail Barang | `modul-naufal` | Video + tangkapan layar — direkam setelah modul dirangkai ke navigasi (target 22 Okt) — [link video] |
| 4 | M2 Safe-Meet (Flow C) | Peta & jarak GPS → detail titik → ajukan pertemuan (waktu < 1 jam ditolak) → Pertemuan Saya → konfirmasi/batal/hapus → Buka Rute | `modul-bayu` | Video + tangkapan layar direktori — [link video] |
| 5 | M4 Serah Terima QR (Flow D) | Layar QR → hitung mundur → batalkan sesi → buat ulang | `modul-fadel` | Video + tangkapan layar hasil `flutter test` (5 lulus) — [link video] |
| 6 | M5 Hibah | Katalog hibah → form klaim (justifikasi < 100 karakter ditolak) → daftar/detail klaim | `modul-racha` | Video + tangkapan layar — direkam setelah Provider dan navigasi dirangkai (target 25 Okt) — [link video] |
| 7 | Kualitas kode | Hasil `flutter analyze` setiap branch | Semua | Tangkapan layar terminal |
| 8 | Refactoring R1–R3 | Diff before–after commit 93fdca4 dan 786ef00 | `main` | Tangkapan layar halaman commit di GitHub |
| 9 | Koordinasi tim | Daftar Pull Request #2–#4, daftar branch, riwayat commit | — | Tangkapan layar GitHub |

Catatan: video diunggah ke Google Drive dengan akses "Siapa saja yang memiliki link" atau YouTube (*unlisted*), lalu link-nya ditempel pada kolom terakhir.
