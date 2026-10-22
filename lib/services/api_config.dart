import 'package:flutter/foundation.dart' show kIsWeb;

/// Alamat backend `be-campusshift` yang dipakai semua modul.
///
/// Semua service membangun URL dari [baseUrl], jadi alamat cukup diubah di
/// sini. Default mengikuti `PORT=5000` di `.env` backend:
/// - Flutter Web (Chrome): akses langsung ke localhost PC.
/// - Android Emulator: gunakan 10.0.2.2 (loopback ke host PC).
/// - Android Fisik (USB): jalankan `adb reverse tcp:5000 tcp:5000` terlebih dahulu.
///
/// Alamat lain (misalnya Docker lewat Nginx di port 8081) dapat dipilih tanpa
/// mengubah kode:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081/api`
class ApiConfig {
  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// URL backend publik di homeserver (Cloudflare Tunnel)
  static const String productionUrl =
      'https://campusshift-api.habibdev.site/api';

  /// URL backend lokal untuk pengujian di komputer sendiri
  static String get localUrl =>
      kIsWeb ? 'http://127.0.0.1:5000/api' : 'http://10.0.2.2:5000/api';

  static String get baseUrl {
    // 1. Prioritaskan jika dioper via flag `--dart-define=API_BASE_URL=...`
    if (_override.isNotEmpty) return _override;

    // 2. Default: menggunakan server homeserver yang aktif
    return productionUrl;

    // Catatan: Jika ingin kembali menggunakan backend lokal di PC,
    // ubah baris di atas menjadi: return localUrl;
  }
}
