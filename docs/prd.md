# PROJECT PRD
## Product Requirements Document

- **Project Name**: CampuShift - Aplikasi Mobile Pengalihan Barang Bekas Antar Mahasiswa yang Aman dan Tepercaya
- **Team**: 
  - Muhammad Racha Ardiwinata (2411522020)
  - Bayu Mutawakkil (2411522023)
  - Muhammad Habib (2411522024)
  - Naufal Baihaqi Zachwan (2411522025)
  - Fadel Muhammad (2411522029)
- **Course**: Mobile Programming
- **Version**: 1.1 (Revisi berdasarkan umpan balik dosen)
- **Date**: 11 Oktober 2026

### Tujuan Dokumen
PRD ini digunakan untuk menjelaskan apa yang akan dibangun, untuk siapa, mengapa produk dibutuhkan, dan kebutuhan utama produk. PRD tidak perlu menjelaskan detail implementasi kode. Dokumen ini menjadi acuan spesifikasi fungsional dan teknis bagi tim pengembang dalam membangun aplikasi mobile CampuShift.

### Riwayat Revisi

| Versi | Tanggal | Ringkasan |
|---|---|---|
| 1.0 | 13 September 2026 | PRD awal. |
| 1.1 | 11 Oktober 2026 | Revisi sesuai umpan balik dosen: scope dipersempit ke satu masalah utama, peran pengguna didefinisikan, mekanisme notifikasi disesuaikan dengan batasan teknis, dan fitur disederhanakan serta diberi prioritas. |

### Tindak Lanjut Umpan Balik Dosen

| Umpan Balik | Tindak Lanjut pada v1.1 |
|---|---|
| Scope terlalu luas untuk proyek mahasiswa. | Aplikasi difokuskan pada **satu masalah utama**: kepercayaan dalam pengalihan barang bekas antar mahasiswa. Jual-beli, barter, dan hibah tidak lagi menjadi tiga subsistem terpisah, melainkan tiga **jalur** dalam satu alur yang sama: *Listing → Kesepakatan → Pertemuan di Titik Temu Resmi → Serah Terima QR → Ulasan* (lihat 2.3). Fitur yang dihapus/dipindah ke Out of Scope: peta persebaran barang & filter radius, titik temu kustom buatan pengguna, entitas hibah terpisah (hibah kini memakai listing yang sama), Digital Claim Pass, enkripsi token QR kustom, balasan ulasan, dan target pengguna dosen/staf. |
| Requirement belum konsisten dengan batasan teknis, terutama notifikasi lokal yang ditargetkan instan ketika terjadi event dari pengguna lain. | Notifikasi dibagi menjadi tiga jenis pemicu yang realistis tanpa FCM: **terjadwal lokal**, **langsung lokal** (aksi di perangkat sendiri), dan **berbasis sinkronisasi** (aplikasi memeriksa server saat aktif). Tidak ada lagi requirement notifikasi "instan" untuk event dari perangkat lain (lihat 2.8). |
| Role pengguna (penjual, pembeli, donatur, pemohon) belum didefinisikan dengan jelas. | Hanya ada satu jenis akun (Mahasiswa) dengan dua peran per transaksi: **Pemilik Barang** dan **Peminat**. Penjual, donatur, pembeli, pengaju barter, dan pemohon dipetakan ke dua peran tersebut beserta hak aksesnya (lihat 1.3). |
| Prioritaskan satu masalah utama dan sederhanakan fitur. | Setiap functional requirement diberi label prioritas **[W] Wajib** atau **[O] Opsional**. Hanya requirement [W] yang menjadi target demo; [O] dikerjakan bila waktu tersisa. |

## 1. Problem & Users

### 1.1 Problem Statement
Mahasiswa yang ingin melepas atau memperoleh barang bekas perlengkapan kuliah di lingkungan kampus saat ini bergantung pada grup chat dan media sosial. Pada saluran tersebut tidak ada jaminan bahwa foto mencerminkan kondisi barang yang sebenarnya, lokasi pertemuan ditentukan seadanya, dan tidak ada bukti bahwa barang telah berpindah tangan. Akibatnya mahasiswa ragu bertransaksi, rawan tertipu, dan barang yang masih layak pakai berakhir terbuang.

**Masalah utama yang diprioritaskan:** *kurangnya kepercayaan dalam proses pengalihan barang bekas antar mahasiswa*, mulai dari kejelasan kondisi barang, keamanan pertemuan, hingga bukti serah terima.

### 1.2 Target Users
Target pengguna adalah **mahasiswa aktif dari satu kampus** (kampus pilot tim), dengan tiga segmen utama:
- **Mahasiswa Tingkat Akhir**: memiliki barang kuliah atau perabot kos (buku referensi, kalkulator saintifik, meja lipat, monitor) yang ingin dijual, ditukar, atau dihibahkan sebelum lulus.
- **Mahasiswa Baru**: membutuhkan perlengkapan kuliah dengan harga terjangkau, tetapi khawatir terhadap penipuan kondisi barang dan keamanan lokasi transaksi.
- **Mahasiswa Berdana Terbatas**: membutuhkan barang tanpa (atau dengan sedikit) uang tunai melalui barter atau hibah.

### 1.3 Peran Pengguna (User Roles)
Aplikasi hanya memiliki **satu jenis akun, yaitu Mahasiswa**. Peran ditentukan **per transaksi**, bukan per akun: satu akun dapat menjadi Pemilik Barang pada satu transaksi dan Peminat pada transaksi lain.

