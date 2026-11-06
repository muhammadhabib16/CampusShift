/// Barang yang dapat ditukar dalam barter (Modul 3).
///
/// Model hanya menyimpan data. Tampilan seperti ikon dan warna kondisi
/// ditentukan di lapisan View.
class BarterItem {
  final String id;
  final String name;
  final int price;
  final String
  category; // Buku & Referensi, Furnitur Kos, Elektronik, Alat Perkuliahan
  final String condition; // Baru, Sangat Baik, Baik, Cukup
  final String? photoUrl;

  const BarterItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.condition,
    this.photoUrl,
  });

  factory BarterItem.fromJson(Map<String, dynamic> json) {
    return BarterItem(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      price: (json['price'] as num? ?? 0).toInt(),
      category: (json['category'] ?? '').toString(),
      condition: (json['condition'] ?? '').toString(),
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'category': category,
    'condition': condition,
  };
}
