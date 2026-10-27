class ItemModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String title;
  final String description;
  final String category;
  final String listingType; // 'Jual' atau 'Hibah'
  final int price;
  final bool isBarterOpen;
  final String condition;
  final List<String> photoUrls;
  final String status; // Available, Reserved, Completed, Archived

  ItemModel({
    required this.id,
    required this.ownerId,
    this.ownerName = '',
    required this.title,
    required this.description,
    required this.category,
    required this.listingType,
    required this.price,
    required this.isBarterOpen,
    required this.condition,
    required this.photoUrls,
    required this.status,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['item_id'].toString(),
      ownerId: json['owner_user_id'].toString(),
      ownerName: (json['owner_name'] ?? '').toString(),
      title: json['judul'] ?? '',
      description: json['deskripsi'] ?? '',
      category: json['kategori'] ?? '',
      listingType: json['tipe_listing'] ?? 'Jual',
      price: json['harga'] != null ? int.parse(json['harga'].toString()) : 0,
      isBarterOpen:
          json['terbuka_untuk_barter'] == 1 ||
          json['terbuka_untuk_barter'] == true,
      condition: json['kondisi'] ?? '',
      photoUrls: List<String>.from(json['url_foto'] ?? []),
      status: json['status'] ?? 'Available',
    );
  }
}
