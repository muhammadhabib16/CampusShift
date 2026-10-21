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
    const totalDurationSeconds = 300.0; // 5 menit = 300 detik (FR-17)
    final remaining = remainingSeconds.toDouble();
    return (remaining / totalDurationSeconds).clamp(0.0, 1.0);
  }

  factory HandoverTokenModel.fromJson(Map<String, dynamic> json) {
    return HandoverTokenModel(
      tokenId: (json['token_id'] ?? json['id'] ?? '').toString(),
      meetupId: (json['meetup_id'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'].toString())
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'].toString())
          : DateTime.now().add(const Duration(minutes: 5)),
      usedAt: json['used_at'] != null
          ? DateTime.parse(json['used_at'].toString())
          : null,
      status: (json['status'] ?? 'active').toString(),
      proofNumber: json['proof_number']?.toString(),
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