/// Teks terpusat CampuShift (Section 7 PRD).
abstract final class AppStrings {
  // Aksi Tombol Umum
  static const save = 'Simpan';
  static const cancel = 'Batal';
  static const delete = 'Hapus';
  static const retry = 'Coba Lagi';
  static const back = 'Kembali';
  static const next = 'Lanjut';
  static const start = 'Mulai';
  static const send = 'Kirim';
  static const agree = 'Setuju';
  static const confirm = 'Konfirmasi';
  static const close = 'Tutup';
  static const search = 'Cari';
  static const seeAll = 'Lihat Semua';
  static const skip = 'Lewati';

  // Istilah Glosarium PRD
  static const listing = 'Listing';
  static const cashTopUp = 'Cash Top-Up';
  static const safeMeetPoint = 'Safe-Meet Point';
  static const meetup = 'Pertemuan';
  static const barter = 'Barter';
  static const hibah = 'Hibah';
  static const cod = 'Jual (COD)';

  // Pesan Error & Jaringan (PRD 2.10)
  static const generalConnectionError =
      'Tidak dapat terhubung ke server. Silakan coba lagi.';
  static const timeoutError =
      'Koneksi melebihi batas waktu (15 detik). Periksa jaringan Anda.';
  static const locationPermissionDenied =
      'Izin lokasi diperlukan untuk menghitung jarak ke titik temu.';
  static const cameraPermissionDenied =
      'Izin kamera diperlukan untuk memindai kode QR serah terima.';
  static const openSettings = 'Buka Pengaturan';

  // Empty States
  static const emptyListingTitle = 'Belum Ada Barang';
  static const emptyListingDesc =
      'Jadilah yang pertama menambahkan barang di katalog!';
  static const emptyBarterTitle = 'Belum Ada Tawaran Barter';
  static const emptyBarterDesc =
      'Mulai ajukan tawaran barter pada barang yang kamu minati.';
  static const emptyGrantTitle = 'Belum Ada Hibah';
  static const emptyGrantDesc =
      'Belum ada barang hibah yang dibagikan saat ini.';
  static const emptyMeetupTitle = 'Belum Ada Jadwal';
  static const emptyMeetupDesc =
      'Jadwal pertemuan COD atau barter akan muncul di sini.';
}
