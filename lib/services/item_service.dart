import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item_model.dart';
import 'api_client.dart';
import 'api_config.dart';

class ItemService {
  static String get baseUrl => '${ApiConfig.baseUrl}/items';
  static const Duration _timeout = Duration(seconds: 10);

  /// Unggah foto butuh waktu lebih lama dari request biasa.
  static const Duration _uploadTimeout = Duration(seconds: 90);

  /// Batas ukuran per foto di server (multer, BR-03).
  static const int _maxPhotoBytes = 5 * 1024 * 1024;

  // Helper untuk mengambil token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Helper untuk menyiapkan header request
  static Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper untuk menangani error dari respon API
  static void _handleError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String message = 'Terjadi kesalahan (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {}
    throw Exception(message);
  }

  static String? _normalizeListingType(String? type) {
    if (type == null ||
        type.isEmpty ||
        type == 'Semua' ||
        type == 'Semua Transaksi' ||
        type == 'Terbuka Barter') {
      return null;
    }
    if (type.startsWith('Jual')) return 'Jual';
    if (type.startsWith('Hibah')) return 'Hibah';
    return type;
  }

  // GET /items (Katalog dengan Filter)
  static Future<List<ItemModel>> getCatalog({
    String? search,
    String? category,
    String? type,
    double? minPrice,
    double? maxPrice,
  }) async {
    final token = await _getToken();
    final queryParams = <String, String>{};

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (category != null &&
        category.isNotEmpty &&
        category != 'Semua Kategori') {
      queryParams['category'] = category;
    }
    final normalizedType = _normalizeListingType(type);
    if (normalizedType != null) {
      queryParams['type'] = normalizedType;
    }
    if (minPrice != null && minPrice > 0) {
      queryParams['min_price'] = minPrice.toInt().toString();
    }
    if (maxPrice != null && maxPrice < 500000) {
      queryParams['max_price'] = maxPrice.toInt().toString();
    }

    final parsedBase = Uri.parse(baseUrl);
    final uri = queryParams.isEmpty
        ? parsedBase
        : parsedBase.replace(queryParameters: queryParams);

    final response = await ApiClient.guardNetwork(
      () => http.get(uri, headers: _headers(token)).timeout(_timeout),
    );
    _handleError(response);

    final decoded = jsonDecode(response.body);
    final data = (decoded['data'] as List?) ?? const [];
    return data
        .map((json) => ItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // GET /items/me (Barang Saya)
  static Future<List<ItemModel>> getMyItems() async {
    final token = await _getToken();
    final response = await ApiClient.guardNetwork(
      () => http
          .get(Uri.parse('$baseUrl/me'), headers: _headers(token))
          .timeout(_timeout),
    );
    _handleError(response);

    final decoded = jsonDecode(response.body);
    final data = (decoded['data'] as List?) ?? const [];
    return data
        .map((json) => ItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Helper Multipart Request (POST / PUT dengan file gambar)
  static Future<bool> _sendMultipart(
    String method,
    String url,
    Map<String, dynamic> data,
    List<File> imageFiles,
  ) async {
    // Server memutus koneksi (connection reset) bila satu foto > 5 MB,
    // sehingga pesan errornya tidak sampai ke aplikasi. Periksa lebih dulu.
    for (var i = 0; i < imageFiles.length; i++) {
      final size = await imageFiles[i].length();
      if (size > _maxPhotoBytes) {
        final mb = (size / (1024 * 1024)).toStringAsFixed(1);
        throw Exception(
          'Foto ke-${i + 1} terlalu besar ($mb MB). Maksimal 5 MB per foto, silakan ambil ulang foto.',
        );
      }
    }

    final token = await _getToken();
    final request = http.MultipartRequest(method, Uri.parse(url));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    data.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    for (final file in imageFiles) {
      request.files.add(await http.MultipartFile.fromPath('fotos', file.path));
    }

    final http.Response response;
    try {
      final streamedResponse = await request.send().timeout(_uploadTimeout);
      response = await http.Response.fromStream(streamedResponse)
          .timeout(_uploadTimeout);
    } on TimeoutException {
      throw Exception(
        'Unggah listing terlalu lama. Periksa koneksi internet lalu coba lagi.',
      );
    } on SocketException {
      throw Exception(
        'Koneksi ke server terputus saat mengunggah. Periksa internet atau kurangi ukuran foto, lalu coba lagi.',
      );
    } on http.ClientException {
      throw Exception(
        'Koneksi ke server terputus saat mengunggah. Periksa internet atau kurangi ukuran foto, lalu coba lagi.',
      );
    }
    _handleError(response);
    return true;
  }

  // POST /items (Tambah Listing)
  static Future<bool> createListing(
    Map<String, dynamic> data,
    List<File> imageFiles,
  ) async {
    return _sendMultipart('POST', baseUrl, data, imageFiles);
  }

  // PUT /items/:id (Update Listing)
  static Future<bool> updateListing(
    String id,
    Map<String, dynamic> data,
    List<File> imageFiles,
  ) async {
    return _sendMultipart('PUT', '$baseUrl/$id', data, imageFiles);
  }

  // PUT /items/:id/archive (Arsipkan)
  static Future<bool> archiveListing(String id) async {
    final token = await _getToken();
    final response = await ApiClient.guardNetwork(
      () => http
          .put(Uri.parse('$baseUrl/$id/archive'), headers: _headers(token))
          .timeout(_timeout),
    );
    _handleError(response);
    return true;
  }

  // PUT /items/:id/activate (Aktifkan)
  static Future<bool> activateListing(String id) async {
    final token = await _getToken();
    final response = await ApiClient.guardNetwork(
      () => http
          .put(Uri.parse('$baseUrl/$id/activate'), headers: _headers(token))
          .timeout(_timeout),
    );
    _handleError(response);
    return true;
  }

  // DELETE /items/:id (Hapus Permanen)
  static Future<bool> deleteListing(String id) async {
    final token = await _getToken();
    final response = await ApiClient.guardNetwork(
      () => http
          .delete(Uri.parse('$baseUrl/$id'), headers: _headers(token))
          .timeout(_timeout),
    );
    _handleError(response);
    return true;
  }
}
