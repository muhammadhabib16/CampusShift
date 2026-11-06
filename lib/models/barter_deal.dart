import 'package:intl/intl.dart';

import 'barter_item.dart';

/// Tawaran barter milik pengguna (Modul 3), dilihat dari sisi pengguna:
/// [myItem] adalah barang milik sendiri, [partnerItem] barang milik mitra.
class BarterDeal {
  final String id;
  final int partnerUserId;
  final String partnerName;
  final BarterItem myItem;
  final BarterItem partnerItem;
  final int cashTopUp;
  final bool topUpPaidByMe;
  final bool
  isSentByMe; // true: tab Dikirim (Pengaju), false: tab Diterima (Penerima)
  final String
  status; // Menunggu, Negosiasi, Terkunci, Ditolak, Dibatalkan, Selesai
  final bool myConfirmed;
  final bool partnerConfirmed;
  final String dateLabel;

  /// Aksi yang diizinkan server (`can_*` pada serializeBarter). Null pada
  /// data contoh lokal — ViewModel lalu memakai aturan bawaan.
  final bool? canConfirm;
  final bool? canReject;
  final bool? canCancel;
  final bool? canDelete;

  const BarterDeal({
    required this.id,
    this.partnerUserId = 0,
    required this.partnerName,
    required this.myItem,
    required this.partnerItem,
    required this.cashTopUp,
    required this.topUpPaidByMe,
    required this.isSentByMe,
    required this.status,
    required this.myConfirmed,
    required this.partnerConfirmed,
    required this.dateLabel,
    this.canConfirm,
    this.canReject,
    this.canCancel,
    this.canDelete,
  });

  BarterDeal copyWith({
    String? status,
    bool? myConfirmed,
    bool? partnerConfirmed,
  }) {
    return BarterDeal(
      id: id,
      partnerUserId: partnerUserId,
      partnerName: partnerName,
      myItem: myItem,
      partnerItem: partnerItem,
      cashTopUp: cashTopUp,
      topUpPaidByMe: topUpPaidByMe,
      isSentByMe: isSentByMe,
      status: status ?? this.status,
      myConfirmed: myConfirmed ?? this.myConfirmed,
      partnerConfirmed: partnerConfirmed ?? this.partnerConfirmed,
      dateLabel: dateLabel,
      canConfirm: canConfirm,
      canReject: canReject,
      canCancel: canCancel,
      canDelete: canDelete,
    );
  }

  /// Membaca `serializeBarter` dari backend. Status yang dipakai UI adalah
  /// label Indonesia (`status_label`: Menunggu, Negosiasi, Terkunci, ...).
  factory BarterDeal.fromJson(Map<String, dynamic> json) {
    String dateLabel = (json['date_label'] ?? '').toString();
    if (dateLabel.isEmpty) {
      final at = DateTime.tryParse('${json['updated_at'] ?? json['created_at'] ?? ''}');
      dateLabel = at == null
          ? ''
          : '${DateFormat('d MMM yyyy, HH:mm').format(at.toLocal())} WIB';
    }

    return BarterDeal(
      id: json['id'].toString(),
      partnerUserId: int.tryParse('${json['partner_user_id'] ?? ''}') ?? 0,
      partnerName: (json['partner_name'] ?? 'Mitra Barter').toString(),
      myItem: BarterItem.fromJson(Map<String, dynamic>.from(json['my_item'] as Map)),
      partnerItem: BarterItem.fromJson(
        Map<String, dynamic>.from(json['partner_item'] as Map),
      ),
      cashTopUp: (json['cash_top_up'] as num? ?? 0).toInt(),
      topUpPaidByMe: json['top_up_paid_by_me'] as bool? ?? false,
      isSentByMe: json['is_sent_by_me'] as bool? ?? false,
      status: (json['status_label'] ?? json['status'] ?? 'Menunggu').toString(),
      myConfirmed: json['my_confirmed'] as bool? ?? false,
      partnerConfirmed: json['partner_confirmed'] as bool? ?? false,
      dateLabel: dateLabel,
      canConfirm: json['can_confirm'] as bool?,
      canReject: json['can_reject'] as bool?,
      canCancel: json['can_cancel'] as bool?,
      canDelete: json['can_delete'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'partner_user_id': partnerUserId,
    'partner_name': partnerName,
    'my_item': myItem.toJson(),
    'partner_item': partnerItem.toJson(),
    'cash_top_up': cashTopUp,
    'top_up_paid_by_me': topUpPaidByMe,
    'is_sent_by_me': isSentByMe,
    'status': status,
    'my_confirmed': myConfirmed,
    'partner_confirmed': partnerConfirmed,
    'date_label': dateLabel,
  };
}
