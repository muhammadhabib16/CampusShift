import 'api_client.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// Titik akses tunggal ke backend `be-campusshift` untuk semua modul.
///
/// Pola yang dipakai service:
/// - [isOnline] true (pengguna login, ada JWT) → data dibaca/ditulis ke server.
/// - [isOnline] false (belum login / mode uji) → service memakai data contoh
///   lokal agar demo dan widget test tetap berjalan tanpa server.
class Backend {
  Backend._();

  static final ApiClient client = ApiClient(
    baseUrl: ApiConfig.baseUrl,
    getToken: token,
  );

  /// JWT tersimpan. Aman dipanggil di lingkungan test (plugin
  /// SharedPreferences tidak tersedia) — mengembalikan null.
  static Future<String?> token() async {
    try {
      return await AuthService.getToken();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isOnline() async {
    final t = await token();
    return t != null && t.isNotEmpty;
  }

  /// Isi `data` sebagai list of map.
  static List<Map<String, dynamic>> list(dynamic body) {
    final data = ApiClient.unwrap(body);
    if (data is! List) return const [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Isi `data` sebagai map.
  static Map<String, dynamic> map(dynamic body) {
    final data = ApiClient.unwrap(body);
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }

  static int toInt(dynamic v, [int fallback = 0]) =>
      v is int ? v : int.tryParse('${v ?? ''}') ?? fallback;

  static DateTime toLocalTime(dynamic v) =>
      (DateTime.tryParse('${v ?? ''}') ?? DateTime.now()).toLocal();
}