| Peran | Definisi | Hak Akses | Batasan |
|---|---|---|---|
| **Tamu** | Pengguna yang belum login. | Melihat splash, onboarding, registrasi, dan login. | Tidak dapat mengakses fitur lain. |
| **Pemilik Barang** | Pengguna yang membuat listing. Disebut **Penjual** jika listing bertipe Jual dan **Donatur** jika listing bertipe Hibah. | Mengelola (CRUD) listing miliknya; menerima/menolak ajakan pertemuan, tawaran barter, dan klaim hibah atas barangnya; menampilkan QR serah terima; memberi ulasan kepada mitra. | Tidak dapat menawar, membeli, atau mengklaim barang miliknya sendiri. |
| **Peminat** | Pengguna yang tertarik pada listing milik orang lain. Disebut **Pembeli** (jalur Jual), **Pengaju Barter** (jalur Barter), atau **Pemohon** (jalur Hibah). | Mengajukan pertemuan COD, mengajukan tawaran barter dengan barang miliknya, mengajukan klaim hibah; memindai QR serah terima; memberi ulasan kepada mitra. | Tidak dapat mengubah listing orang lain atau menyetujui permintaannya sendiri. |
| **Admin Data** (tim pengembang) | Bukan pengguna aplikasi. | Mengisi data titik temu resmi kampus langsung pada basis data (seed data). | Tidak ada antarmuka admin di aplikasi. |

*Catatan jalur Barter: kedua pihak sama-sama pemilik barang. Pihak yang mengajukan tawaran disebut **Pengaju** (berperan sebagai Peminat atas barang target), sedangkan pihak yang barangnya ditawar disebut **Penerima** (berperan sebagai Pemilik Barang).*

### 1.4 User Needs / Pain Points
- **Kejelasan Kondisi Barang**: foto riil dari kamera dan label kondisi terstandar sebelum memutuskan transaksi.
- **Keamanan Pertemuan**: lokasi dan jadwal pertemuan di titik temu resmi kampus yang diawasi.
- **Opsi Non-Tunai**: dapat menukar barang (dengan selisih tunai bila perlu) atau memperoleh hibah sesuai kebutuhan.
- **Bukti Serah Terima**: bukti digital yang sah bahwa barang benar-benar telah diserahkan.
- **Rekam Jejak Mitra**: dapat melihat reputasi mitra transaksi dari ulasan transaksi sebelumnya.

### 1.5 Project Goal
Membangun aplikasi Android yang membuat pengalihan barang bekas antar mahasiswa di satu kampus dapat dipercaya melalui satu alur terpadu: listing berfoto riil → kesepakatan (jual, barter, atau hibah) → pertemuan di titik temu resmi → validasi serah terima dengan kode QR → ulasan reputasi. Aplikasi mendukung SDG 12 (Konsumsi dan Produksi yang Bertanggung Jawab) dengan memperpanjang umur pakai barang di lingkungan kampus.

## 2. Product Requirements

### 2.1 Functional Requirements
Label prioritas: **[W] Wajib** (target demo dan penilaian) dan **[O] Opsional** (dikerjakan bila waktu tersisa).

#### Modul Pendukung: Autentikasi & Profil (Tanggung Jawab Bersama Tim)
Modul infrastruktur yang dipakai seluruh modul lain. Tidak dihitung sebagai salah satu dari 5 modul penilaian individu.
- **FR-A01 [W]**: Pengguna dapat mendaftar dengan NIM, nama lengkap, email kampus, dan kata sandi. Server memvalidasi format email kampus serta keunikan NIM dan email.
- **FR-A02 [W]**: Pengguna dapat login (email/NIM dan kata sandi) dan logout. Server menerbitkan JSON Web Token (JWT) yang disimpan di perangkat dan disertakan pada setiap request privat.
- **FR-A03 [W]**: Pengguna dapat melihat dan menyunting profil sendiri: nama, nomor telepon, dan foto profil (kamera/galeri).
- **FR-A04 [O]**: Pengguna dapat mengganti kata sandi.

*Profil publik dan skor reputasi mitra dipindahkan ke Modul 4 karena bersumber dari data ulasan.*

#### Modul 1: Listing Barang & Kondisi Fisik — Naufal Baihaqi Zachwan (2411522025)
Entitas CRUD utama: **Items**.
- **FR-01 [W]**: Pemilik Barang dapat membuat, melihat, menyunting, dan menghapus listing: judul, deskripsi, kategori (Buku & Referensi, Furnitur Kos, Elektronik, Alat Perkuliahan), tipe listing (**Jual** dengan harga atau **Hibah** gratis), opsi "Terbuka untuk Barter" (khusus tipe Jual), dan label kondisi (Baru/Sangat Baik/Baik/Cukup). Listing hanya dapat dihapus bila tidak sedang dalam kesepakatan aktif.
- **FR-02 [W]**: Setiap listing wajib memiliki minimal 2 foto (tampak utama dan detail kondisi/cacat), maksimal 3 foto, yang diambil langsung melalui kamera aplikasi (image_picker mode kamera).
- **FR-03 [W]**: Peminat dapat menelusuri katalog dengan pencarian kata kunci serta filter kategori, tipe listing (Jual/Hibah/Terbuka untuk Barter), dan rentang harga.
- **FR-04 [W]**: Pemilik Barang dapat mengelola barang miliknya pada halaman "Barang Saya": mengarsipkan dan mengaktifkan kembali listing, serta melihat status yang diubah oleh server (Reserved/Completed) beserta asal kesepakatannya.
- **FR-05 [W] (Notifikasi)**: Listing Stale Alert — notifikasi lokal **terjadwal** 14 hari setelah listing dibuat atau terakhir diperbarui. Jadwal diperbarui saat listing disunting dan dibatalkan saat listing tidak lagi berstatus Available.

