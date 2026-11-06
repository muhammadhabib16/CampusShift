import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'backend.dart';
import '../utils/error_message.dart';

class AuthService {
  static String get baseUrl => '${ApiConfig.baseUrl}/auth';

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
      return {'success': false, 'message': errorMessageOf(e)};
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
        body: jsonEncode({'email': email, 'password': password}),
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
      return {'success': false, 'message': errorMessageOf(e)};
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
  }

  /// Token JWT yang tersimpan, atau null bila belum login.
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('jwt_token');
  }

  /// Data pengguna yang disimpan saat login, atau null bila belum login.
  // ===== Profil (`/api/users/me`, FR-A03 & FR-A04) =====

  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user));
  }

  /// Memuat profil terbaru dari server dan memperbarui cache lokal.
  static Future<User?> fetchProfile() async {
    final data = Backend.map(await Backend.client.get('/users/me'));
    if (data.isEmpty) return null;
    await _saveUser(data);
    return User.fromJson(data);
  }

  /// Mengubah nama, nomor telepon, bio, dan (opsional) foto profil.
  /// Foto dikirim sebagai multipart field `photo` ke `PUT /users/me`.
  /// Mengembalikan {success, message, user?}.
  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String phone,
    String? bio,
    String? photoPath,
  }) async {
    try {
      // `bio` hanya dikirim bila diubah, agar penyuntingan nama/telepon tetap
      // berjalan di server yang belum memiliki kolom bio.
      final fields = {
        'full_name': fullName,
        'phone': phone,
        'bio': ?bio,
      };
      final body = photoPath == null
          ? await Backend.client.put('/users/me', body: fields)
          : await Backend.client.sendMultipart(
              'PUT',
              '/users/me',
              fields: fields,
              fileField: 'photo',
              filePath: photoPath,
              timeout: const Duration(seconds: 60),
            );
      final data = Backend.map(body);
      await _saveUser(data);
      return {
        'success': true,
        'message': (body is Map ? body['message'] : null) ?? 'Profil berhasil diperbarui',
        'user': User.fromJson(data),
      };
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': errorMessageOf(e)};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final body = await Backend.client.put(
        '/users/me/password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      return {
        'success': true,
        'message': (body is Map ? body['message'] : null) ?? 'Password berhasil diganti',
      };
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': errorMessageOf(e)};
    }
  }

  static Future<User?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_data');
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
