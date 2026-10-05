import '../models/social_grant.dart';
import 'api_client.dart';

/// Lapisan komunikasi ke backend khusus entity SocialGrant.
/// Tidak menyimpan state apa pun — semua state ada di SocialGrantViewModel.
/// "Bodoh" secara sengaja supaya gampang dites terpisah dari UI.
class SocialGrantService {
  SocialGrantService(this._client);
  final ApiClient _client;

  Future<List<SocialGrant>> fetchActiveGrants({String? category}) async {
    final json = await _client.get('/grants', query: {
      'status': 'Active',
      'category': ?category,
    });
    return (json as List)
        .map((e) => SocialGrant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// FR-21: create dengan foto wajib → pakai multipart, bukan JSON biasa.
  Future<SocialGrant> createGrant({
    required String itemName,
    required String academicCategory,
    required String description,
    required int quota,
    required String photoFilePath,
  }) async {
    final json = await _client.postMultipart(
      '/grants',
      fields: {
        'item_name': itemName,
        'academic_category': academicCategory,
        'description': description,
        'quota': quota.toString(),
      },
      fileField: 'photo',
      filePath: photoFilePath,
    );
    return SocialGrant.fromJson(json as Map<String, dynamic>);
  }

  Future<SocialGrant> updateGrant(String id, SocialGrant grant) async {
    final json = await _client.put('/grants/$id', body: grant.toJson());
    return SocialGrant.fromJson(json as Map<String, dynamic>);
  }

  /// FR-21 "Delete" = arsipkan, bukan hapus permanen — jejak transaksi &
  /// klaim yang sudah pernah dibuat terhadap barang ini tetap konsisten.
  Future<void> archiveGrant(String id) async {
    await _client.put('/grants/$id', body: {'availability_status': 'Archived'});
  }
}
