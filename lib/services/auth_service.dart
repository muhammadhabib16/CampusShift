import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // kIsWeb aman untuk semua platform (Android, iOS, Web).
  // - Flutter Web (Chrome): akses langsung ke localhost PC.
  // - Android Emulator: gunakan 10.0.2.2 (loopback ke host PC).
  // - Android Fisik (USB): jalankan `adb reverse tcp:5000 tcp:5000` terlebih dahulu.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api/auth';
    }
    // Android emulator menggunakan 10.0.2.2 untuk mengakses localhost PC
    return 'http://10.0.2.2:5000/api/auth';
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String nim,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'nim': nim,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        String msg = data['message'] ?? 'Gagal mendaftar';
        if (data['errors'] != null) {
          msg = data['errors'][0]['msg']; // Ambil error pertama dari validator
        }
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String token = data['data']['token'];
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_data', jsonEncode(data['data']['user']));

        return {'success': true, 'message': data['message']};
      } else {
        String msg = data['message'] ?? 'Login gagal';
        if (data['errors'] != null) {
          msg = data['errors'][0]['msg'];
        }
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('jwt_token');
  }
}