#### Modul 2: Safe-Meet Point & Jadwal Pertemuan — Bayu Mutawakkil (2411522023)
Entitas CRUD utama: **Meetups** (data Safe-Meet Points bersifat baca-saja).
- **FR-06 [W]**: Pengguna dapat melihat direktori titik temu resmi kampus (pos satpam, perpustakaan, gedung pusat, dan sejenisnya) dalam bentuk daftar dan peta (flutter_map), diurutkan berdasarkan jarak dari posisi GPS pengguna (geolocator) dengan jarak dalam meter (formula Haversine).
- **FR-07 [W]**: Peminat dapat mengajukan jadwal pertemuan (memilih titik temu dan waktu) langsung dari detail barang bertipe Jual, atau setelah tawaran barter berstatus Locked / klaim hibah disetujui. Kedua pihak dapat melihat daftar pertemuan, mengubah waktu atau lokasi selama belum dikonfirmasi, dan membatalkan pertemuan.
- **FR-08 [W]**: Pemilik Barang dapat mengonfirmasi atau menolak ajakan pertemuan. Pada jalur Jual, konfirmasi membuat barang berstatus Reserved dan membatalkan ajakan pertemuan lain atas barang yang sama.
- **FR-09 [W]**: Pengguna dapat menekan tombol "Buka Rute" untuk membuka navigasi menuju titik temu pada aplikasi Google Maps (intent).
- **FR-10 [W] (Notifikasi)**: Meeting Reminder — notifikasi lokal **terjadwal** 30 menit sebelum waktu pertemuan. Pengingat dijadwalkan di perangkat masing-masing pihak saat pertemuan berstatus Dikonfirmasi (perangkat Peminat menjadwalkannya setelah sinkronisasi mendeteksi konfirmasi).

#### Modul 3: Barter & Cash Top-Up — Muhammad Habib (2411522024)
Entitas CRUD utama: **Barter Deals**.
- **FR-11 [W]**: Pengaju dapat mengajukan tawaran barter pada listing yang "Terbuka untuk Barter" dengan memilih satu barang miliknya yang berstatus Available, mengisi selisih tunai (cash top-up) opsional beserta pihak yang membayar, dan pesan singkat.
- **FR-12 [W]**: Pengguna dapat mengelola tawaran barter: melihat daftar tawaran masuk dan keluar beserta statusnya (Read), mengajukan nominal top-up baru sebagai tawaran balik (Update), menolak tawaran (oleh Penerima), dan membatalkan tawaran (oleh Pengaju) selama belum Locked (Delete). Setiap perubahan nominal mengubah status menjadi Negotiating dan mereset konfirmasi kedua pihak.
- **FR-13 [W]**: Dual-Confirmation — masing-masing pihak menekan tombol "Setuju & Kunci Kesepakatan" dari akunnya sendiri. Server mencatat konfirmasi Pengaju dan Penerima secara terpisah, dan status berubah menjadi Locked hanya jika keduanya telah mengonfirmasi.
- **FR-14 [W]**: Asset Locking — saat status menjadi Locked, server mengubah kedua barang menjadi Reserved dan otomatis menolak tawaran lain yang melibatkan salah satu barang tersebut. Penguncian dilakukan di server agar konsisten di semua perangkat. Kesepakatan Locked masih dapat dibatalkan sebelum serah terima, dan pembatalan mengembalikan kedua barang menjadi Available.
- **FR-15 [W] (Notifikasi)**: Barter Alert — notifikasi lokal **berbasis sinkronisasi** ketika terdapat tawaran baru, tawaran balik, atau perubahan status tawaran (Locked/Rejected/Cancelled) sejak sinkronisasi terakhir.
- **FR-16 [O]**: Pengaju dapat melampirkan foto kondisi terbaru barang miliknya dari kamera saat mengajukan tawaran.

