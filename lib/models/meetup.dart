import 'package:intl/intl.dart';

import '../utils/formatters.dart';
import 'safe_meet_point.dart';

class Meetup {
  final int id;
  final int itemId;
  final String itemTitle;
  final String itemCategory;
  final String itemPrice;
  final String itemType; // 'Jual', 'Barter', 'Hibah'
  final int requesterId;
  final String requesterName;
  final String requesterNim;
  final int ownerId;
  final String ownerName;
  final String ownerNim;
  SafeMeetPoint safeMeetPoint;
  DateTime scheduledTime;
  String notes;
  String status; // 'Diajukan', 'Dikonfirmasi', 'Dibatalkan', 'Selesai'
  final DateTime createdAt;
  String? cancelledBy;
  String? cancellationReason;
  String itemStatus; // 'Available', 'Reserved', 'Completed'
  final int? dealId; // jalur Barter (Modul 3)
  final int? claimId; // jalur Hibah (Modul 5)

  Meetup({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    this.itemCategory = 'Perlengkapan Kuliah',
    this.itemPrice = 'Rp 120.000',
    this.itemType = 'Jual',
    required this.requesterId,
    required this.requesterName,
    this.requesterNim = '2411522023',
    required this.ownerId,
    required this.ownerName,
    this.ownerNim = '2411522020',
    required this.safeMeetPoint,
    required this.scheduledTime,
    this.notes = '',
    this.status = 'Diajukan',
    required this.createdAt,
    this.cancelledBy,
    this.cancellationReason,
    this.itemStatus = 'Available',
    this.dealId,
    this.claimId,
  });

  bool get isDiajukan => status == 'Diajukan';
  bool get isDikonfirmasi => status == 'Dikonfirmasi';
  bool get isDibatalkan => status == 'Dibatalkan';
  bool get isSelesai => status == 'Selesai';
  bool get isDitolak => status == 'Ditolak';

  String get formattedDateTime {
    final dateStr = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(scheduledTime);
    final timeStr = DateFormat('HH:mm').format(scheduledTime);
    return '$dateStr • $timeStr WIB';
  }

  String get formattedShortDateTime {
    final dateStr = DateFormat('d MMM yyyy, HH:mm').format(scheduledTime);
    return '$dateStr WIB';
  }

  // Clone with modified values for immutable update flow
  Meetup copyWith({
    SafeMeetPoint? safeMeetPoint,
    DateTime? scheduledTime,
    String? notes,
    String? status,
    String? cancelledBy,
    String? cancellationReason,
    String? itemStatus,
  }) {
    return Meetup(
      id: id,
      itemId: itemId,
      itemTitle: itemTitle,
      itemCategory: itemCategory,
      itemPrice: itemPrice,
      itemType: itemType,
      requesterId: requesterId,
      requesterName: requesterName,
      requesterNim: requesterNim,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerNim: ownerNim,
      safeMeetPoint: safeMeetPoint ?? this.safeMeetPoint,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      itemStatus: itemStatus ?? this.itemStatus,
      dealId: dealId,
      claimId: claimId,
    );
  }

  /// Membaca `serializeMeetup` dari backend. `item_price` dari server berupa
  /// angka (Rupiah) sedangkan data lokal menyimpan teks terformat.
  factory Meetup.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;
    int? toIntOrNull(dynamic v) => v == null ? null : int.tryParse('$v');
    DateTime toLocal(dynamic v) =>
        (DateTime.tryParse('${v ?? ''}') ?? DateTime.now()).toLocal();

    final rawPrice = json['item_price'];
    final itemType = json['item_type'] as String? ?? 'Jual';
    final String price;
    if (rawPrice is num) {
      price = itemType == 'Hibah' ? 'Gratis (Hibah)' : formatRupiah(rawPrice.toInt());
    } else {
      price = rawPrice as String? ?? 'Rp0';
    }

    return Meetup(
      id: toInt(json['id']),
      itemId: toInt(json['item_id']),
      itemTitle: json['item_title'] as String? ?? 'Barang Kuliah',
      itemCategory: json['item_category'] as String? ?? 'Akademik',
      itemPrice: price,
      itemType: itemType,
      requesterId: toInt(json['requester_id']),
      requesterName: json['requester_name'] as String? ?? 'Peminat',
      requesterNim: json['requester_nim'] as String? ?? '',
      ownerId: toInt(json['owner_id']),
      ownerName: json['owner_name'] as String? ?? 'Pemilik Barang',
      ownerNim: json['owner_nim'] as String? ?? '',
      safeMeetPoint: SafeMeetPoint.fromJson(
        Map<String, dynamic>.from(json['safe_meet_point'] as Map),
      ),
      scheduledTime: toLocal(json['scheduled_time']),
      notes: json['notes'] as String? ?? '',
      status: json['status'] as String? ?? 'Diajukan',
      createdAt: toLocal(json['created_at']),
      cancelledBy: json['cancelled_by'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      itemStatus: json['item_status'] as String? ?? 'Available',
      dealId: toIntOrNull(json['deal_id']),
      claimId: toIntOrNull(json['claim_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'item_title': itemTitle,
      'item_category': itemCategory,
      'item_price': itemPrice,
      'item_type': itemType,
      'requester_id': requesterId,
      'requester_name': requesterName,
      'requester_nim': requesterNim,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'owner_nim': ownerNim,
      'safe_meet_point': safeMeetPoint.toJson(),
      'scheduled_time': scheduledTime.toIso8601String(),
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'cancelled_by': cancelledBy,
      'cancellation_reason': cancellationReason,
      'item_status': itemStatus,
    };
  }
}
