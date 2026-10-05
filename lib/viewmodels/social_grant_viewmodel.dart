import 'package:flutter/foundation.dart';
import '../models/social_grant.dart';
import '../services/social_grant_service.dart';

/// State & aturan bisnis untuk layar katalog/formulir hibah.
/// Views HANYA boleh memanggil method di sini, tidak boleh panggil
/// SocialGrantService langsung (TEAM_GUIDELINES.md #2: pola MVVM).
class SocialGrantViewModel extends ChangeNotifier {
  SocialGrantViewModel(this._service);
  final SocialGrantService _service;

  List<SocialGrant> grants = [];
  bool isLoading = false;
  String? errorMessage;
  String? selectedCategory; // null = chip "Semua"

  /// Dipanggil dari chip kategori di layar katalog-hibah.
  void setCategory(String? category) {
    selectedCategory = category;
    loadGrants(category: category);
  }

  Future<void> loadGrants({String? category}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      grants = await _service.fetchActiveGrants(category: category);
    } catch (e) {
      errorMessage = 'Gagal memuat katalog hibah. Coba lagi.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// FR-21: aturan "wajib minimal 1 foto" divalidasi DI SINI, bukan di
  /// Service — supaya Service tetap sederhana (murni I/O) dan aturan
  /// bisnisnya mudah dites/diperiksa terpisah dari jaringan.
  Future<bool> submitNewGrant({
    required String itemName,
    required String academicCategory,
    required String description,
    required int quota,
    required String? photoFilePath,
  }) async {
    if (photoFilePath == null) {
      errorMessage = 'Foto kondisi barang wajib diambil dari kamera.';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();
    try {
      final grant = await _service.createGrant(
        itemName: itemName,
        academicCategory: academicCategory,
        description: description,
        quota: quota,
        photoFilePath: photoFilePath,
      );
      grants = [grant, ...grants];
      return true;
    } catch (e) {
      errorMessage = 'Gagal menyimpan hibah. Periksa koneksi Anda.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> archiveGrant(String id) async {
    await _service.archiveGrant(id);
    grants = grants.where((g) => g.id != id).toList();
    notifyListeners();
  }
}
