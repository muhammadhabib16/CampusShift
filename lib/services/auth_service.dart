import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class AuthService {
  // Gunakan IP yang tepat berdasarkan platform atau device yang dipakai
  // 10.0.2.2 untuk emulator Android
  // localhost (127.0.0.1) untuk iOS simulator
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/auth';
    }
    return 'http://127.0.0.1:3000/api/auth';
  }

  static bool useDummy = true; // Ubah ke false untuk menggunakan API sungguhan

  static const Map<String, dynamic> _dummyUser = {
    'id': '1',
    'full_name': 'Dummy Mahasiswa',
    'nim': '1234567890',
    'email': 'contoh@mahasiswa.ui.ac.id',
  };

  static const String _dummyToken = 'dummy_jwt_token_12345';

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String nim,
    required String email,
    required String password,
  }) async {
    if (useDummy) {
      await Future.delayed(const Duration(seconds: 1)); // Simulasi loading
      return {'success': true, 'message': 'Registrasi berhasil (Dummy)'};
    }

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
    if (useDummy) {
      await Future.delayed(const Duration(seconds: 1)); // Simulasi loading
      
      // Validasi dummy sederhana
      if (email.isNotEmpty && password.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _dummyToken);
        await prefs.setString('user_data', jsonEncode(_dummyUser));
        return {'success': true, 'message': 'Login berhasil (Dummy)'};
      } else {
        return {'success': false, 'message': 'Email atau password salah'};
      }
    }

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