#### Modul 4: Serah Terima QR & Reputasi — Fadel Muhammad (2411522029)
Entitas CRUD utama: **Reviews** (didukung entitas Handover Tokens).
- **FR-17 [W]**: Pada pertemuan berstatus Dikonfirmasi, Pemilik Barang dapat menampilkan kode QR serah terima. Server membuat token acak sekali pakai yang berlaku 5 menit, dan QR diperbarui otomatis saat kedaluwarsa.
- **FR-18 [W]**: Peminat memindai kode QR menggunakan kamera (mobile_scanner). Server memvalidasi bahwa token cocok dengan pertemuan, belum kedaluwarsa, belum pernah dipakai, dan dipindai oleh Peminat pada pertemuan tersebut. Jika valid, pertemuan menjadi Selesai dan barang terkait menjadi Completed (kedua barang pada jalur Barter).
- **FR-19 [W]**: Pengguna dapat melihat riwayat transaksi selesai beserta bukti serah terima digital yang memuat barang, kedua pihak, titik temu, jalur transaksi, dan waktu validasi.
- **FR-20 [W]**: Setelah transaksi Selesai, setiap pihak dapat memberi ulasan untuk mitranya berupa rating 1–5 dan komentar (Create, satu ulasan per pihak per transaksi), menyunting (Update) dan menghapus (Delete) ulasan miliknya, serta melihat profil publik pengguna lain yang menampilkan rata-rata rating dan daftar ulasan (Read).
- **FR-21 [W] (Notifikasi)**: Handover Success Alert — notifikasi lokal **langsung** di perangkat Peminat setelah pemindaian berhasil divalidasi, berisi ajakan memberi ulasan. Layar QR milik Pemilik Barang memeriksa status token secara berkala selama terbuka sehingga keberhasilan serah terima juga ditampilkan di perangkat Pemilik.
- **FR-22 [O] (Notifikasi)**: Review Reminder — notifikasi lokal terjadwal 24 jam setelah transaksi Selesai apabila pengguna belum memberi ulasan.

#### Modul 5: Hibah & Klaim Berbasis Kebutuhan — Muhammad Racha Ardiwinata (2411522020)
Entitas CRUD utama: **Claims**. Barang hibah menggunakan entitas Items dari Modul 1 dengan tipe listing Hibah.
- **FR-23 [W]**: Pemohon dapat mengajukan klaim atas listing bertipe Hibah dengan mengisi tingkat urgensi (Mendesak/Sedang/Rendah) dan justifikasi kebutuhan berupa teks minimal 100 karakter. Setiap pemohon dibatasi 1 klaim per barang dan maksimal 3 klaim aktif sekaligus agar distribusi adil.
- **FR-24 [W]**: Pemohon dapat mengelola klaim miliknya: melihat status klaim (Read), menyunting urgensi dan justifikasi selama klaim masih Pending (Update), dan membatalkan klaim (Delete).
- **FR-25 [W]**: Donatur dapat melihat antrean klaim untuk setiap barang hibahnya, diurutkan berdasarkan tingkat urgensi kemudian tanggal pengajuan, dan membaca justifikasi tiap pemohon.
- **FR-26 [W]**: Donatur dapat menyetujui satu pemohon atau menolak klaim satu per satu. Saat sebuah klaim disetujui, server menjadikan barang Reserved dan otomatis menolak klaim lain atas barang tersebut; pemohon kemudian diarahkan untuk menjadwalkan pengambilan melalui Modul 2.
- **FR-27 [W] (Notifikasi)**: Claim Status Alert — notifikasi lokal **berbasis sinkronisasi** kepada pemohon saat klaimnya disetujui atau ditolak, dan kepada donatur saat ada klaim baru pada barang hibahnya.
- **FR-28 [O] (Notifikasi)**: Pickup Reminder — notifikasi lokal terjadwal 2 hari setelah klaim disetujui apabila pemohon belum menjadwalkan pengambilan.

### 2.2 Non-functional Requirements
- **NFR-01 (Performance)**: Halaman katalog, daftar titik temu, dan riwayat transaksi dimuat dalam waktu ≤ 3 detik pada jaringan seluler normal.
- **NFR-02 (Compatibility & Platform)**: Aplikasi terpasang dan berjalan stabil pada Android 8.0 (API Level 26) hingga Android 14.
- **NFR-03 (Usability & Design System)**: Seluruh screen menggunakan komponen Flutter/Material Design 3 dengan warna utama `#0D9488` dan tampil tanpa overflow pada layar 5,0–6,7 inci dalam orientasi potret.
- **NFR-04 (Security)**: Sesi diamankan dengan JWT yang berlaku maksimal 24 jam; kata sandi disimpan dalam bentuk hash; token QR serah terima bersifat acak, sekali pakai, kedaluwarsa maksimal 5 menit, dan hanya divalidasi di server. Setiap endpoint yang mengubah data memeriksa bahwa pengguna memiliki peran yang sesuai (misalnya hanya Pemilik Barang yang dapat mengonfirmasi pertemuan atau menyetujui klaim).
- **NFR-05 (Architectural Compliance — Non-Firebase)**: Backend menggunakan RESTful API mandiri (Node.js/Express) dengan basis data relasional (MySQL/PostgreSQL). Jumlah dependensi Firebase pada `pubspec.yaml` dan backend adalah nol, termasuk untuk autentikasi, penyimpanan media, dan notifikasi.
- **NFR-06 (Reliability & Hardware Fault Tolerance)**: Penolakan izin Kamera, Lokasi, dan Notifikasi ditangani dengan dialog informatif dan aplikasi tetap berjalan; kegagalan jaringan ditampilkan dengan pesan yang jelas tanpa crash maupun loading tanpa henti.
- **NFR-07 (Notification Latency)**: Saat aplikasi aktif, notifikasi berbasis sinkronisasi muncul paling lambat ±60 detik setelah perubahan terjadi di server. Saat aplikasi tertutup, notifikasi tersebut muncul ketika aplikasi dibuka kembali.

### 2.3 Core Features
Kelima core feature membentuk **satu alur inti** yang menjawab satu masalah utama:

