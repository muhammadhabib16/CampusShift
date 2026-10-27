class SocialGrant {
  final String id;
  final String ownerUserId;
  final String ownerName;
  final double ownerReputation;
  final String title;
  final String description;
  final String category; // Buku & Referensi, Furnitur Kos, Elektronik, Alat Perkuliahan
  final String condition; // Baru, Sangat Baik, Baik, Cukup
  final List<String> photoUrls; // 2-3 foto kamera (FR-02)
  final String status; // Available, Reserved, Completed, Archived
  final String listingType; // Hibah / Jual
  final DateTime createdAt;
  final DateTime updatedAt;

  SocialGrant({
    required this.id,
    required this.ownerUserId,
    this.ownerName = 'Mahasiswa Unand',
    this.ownerReputation = 5.0,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    this.photoUrls = const [],
    this.status = 'Available',
    this.listingType = 'Hibah',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Getter kompatibilitas dengan kode lama
  String get itemId => id;
  String get donorId => ownerUserId;
  String get donorName => ownerName;
  String get imageUrl => photoUrls.isNotEmpty ? photoUrls.first : '';
  bool get isAvailable => status.toLowerCase() == 'available';

  factory SocialGrant.fromJson(Map<String, dynamic> json) {
    List<String> photos = [];
    if (json['photo_urls'] is List) {
      photos = List<String>.from(json['photo_urls'].map((e) => e.toString()));
    } else if (json['photoUrls'] is List) {
      photos = List<String>.from(json['photoUrls'].map((e) => e.toString()));
    } else if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      photos = [json['image_url'].toString()];
    }

    return SocialGrant(
      id: (json['item_id'] ?? json['id'] ?? '').toString(),
      ownerUserId: (json['owner_user_id'] ?? json['ownerUserId'] ?? json['donor_id'] ?? '').toString(),
      ownerName: (json['owner_name'] ?? json['ownerName'] ?? json['donor_name'] ?? 'Mahasiswa Unand').toString(),
      ownerReputation: double.tryParse((json['owner_reputation'] ?? json['ownerReputation'] ?? 5.0).toString()) ?? 5.0,
      title: (json['judul'] ?? json['title'] ?? '').toString(),
      description: (json['deskripsi'] ?? json['description'] ?? '').toString(),
      category: (json['kategori'] ?? json['category'] ?? 'Buku & Referensi').toString(),
      condition: (json['kondisi'] ?? json['condition'] ?? 'Baik').toString(),
      photoUrls: photos,
      status: (json['status'] ?? 'Available').toString(),
      listingType: (json['tipe_listing'] ?? json['listingType'] ?? 'Hibah').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': id,
      'owner_user_id': ownerUserId,
      'owner_name': ownerName,
      'owner_reputation': ownerReputation,
      'judul': title,
      'deskripsi': description,
      'kategori': category,
      'kondisi': condition,
      'photo_urls': photoUrls,
      'status': status,
      'tipe_listing': listingType,
      'harga': 0,
      'terbuka_untuk_barter': false,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SocialGrant copyWith({
    String? id,
    String? ownerUserId,
    String? ownerName,
    double? ownerReputation,
    String? title,
    String? description,
    String? category,
    String? condition,
    List<String>? photoUrls,
    String? status,
    String? listingType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialGrant(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerName: ownerName ?? this.ownerName,
      ownerReputation: ownerReputation ?? this.ownerReputation,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      photoUrls: photoUrls ?? this.photoUrls,
      status: status ?? this.status,
      listingType: listingType ?? this.listingType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
