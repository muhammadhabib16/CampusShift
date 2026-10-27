# Dokumentasi Komponen Bersama CampuShift

Dokumen ini memuat katalog lengkap komponen UI bersama (*shared widgets*) yang telah distandarkan di dalam direktori `lib/shared/widgets/` untuk seluruh modul aplikasi CampuShift (Android 8.0–14, Material Design 3).

---

## 1. Tombol (Buttons) — `buttons.dart`

### 1.1 `AppPrimaryButton`
Tombol aksi utama aplikasi dengan tinggi standar 52 dp, lebar penuh (atau fleksibel), efek ripple Material 3, proteksi ketukan ganda (*prevent double tap*), dan status pemuatan (*loading state* dengan spinner terintegrasi).

- **Lokasi File:** `lib/shared/widgets/buttons.dart`
- **Tinggi:** 52 dp
- **Warna Latar:** `AppColors.primary` (`#0F766E`)
- **Warna Teks/Ikon:** `AppColors.onPrimary` (`#FFFFFF`)
- **Radius:** 12 dp (`AppRadius.medium`)

#### Parameter:
| Nama | Tipe | Default | Keterangan |
|---|---|---|---|
| `label` | `String` | Wajib | Teks label tombol (kata kerja ringkas) |
| `onPressed` | `VoidCallback?` | Wajib | Fungsi callback saat ditekan. Bernilai `null` untuk menonaktifkan tombol |
| `icon` | `IconData?` | `null` | Ikon opsional di sebelah kiri label |
| `isLoading` | `bool` | `false` | Menampilkan spinner loading dan mengunci tombol dari penekanan berulang |
| `isFullWidth` | `bool` | `true` | Apakah tombol merentang selebar layar |

#### Contoh Pemakaian:
```dart
AppPrimaryButton(
  label: 'Ajukan Pertemuan COD',
  icon: Icons.calendar_month_rounded,
  isLoading: vm.isLoading,
  onPressed: vm.isValid ? () => vm.submit() : null,
)
```

---

### 1.2 `AppSecondaryButton`
Tombol aksi sekunder berbingkai (*outlined*) atau varian aksi destruktif (misal: "Batalkan Sesi QR", "Tolak Pengajuan").

- **Warna Normal:** Teks & border `AppColors.primary` (`#0F766E`), latar transparan
- **Warna Destruktif (`isDestructive: true`):** Teks & border `AppColors.error` (`#DC2626`)
- **Tinggi:** 52 dp (atau 44 dp compact)

#### Contoh Pemakaian:
```dart
AppSecondaryButton(
  label: 'Batalkan Sesi QR',
  icon: Icons.cancel_outlined,
  isDestructive: true,
  onPressed: () => _confirmCancel(),
)
```

---

### 1.3 `AppTextButton`
Tombol teks tanpa border untuk aksi pendukung dengan area sentuh minimal 48 dp (aksesibilitas WCAG).

#### Contoh Pemakaian:
```dart
AppTextButton(
  label: 'Lihat Selengkapnya',
  icon: Icons.arrow_forward_rounded,
  onPressed: () => _openDetails(),
)
```

---

## 2. Formulir Input (Text Field) — `text_field.dart`

### 2.1 `AppTextField`
Komponen input teks tunggal yang menyatukan label terpisah di atas, teks pembantu (*helper*), pesan validasi error, ikon awalan/akhiran, dan penghitung karakter otomatis (wajib untuk judul max 80, deskripsi max 1.000, justifikasi klaim 100–1.000 karakter sesuai BR-01, BR-27, AC-27).

- **Latar Kolom:** `AppColors.surfaceVariant` (`#F1F5F9`)
- **Border:** `AppColors.outline` (`#E2E8F0`), fokus `AppColors.primary`
- **Radius:** 12 dp (`AppRadius.medium`)

#### Parameter:
| Nama | Tipe | Default | Keterangan |
|---|---|---|---|
| `label` | `String` | Wajib | Label jelas di atas kolom |
| `hintText` | `String?` | `null` | Placeholder petunjuk pengisian |
| `controller` | `TextEditingController?` | `null` | Kontroler teks |
| `maxLength` | `int?` | `null` | Batas maksimum karakter |
| `maxLines` | `int` | `1` | Jumlah baris input (misal: 4 untuk deskripsi) |
| `showCounter` | `bool` | `false` | Menampilkan penghitung karakter "X/Max" |
| `prefixIcon` | `Widget?` | `null` | Ikon awal kolom |
| `suffixIcon` | `Widget?` | `null` | Ikon akhir kolom (misal: tombol intip sandi) |