```
[M1] Listing berfoto riil
        │  Peminat memilih jalur
        ├── Jual   : langsung ajukan pertemuan ─────────────────────────┐
        ├── Barter : [M3] tawaran → negosiasi top-up → dual-confirmation ─┤
        └── Hibah  : [M5] klaim → antrean → donatur menyetujui ──────────┤
                                                                        ▼
                                     [M2] Pertemuan di Safe-Meet Point resmi
                                                                        ▼
                                     [M4] Serah terima QR → Selesai → Ulasan
```

| No. | Core Feature | Purpose / Value |
|---|---|---|
| 1 | Listing Berfoto Riil & Pencarian | Menjamin kejelasan kondisi barang melalui foto kamera dan label kondisi terstandar, serta memudahkan penemuan barang lewat pencarian dan filter. |
| 2 | Pertemuan di Titik Temu Resmi | Menjamin keamanan COD dengan jadwal pertemuan yang disepakati di titik temu resmi kampus, lengkap dengan jarak dan rute. |
| 3 | Barter dengan Dual-Confirmation | Menyediakan opsi non-tunai dengan selisih tunai opsional dan persetujuan eksplisit dua pihak, disertai penguncian barang di server. |
| 4 | Serah Terima QR & Reputasi | Memberikan bukti serah terima yang sah di lokasi dan membangun rekam jejak kepercayaan melalui ulasan. |
| 5 | Hibah Berbasis Kebutuhan | Menyalurkan barang gratis secara adil kepada mahasiswa yang paling membutuhkan melalui klaim terstruktur dan antrean berbasis urgensi. |

*Catatan: Modul Pendukung Autentikasi & Profil tidak dimasukkan sebagai Core Feature bernomor karena sifatnya infrastruktur pendukung seluruh fitur di atas.*

### 2.4 User Flow

#### Flow 0: Registrasi, Login & Profil (Modul Pendukung)
- Tamu membuka aplikasi → Splash → Onboarding → menekan "Daftar" → mengisi NIM, nama, email kampus, dan kata sandi.
- Pengguna login dengan email/NIM dan kata sandi → server menerbitkan JWT → masuk ke Beranda.
- Pengguna membuka Profil → menyunting nama, nomor telepon, dan foto profil.
- Pengguna menekan "Keluar" untuk mengakhiri sesi.

#### Flow 1: Membuat Listing (Modul 1)
- Pemilik Barang menekan tombol Tambah (+) → mengisi judul, deskripsi, kategori, tipe listing (Jual/Hibah), harga, dan opsi "Terbuka untuk Barter".
- Membuka kamera aplikasi → mengambil foto tampak utama dan detail kondisi/cacat.
- Memilih label kondisi → menekan "Simpan" → listing tersimpan di server dengan status Available.
- Aplikasi menjadwalkan Listing Stale Alert 14 hari ke depan.

#### Flow 2: Jalur Jual — Mengajukan Pertemuan COD (Modul 1 → Modul 2)
- Peminat mencari barang di katalog → membuka detail barang bertipe Jual → menekan "Ajukan Pertemuan".
- Memilih titik temu resmi (diurutkan berdasarkan jarak GPS) dan waktu → mengirim ajakan.
- Pemilik Barang melihat ajakan (setelah sinkronisasi) → mengonfirmasi → barang menjadi Reserved.
- Kedua perangkat menjadwalkan Meeting Reminder 30 menit sebelum pertemuan; pengguna dapat menekan "Buka Rute" ke Google Maps.

#### Flow 3: Jalur Barter (Modul 3 → Modul 2)
- Pengaju membuka detail barang yang Terbuka untuk Barter → menekan "Tukar (Barter)".
- Memilih satu barang miliknya yang Available → mengisi selisih tunai (opsional) dan pesan → mengirim tawaran (status Pending).
- Penerima menerima Barter Alert (melalui sinkronisasi) → menolak, atau mengajukan nominal baru (status Negotiating).
- Setelah sepakat, kedua pihak menekan "Setuju & Kunci Kesepakatan" dari akun masing-masing → status Locked → kedua barang menjadi Reserved.
- Pengaju mengajukan jadwal pertemuan melalui Modul 2.

#### Flow 4: Jalur Hibah (Modul 5 → Modul 2)
- Pemohon membuka listing bertipe Hibah → menekan "Ajukan Klaim" → memilih tingkat urgensi dan menulis justifikasi (minimal 100 karakter) → mengirim klaim (status Pending).
- Donatur membuka antrean klaim barang tersebut, terurut berdasarkan urgensi dan tanggal → membaca justifikasi → menyetujui satu pemohon.
- Barang menjadi Reserved dan klaim lain otomatis ditolak → pemohon menerima Claim Status Alert (melalui sinkronisasi).
- Pemohon mengajukan jadwal pengambilan melalui Modul 2.

#### Flow 5: Serah Terima & Ulasan (Modul 4)
- Kedua pihak bertemu di titik temu pada waktu yang disepakati.
- Pemilik Barang membuka pertemuan → menampilkan QR serah terima (berlaku 5 menit).
- Peminat membuka pemindai → memindai QR → server memvalidasi token.
- Pertemuan menjadi Selesai, barang menjadi Completed, bukti serah terima tercatat di riwayat → Handover Success Alert muncul di perangkat Peminat dan layar QR Pemilik menampilkan status berhasil.
- Kedua pihak diarahkan untuk memberi ulasan kepada mitranya.

### 2.5 Data Requirements

