/// Ringkasan listing untuk bagian "Barang Terbaru" di Beranda.
///
/// SEMENTARA sampai Modul 1 (Listing) masuk ke `main`; setelah itu Beranda
/// cukup memakai model listing dari Modul 1.
class ListingSummary {
  final String id;
  final String title;
  final String category; // Buku & Referensi, Furnitur Kos, Elektronik, Alat Perkuliahan
  final String faculty;
  final int price;
  final int ownerId;
  final String ownerName;

  const ListingSummary({
    required this.id,
    required this.title,
    required this.category,
    required this.faculty,
    required this.price,
    required this.ownerId,
    required this.ownerName,
  });

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
