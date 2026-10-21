import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item_model.dart';
import 'auth_service.dart';

class ItemService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/items';
    }
    return 'http://127.0.0.1:3000/api/items';
  }

  // Helper untuk mengambil token
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<List<ItemModel>> getCatalog({
    String? search,
    String? category,
    String? type,
  }) async {
    final token = await _getToken();

    // Buat query parameters untuk filter pencarian (FR-03)
    var queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty && category != 'Semua Kategori')
      queryParams['category'] = category;
    if (type != null && type.isNotEmpty && type != 'Semua')
      queryParams['type'] = type;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['data'];
      return items.map((json) => ItemModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat katalog');
    }
  }

  // Menggunakan MultipartRequest karena ada upload gambar kamera (FR-02)
  static Future<bool> createListing(
    Map<String, dynamic> data,
    List<File> imageFiles,
  ) async {
    final token = await _getToken();
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

    request.headers.addAll({'Authorization': 'Bearer $token'});

    // Masukkan data text
    request.fields['judul'] = data['judul'];
    request.fields['deskripsi'] = data['deskripsi'];
    request.fields['kategori'] = data['kategori'];
    request.fields['tipe_listing'] = data['tipe_listing'];
    request.fields['harga'] = data['harga'].toString();
    request.fields['terbuka_untuk_barter'] = data['terbuka_untuk_barter']
        .toString();
    request.fields['kondisi'] = data['kondisi'];

    // Masukkan file gambar hasil kompresi image_picker (BR-03)
    for (int i = 0; i < imageFiles.length; i++) {
      var pic = await http.MultipartFile.fromPath('fotos', imageFiles[i].path);
      request.files.add(pic);
    }

    final response = await request.send();
    return response.statusCode == 201;
  }
}
