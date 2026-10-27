import 'item_model.dart';

/// Ringkasan listing untuk bagian "Barang Terbaru" di Beranda.
/// Dibentuk dari listing Modul 1 ([ItemModel]) lewat [ListingSummary.fromItem].
class ListingSummary {
  final String id;
  final String title;
  final String
  category; // Buku & Referensi, Furnitur Kos, Elektronik, Alat Perkuliahan
  final String faculty;
  final int price;
  final int ownerId;
  final String ownerName;
  final String condition; // Baru, Sangat Baik, Baik, Cukup

  const ListingSummary({
    required this.id,
    required this.title,
    required this.category,
    required this.faculty,
    required this.price,
    required this.ownerId,
    required this.ownerName,
    this.condition = 'Baik',
  });

  /// Listing Modul 1 belum membawa data fakultas, jadi baris kedua kartu
  /// menampilkan kondisi barang.
  factory ListingSummary.fromItem(ItemModel item) {
    return ListingSummary(
      id: item.id,
      title: item.title,
      category: item.category,
      faculty: 'Kondisi: ${item.condition}',
      price: item.price,
      ownerId: int.tryParse(item.ownerId) ?? 0,
      ownerName: item.ownerName.isEmpty ? 'Pemilik Barang' : item.ownerName,
      condition: item.condition,
    );
  }

  factory ListingSummary.fromJson(Map<String, dynamic> json) {
    return ListingSummary(
      id: json['id'].toString(),
      title: json['title'] as String,
      category: json['category'] as String,
      faculty: json['faculty'] as String,
      price: (json['price'] as num).toInt(),
      ownerId: (json['owner_id'] as num).toInt(),
      ownerName: json['owner_name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'faculty': faculty,
    'price': price,
    'owner_id': ownerId,
    'owner_name': ownerName,
  };
}
