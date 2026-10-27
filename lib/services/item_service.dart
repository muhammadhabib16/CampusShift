import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item_model.dart';
import 'api_config.dart';

class ItemService {
  static String get baseUrl => '${ApiConfig.baseUrl}/items';

  // Helper untuk mengambil token
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
      if (body['message'] != null) message = body['message'];
    } catch (_) {}
    throw Exception(message);
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

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (category != null && category != 'Semua Kategori') {
      queryParams['category'] = category;
    }
    if (type != null && type != 'Semua Transaksi') {
      queryParams['type'] = type;
    }
    if (minPrice != null) {
      queryParams['min_price'] = minPrice.toInt().toString();
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice.toInt().toString();
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers(token));
    _handleError(response);

    final data = jsonDecode(response.body)['data'] as List;
    return data.map((json) => ItemModel.fromJson(json)).toList();
  }

  // GET /items/me (Barang Saya)
  static Future<List<ItemModel>> getMyItems() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: _headers(token),
    );
    _handleError(response);

    final data = jsonDecode(response.body)['data'] as List;
    return data.map((json) => ItemModel.fromJson(json)).toList();
  }

  // Helper Muti-part Request (POST / PUT dengan file gambar)
  static Future<bool> _sendMultipart(
    String method,
    String url,
    Map<String, dynamic> data,
    List<File> imageFiles,
  ) async {
    final token = await _getToken();
    final request = http.MultipartRequest(method, Uri.parse(url));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    // Masukkan data teks
    data.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    // Masukkan file gambar
    for (var file in imageFiles) {
      request.files.add(await http.MultipartFile.fromPath('fotos', file.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
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
    final response = await http.put(
      Uri.parse('$baseUrl/$id/archive'),
      headers: _headers(token),
    );
    _handleError(response);
    return true;
  }

  // PUT /items/:id/activate (Aktifkan)
  static Future<bool> activateListing(String id) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$id/activate'),
      headers: _headers(token),
    );
    _handleError(response);
    return true;
  }

  // DELETE /items/:id (Hapus Permanen)
  static Future<bool> deleteListing(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: _headers(token),
    );
    _handleError(response);
    return true;
  }
}
