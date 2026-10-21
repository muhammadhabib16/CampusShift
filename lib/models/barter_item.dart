/// Barang yang dapat ditukar dalam barter (Modul 3).
///
/// Model hanya menyimpan data. Tampilan seperti ikon dan warna kondisi
/// ditentukan di lapisan View.
class BarterItem {
  final String id;
  final String name;
  final int price;
  final String category; // Buku & Referensi, Furnitur Kos, Elektronik, Alat Perkuliahan
  final String condition; // Baru, Sangat Baik, Baik, Cukup

  const BarterItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.condition,
  });

  factory BarterItem.fromJson(Map<String, dynamic> json) {
    return BarterItem(
      id: json['id'].toString(),
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      category: json['category'] as String,
      condition: json['condition'] as String,
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