| Data / Entity | Key Information | Purpose | Modul |
|---|---|---|---|
| **Users** | User ID, Nama Lengkap, NIM, Email Kampus, Kata Sandi (hash), Foto Profil (URL), Nomor Telepon, Tanggal Bergabung. | Identitas, autentikasi JWT, dan profil. Skor reputasi dihitung dari Reviews, tidak disimpan terpisah. | Pendukung |
| **Items** | Item ID, Owner User ID, Judul, Deskripsi, Kategori, Tipe Listing (Jual/Hibah), Harga (0 untuk Hibah), Terbuka untuk Barter (bool), Kondisi (Baru/Sangat Baik/Baik/Cukup), URL Foto (2–3), Status (Available/Reserved/Completed/Archived), Created/Updated At. | Katalog barang untuk ketiga jalur transaksi. | M1 |
| **Safe-Meet Points** | Point ID, Nama, Kategori Lokasi (Pos Satpam/Perpustakaan/Gedung Pusat/dll.), Latitude, Longitude, Panduan Keamanan. | Direktori titik temu resmi (seed data, baca-saja). | M2 |
| **Meetups** | Meetup ID, Item ID, Jalur (Jual/Barter/Hibah), Referensi (Deal ID atau Claim ID, opsional), Owner User ID, Requester User ID, Point ID, Waktu Pertemuan, Status (Diajukan/Dikonfirmasi/Ditolak/Dibatalkan/Selesai). | Jadwal pertemuan sekaligus "transaksi" yang menjadi acuan serah terima. | M2 |
| **Barter Deals** | Deal ID, Sender Item ID, Receiver Item ID, Sender User ID, Receiver User ID, Nominal Top-Up, Pihak Pembayar Top-Up, Pesan, Status (Pending/Negotiating/Locked/Rejected/Cancelled), Sender Confirmed (bool), Receiver Confirmed (bool), Created/Updated At. | Riwayat tawaran barter, dual-confirmation, dan penguncian aset. | M3 |
| **Handover Tokens** | Token ID, Meetup ID, Token (acak), Issued At, Expires At, Used At, Status (Active/Used/Expired). | Validasi serah terima dengan QR sekali pakai berbatas waktu. | M4 |
| **Reviews** | Review ID, Meetup ID, Reviewer User ID, Reviewee User ID, Rating (1–5), Komentar, Created/Updated At. | Rekam jejak dan perhitungan skor reputasi pengguna. | M4 |
| **Claims** | Claim ID, Item ID (tipe Hibah), Applicant User ID, Urgensi (Mendesak/Sedang/Rendah), Justifikasi, Status (Pending/Approved/Rejected/Cancelled), Created/Updated At. | Permohonan hibah berbasis kebutuhan dan antrean donatur. | M5 |

**Aturan status barang (berlaku lintas modul, hanya diubah oleh server):**

| Status | Arti | Dipicu oleh |
|---|---|---|
| Available | Tampil di katalog dan dapat diajukan. | Listing dibuat (M1); pembatalan kesepakatan/pertemuan/klaim. |
| Reserved | Sedang dalam kesepakatan; tidak dapat diajukan pengguna lain. | Pertemuan jalur Jual dikonfirmasi (M2), barter Locked (M3), atau klaim hibah disetujui (M5). |
| Completed | Barang sudah berpindah tangan. | Validasi QR serah terima berhasil (M4). |
| Archived | Disembunyikan oleh pemilik. | Pemilik Barang (M1). |

### 2.6 Constraints & Assumptions
- **Platform**: Flutter SDK untuk Android 8.0 (API 26) hingga Android 14.
- **Backend & Larangan Firebase**: Seluruh data, termasuk akun, sesi, dan file foto, dikelola oleh RESTful API mandiri (Node.js/Express) dan basis data relasional. Server berjalan di VPS; server lokal diperbolehkan selama pengembangan. Firebase dalam bentuk apa pun dilarang.
- **Notifikasi**: Menggunakan flutter_local_notifications tanpa FCM atau push server, sehingga event dari pengguna lain hanya diketahui melalui sinkronisasi (lihat 2.8).
- **Hardware**: Hanya Kamera (image_picker, mobile_scanner) dan GPS (geolocator, flutter_map). Tidak ada sensor biometrik maupun mikrofon.
- **Lingkup Pengguna**: Satu kampus pilot; pengguna diasumsikan mahasiswa aktif yang terhubung ke internet kampus/seluler saat bertransaksi.
- **Data Titik Temu**: Titik temu resmi disiapkan tim sebagai seed data; pengguna tidak dapat menambah titik temu sendiri.
- **Kepemilikan Modul Pendukung**: Modul Autentikasi & Profil dikerjakan bersama di awal sprint dan tidak dihitung sebagai modul penilaian individu.

