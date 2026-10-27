import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static const String productionUrl =
      'https://campusshift-api.habibdev.site/api';

  // UBAH: Sesuaikan port menjadi 3000 sesuai terminal backend Anda
  static String get localUrl =>
      kIsWeb ? 'http://127.0.0.1:3000/api' : 'http://10.0.2.2:3000/api';

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;

    // Menggunakan backend production online (milik Habib)
    return productionUrl;
  }
}
