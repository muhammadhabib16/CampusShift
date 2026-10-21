/// Model Bukti Serah Terima Digital (FR-19 & BR-24).
/// Bukti ini bersifat immutable (tidak dapat diubah atau dihapus).
class HandoverProofModel {
  final String proofNumber; // Nomor bukti unik, misal PRF-202610-1011
  final int meetupId;
  final int itemId;
  final String itemTitle;
  final String itemPrice;
  final String itemType; // 'Jual', 'Barter', 'Hibah'
  final int ownerId;
  final String ownerName;
  final String ownerNim;
  final int requesterId;
  final String requesterName;
  final String requesterNim;
  final String safeMeetPointName;
  final DateTime validatedAt;
  final String tokenString;
  final String verificationHash;

  HandoverProofModel({
    required this.proofNumber,
    required this.meetupId,
    required this.itemId,
    required this.itemTitle,
    required this.itemPrice,
    required this.itemType,
    required this.ownerId,
    required this.ownerName,
    required this.ownerNim,
    required this.requesterId,
    required this.requesterName,
    required this.requesterNim,
    required this.safeMeetPointName,
    required this.validatedAt,
    required this.tokenString,
    required this.verificationHash,
  });

  factory HandoverProofModel.fromJson(Map<String, dynamic> json) {
    return HandoverProofModel(
      proofNumber: json['proof_number'] as String,
      meetupId: json['meetup_id'] as int,
      itemId: json['item_id'] as int,
      itemTitle: json['item_title'] as String,
      itemPrice: json['item_price'] as String? ?? 'Rp 0',
      itemType: json['item_type'] as String? ?? 'Jual',
      ownerId: json['owner_id'] as int,
      ownerName: json['owner_name'] as String,
      ownerNim: json['owner_nim'] as String? ?? '',
      requesterId: json['requester_id'] as int,
      requesterName: json['requester_name'] as String,
      requesterNim: json['requester_nim'] as String? ?? '',
      safeMeetPointName: json['safe_meet_point_name'] as String,
      validatedAt: DateTime.parse(json['validated_at'] as String),
      tokenString: json['token_string'] as String,
      verificationHash: json['verification_hash'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proof_number': proofNumber,
      'meetup_id': meetupId,
      'item_id': itemId,
      'item_title': itemTitle,
      'item_price': itemPrice,
      'item_type': itemType,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'owner_nim': ownerNim,
      'requester_id': requesterId,
      'requester_name': requesterName,
      'requester_nim': requesterNim,
      'safe_meet_point_name': safeMeetPointName,
      'validated_at': validatedAt.toIso8601String(),
      'token_string': tokenString,
      'verification_hash': verificationHash,
    };
  }
}