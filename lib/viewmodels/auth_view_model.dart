import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

/// State dan logika autentikasi (Modul Pendukung). View splash, login,
/// registrasi, beranda, dan profil memakai ViewModel ini alih-alih memanggil
/// AuthService langsung.
class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _message;
  User? _currentUser;
  String? _token;

  bool get isLoading => _isLoading;

  /// Pesan terakhir untuk ditampilkan ke pengguna (sukses maupun gagal).
  String? get message => _message;

  /// Pengguna yang sedang login; null bila belum login (atau mode uji debug).
  User? get currentUser => _currentUser;

  /// Token JWT untuk header `Authorization` pada service modul lain.
  String? get token => _token;

  /// Nama untuk sapaan di layar; memakai label umum bila data belum ada.
  String get displayName {
    final name = _currentUser?.fullName ?? '';
    return name.isEmpty ? 'Mahasiswa' : name;
  }

  /// Memeriksa token tersimpan saat aplikasi dibuka (splash).
  /// Mengembalikan true bila pengguna masih login.
  Future<bool> restoreSession() async {
    final loggedIn = await AuthService.isLoggedIn();
    _currentUser = loggedIn ? await AuthService.getCurrentUser() : null;
    _token = loggedIn ? await AuthService.getToken() : null;
    notifyListeners();
    return loggedIn;
  }

  Future<bool> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      _message = 'Email dan Password tidak boleh kosong';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    final result = await AuthService.login(email: email, password: password);
    final success = result['success'] == true;
    _message =
        result['message'] ?? (success ? 'Login berhasil' : 'Login gagal');
    if (success) {
      _currentUser = await AuthService.getCurrentUser();
      _token = await AuthService.getToken();
    }
    _setLoading(false);
    return success;
  }

  Future<bool> register({
    required String fullName,
    required String nim,
    required String email,
    required String password,
  }) async {
    final trimmedName = fullName.trim();
    final trimmedNim = nim.trim();
    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedName.isEmpty ||
        trimmedNim.isEmpty ||
        trimmedEmail.isEmpty ||
        password.isEmpty) {
      _message = 'Semua kolom wajib diisi';
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(trimmedNim)) {
      _message = 'NIM harus berupa 10 digit angka (Sesuai format UNAND)';
      notifyListeners();
      return false;
    }

    if (!trimmedEmail.endsWith('@student.unand.ac.id') &&
        !trimmedEmail.endsWith('@unand.ac.id')) {
      _message = 'Pendaftaran saat ini khusus mahasiswa Universitas Andalas (@student.unand.ac.id)';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    final result = await AuthService.register(
      fullName: trimmedName,
      nim: trimmedNim,
      email: trimmedEmail,
      password: password,
    );
    final success = result['success'] == true;
    _message =
        result['message'] ??
        (success ? 'Registrasi berhasil, silakan login' : 'Registrasi gagal');
    _setLoading(false);
    return success;
  }

  /// Menghapus token dan data pengguna yang tersimpan di perangkat.
  Future<void> logout() async {
    await AuthService.logout();
    _message = null;
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