#### Contoh Pemakaian:
```dart
AppTextField(
  label: 'Justifikasi Akademik',
  hintText: 'Jelaskan kebutuhan perkuliahan Anda secara objektif...',
  controller: _justificationController,
  maxLines: 4,
  maxLength: 1000,
  showCounter: true,
  helperText: 'Minimal 100 karakter untuk mengajukan klaim.',
)
```

---

## 3. Kartu (Card) — `card.dart`

### 3.1 `AppCard`
Wadah konten standar berbentuk rounded card dengan latar putih, border tipis `outline`, bayangan halus (*soft elevation* blur 12, opacity 6%), serta efek ripple penekanan.

- **Latar:** `AppColors.surface` (`#FFFFFF`)
- **Border:** 1 dp solid `AppColors.outline` (`#E2E8F0`)
- **Radius:** 16 dp (`AppRadius.large`)
- **Shadow:** `AppElevation.softShadow`

#### Contoh Pemakaian:
```dart
AppCard(
  padding: const EdgeInsets.all(AppSpacing.md),
  onTap: () => Navigator.push(...),
  child: Column(
    children: [
      Text('Judul Barang', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: AppSpacing.sm),
      PriceTag(price: 55000),
    ],
  ),
)
```

---

## 4. Status Badge & Tag Harga — `badge.dart`

### 4.1 `StatusBadge`
Komponen tunggal untuk seluruh modul yang menampilkan status transaksi dan barang dengan warna teks kontras tinggi, latar pastel lembut, serta ikon semantik yang sesuai dengan Pemetaan Terpusat PRD Bagian 2.2.

| Status String | Label Tampilan | Teks | Latar | Ikon |
|---|---|---|---|---|
| `Available` | Tersedia | `#15803D` | `#DCFCE7` | `check_circle_outline` |
| `Reserved` | Dalam Kesepakatan | `#B45309` | `#FEF3C7` | `handshake_outlined` |
| `Completed` | Selesai | `#1D4ED8` | `#DBEAFE` | `verified_outlined` |
| `Archived` | Diarsipkan | `#475569` | `#F1F5F9` | `inventory_2_outlined` |
| `Cancelled` / `Dibatalkan` | Dibatalkan | `#475569` | `#F1F5F9` | `cancel_outlined` |
| `Rejected` / `Ditolak` | Ditolak | `#B91C1C` | `#FEE2E2` | `block` |
| `Pending` / `Diajukan` | Menunggu | `#6D28D9` | `#EDE9FE` | `schedule` |
| `Negotiating` | Negosiasi | `#6D28D9` | `#EDE9FE` | `forum_outlined` |
| `Locked` / `Dikonfirmasi` | Dikonfirmasi | `#0F766E` | `#CCFBF1` | `lock_outline` |

#### Contoh Pemakaian:
```dart
StatusBadge(status: 'Dikonfirmasi')
```

---

### 4.2 `PriceTag`
Format harga konsisten berawalan `Rp` dengan titik ribuan (misal: `Rp55.000`) atau badge khusus "Gratis (Hibah)" berlatar accent lembut (`#FEF3C7` / `#B45309`).

#### Contoh Pemakaian:
```dart
// Untuk barang jual biasa / COD
PriceTag(price: 120000)

// Untuk barang hibah sosial
PriceTag(price: 0, isGrant: true)
```

---

## 5. Keadaan Layar (States) — `states.dart`

Setiap layar utama wajib memiliki penanganan 3 kondisi sesuai PRD 2.10: **Memuat (Loading)**, **Kosong (Empty)**, dan **Galat (Error)**.

### 5.1 `EmptyState`
Ikon besar di dalam lingkaran `primaryContainer`, judul, deskripsi informatif, dan tombol aksi opsional.

```dart
EmptyState(
  icon: Icons.inventory_2_outlined,
  title: 'Belum Ada Barang Listing',
  description: 'Mulai tawarkan perlengkapan kuliah bekas Anda kepada rekan kampus.',
  actionLabel: 'Tambah Listing',
  onAction: () => _navigateToAdd(),
)
```

### 5.2 `ErrorState`
Tampilan galat ramah pengguna dengan tombol "Coba Lagi" terintegrasi untuk aksi pemulihan jaringan.

```dart
ErrorState(
  title: 'Koneksi Terputus',
  message: 'Tidak dapat terhubung ke server. Silakan periksa koneksi internet Anda.',
  onRetry: () => vm.fetchData(),
)
```

### 5.3 `LoadingState` & `ShimmerBox`
Indikator pemuatan standar Material 3 dengan warna `primary` dan pesan status yang jelas.

```dart
LoadingState(label: 'Memuat data transaksi…')
```

---

