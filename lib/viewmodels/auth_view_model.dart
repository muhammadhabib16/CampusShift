import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/push_service.dart';

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
    // Token FCM bisa berubah selama aplikasi tertutup; daftarkan ulang tanpa menahan splash.
    if (loggedIn) unawaited(PushService.registerDevice());
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
      unawaited(PushService.registerDevice());
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

    // BR-A1: server hanya menerima domain @student.unand.ac.id.
    if (!trimmedEmail.endsWith('@student.unand.ac.id')) {
      _message = 'Pendaftaran saat ini khusus mahasiswa Universitas Andalas (@student.unand.ac.id)';
      notifyListeners();
      return false;
    }

    if (trimmedName.length < 3 || trimmedName.length > 60) {
      _message = 'Nama lengkap harus 3–60 karakter';
      notifyListeners();
      return false;
    }

    // BR-A2: minimal 8 karakter dengan kombinasi huruf dan angka.
    if (password.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      _message = 'Kata sandi minimal 8 karakter dan harus berisi huruf serta angka';
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

  /// Memuat profil terbaru dari server (nama, telepon) tanpa mengganggu UI
  /// bila gagal — data tersimpan tetap dipakai.
  Future<void> refreshProfile() async {
    if (_token == null) return;
    try {
      final user = await AuthService.fetchProfile();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    String? bio,
    String? photoPath,
  }) async {
    _setLoading(true);
    final result = await AuthService.updateProfile(
      fullName: fullName.trim(),
      phone: phone.trim(),
      bio: bio?.trim(),
      photoPath: photoPath,
    );
    final success = result['success'] == true;
    if (success) _currentUser = result['user'] as User;
    _message = result['message'] as String?;
    _setLoading(false);
    return success;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    final result = await AuthService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    _message = result['message'] as String?;
    _setLoading(false);
    return result['success'] == true;
  }

  /// Menghapus token dan data pengguna yang tersimpan di perangkat.
  Future<void> logout() async {
    // Hapus token FCM dari backend selagi JWT masih ada.
    await PushService.unregisterDevice();
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
