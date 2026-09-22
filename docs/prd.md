PROJECT PRD
Product Requirements Document
Project Name CampuShift - Aplikasi Mobile Ekonomi Sirkular dan Jual Beli
Barang Bekas Mahasiswa
Team Muhammad Racha Ardiwinata (2411522020)
Bayu Mutawakkil (2411522023)
Muhammad Habib (2411522024)
Naufal Baihaqi Zachwan (2411522025)
Fadel Muhammad (2411522029)
Course Mobile Programming
Version 1.0
Date 13 September 2026
Tujuan Dokumen
PRD ini digunakan untuk menjelaskan apa yang akan dibangun, untuk siapa, mengapa produk
dibutuhkan, dan kebutuhan utama produk. PRD tidak perlu menjelaskan detail implementasi kode.
Dokumen ini menjadi acuan spesifikasi fungsional dan teknis bagi tim pengembang dalam membangun
aplikasi mobile CampuShift.
1. Problem & Users
1.1 Problem Statement
Mahasiswa kesulitan mengalihkan dan memperoleh barang bekas layak pakai di lingkungan kampus
secara aman dan tepercaya. Saluran transaksi informal daring rentan manipulasi kondisi fisik barang,
tidak menjamin keamanan saat pertemuan tatap muka, dan tidak memberi kepastian saat serah terima
berlangsung.
1.2 Target Users
• Mahasiswa Tingkat Akhir: memiliki barang kebutuhan perkuliahan (buku referensi, meja
lipat, kalkulator saintifik, perabot kos, monitor) yang ingin dijual dengan harga wajar, dibarter,
atau dihibahkan secara gratis kepada junior sebelum meninggalkan kampus.
• Mahasiswa Berpenghasilan Terbatas: memerlukan akses terhadap barang atau perlengkapan
kuliah tanpa biaya tunai (melalui skema barter atau hibah), serta membutuhkan jaminan
keamanan transaksi mengingat keterbatasan dana untuk menanggung risiko kerugian.
• Mahasiswa Baru: memerlukan perlengkapan penunjang kuliah dengan harga terjangkau,
namun memiliki kekhawatiran tinggi terhadap penipuan kondisi barang dan keamanan lokasi
transaksi.
• Komunitas Civitas Akademika (Dosen & Staf): pihak yang ingin mendukung gerakan
keberlanjutan kampus (SDG 12) melalui donasi barang layak pakai.
1.3 User Needs / Pain Points
• Transparansi Kondisi Fisik Barang (Anti-Catfishing): kepastian visual riil atas kondisi fisik
barang bekas sebelum membeli, termasuk dokumentasi kecacatan atau minus pemakaian.
• Keamanan Bertransaksi Tatap Muka (Safe Meet-Up): rekomendasi titik pertemuan publik
yang diawasi dan resmi di lingkungan kampus.
• Fleksibilitas Metode Transaksi & Opsi Non-Tunai: fleksibilitas metode transaksi (COD
tunai, barter murni, atau kombinasi barter + cash top-up).
• Validasi & Kepastian Serah Terima Barang: bukti digital yang sah dan instan saat serah
terima barang berlangsung.
• Akses Hibah/Bantuan Perlengkapan Belajar: akses terbuka dan transparan untuk
memperoleh donasi peralatan belajar dari mahasiswa lain.
• Identitas & Kepercayaan Antar Pengguna: pengguna perlu mendaftar dengan identitas
kampus yang jelas dan dapat melihat profil serta reputasi mitra transaksi sebagai dasar
kepercayaan.
1.4 Project Goal
Membangun platform ekonomi sirkular digital terpadu berbasis mobile yang memfasilitasi civitas
akademika kampus dalam memperpanjang siklus hidup barang melalui transaksi jual-beli transparan,
sistem barter non-tunai, titik temu aman terintegrasi GPS, validasi serah terima kode QR, serta
penyaluran hibah sosial untuk mendukung pencapaian SDG 12, di atas fondasi identitas pengguna
yang terverifikasi kampus.
2. Product Requirements
2.1 Functional Requirements
Modul Pendukung: Autentikasi & Manajemen Profil (Tanggung Jawab Bersama Tim)
Modul ini bersifat infrastruktur yang dipakai seluruh modul lain. Tidak dihitung sebagai salah satu dari
5 modul penilaian per anggota, namun wajib ada agar aplikasi utuh secara fungsional dan setiap
anggota tetap harus memahami cara modulnya terintegrasi dengan sesi pengguna yang login.
• FR-A01: Pengguna dapat mendaftar akun baru menggunakan Nomor Induk Mahasiswa
(NIM), email kampus, dan kata sandi.
• FR-A02: Pengguna dapat login dan logout menggunakan email/NIM dan kata sandi, dengan
sesi diamankan menggunakan JSON Web Token (JWT).
• FR-A03: Pengguna dapat melihat dan menyunting profil pribadi (nama, foto profil
menggunakan kamera/image_picker, nomor telepon) serta mengganti kata sandi.
• FR-A04: Pengguna dapat melihat ringkasan profil publik mitra transaksi, mencakup skor
reputasi dan riwayat ulasan yang diambil dari data Modul 4 (Rating & Ulasan).
Modul 1: Manajemen Listing & QA Fisik Barang — Naufal Baihaqi Zachwan (2411522025)
• FR-01: Pengguna dapat membuat (Create), melihat katalog dan rincian (Read), menyunting
informasi harga dan deskripsi (Update), serta menghapus (Delete) data listing barang bekas.
• FR-02: Sistem mewajibkan pengguna mengambil minimal 3 foto kondisi riil barang (tampak
depan, samping, dan detail cacat/minus) secara langsung melalui antarmuka kamera aplikasi
(hardware image_picker).
• FR-03: Pengguna dapat melakukan pencarian berbasis kata kunci serta menyaring katalog
barang berdasarkan multi-kategori akademik (Buku & Referensi, Furnitur Kos, Elektronik, Alat
Perkuliahan) dan batas harga.
• FR-04: Pengguna dapat mengelola status ketersediaan barang (Available, Reserved,
Completed, Archived) serta menandai kondisi fisik barang menggunakan skala kategori
terstandar (Baru/Sangat Baik/Baik/Cukup) yang diisi manual oleh penjual.
• FR-05 (Notifikasi): Sistem mengirimkan notifikasi lokal terjadwal (Listing Stale Alert)
kepada pemilik barang apabila listing belum mengalami pembaruan atau transaksi dalam kurun
waktu 14 hari sejak diunggah.
Modul 2: Eksplorasi Geospasial & Safe-Meet Point — Bayu Mutawakkil (2411522023)
• FR-06: Pengguna dapat melihat persebaran barang di sekitar kampus dan kos mahasiswa
melalui antarmuka peta digital interaktif (flutter_map).
• FR-07: Pengguna dapat memfilter daftar barang berdasarkan radius kedekatan geografis (< 1
km, 1–3 km, > 3 km) dari posisi GPS pengguna saat ini (hardware geolocator).
• FR-08: Pengguna dapat mengelola direktori titik temu aman kampus (Safe-Meet Point
Manager): penambahan usulan titik temu (Create), penelusuran direktori resmi (Read),
pengubahan catatan panduan (Update), dan penghapusan titik kustom pribadi (Delete).
• FR-09: Sistem menampilkan indikator jarak presisi dalam meter (formula Haversine) serta
menyediakan tombol integrasi cepat untuk membuka rute navigasi pada aplikasi peta eksternal
(Google Maps Intent).
• FR-10 (Notifikasi): Sistem mengirimkan notifikasi lokal terjadwal (Meeting Reminder Alert)
beberapa saat sebelum waktu pertemuan COD yang telah disepakati kedua pihak.
Modul 3: Sistem Barter & Penawaran Non-Tunai — Muhammad Habib (2411522024)
• FR-11: Pengguna dapat mengajukan tiket penawaran barter dengan memilih salah satu barang
miliknya yang berstatus aktif, dan wajib melampirkan minimal 1 foto kondisi terkini barang
tersebut yang diambil langsung melalui kamera aplikasi (hardware image_picker, mode
kamera) sebagai bukti kondisi pada saat penawaran diajukan.
• FR-12: Pengguna dapat mengelola tiket negosiasi barter (CRUD Barter Deal): pembuatan
tawaran (Create), melihat riwayat negosiasi (Read), mengajukan penyesuaian nominal selisih
tunai/cash top-up (Update), serta membatalkan/menolak tawaran (Delete).
• FR-13: Sistem secara otomatis mengunci (Asset Locking Engine) status kedua barang yang
disetujui menjadi Locked agar tidak dapat ditawar atau dibeli oleh pengguna lain selama proses
pertemuan tatap muka.
• FR-14: Sistem menerapkan mekanisme Dual-Confirmation: kedua pihak wajib menekan
tombol "Setuju & Kunci Kesepakatan" secara terpisah pada sesi akun masing-masing sebelum
status barter dapat dikunci final menjadi Locked.
• FR-15 (Notifikasi): Sistem mengirimkan notifikasi lokal (Barter Proposal Alert) secara instan
ketika akun pengguna menerima pengajuan tiket tukar barang baru dari mahasiswa lain.
Modul 4: Validasi Serah Terima Fisik & Rekam Jejak — Fadel Muhammad (2411522029)
• FR-16: Sistem menghasilkan token sesi transaksi terenkripsi berbasis waktu berbentuk kode
QR dinamis pada akun penjual saat waktu transaksi tiba.
• FR-17: Pengguna pembeli dapat memindai kode QR penjual menggunakan pemindai kamera
(hardware mobile_scanner) untuk memvalidasi serah terima barang secara instan di tempat.
• FR-18: Pengguna dapat memberikan penilaian rating bintang dan ulasan (Create), melihat
rekam jejak reputasi profil mitra (Read), menyunting tanggapan ulasan (Update), serta
menghapus ulasan (Delete).
• FR-19: Sistem menerbitkan bukti tanda terima digital (Digital Handover Receipt) yang
mencatat ringkasan verifikasi serah terima fisik ke dalam riwayat transaksi permanen.
• FR-20 (Notifikasi): Sistem memicu notifikasi lokal (Handover Success Alert) sesaat setelah
pemindaian kode QR berhasil divalidasi, disertai ajakan pengisian reputasi mitra transaksi.
Modul 5: Hibah Sosial Kampus & Donasi Perlengkapan Belajar — Muhammad Racha
Ardiwinata (2411522020)
• FR-21: Pengguna dapat mendaftarkan barang donasi gratis (Create) dengan wajib mengambil
minimal 1 foto kondisi riil barang secara langsung melalui kamera aplikasi (hardware
image_picker, mode kamera), menelusuri katalog hibah aktif (Read), memperbarui kuota atau
rincian deskripsi (Update), dan mengarsipkan postingan hibah (Delete).
• FR-22: Mahasiswa pemohon dapat mengajukan Formulir Klaim Terstruktur (Need-Based
Claim) yang terdiri atas kategori tingkat urgensi (Mendesak/Sedang/Rendah) dan justifikasi
akademik dalam bentuk teks (minimal 100 karakter) untuk ditinjau donatur.
• FR-23: Sistem menampilkan antrean klaim kepada donatur, dapat diurutkan berdasarkan
tingkat urgensi dan tanggal pengajuan, agar donatur dapat meninjau lebih cepat dan objektif.
• FR-24: Donatur dapat meninjau justifikasi pemohon, menyetujui penerima yang layak, dan
sistem secara otomatis menerbitkan tiket klaim digital (Digital Claim Pass) untuk pengambilan
barang.
• FR-25 (Notifikasi): Sistem mengirimkan notifikasi lokal (Donation Claim Approval Alert)
kepada pemohon saat pengajuan klaim hibahnya telah disetujui oleh donatur.
2.2 Non-functional Requirements
• NFR-01 (Performance): Halaman katalog barang, peta interaktif, dan riwayat transaksi harus
dapat dimuat dalam waktu ≤ 3 detik pada kondisi jaringan seluler normal.
• NFR-02 (Compatibility & Platform): Aplikasi harus dapat terpasang dan berjalan stabil pada
perangkat Android minimal versi 8.0 (API Level 26) hingga Android 14.
• NFR-03 (Usability & Design System): Seluruh screen dibangun dengan komponen
Flutter/Material Design 3 dan dapat ditampilkan tanpa overflow pada rentang layar 5,0–6,7 inci
dengan orientasi potret.
• NFR-04 (Security & Authentication): Sesi pengguna diamankan menggunakan JSON Web
Token (JWT) dengan masa berlaku maksimal 24 jam, kata sandi disimpan dalam bentuk hash,
dan payload token QR serah terima dienkripsi serta kadaluwarsa maksimal 5 menit sejak
diterbitkan.
• NFR-05 (Architectural Compliance — Non-Firebase): Sistem backend sepenuhnya
menggunakan RESTful API mandiri (Node.js/Express atau Laravel) dengan basis data
relasional (PostgreSQL atau MySQL) pada VPS mandiri; jumlah dependensi Firebase pada
pubspec.yaml dan pada konfigurasi backend harus nol, termasuk untuk media storage dan
autentikasi.
• NFR-06 (Reliability & Hardware Fault Tolerance): Seluruh skenario penolakan izin
Kamera dan GPS ditangani dengan dialog informatif dan aplikasi tetap berjalan; target nol
crash pada pengujian skenario izin ditolak, izin dicabut saat aplikasi berjalan, dan GPS
dinonaktifkan.
2.3 Core Features
No. Core Feature Purpose / Value
1 Multi-Angle Visual QA &
Smart Search
Menjamin transparansi fisik barang melalui
minimal 3 foto riil kamera aplikasi serta
mempermudah penemuan perlengkapan kuliah
melalui filter kategori akademik terstruktur.
2 Geospatial Proximity &
Campus Safe-Meet Points
Memudahkan pencarian barang dalam radius jalan
kaki serta menyediakan direktori titik kumpul
transaksi resmi kampus demi keamanan fisik
mahasiswa saat COD.
3 Interactive Barter Deals &
Dual-Confirmation
Agreement
Memfasilitasi pertukaran barang non-tunai
maupun penyesuaian selisih tunai (cash top-up),
dengan foto bukti kondisi barang dari kamera dan
mekanisme persetujuan eksplisit dua pihak untuk
mencegah klaim sepihak.
4 QR Handover Validation &
Digital Receipt
Memberikan kepastian validasi serah terima
transaksi secara instan di tempat menggunakan
pemindai QR serta menerbitkan bukti tanda terima
digital tanpa ketergantungan payment gateway.
5 Social Grant & Structured
Need Verification
Membantu penyaluran donasi perlengkapan
belajar secara gratis dan tepat sasaran melalui foto
kondisi barang dari kamera, formulir klaim
terstruktur (kategori urgensi + justifikasi teks),
serta tiket pengambilan digital (Digital Claim
Pass).
Modul Pendukung Autentikasi & Profil tidak dimasukkan sebagai Core Feature bernomor karena
sifatnya infrastruktur pendukung seluruh fitur di atas, bukan pembeda nilai produk (differentiator).
2.4 User Flow
Flow 0: Registrasi, Login & Manajemen Profil (Modul Pendukung)
• Pengguna baru membuka aplikasi → Menekan "Daftar Akun" → Mengisi NIM, email
kampus, dan kata sandi.
• Pengguna menekan "Masuk" → Login menggunakan email/NIM dan kata sandi → Sistem
menerbitkan sesi JWT.
• Pengguna membuka menu Profil → Menyunting nama, foto profil (ambil dari kamera), dan
nomor telepon.
• Pengguna membuka profil mitra transaksi di modul lain (mis. dari Barter Deal atau Handover)
→ Melihat skor reputasi dan riwayat ulasan mitra.
• Pengguna dapat menekan "Keluar" (Logout) kapan saja untuk mengakhiri sesi.
Flow 1: Pendaftaran & Listing Barang Bekas (Modul 1)
• Pengguna membuka aplikasi CampuShift (Open App) → Masuk ke Beranda (Home).
• Menekan tombol Tambah Barang (+) → Mengisi data barang dan memilih kategori akademik.
• Membuka kamera aplikasi → Mengambil 3 foto fisik riil barang (Depan, Samping,
Cacat/Minus).
• Pengguna memilih kategori kondisi fisik barang secara manual (Baru/Sangat
Baik/Baik/Cukup).
• Pengguna menekan Simpan Listing → Data barang tersimpan di Server Backend.
Flow 2: Eksplorasi Barang & Penentuan Safe-Meet Point (Modul 2)
• Pengguna membuka Beranda (Home) → Memilih tab Peta Geospasial atau menerapkan filter
radius (< 1 km).
• Memilih barang yang diminati → Meninjau rincian kondisi barang berdasarkan 3 sudut foto.
• Menekan tombol "Ajukan Pertemuan COD" → Memilih lokasi Safe-Meet Point resmi kampus
dan menyepakati waktu pertemuan.
• Sistem menampilkan jarak presisi dari lokasi pengguna ke titik temu → Menyediakan opsi
navigasi Google Maps.
• Menjelang waktu pertemuan yang disepakati → Aplikasi mengirimkan notifikasi Meeting
Reminder Alert kepada kedua pihak.
Flow 3: Pengajuan & Negosiasi Barter dengan Dual-Confirmation (Modul 3)
• Pengguna membuka Rincian Barang Incaran → Menekan opsi "Tukar Guling (Barter)".
• Memilih barang aktif milik sendiri dari Katalog → Menentukan penyesuaian selisih nominal
(Cash Top-Up).
• Menekan Kirim Tiket Barter → Pemilik menerima notifikasi Barter Proposal Alert.
• Kedua pihak melakukan negosiasi hingga mencapai kesepakatan.
• Kedua pihak menekan tombol "Setuju & Kunci Kesepakatan" secara terpisah pada akun
masing-masing (Dual-Confirmation).
• Setelah kedua konfirmasi diterima → Status kedua barang menjadi Locked.
Flow 4: Validasi Serah Terima QR di Lokasi & Ulasan (Modul 4)
• Kedua pengguna bertemu di Safe-Meet Point Kampus.
• Penjual menampilkan Kode QR Handover Dinamis yang terenkripsi.
• Pembeli membuka Pemindai QR pada aplikasi → Memindai kode QR dari ponsel penjual.
• Server memverifikasi validitas token → Notifikasi Handover Success Alert aktif pada kedua
perangkat.
• Status transaksi berubah menjadi Completed → Tanda Terima Digital diterbitkan.
• Pengguna diarahkan ke Formulir Rating Reputasi.
Flow 5: Pengajuan Donasi Hibah Perlengkapan Belajar (Modul 5)
• Mahasiswa pemohon membuka Modul Hibah Sosial → Memilih perlengkapan belajar yang
dibutuhkan.
• Menekan "Ajukan Klaim Hibah" → Memilih kategori urgensi dan mengisi justifikasi
akademik dalam bentuk teks.
• Menekan Kirim Pengajuan → Klaim masuk ke antrean donatur, terurut berdasarkan urgensi
dan tanggal.
• Donatur meninjau daftar pengajuan beserta justifikasi teks pemohon.
• Donatur menyetujui pemohon yang dinilai layak.
• Pemohon menerima Donation Claim Approval Alert → Aplikasi menampilkan Tiket Klaim
Digital (Digital Claim Pass).
2.5 Data Requirements
Data / Entity Key Information Purpose
Users User ID, Nama Lengkap, NIM, Email
Kampus, Kata Sandi (Hash), Foto Profil
(URL), Nomor Telepon, Skor Reputasi,
Tanggal Bergabung.
Mengelola identitas
civitas akademika,
autentikasi sesi JWT, data
profil, serta akumulasi
reputasi transaksi.
Items /
Listings
Item ID, User ID (Pemilik), Judul Barang,
Kategori Akademik, Harga Jual, Kategori
Kondisi Fisik (Baru/Sangat
Baik/Baik/Cukup), URL 3 Foto Multi-Sudut,
Status Barang
(Available/Reserved/Completed/Archived),
Koordinat Lokasi (Lat, Long).
Menyimpan katalog
barang jual-beli dan data
koordinat untuk
visualisasi geospasial.
Safe-Meet
Points
Point ID, Nama Titik Pertemuan, Kategori
Lokasi (Pos Satpam, Gedung Pusat,
Perpustakaan), Koordinat (Lat, Long),
Deskripsi Panduan Keamanan, Tipe
(Official/User-Custom).
Menyimpan direktori
lokasi titik temu
pertemuan fisik resmi
kampus yang aman untuk
transaksi COD.
Barter Deals Deal ID, Sender Item ID, Receiver Item ID,
Sender User ID, Receiver User ID, Selisih
Tunai (Cash Top-Up), URL Foto Bukti
Kondisi Barang, Status Penawaran
(Pending/Negotiating/Accepted/Rejected/Lo
cked), Sender Confirmed (bool), Receiver
Confirmed (bool), Timestamp.
Mencatat riwayat
transaksi tukar guling
non-tunai dan mengontrol
mekanisme
dual-confirmation serta
penguncian aset.
Handover
Tokens
Handover ID, Transaction ID, Encrypted
Token Payload, Issued Timestamp, Expiry
Timestamp, Status Verifikasi
(Pending/Verified/Expired).
Mengamankan proses
otentikasi serah terima
tatap muka melalui kode
QR dinamis berbatas
waktu.
Reviews &
Ratings
Review ID, Transaction ID, Reviewer User
ID, Reviewed User ID, Rating Bintang
(1–5), Teks Komentar Ulasan, Tanggapan
Pemilik, Timestamp.
Menyimpan rekam jejak
ulasan dan menjadi
sumber perhitungan skor
reputasi yang ditampilkan
pada profil (FR-A04).
Social Grants
& Claims
Grant ID, Donatur User ID, Nama Barang
Donasi, Kategori Akademik, URL Foto
Barang Donasi, Status Ketersediaan, Claim
ID, Pemohon User ID, Kategori Urgensi,
Teks Justifikasi Akademik, Status
Mengelola pendaftaran
barang hibah gratis,
permohonan klaim
mahasiswa, dan bukti tiket
pengambilan digital.
Persetujuan (Pending/Approved/Rejected),
Digital Claim Pass Code.
2.6 Constraints & Assumptions
• Batasan Platform & Framework: Aplikasi dikembangkan secara eksklusif menggunakan
Flutter SDK untuk sistem operasi Android (minimal Android 8.0 / API Level 26 hingga
Android 14).
• Batasan Backend & Larangan Firebase: Seluruh logika penyimpanan data relasional dan
berkas media, termasuk data akun dan sesi autentikasi, wajib dikelola oleh server RESTful API
mandiri (Node.js/Laravel + PostgreSQL/MySQL pada VPS). Layanan Firebase (termasuk
Firebase Authentication) dilarang digunakan.
• Batasan Notifikasi: Notifikasi dikirimkan secara lokal pada perangkat menggunakan pustaka
flutter_local_notifications tanpa ketergantungan layanan Firebase Cloud Messaging (FCM).
• Batasan Sensor Hardware: Perangkat pengujian wajib memiliki modul fungsional Kamera
dan sensor GPS yang aktif dan berfungsi normal. Tidak ada sensor lain (biometrik/mikrofon)
yang diwajibkan pada versi ini.
• Asumsi Operasional: Pengguna diasumsikan merupakan civitas akademika aktif yang
terhubung ke jaringan internet kampus/seluler saat melakukan sinkronisasi data transaksi dan
pemuatan peta digital.
• Batasan Kepemilikan Modul Pendukung: Modul Autentikasi & Profil dikerjakan bersama
oleh tim di awal sprint sebagai fondasi, dan tidak dihitung sebagai salah satu dari 5 modul
penilaian individu.
2.7 Success Criteria
• Fungsionalitas Mandiri 100% Berjalan: Kelima modul fungsional utama berhasil
diimplementasikan lengkap dengan operasi CRUD, integrasi hardware yang relevan, dan
notifikasi lokal masing-masing tanpa unhandled exceptions.
• Fondasi Autentikasi Berfungsi Penuh: Registrasi, login, logout, dan edit profil berjalan
lancar serta menjadi prasyarat akses ke seluruh modul lain.
• Kepatuhan Aturan Non-Firebase: Tidak terdapat dependensi Firebase sama sekali dalam
skema basis data, konfigurasi proyek (pubspec.yaml), maupun arsitektur backend, termasuk
untuk autentikasi.
• Kecepatan Validasi Serah Terima QR: Kode QR dinamis berhasil diverifikasi oleh pemindai
dalam waktu < 2 detik pada kondisi pencahayaan normal.
• Tingkat Keamanan Transaksi: Seluruh transaksi serah terima terotentikasi melalui kode QR
dinamis, dan kesepakatan barter terlindungi oleh mekanisme dual-confirmation dua pihak
beserta penguncian status barang di server.
• Kesiapan Evaluasi Teknis: Setiap anggota tim mampu mendemonstrasikan fitur dan
menjelaskan kode modul tanggung jawabnya secara mandiri pada sesi code review.
3. Scope
3.1 In Scope
• Modul Pendukung Autentikasi & Manajemen Profil (registrasi, login/logout, edit profil, lihat
reputasi mitra) sebagai fondasi seluruh aplikasi.
• Pengembangan 5 modul fungsional aplikasi mobile menggunakan Flutter SDK (Manajemen
Listing & QA, Geospasial & Safe-Meet Point, Sistem Barter Non-Tunai, Validasi Serah Terima
QR, serta Hibah Sosial & Donasi Belajar).
• Pembuatan antarmuka pengguna interaktif, responsif, dan konsisten berbasis Material Design
3.
• Integrasi 2 fitur hardware native Android pada seluruh modul: Kamera (image_picker untuk
foto listing, foto penawaran barter, foto barang donasi, dan foto profil; mobile_scanner untuk
pindai QR) dan GPS (geolocator + flutter_map).
• Pemicuan notifikasi lokal mandiri pada setiap modul menggunakan pustaka
flutter_local_notifications.
• Pembangunan backend RESTful API mandiri berbasis Node.js atau Laravel serta basis data
relasional PostgreSQL/MySQL pada VPS non-Firebase, termasuk endpoint autentikasi.
• Penerbitan bukti tanda terima digital (Digital Handover Receipt) dan tiket klaim pengambilan
donasi (Digital Claim Pass).
• Pencatatan riwayat bantuan kecerdasan buatan (AI Usage Log) secara transparan untuk setiap
anggota tim.
3.2 Out of Scope
• Integrasi payment gateway pihak ketiga (transaksi diselesaikan secara langsung saat tatap
muka di Safe-Meet Point atau melalui barter non-tunai).
• Layanan kurir ekspedisi logistik pengantaran barang eksternal (proses serah terima dilakukan
mandiri oleh mahasiswa di dalam lingkungan kampus).
• Pengembangan aplikasi untuk platform iOS atau Web (fokus pengembangan dan pengujian
pada sistem operasi Android).
• Penggunaan layanan cloud database Firebase (Firestore / Firebase Realtime Database /
Firebase Authentication).
• Fitur perpesanan instan bertingkat (real-time chat) yang kompleks (komunikasi difokuskan
pada tiket transaksi, barter deal, dan koordinasi Safe-Meet Point).
• Verifikasi biometrik lintas pengguna dan perekaman suara (voice note) — digantikan dengan
mekanisme dual-confirmation dan formulir teks terstruktur.
• Login sosial pihak ketiga (Google Sign-In, Sign in with Apple) — autentikasi dibatasi pada
email/NIM kampus dan kata sandi untuk menyederhanakan lingkup backend.
4. AI Prompt Context
Saya sedang mengembangkan aplikasi mobile bernama "CampuShift" untuk tugas mata kuliah Mobile
Programming (tim 5 orang). Aplikasi ini adalah platform ekonomi sirkular kampus & barter berbasis
Flutter yang mendukung SDG 12.
Aplikasi memiliki 1 modul pendukung (dikerjakan bersama tim) dan 5 modul utama yang
masing-masing dipegang oleh 1 mahasiswa:
• Modul Pendukung: Autentikasi & Manajemen Profil (registrasi/login JWT, edit profil dengan
foto dari kamera, ringkasan reputasi mitra) — tanggung jawab bersama, bukan modul penilaian
individu.
• Modul 1: Manajemen Listing & QA Fisik (Kamera image_picker, pencarian multi-kategori,
notifikasi Listing Stale Alert, CRUD barang, penandaan kondisi fisik manual).
• Modul 2: Geospasial & Safe-Meet Point (GPS geolocator & flutter_map, formula Haversine
jarak presisi, integrasi peta eksternal, notifikasi Meeting Reminder Alert terjadwal, CRUD titik
temu).
• Modul 3: Sistem Barter Non-Tunai (foto bukti kondisi barang dari kamera saat penawaran
diajukan, mekanisme dual-confirmation dua pihak untuk otorisasi deal, notifikasi Barter
Proposal Alert, CRUD barter & cash top-up, Asset Locking).
• Modul 4: Validasi Serah Terima Fisik (Scanner QR mobile_scanner, token dinamis, ulasan
reputasi, bukti tanda terima digital, notifikasi Handover Success).
• Modul 5: Hibah Sosial Kampus (foto barang donasi dari kamera saat pendaftaran hibah,
formulir klaim terstruktur berbasis kategori urgensi & teks justifikasi, tiket klaim digital,
notifikasi Donation Claim Approval, CRUD hibah).
Batasan Teknis Mutlak
• Framework: Flutter SDK (Android target).
• Backend: RESTful API mandiri (Node.js/Laravel) + database relasional
(PostgreSQL/MySQL) di VPS, termasuk autentikasi JWT sendiri (bukan Firebase Auth).
• Dilarang menggunakan Firebase (baik database, storage, maupun authentication).
• Notifikasi: pustaka lokal flutter_local_notifications (bukan FCM).
• Sensor hardware dibatasi hanya Kamera dan GPS — tidak menggunakan biometrik atau
mikrofon.
Instruksi kepada AI
Bantu saya merancang arsitektur kode/model/service sesuai modul saya, termasuk cara modul saya
mengonsumsi sesi login dari Modul Pendukung Autentikasi, dengan kode yang bersih, modular, dapat
diuji secara mandiri, dan mudah saya jelaskan saat sesi code review teknis.
PRD Checklist
☑ Problem statement jelas dan berfokus pada pengguna.
☑ Target users spesifik.
☑ Project goal menjawab masalah yang diidentifikasi.
☑ Core features berjumlah sekitar 4–6 dan relevan.
☑ User flow utama sudah dituliskan.
☑ Data utama sudah diidentifikasi.
☑ Constraints dan assumptions sudah dicatat.
☑ Success criteria dapat digunakan untuk menilai hasil project.
☑ In Scope dan Out of Scope sudah jelas.
☑ Functional requirements menjelaskan perilaku/fungsi yang harus dilakukan aplikasi.
☑ Non-functional requirements menjelaskan kualitas atau batasan sistem dan, jika memungkinkan,
dapat diukur.
☑ Functional requirements konsisten dengan core features.
☑ Non-functional requirements tidak ditulis sebagai fitur baru.