import 'review_model.dart';

/// Profil publik pengguna (`GET /users/:id/profile`): identitas, reputasi,
/// jumlah transaksi selesai, dan ulasan yang diterima.
class PublicProfile {
  const PublicProfile({
    required this.id,
    required this.fullName,
    required this.nim,
    this.bio = '',
    required this.photoUrl,
    required this.joinedAt,
    required this.completedDeals,
    required this.averageRating,
    required this.reviewCount,
    required this.reviews,
  });

  final int id;
  final String fullName;
  final String nim;
  final String bio;
  final String? photoUrl;
  final DateTime? joinedAt;
  final int completedDeals;

  /// Null bila belum ada ulasan.
  final double? averageRating;
  final int reviewCount;
  final List<ReviewModel> reviews;

  /// Jumlah ulasan per bintang (5..1) dari ulasan yang dimuat.
  Map<int, int> get ratingDistribution {
    final dist = {for (var s = 1; s <= 5; s++) s: 0};
    for (final r in reviews) {
      if (dist.containsKey(r.rating)) dist[r.rating] = dist[r.rating]! + 1;
    }
    return dist;
  }

  factory PublicProfile.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;
    final reputation = json['reputation'] is Map
        ? Map<String, dynamic>.from(json['reputation'] as Map)
        : const <String, dynamic>{};
    final avg = reputation['average'] ?? json['score'];
    final name = (json['full_name'] ?? 'Mahasiswa Unand').toString();
    final photo = json['profile_photo_url']?.toString();

    return PublicProfile(
      id: toInt(json['id']),
      fullName: name,
      nim: (json['nim'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString().trim(),
      photoUrl: (photo == null || photo.isEmpty) ? null : photo,
      joinedAt: DateTime.tryParse('${json['joined_at'] ?? ''}')?.toLocal(),
      completedDeals: toInt(json['completed_deals']),
      averageRating: avg is num ? avg.toDouble() : double.tryParse('$avg'),
      reviewCount: toInt(reputation['count'] ?? json['reviewCount']),
      reviews: (json['reviews'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (e) => ReviewModel.fromServer(
              Map<String, dynamic>.from(e),
              targetUserName: name,
            ),
          )
          .toList(),
    );
  }
}
