/// Model Ulasan dan Rating Reputasi (FR-20, BR-25, BR-26).
/// Ulasan bersifat permanen dan tidak dapat dihapus oleh siapa pun (AC-25).
/// Pemberi ulasan hanya dapat menyunting ulasan 1 kali dalam 7 hari (AC-24).
class ReviewModel {
  final String id;
  final int meetupId;
  final String proofNumber;
  final int reviewerId;
  final String reviewerName;
  final String reviewerNim;
  final int targetUserId;
  final String targetUserName;
  final int rating; // 1 s/d 5 (wajib diisi, BR-25)
  final String comment; // Maks 500 karakter (BR-25)
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited; // Ditandai "Diedit" jika sudah disunting (BR-26)

  ReviewModel({
    required this.id,
    required this.meetupId,
    required this.proofNumber,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerNim,
    required this.targetUserId,
    required this.targetUserName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    this.isEdited = false,
  });

  /// Validasi izin sunting: hanya jika belum pernah disunting dan dalam 7 hari (BR-26)
  bool get canEdit {
    if (isEdited) return false;
    final diffDays = DateTime.now().difference(createdAt).inDays;
    return diffDays < 7;
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      meetupId: json['meetup_id'] as int,
      proofNumber: json['proof_number'] as String,
      reviewerId: json['reviewer_id'] as int,
      reviewerName: json['reviewer_name'] as String,
      reviewerNim: json['reviewer_nim'] as String? ?? '',
      targetUserId: json['target_user_id'] as int,
      targetUserName: json['target_user_name'] as String? ?? 'Mitra Transaksi',
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isEdited: json['is_edited'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetup_id': meetupId,
      'proof_number': proofNumber,
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerName,
      'reviewer_nim': reviewerNim,
      'target_user_id': targetUserId,
      'target_user_name': targetUserName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_edited': isEdited,
    };
  }

  ReviewModel copyWith({
    int? rating,
    String? comment,
    DateTime? updatedAt,
    bool? isEdited,
  }) {
    return ReviewModel(
      id: id,
      meetupId: meetupId,
      proofNumber: proofNumber,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      reviewerNim: reviewerNim,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}