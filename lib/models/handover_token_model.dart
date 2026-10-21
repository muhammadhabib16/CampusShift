class HandoverTokenModel {
  final String tokenId;
  final String meetupId;
  final String token;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final String status; // 'active', 'expired', 'used', 'cancelled'
  final String? proofNumber; // Nomor bukti unik (BR-24)

  HandoverTokenModel({
    required this.tokenId,
    required this.meetupId,
    required this.token,
    required this.issuedAt,
    required this.expiresAt,
    this.usedAt,
    required this.status,
    this.proofNumber,
  });

  bool get isExpired {
    if (status == 'expired') return true;
    return DateTime.now().isAfter(expiresAt);
  }

  bool get isActive => status == 'active' && !isExpired;

  int get remainingSeconds {
    final diff = expiresAt.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  String get formattedRemainingTime {
    final seconds = remainingSeconds;
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  double get progressRatio {
    const totalDurationSeconds = 300.0; // 5 menit = 300 detik
    final remaining = remainingSeconds.toDouble();
    return (remaining / totalDurationSeconds).clamp(0.0, 1.0);
  }

  factory HandoverTokenModel.fromJson(Map<String, dynamic> json) {
    return HandoverTokenModel(
      tokenId: json['token_id'] ?? json['id'] ?? '',
      meetupId: json['meetup_id'] ?? '',
      token: json['token'] ?? '',
      issuedAt: json['issued_at'] != null 
          ? DateTime.parse(json['issued_at']) 
          : DateTime.now(),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : DateTime.now().add(const Duration(minutes: 5)),
      usedAt: json['used_at'] != null ? DateTime.parse(json['used_at']) : null,
      status: json['status'] ?? 'active',
      proofNumber: json['proof_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token_id': tokenId,
      'meetup_id': meetupId,
      'token': token,
      'issued_at': issuedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
      'status': status,
      'proof_number': proofNumber,
    };
  }

  HandoverTokenModel copyWith({
    String? tokenId,
    String? meetupId,
    String? token,
    DateTime? issuedAt,
    DateTime? expiresAt,
    DateTime? usedAt,
    String? status,
    String? proofNumber,
  }) {
    return HandoverTokenModel(
      tokenId: tokenId ?? this.tokenId,
      meetupId: meetupId ?? this.meetupId,
      token: token ?? this.token,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt ?? this.usedAt,
      status: status ?? this.status,
      proofNumber: proofNumber ?? this.proofNumber,
    );
  }
}

class MeetupDetailModel {
  final String meetupId;
  final String locationTitle;
  final String locationSub;
  final String scheduledDate;
  final String scheduledTime;
  final String status; // 'Dikonfirmasi', 'Selesai', 'Dibatalkan'
  
  // Item details
  final String itemName;
  final String itemCategory;
  final String itemGrade;
  final String itemPrice;
  final String? itemImageUrl;

  // Partner / Buyer details
  final String partnerName;
  final String partnerNim;
  final String partnerFaculty;
  final double partnerRating;
  final int partnerCompletedDeals;
  final bool isPartnerVerified;

  MeetupDetailModel({
    required this.meetupId,
    required this.locationTitle,
    required this.locationSub,
    required this.scheduledDate,
    required this.scheduledTime,
    this.status = 'Dikonfirmasi',
    required this.itemName,
    required this.itemCategory,
    required this.itemGrade,
    required this.itemPrice,
    this.itemImageUrl,
    required this.partnerName,
    required this.partnerNim,
    required this.partnerFaculty,
    required this.partnerRating,
    required this.partnerCompletedDeals,
    this.isPartnerVerified = true,
  });

  factory MeetupDetailModel.sample() {
    return MeetupDetailModel(
      meetupId: 'MEET-2026-0891',
      locationTitle: 'Pos Satpam Gedung A (Lobby Utama)',
      locationSub: 'Area Terpantau CCTV Kampus • Bebas Biaya Parkir Mahasiswa',
      scheduledDate: 'Hari Ini',
      scheduledTime: '14:30 WIB',
      status: 'Dikonfirmasi',
      itemName: 'Kalkulator Saintifik Casio fx-991EX',
      itemCategory: 'Jual (COD Tunai di Lokasi)',
      itemGrade: 'Grade A+',
      itemPrice: 'Rp 180.000',
      itemImageUrl: null,
      partnerName: 'Dimas FTI',
      partnerNim: '2411522019',
      partnerFaculty: 'F. Teknologi Info',
      partnerRating: 4.9,
      partnerCompletedDeals: 14,
      isPartnerVerified: true,
    );
  }
}
