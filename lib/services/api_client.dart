import 'dart:convert';
import 'package:http/http.dart' as http;

/// Klien HTTP dasar untuk Modul 5 (Hibah Sosial).
///
/// Sengaja TIDAK bergantung langsung ke kelas AuthViewModel milik Modul
/// Pendukung — hanya menerima fungsi `getToken`. Ini supaya coupling antar
/// modul tetap rendah sesuai TEAM_GUIDELINES.md #3 (Aturan Modul & Low
/// Coupling): saat main.dart merangkai provider, cukup teruskan
/// `() => context.read<AuthViewModel>().token`.
///
/// Jika tim sudah punya ApiClient bersama dari Modul Pendukung, cukup pakai
/// itu — file ini contoh minimal kalau belum ada.
class ApiClient {
  ApiClient({required this.baseUrl, required this.getToken});

  final String baseUrl;
  final String? Function() getToken;

  Map<String, String> get _headers {
    final token = getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: _headers);
    return _handle(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await http.post(Uri.parse('$baseUrl$path'),
        headers: _headers, body: jsonEncode(body));
    return _handle(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await http.put(Uri.parse('$baseUrl$path'),
        headers: _headers, body: body == null ? null : jsonEncode(body));
    return _handle(res);
  }

  /// Upload multipart khusus untuk field foto (FR-21: wajib foto dari kamera).
  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required String filePath,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    final headers = Map<String, String>.from(_headers)..remove('Content-Type');
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    // Dilempar sebagai Exception biasa supaya ViewModel bisa tangkap dengan
    // try-catch dan tampilkan SnackBar (TEAM_GUIDELINES.md #4).
    throw ApiException(res.statusCode, res.body);
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
