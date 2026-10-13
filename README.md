# CampuShift

**Aplikasi mobile pengalihan barang bekas antar mahasiswa yang aman dan tepercaya.**

Tugas Besar Mata Kuliah Mobile Programming 2026 — Kelompok 3. Mendukung SDG 12 (Konsumsi dan Produksi yang Bertanggung Jawab).

## Tentang Aplikasi

Mahasiswa sering melepas atau mencari barang bekas perlengkapan kuliah lewat grup chat, tanpa kepastian kondisi barang, tempat bertemu, maupun bukti serah terima. CampuShift menyatukan proses tersebut dalam satu alur:

```
Listing berfoto riil  →  Kesepakatan (Jual / Barter / Hibah)  →  Pertemuan di titik temu resmi  →  Serah terima QR  →  Ulasan
```

Spesifikasi lengkap ada di [PRD v1.1](docs/prd.md) ([versi PDF](docs/PRD_CampusShift_Kelompok_3_v1.1.pdf)).

## Tim & Pembagian Modul

| Modul | Penanggung Jawab | NIM | Fokus |
|---|---|---|---|
| Pendukung: Autentikasi & Profil | Semua anggota | — | Register, login/logout JWT, edit profil |
| M1: Listing & Kondisi Fisik | Naufal Baihaqi Zachwan | 2411522025 | CRUD listing (Jual/Hibah), foto kamera, pencarian & filter |
| M2: Safe-Meet Point & Pertemuan | Bayu Mutawakkil | 2411522023 | Titik temu resmi + jarak GPS, jadwal pertemuan, rute Google Maps |
| M3: Barter & Cash Top-Up | Muhammad Habib | 2411522024 | Tawaran barter, negosiasi top-up, dual-confirmation, asset locking |
| M4: Serah Terima QR & Reputasi | Fadel Muhammad | 2411522029 | QR token sekali pakai, pemindai QR, bukti serah terima, ulasan |
| M5: Hibah & Klaim | Muhammad Racha Ardiwinata | 2411522020 | Klaim berbasis urgensi, antrean donatur, persetujuan klaim |

Backend REST API dikoordinasikan oleh Bayu dan Habib. Jadwal dan to-do tiap anggota ada di [timeline v4](docs/CampuShift_Timeline_v4.xlsx).

## Tech Stack

- **Mobile:** Flutter (Dart SDK `^3.13.1`), Material Design 3, target Android 8.0 (API 26) – Android 14
- **Arsitektur:** MVVM (`views/`, `viewmodels/`, `models/`, `services/`)
- **Backend:** RESTful API mandiri (Node.js/Express) + basis data relasional, autentikasi JWT
- **Notifikasi:** `flutter_local_notifications` (tanpa FCM)
- **Hardware:** Kamera (`image_picker`, `mobile_scanner`) dan GPS (`geolocator`, `flutter_map`)
- **Tanpa Firebase** dalam bentuk apa pun (database, auth, storage, maupun notifikasi)

## Struktur Proyek

```
lib/
├── main.dart              # Entry point & tema (seed color #0D9488)
├── models/                # Entitas data + fromJson/toJson
├── services/              # Pemanggilan REST API / local storage
│   └── auth_service.dart
├── viewmodels/            # State management & logika per modul
└── views/                 # UI (widget) saja, tanpa pemanggilan API langsung
    ├── splash_screen.dart, onboarding_screen.dart
    ├── login_screen.dart, register_screen.dart
    ├── main_screen.dart, home_screen.dart, profile_screen.dart
    └── barter/            # Modul 3
docs/
├── prd.md                 # Product Requirements Document
├── TEAM_GUIDELINES.md     # Aturan kolaborasi tim (wajib dibaca)
├── Aturan_Project_Mobile_2026.md
└── ai_logs/               # AI Usage Log per anggota
```

Folder `models/` dan `viewmodels/` dibuat seiring pengerjaan tiap modul.

## Menjalankan Aplikasi

**Prasyarat:** Flutter SDK (stable) dan emulator atau perangkat Android 8.0+.

```bash
git clone https://github.com/muhammadhabib16/CampusShift.git
cd CampusShift
flutter pub get
flutter run
```

**Backend:** kode backend tidak berada di repository ini. Jalankan server backend di port `3000` terlebih dahulu; hubungi Bayu atau Habib untuk akses dan konfigurasinya. Alamat API diatur di [`lib/services/auth_service.dart`](lib/services/auth_service.dart):

| Lingkungan | Base URL |
|---|---|
| Emulator Android | `http://10.0.2.2:3000/api/auth` |
| Selain Android (mis. iOS simulator, desktop) | `http://127.0.0.1:3000/api/auth` |
| Perangkat Android fisik | Ganti dengan IP LAN komputer yang menjalankan backend |

## Alur Kerja Git

Ringkasan dari [TEAM_GUIDELINES.md](docs/TEAM_GUIDELINES.md):

1. Kerjakan di branch modul masing-masing: `modul-[nama]` (contoh: `modul-habib`). **Jangan commit atau push langsung ke `main`.**
2. Sebelum membuat Pull Request, sinkronkan dulu: `git pull origin main`.
3. Pastikan `flutter analyze` tidak menampilkan error.
4. Buat Pull Request ke `main`. Kabari grup jika mengubah file inti seperti `lib/main.dart` atau `pubspec.yaml`.
5. Catat setiap penggunaan AI di `docs/ai_logs/[nama]_logs.md` sesuai [template](docs/ai_logs/TEMPLATE.md).

## Dokumentasi

- [PRD v1.1](docs/prd.md) — masalah, peran pengguna, functional/non-functional requirements, alur, data
- [Timeline v4](docs/CampuShift_Timeline_v4.xlsx) — Gantt chart, to-do per anggota, milestone
- [Panduan Tim](docs/TEAM_GUIDELINES.md) — Git, MVVM, integrasi antar modul, standar API & UI
- [Aturan Project Mobile 2026](docs/Aturan_Project_Mobile_2026.md) — ketentuan tugas dari dosen
