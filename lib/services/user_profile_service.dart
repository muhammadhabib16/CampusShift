import '../models/item_model.dart';
import '../models/public_profile.dart';
import 'backend.dart';
import 'item_service.dart';

/// Sumber data profil publik pengguna lain.
class UserProfileService {
  /// [fetchProfile] dan [fetchCatalog] dapat diganti pada pengujian.
  UserProfileService({
    Future<PublicProfile> Function(int userId)? fetchProfile,
    Future<List<ItemModel>> Function()? fetchCatalog,
  }) : _fetchProfile = fetchProfile ?? _profileFromServer,
       _fetchCatalog = fetchCatalog ?? (() => ItemService.getCatalog());

  final Future<PublicProfile> Function(int userId) _fetchProfile;
  final Future<List<ItemModel>> Function() _fetchCatalog;

  static Future<PublicProfile> _profileFromServer(int userId) async {
    final body = await Backend.client.get('/users/$userId/profile');
    return PublicProfile.fromJson(Backend.map(body));
  }

  Future<PublicProfile> getProfile(int userId) => _fetchProfile(userId);

  /// Listing Available milik [userId]. Katalog server belum punya filter
  /// pemilik, jadi disaring di aplikasi dari hasil katalog.
  Future<List<ItemModel>> getActiveListings(int userId) async {
    final items = await _fetchCatalog();
    return items
        .where((i) => i.ownerId == '$userId' && i.status == 'Available')
        .toList();
  }
}
