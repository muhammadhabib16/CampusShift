import 'package:intl/intl.dart';
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
  });

  bool get isDiajukan => status == 'Diajukan';
  bool get isDikonfirmasi => status == 'Dikonfirmasi';
  bool get isDibatalkan => status == 'Dibatalkan';
  bool get isSelesai => status == 'Selesai';

  String get formattedDateTime {
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(scheduledTime);
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
    );
  }

  factory Meetup.fromJson(Map<String, dynamic> json) {
    return Meetup(
      id: json['id'] as int,
      itemId: json['item_id'] as int,
      itemTitle: json['item_title'] as String? ?? 'Barang Kuliah',
      itemCategory: json['item_category'] as String? ?? 'Akademik',
      itemPrice: json['item_price'] as String? ?? 'Rp 0',
      itemType: json['item_type'] as String? ?? 'Jual',
      requesterId: json['requester_id'] as int,
      requesterName: json['requester_name'] as String? ?? 'Peminat',
      requesterNim: json['requester_nim'] as String? ?? '',
      ownerId: json['owner_id'] as int,
      ownerName: json['owner_name'] as String? ?? 'Pemilik Barang',
      ownerNim: json['owner_nim'] as String? ?? '',
      safeMeetPoint: SafeMeetPoint.fromJson(json['safe_meet_point'] as Map<String, dynamic>),
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      notes: json['notes'] as String? ?? '',
      status: json['status'] as String? ?? 'Diajukan',
      createdAt: DateTime.parse(json['created_at'] as String),
      cancelledBy: json['cancelled_by'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      itemStatus: json['item_status'] as String? ?? 'Available',
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