### 2.7 Success Criteria
- **Alur Inti Berjalan End-to-End**: Ketiga jalur (Jual, Barter, Hibah) dapat didemonstrasikan dari listing hingga ulasan menggunakan dua akun pada dua perangkat/emulator.
- **Seluruh Requirement [W] Terpenuhi**: Setiap modul menyelesaikan seluruh requirement Wajib, termasuk operasi CRUD entitas utamanya dan notifikasinya, tanpa unhandled exception.
- **Fondasi Autentikasi Berfungsi**: Registrasi, login, logout, dan edit profil berjalan serta menjadi prasyarat akses ke seluruh modul.
- **Konsistensi Status**: Barang yang Reserved tidak dapat diajukan oleh pengguna lain, dan barter tidak dapat Locked tanpa konfirmasi kedua pihak (diuji dengan dua akun).
- **Kecepatan Validasi QR**: Pemindaian QR hingga hasil validasi tampil dalam waktu < 2 detik pada pencahayaan normal; token kedaluwarsa atau yang sudah dipakai ditolak.
- **Kepatuhan Non-Firebase**: Tidak ada dependensi Firebase di `pubspec.yaml` maupun backend.
- **Kesiapan Code Review**: Setiap anggota mampu mendemonstrasikan dan menjelaskan kode modulnya secara mandiri.

### 2.8 Mekanisme Notifikasi
Karena aplikasi tidak menggunakan push server (FCM), setiap notifikasi menggunakan salah satu dari tiga jenis pemicu berikut:

| Jenis Pemicu | Kapan Digunakan | Cara Kerja | Dipakai oleh |
|---|---|---|---|
| **Terjadwal Lokal** | Waktu kejadian sudah diketahui perangkat sendiri. | Dijadwalkan di perangkat saat data dibuat/berubah; tetap muncul walaupun aplikasi ditutup. | FR-05 (M1), FR-10 (M2), FR-22 (M4, opsional), FR-28 (M5, opsional) |
| **Langsung Lokal** | Kejadian terjadi akibat aksi pengguna di perangkat itu sendiri. | Ditampilkan segera setelah server mengonfirmasi aksi berhasil. | FR-21 (M4) |
| **Berbasis Sinkronisasi** | Kejadian berasal dari aksi pengguna lain. | Aplikasi memeriksa server saat dibuka, saat kembali aktif dari background, saat pull-to-refresh, dan berkala (±60 detik) selama aplikasi aktif. Perubahan baru dibandingkan dengan data sinkronisasi terakhir yang tersimpan lokal, lalu ditampilkan sebagai notifikasi lokal. | FR-15 (M3), FR-27 (M5), deteksi konfirmasi pertemuan pada FR-10 (M2) |

**Konsekuensi yang diterima:** notifikasi dari aksi pengguna lain tidak bersifat instan. Jika aplikasi tertutup, notifikasi baru muncul saat aplikasi dibuka kembali. Sinkronisasi di latar belakang (misalnya WorkManager) berada di luar scope.

### 2.9 Pembagian Modul & Beban Kerja

| Modul | PJ | Fungsionalitas Utama (≥ 4) | Entitas CRUD | Fitur Device | Notifikasi |
|---|---|---|---|---|---|
| M1 Listing & Kondisi Fisik | Naufal | CRUD listing; foto kamera; pencarian & filter; kelola status "Barang Saya" | Items | Kamera | Terjadwal lokal |
| M2 Safe-Meet Point & Pertemuan | Bayu | Direktori titik temu + jarak GPS; CRUD jadwal pertemuan; konfirmasi pemilik; buka rute Google Maps | Meetups | GPS + Peta | Terjadwal lokal |
| M3 Barter & Cash Top-Up | Habib | Ajukan tawaran; negosiasi & kelola tawaran; dual-confirmation; asset locking | Barter Deals | — (Kamera opsional, FR-16) | Berbasis sinkronisasi |
| M4 Serah Terima QR & Reputasi | Fadel | QR token sekali pakai; pindai & validasi; bukti serah terima; CRUD ulasan & profil reputasi | Reviews | Kamera (pemindai QR) | Langsung lokal |
| M5 Hibah & Klaim | Racha | Ajukan klaim terstruktur; kelola klaim; antrean berbasis urgensi; persetujuan donatur | Claims | — | Berbasis sinkronisasi |
| Pendukung Auth & Profil | Semua | Register; login/logout JWT; edit profil | Users | Kamera (foto profil) | — |

**Aturan integrasi antar modul:** modul saling berkomunikasi melalui ID (`item_id`, `deal_id`, `claim_id`, `meetup_id`) dan API backend, bukan dengan saling mengubah state layar modul lain. Perubahan status barang lintas modul dilakukan oleh server sesuai aturan status pada 2.5. Pengembangan backend REST API dikoordinasikan oleh Bayu dan Habib, dan setiap PJ modul ikut menyusun kontrak endpoint modulnya.

## 3. Scope

### 3.1 In Scope
- Modul Pendukung Autentikasi & Profil (registrasi, login/logout JWT, edit profil).
- Lima modul fungsional dalam satu alur inti: Listing & Kondisi Fisik, Safe-Meet Point & Pertemuan, Barter & Cash Top-Up, Serah Terima QR & Reputasi, serta Hibah & Klaim.
- Antarmuka Flutter berbasis Material Design 3.
- Integrasi hardware: Kamera (foto listing, foto profil, pemindai QR) dan GPS (jarak dan peta titik temu).
- Notifikasi lokal per modul dengan flutter_local_notifications sesuai mekanisme pada 2.8.
- Backend RESTful API mandiri dengan basis data relasional, termasuk endpoint autentikasi dan penyimpanan foto.
- Pencatatan AI Usage Log untuk setiap anggota tim.

