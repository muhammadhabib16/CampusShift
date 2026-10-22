import 'package:flutter/foundation.dart';
import '../models/social_grant.dart';
import '../services/social_grant_service.dart';

class SocialGrantViewModel extends ChangeNotifier {
  final SocialGrantService _service = SocialGrantService();

  List<SocialGrant> _grants = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  List<SocialGrant> get grants => _grants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  static const List<String> categories = [
    'Semua',
    'Buku & Referensi',
    'Furnitur Kos',
    'Elektronik',
    'Alat Perkuliahan',
  ];

  Future<void> loadGrants({String? currentUserId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _grants = await _service.fetchAvailableGrants(
        query: _searchQuery,
        category: _selectedCategory,
        excludeOwnerId: currentUserId,
      );
    } catch (e) {
      _errorMessage = 'Tidak dapat terhubung ke server. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query, {String? currentUserId}) {
    _searchQuery = query;
    loadGrants(currentUserId: currentUserId);
  }

  void setCategory(String category, {String? currentUserId}) {
    _selectedCategory = category;
    loadGrants(currentUserId: currentUserId);
  }
}
