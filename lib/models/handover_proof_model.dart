import '../utils/formatters.dart';
import 'review_model.dart';

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

  /// Ulasan pada transaksi ini (hanya tersedia dari server).
  final ReviewModel? myReview;
  final ReviewModel? partnerReview;

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
    this.myReview,
    this.partnerReview,
  });

  /// Membaca bukti serah terima dari `GET /handover/history` (serializeProof
  /// di backend). Bukti diterbitkan dan diverifikasi oleh server (BR-24).
  factory HandoverProofModel.fromServer(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;
    Map<String, dynamic> obj(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

    final owner = obj(json['owner']);
    final requester = obj(json['requester']);
    final point = obj(json['safe_meet_point']);
    final items = (json['items'] as List? ?? const [])
        .map((e) => obj(e))
        .toList();
    final itemType = (json['item_type'] ?? 'Jual').toString();
    final proofNumber = (json['proof_number'] ?? '-').toString();

    final String price;
    if (itemType == 'Barter') {
      final topUp = toInt(json['cash_top_up']);
      price = topUp > 0 ? 'Top-up ${formatRupiah(topUp)}' : 'Tanpa selisih tunai';
    } else if (itemType == 'Hibah') {
      price = 'Gratis (Hibah)';
    } else {
      price = formatRupiah(toInt(json['item_price']));
    }

    final meetupId = toInt(json['meetup_id']);
    ReviewModel? review(dynamic v) => v is Map
        ? ReviewModel.fromServer(
            Map<String, dynamic>.from(v),
            proofNumber: proofNumber,
          )
        : null;

    return HandoverProofModel(
      proofNumber: proofNumber,
      meetupId: meetupId,
      itemId: items.isEmpty ? 0 : toInt(items.first['id']),
      itemTitle: items.isEmpty
          ? 'Barang'
          : items.map((i) => (i['title'] ?? '').toString()).join(' ⇄ '),
      itemPrice: price,
      itemType: itemType,
      ownerId: toInt(owner['id']),
      ownerName: (owner['full_name'] ?? '').toString(),
      ownerNim: (owner['nim'] ?? '').toString(),
      requesterId: toInt(requester['id']),
      requesterName: (requester['full_name'] ?? '').toString(),
      requesterNim: (requester['nim'] ?? '').toString(),
      safeMeetPointName: (point['name'] ?? '').toString(),
      validatedAt:
          (DateTime.tryParse('${json['validated_at'] ?? ''}') ?? DateTime.now())
              .toLocal(),
      tokenString: '',
      verificationHash: 'Terverifikasi server CampuShift • $proofNumber',
      myReview: review(json['my_review']),
      partnerReview: review(json['partner_review']),
    );
  }

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