### 3.2 Out of Scope
- Payment gateway (pembayaran diselesaikan tunai saat bertemu atau melalui barter).
- Kurir/ekspedisi pengantaran barang.
- Platform iOS dan Web.
- Firebase dalam bentuk apa pun (Firestore, Realtime Database, Authentication, Storage, FCM).
- Push notification real-time dan sinkronisasi latar belakang.
- Fitur chat antar pengguna (koordinasi dilakukan melalui tawaran barter, klaim, dan jadwal pertemuan).
- Peta persebaran barang dan filter radius jarak barang *(dihapus pada v1.1)*.
- Titik temu kustom buatan pengguna dan antarmuka admin *(dihapus pada v1.1)*.
- Digital Claim Pass terpisah; bukti pengambilan hibah menggunakan serah terima QR Modul 4 *(dihapus pada v1.1)*.
- Enkripsi payload QR kustom; keamanan dijamin oleh token acak sekali pakai yang divalidasi server *(disederhanakan pada v1.1)*.
- Balasan/tanggapan atas ulasan *(dihapus pada v1.1)*.
- Pengguna dosen/staf, multi-kampus, verifikasi email melalui OTP, dan login sosial pihak ketiga.
- Verifikasi biometrik dan perekaman suara.

## 4. AI Prompt Context
Saya sedang mengembangkan aplikasi mobile bernama "CampuShift" untuk tugas mata kuliah Mobile Programming (tim 5 orang). CampuShift adalah aplikasi Flutter (Android) yang membuat pengalihan barang bekas antar mahasiswa di satu kampus menjadi aman dan tepercaya, mendukung SDG 12.

Alur inti aplikasi: Listing berfoto riil → kesepakatan melalui salah satu jalur (Jual / Barter / Hibah) → pertemuan di titik temu resmi kampus → serah terima dengan validasi kode QR → ulasan.

Peran pengguna: satu jenis akun (Mahasiswa) dengan peran per transaksi, yaitu **Pemilik Barang** (penjual/donatur/penerima barter) dan **Peminat** (pembeli/pemohon/pengaju barter).

Modul:
- **Modul Pendukung (bersama)**: Registrasi, login/logout JWT, edit profil.
- **Modul 1 (Naufal)**: Listing & Kondisi Fisik — CRUD Items (tipe Jual/Hibah, opsi Terbuka untuk Barter), 2–3 foto kamera, pencarian & filter, kelola status; notifikasi terjadwal Listing Stale Alert.
- **Modul 2 (Bayu)**: Safe-Meet Point & Pertemuan — direktori titik temu resmi (seed) dengan jarak GPS dan peta, CRUD Meetups, konfirmasi pemilik, intent Google Maps; notifikasi terjadwal Meeting Reminder.
- **Modul 3 (Habib)**: Barter & Cash Top-Up — CRUD Barter Deals, negosiasi nominal top-up, dual-confirmation, asset locking di server; notifikasi Barter Alert berbasis sinkronisasi.
- **Modul 4 (Fadel)**: Serah Terima QR & Reputasi — token QR acak sekali pakai (5 menit), pemindaian mobile_scanner, bukti serah terima, CRUD Reviews; notifikasi langsung Handover Success.
- **Modul 5 (Racha)**: Hibah & Klaim — CRUD Claims (urgensi + justifikasi ≥ 100 karakter), antrean berbasis urgensi, persetujuan donatur; notifikasi Claim Status Alert berbasis sinkronisasi.

**Batasan Teknis Mutlak**
- Framework: Flutter SDK (target Android), arsitektur MVVM (`views/`, `viewmodels/`, `models/`, `services/`).
- Backend: RESTful API mandiri (Node.js/Express) + basis data relasional, termasuk autentikasi JWT sendiri.
- Dilarang menggunakan Firebase dalam bentuk apa pun.
- Notifikasi: flutter_local_notifications tanpa FCM; event dari pengguna lain dideteksi melalui sinkronisasi saat aplikasi aktif.
- Hardware hanya Kamera dan GPS.
- Status barang hanya diubah oleh server; antar modul berkomunikasi melalui ID.

**Instruksi kepada AI**
Bantu saya merancang arsitektur kode/model/service sesuai modul saya, termasuk cara modul saya mengonsumsi sesi login dari Modul Pendukung Autentikasi, dengan kode yang bersih, modular, dapat diuji secara mandiri, dan mudah saya jelaskan saat sesi code review teknis.

## PRD Checklist
- [x] Problem statement jelas, berfokus pada pengguna, dan memprioritaskan satu masalah utama.
- [x] Target users spesifik.
- [x] Peran pengguna dan hak aksesnya didefinisikan.
- [x] Project goal menjawab masalah yang diidentifikasi.
- [x] Core features berjumlah sekitar 4–6, relevan, dan membentuk satu alur inti.
- [x] User flow utama sudah dituliskan.
- [x] Data utama sudah diidentifikasi.
- [x] Constraints dan assumptions sudah dicatat.
- [x] Success criteria dapat digunakan untuk menilai hasil project.
- [x] In Scope dan Out of Scope sudah jelas.
- [x] Functional requirements menjelaskan perilaku/fungsi yang harus dilakukan aplikasi dan diberi prioritas.
- [x] Non-functional requirements menjelaskan kualitas atau batasan sistem dan, jika memungkinkan, dapat diukur.
- [x] Functional requirements konsisten dengan core features dan batasan teknis (termasuk mekanisme notifikasi).
- [x] Non-functional requirements tidak ditulis sebagai fitur baru.
