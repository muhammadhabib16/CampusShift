import 'barter_item.dart';

/// Tawaran barter milik pengguna (Modul 3), dilihat dari sisi pengguna:
/// [myItem] adalah barang milik sendiri, [partnerItem] barang milik mitra.
class BarterDeal {
  final String id;
  final String partnerName;
  final BarterItem myItem;
  final BarterItem partnerItem;
  final int cashTopUp;
  final bool topUpPaidByMe;
  final bool isSentByMe; // true: tab Dikirim (Pengaju), false: tab Diterima (Penerima)
  final String status; // Menunggu, Negosiasi, Terkunci, Ditolak, Dibatalkan, Selesai
  final bool myConfirmed;
  final bool partnerConfirmed;
  final String dateLabel;

  const BarterDeal({
    required this.id,
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
  });

  BarterDeal copyWith({String? status, bool? myConfirmed, bool? partnerConfirmed}) {
    return BarterDeal(
      id: id,
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
    );
  }

  factory BarterDeal.fromJson(Map<String, dynamic> json) {
    return BarterDeal(
      id: json['id'].toString(),
      partnerName: json['partner_name'] as String,
      myItem: BarterItem.fromJson(json['my_item'] as Map<String, dynamic>),
      partnerItem: BarterItem.fromJson(json['partner_item'] as Map<String, dynamic>),
      cashTopUp: (json['cash_top_up'] as num).toInt(),
      topUpPaidByMe: json['top_up_paid_by_me'] as bool,
      isSentByMe: json['is_sent_by_me'] as bool,
      status: json['status'] as String,
      myConfirmed: json['my_confirmed'] as bool,
      partnerConfirmed: json['partner_confirmed'] as bool,
      dateLabel: json['date_label'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
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
