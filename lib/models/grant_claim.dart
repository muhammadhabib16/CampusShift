class GrantClaim {
  final String id;
  final String itemId;
  final String itemTitle;
  final String itemCategory;
  final String itemCondition;
  final String donorUserId;
  final String donorName;
  final String applicantUserId;
  final String applicantName;
  final String applicantNim;
  final String applicantPhotoUrl;
  final double? applicantReputation; // BR-29: Tampilkan nama, foto, dan skor reputasi pemohon
  final int applicantReviewCount;
  final String urgency; // Mendesak, Sedang, Rendah (FR-23)
  final String justification; // 100 - 1.000 karakter (BR-27)
  final String status; // Pending, Approved, Rejected, Cancelled, Completed (2.6)
  final String? rejectionReason; // BR-30: Alasan penolakan singkat (opsional)
  final String? meetupId; // Integrasi ke Modul 2 via ID
  final DateTime createdAt;
  final DateTime updatedAt;

  GrantClaim({
    required this.id,
    required this.itemId,
    this.itemTitle = '',
    this.itemCategory = 'Buku & Referensi',
    this.itemCondition = 'Baik',
    this.donorUserId = '',
    this.donorName = 'Donatur Unand',
    required this.applicantUserId,
    this.applicantName = 'Mahasiswa Pemohon',
    this.applicantNim = '',
    this.applicantPhotoUrl = '',
    this.applicantReputation,
    this.applicantReviewCount = 0,
    required this.urgency,
    required this.justification,
    this.status = 'Pending',
    this.rejectionReason,
    this.meetupId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Getter kompatibilitas dengan kode versi lama
  String get claimId => id;
  String get grantId => itemId;
  String get grantTitle => itemTitle;
  String get userId => applicantUserId;
  String get userName => applicantName;
  String get reason => justification;

  // BR-28: Klaim aktif adalah klaim berstatus Pending atau Approved
  bool get isActiveClaim => status == 'Pending' || status == 'Approved';

  // BR-32: Hanya klaim Pending yang dapat dihapus permanen atau disunting
  bool get canEditOrDelete => status == 'Pending';

  // BR-31: Klaim Approved dapat dibatalkan sebelum serah terima
  bool get canCancelApproved => status == 'Approved';

  // Bobot numerik urgensi untuk pengurutan antrean (BR-29: Mendesak -> Sedang -> Rendah)
  int get urgencyPriority {
    switch (urgency.toLowerCase()) {
      case 'mendesak':
        return 1;
      case 'sedang':
        return 2;
      case 'rendah':
      default:
        return 3;
    }
  }

  String get reputationLabel {
    if (applicantReputation == null || applicantReviewCount == 0) {
      return 'Belum ada ulasan'; // BR-25
    }
    return '${applicantReputation!.toStringAsFixed(1)} ★ ($applicantReviewCount ulasan)';
  }

  factory GrantClaim.fromJson(Map<String, dynamic> json) {
    return GrantClaim(
      id: (json['claim_id'] ?? json['id'] ?? '').toString(),
      itemId: (json['item_id'] ?? json['itemId'] ?? json['grant_id'] ?? '').toString(),
      itemTitle: (json['item_title'] ?? json['itemTitle'] ?? json['grant_title'] ?? 'Barang Hibah').toString(),
      itemCategory: (json['item_category'] ?? json['itemCategory'] ?? 'Buku & Referensi').toString(),
      itemCondition: (json['item_condition'] ?? json['itemCondition'] ?? 'Baik').toString(),
      donorUserId: (json['donor_user_id'] ?? json['donorUserId'] ?? json['owner_user_id'] ?? '').toString(),
      donorName: (json['donor_name'] ?? json['donorName'] ?? 'Donatur Unand').toString(),
      applicantUserId: (json['applicant_user_id'] ?? json['applicantUserId'] ?? json['user_id'] ?? '').toString(),
      applicantName: (json['applicant_name'] ?? json['applicantName'] ?? json['user_name'] ?? 'Mahasiswa Unand').toString(),
      applicantNim: (json['applicant_nim'] ?? json['applicantNim'] ?? '').toString(),
      applicantPhotoUrl: (json['applicant_photo_url'] ?? json['applicantPhotoUrl'] ?? '').toString(),
      applicantReputation: json['applicant_reputation'] != null
          ? double.tryParse(json['applicant_reputation'].toString())
          : null,
      applicantReviewCount: int.tryParse((json['applicant_review_count'] ?? 0).toString()) ?? 0,
      urgency: (json['urgensi'] ?? json['urgency'] ?? 'Sedang').toString(),
      justification: (json['justifikasi'] ?? json['justification'] ?? json['reason'] ?? '').toString(),
      status: (json['status'] ?? 'Pending').toString(),
      rejectionReason: json['alasan_penolakan']?.toString() ?? json['rejection_reason']?.toString(),
      meetupId: json['meetup_id']?.toString() ?? json['meetupId']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'claim_id': id,
      'item_id': itemId,
      'item_title': itemTitle,
      'item_category': itemCategory,
      'item_condition': itemCondition,
      'donor_user_id': donorUserId,
      'donor_name': donorName,
      'applicant_user_id': applicantUserId,
      'applicant_name': applicantName,
      'applicant_nim': applicantNim,
      'applicant_photo_url': applicantPhotoUrl,
      'applicant_reputation': applicantReputation,
      'applicant_review_count': applicantReviewCount,
      'urgensi': urgency,
      'justifikasi': justification,
      'status': status,
      'alasan_penolakan': rejectionReason,
      'meetup_id': meetupId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GrantClaim copyWith({
    String? id,
    String? itemId,
    String? itemTitle,
    String? itemCategory,
    String? itemCondition,
    String? donorUserId,
    String? donorName,
    String? applicantUserId,
    String? applicantName,
    String? applicantNim,
    String? applicantPhotoUrl,
    double? applicantReputation,
    int? applicantReviewCount,
    String? urgency,
    String? justification,
    String? status,
    String? rejectionReason,
    String? meetupId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GrantClaim(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      itemCategory: itemCategory ?? this.itemCategory,
      itemCondition: itemCondition ?? this.itemCondition,
      donorUserId: donorUserId ?? this.donorUserId,
      donorName: donorName ?? this.donorName,
      applicantUserId: applicantUserId ?? this.applicantUserId,
      applicantName: applicantName ?? this.applicantName,
      applicantNim: applicantNim ?? this.applicantNim,
      applicantPhotoUrl: applicantPhotoUrl ?? this.applicantPhotoUrl,
      applicantReputation: applicantReputation ?? this.applicantReputation,
      applicantReviewCount: applicantReviewCount ?? this.applicantReviewCount,
      urgency: urgency ?? this.urgency,
      justification: justification ?? this.justification,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      meetupId: meetupId ?? this.meetupId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
