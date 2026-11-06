import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'connectivity_service.dart';

/// Klien HTTP dasar untuk Modul 5 (Hibah Sosial).
///
/// Sengaja TIDAK bergantung langsung ke kelas AuthViewModel milik Modul
/// Pendukung — hanya menerima fungsi `getToken`. Ini supaya coupling antar
/// modul tetap rendah sesuai TEAM_GUIDELINES.md #3 (Aturan Modul & Low
/// Coupling). Fungsi boleh async, misalnya `AuthService.getToken` yang membaca
/// JWT dari SharedPreferences.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.getToken,
    this.timeout = const Duration(seconds: 10),
  });

  final String baseUrl;
  final FutureOr<String?> Function() getToken;
  final Duration timeout;

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await getToken();
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    var uri = Uri.parse('$baseUrl$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, ...query});
    }
    final headers = await _headers();
    final res = await guardNetwork(
      () => http.get(uri, headers: headers).timeout(timeout),
    );
    return _handle(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final headers = await _headers();
    final res = await guardNetwork(
      () => http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: headers,
            body: jsonEncode(body ?? const {}),
          )
          .timeout(timeout),
    );
    return _handle(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final headers = await _headers();
    final res = await guardNetwork(
      () => http
          .put(
            Uri.parse('$baseUrl$path'),
            headers: headers,
            body: jsonEncode(body ?? const {}),
          )
          .timeout(timeout),
    );
    return _handle(res);
  }

  Future<dynamic> delete(String path, {Object? body}) async {
    final headers = await _headers();
    final res = await guardNetwork(
      () => http
          .delete(
            Uri.parse('$baseUrl$path'),
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout),
    );
    return _handle(res);
  }

  /// Menjalankan request HTTP dan mengubah kegagalan jaringan (tidak ada
  /// internet, DNS gagal, koneksi terputus, timeout) menjadi
  /// [NetworkException] dengan pesan yang ramah pengguna. Dipakai juga oleh
  /// service yang memanggil `http` langsung (mis. ItemService).
  static Future<T> guardNetwork<T>(Future<T> Function() request) async {
    try {
      final result = await request();
      ConnectivityService.instance.reportOnline();
      return result;
    } on TimeoutException {
      ConnectivityService.instance.reportNetworkFailure();
      throw NetworkException.timeout();
    } on SocketException {
      ConnectivityService.instance.reportNetworkFailure();
      throw NetworkException.offline();
    } on HandshakeException {
      ConnectivityService.instance.reportNetworkFailure();
      throw NetworkException.offline();
    } on http.ClientException {
      ConnectivityService.instance.reportNetworkFailure();
      throw NetworkException.offline();
    }
  }

  /// Upload multipart khusus untuk field foto (FR-21: wajib foto dari kamera).
  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required String filePath,
  }) => sendMultipart(
    'POST',
    path,
    fields: fields,
    fileField: fileField,
    filePath: filePath,
  );

  /// Request multipart dengan metode apa pun (mis. `PUT /users/me` untuk
  /// foto profil). [filePath] opsional: tanpa file hanya field yang dikirim.
  Future<dynamic> sendMultipart(
    String method,
    String path, {
    required Map<String, String> fields,
    String fileField = 'photo',
    String? filePath,
    Duration? timeout,
  }) async {
    final request = http.MultipartRequest(method, Uri.parse('$baseUrl$path'));
    request.headers.addAll(await _headers(json: false));
    request.fields.addAll(fields);
    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }
    final limit = timeout ?? this.timeout;
    final res = await guardNetwork(() async {
      final streamed = await request.send().timeout(limit);
      return http.Response.fromStream(streamed).timeout(limit);
    });
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    // Dilempar sebagai Exception supaya ViewModel bisa tangkap dengan
    // try-catch dan tampilkan SnackBar (TEAM_GUIDELINES.md #4).
    throw ApiException(res.statusCode, _extractMessage(res.body));
  }

  static String _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}
    return body.isEmpty ? 'Terjadi kesalahan pada server' : body;
  }

  /// Backend membungkus respons sebagai `{ success, message, data }`.
  /// Helper ini mengambil isi `data` (atau body apa adanya bila tidak dibungkus).
  static dynamic unwrap(dynamic body) {
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

/// Kegagalan jaringan (bukan error dari server). Turunan [ApiException]
/// dengan statusCode 0 agar penanganan error yang sudah ada (membaca
/// `e.message` atau `e.toString()`) otomatis menampilkan pesan ramah ini.
class NetworkException extends ApiException {
  NetworkException(String message) : super(0, message);

  factory NetworkException.offline() => NetworkException(offlineMessage);
  factory NetworkException.timeout() => NetworkException(timeoutMessage);

  static const String offlineMessage =
      'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.';
  static const String timeoutMessage =
      'Server tidak merespons. Periksa koneksi internet lalu coba lagi.';
}
