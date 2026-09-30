/// Login dummy (belum ada backend). AuthService yang asli tidak diubah.
class AuthRepository {
  AuthRepository._();

  // Akun dummy untuk pengujian.
  static const String dummyEmail = 'mellisa@mahasiswa.ui.ac.id';
  static const String dummyPassword = 'password123';

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    if (identifier.trim().toLowerCase() == dummyEmail &&
        password == dummyPassword) {
      return {'success': true, 'message': 'Login berhasil'};
    }
    return {'success': false, 'message': 'Email/NIM atau kata sandi salah'};
  }
}