## 6. Umpan Balik & Dialog — `dialogs.dart`

### 6.1 `AppSnackBar`
Pemberitahuan mengambang (*floating*) dengan ikon dan palet warna pastel kontras:
- `AppSnackBar.showSuccess(context, 'Data berhasil disimpan')` (Latar hijau lembut `#DCFCE7`, teks `#15803D`)
- `AppSnackBar.showError(context, 'Terjadi kesalahan')` (Latar merah lembut `#FEE2E2`, teks `#B91C1C`)
- `AppSnackBar.showInfo(context, 'Informasi terbaru')` (Latar teal lembut `#CCFBF1`, teks `#0F766E`)

### 6.2 `showConfirmDialog`
Dialog konfirmasi aksi destruktif atau penting (Hapus, Batalkan, Keluar Akun, Setujui):
- Hapus/Batal permanen: Tombol merah dengan ikon tong sampah / peringatan.
- Aksi netral: Tombol abu-abu/teal dengan ikon batal netral.

#### Contoh Pemakaian:
```dart
final confirmed = await showConfirmDialog(
  context,
  title: 'Hapus Listing Barang?',
  message: 'Listing barang ini akan dihapus secara permanen dan tidak dapat dipulihkan kembali.',
  confirmLabel: 'Ya, Hapus',
  cancelLabel: 'Batal',
  destructive: true,
  confirmIcon: Icons.delete_outline_rounded,
);
```

---

## 7. Identitas Pengguna & Reputasi — `user_avatar.dart`

### 7.1 `AvatarWithName`
Foto profil lingkaran atau inisial nama otomatis berlatar `primaryContainer` dengan teks nama dan subjudul identitas (NIM/Fakultas).

```dart
AvatarWithName(
  name: 'Bayu Mutawakkil',
  subtitle: 'NIM: 2411522023 • Universitas Andalas',
  radius: 24,
)
```

### 7.2 `RatingStars`
Bintang reputasi dengan skor desimal bahasa Indonesia (koma) dan jumlah ulasan:
- Mode Tampilan: `RatingStars(rating: 4.8, reviewCount: 15)` $\rightarrow$ menampilkan `★ 4,8 (15 ulasan)`
- Mode Interaktif: `RatingStars(rating: rating, interactive: true, onRatingChanged: (val) => ...)`

---

## 8. Banner Alur & Navigasi — `banners.dart`

### 8.1 `StepBanner`
Banner panduan alur transaksi "Langkah X dari Y" dengan latar `primaryContainer` dan ikon highlight `accent`, memastikan pengguna selalu memahami tahapan transaksi berikutnya.

```dart
StepBanner(
  title: 'Langkah 2: Tentukan Jadwal COD',
  description: 'Pilih titik temu aman resmi kampus dan atur waktu pertemuan minimal 1 jam dari sekarang.',
  stepNumber: 2,
)
```

### 8.2 `SectionHeader`
Judul seksi konten dengan opsi tombol aksi di sebelah kanan.

```dart
SectionHeader(
  title: 'Rekomendasi Barang',
  actionLabel: 'Lihat Semua',
  onAction: () => _openCatalog(),
)
```

---

## 9. Pemilih Foto — `photo_picker.dart`

### 9.1 `PhotoPickerGrid`
Grid pemilih foto kamera/galeri untuk listing barang dengan aturan BR-01 & BR-03 (minimal 2 foto, maksimal 3 foto) lengkap dengan badge kuota dan thumbnail preview.

```dart
PhotoPickerGrid(
  images: _selectedImages,
  onAddImage: () => _pickImage(),
  onRemoveImage: (index) => _removeImage(index),
)
```

---

## 10. Helper Format Bahasa & Angka — `lib/utils/formatters.dart`

| Helper | Input | Output Contoh | Keterangan |
|---|---|---|---|
| `formatRupiah(int)` | `55000` | `Rp55.000` | Awalan Rp, pemisah ribuan titik |
| `formatJarak(double?)` | `450.0` | `450 m` | < 1.000 dalam meter |
| `formatJarak(double?)` | `1500.0` | `1,5 km` | $\ge$ 1.000 dalam km desimal koma |
| `formatJarak(null)` | `null` | `—` | Lokasi tidak tersedia (BR-11) |
| `formatTanggalWib(DateTime)` | `DateTime` | `28 Okt 2026, 14.30 WIB` | Format waktu resmi WIB |
| `formatWaktuRelatif(DateTime)` | `DateTime` | `5 menit lalu` / `Besok, 13.00 WIB` | Relatif interaktif |
| `formatSkor(double?, int?)` | `4.5, 12` | `4,5 (12 ulasan)` | Desimal koma Indonesia |
