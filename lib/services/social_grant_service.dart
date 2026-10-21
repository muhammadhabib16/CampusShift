import '../models/social_grant.dart';
import 'api_client.dart';

class SocialGrantService {
  final ApiClient _apiClient = ApiClient(baseUrl: 'https://api.campushift.unand.ac.id/api', getToken: () => null);

  static final List<SocialGrant> _seedGrants = [
    SocialGrant(
      id: 'item-hibah-001',
      ownerUserId: 'user-raka-001',
      ownerName: 'Raka Pratama (Teknik 22)',
      ownerReputation: 4.9,
      title: 'Buku Kalkulus Purcell Edisi 9',
      description: 'Buku referensi wajib semester 1 & 2. Halaman lengkap, sampul masih rapi, ada sedikit catatan pensil yang mudah dihapus.',
      category: 'Buku & Referensi',
      condition: 'Sangat Baik',
      photoUrls: [
        'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600',
        'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=600',
      ],
      status: 'Available',
      listingType: 'Hibah',
    ),
    SocialGrant(
      id: 'item-hibah-002',
      ownerUserId: 'user-nadia-002',
      ownerName: 'Nadia Putri (SI 22)',
      ownerReputation: 4.8,
      title: 'Meja Belajar Lipat Kayu Kos',
      description: 'Meja belajar lipat ukuran 60x40 cm. Engsel kokoh, permukaan mulus, ada goresan kecil di sudut kanan bawah.',
      category: 'Furnitur Kos',
      condition: 'Baik',
      photoUrls: [
        'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600',
        'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=600',
      ],
      status: 'Available',
      listingType: 'Hibah',
    ),
    SocialGrant(
      id: 'item-hibah-003',
      ownerUserId: 'user-fajar-003',
      ownerName: 'Fajar Ramadhan (Elektro 21)',
      ownerReputation: 4.7,
      title: 'Jas Laboratorium Ukuran L + Kacamata Safety',
      description: 'Jas lab lengan panjang ukuran L bersih sudah di-laundry, kancing lengkap, bonus kacamata safety praktikum.',
      category: 'Alat Perkuliahan',
      condition: 'Sangat Baik',
      photoUrls: [
        'https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=600',
        'https://images.unsplash.com/photo-1576086213369-97a306d36557?w=600',
      ],
      status: 'Available',
      listingType: 'Hibah',
    ),
  ];

  Future<List<SocialGrant>> fetchAvailableGrants({
    String? query,
    String? category,
    String? excludeOwnerId,
  }) async {
    try {
      final response = await _apiClient.get('/items?type=Hibah&status=Available');
      if (response is List && response.isNotEmpty) {
        return response
            .map((e) => SocialGrant.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}

    return _seedGrants.where((item) {
      if (item.status != 'Available') return false;
      if (excludeOwnerId != null &&
          excludeOwnerId.isNotEmpty &&
          item.ownerUserId == excludeOwnerId) {
        return false;
      }
      if (category != null &&
          category.isNotEmpty &&
          category != 'Semua' &&
          item.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchDesc = item.description.toLowerCase().contains(q);
        if (!matchTitle && !matchDesc) return false;
      }
      return true;
    }).toList();
  }

  Future<List<SocialGrant>> fetchDonorGrants(String ownerUserId) async {
    return _seedGrants
        .where((item) => item.ownerUserId == ownerUserId || ownerUserId.isEmpty)
        .toList();
  }

  static void updateLocalGrantStatus(String itemId, String newStatus) {
    final index = _seedGrants.indexWhere((g) => g.id == itemId);
    if (index != -1) {
      _seedGrants[index] = _seedGrants[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    }
  }

  static SocialGrant? findById(String itemId) {
    try {
      return _seedGrants.firstWhere((g) => g.id == itemId);
    } catch (_) {
      return null;
    }
  }
}
