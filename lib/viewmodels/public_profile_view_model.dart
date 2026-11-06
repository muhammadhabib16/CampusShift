import 'package:flutter/foundation.dart';

import '../models/item_model.dart';
import '../models/public_profile.dart';
import '../services/user_profile_service.dart';
import '../utils/error_message.dart';

/// State layar profil publik. Dibuat per layar (bukan global) karena setiap
/// layar menampilkan pengguna yang berbeda.
class PublicProfileViewModel extends ChangeNotifier {
  PublicProfileViewModel({required this.userId, UserProfileService? service})
    : _service = service ?? UserProfileService();

  final int userId;
  final UserProfileService _service;

  PublicProfile? _profile;
  List<ItemModel> _listings = const [];
  bool _isLoading = false;
  String? _errorMessage;

  PublicProfile? get profile => _profile;
  List<ItemModel> get listings => _listings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await _service.getProfile(userId);
      try {
        _listings = await _service.getActiveListings(userId);
      } catch (_) {
        // Daftar barang bersifat pelengkap; profil tetap ditampilkan.
        _listings = const [];
      }
    } catch (e) {
      _errorMessage = errorMessageOf(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
