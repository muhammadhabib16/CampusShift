class SafeMeetPoint {
  final int id;
  final String name;
  final String category; // 'Pos Satpam', 'Perpustakaan', 'Gedung Pusat', 'Selasar'
  final double latitude;
  final double longitude;
  final String description;
  final String type; // 'Official' / 'Resmi Kampus'
  final List<String> safetyFeatures;
  final String operationalHours;
  final String landmark;

  // Nilai jarak dinamis dihitung menggunakan formula Haversine dari posisi GPS pengguna
  double? distanceInMeters;

  SafeMeetPoint({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.type = 'Official',
    this.safetyFeatures = const [],
    this.operationalHours = '07.00 - 21.00 WIB',
    this.landmark = '',
    this.distanceInMeters,
  });

  // Format jarak sesuai BR-11:
  // Dibulatkan ke meter, jika >= 1.000 m ditampilkan dalam km, jika null '—'
  String get formattedDistance {
    if (distanceInMeters == null) return '—';
    if (distanceInMeters! >= 1000) {
      final km = distanceInMeters! / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
    return '${distanceInMeters!.round()} m';
  }

  factory SafeMeetPoint.fromJson(Map<String, dynamic> json) {
    return SafeMeetPoint(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'Official',
      operationalHours: json['operational_hours'] as String? ?? '07.00 - 21.00 WIB',
      landmark: json['landmark'] as String? ?? '',
      safetyFeatures: json['safety_features'] != null
          ? List<String>.from(json['safety_features'] as List)
          : [
              'Tercover CCTV 24 Jam',
              'Area Terbuka & Ramai',
              'Dekat Penjagaan Satpam Kampus',
            ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'type': type,
      'safety_features': safetyFeatures,
      'operational_hours': operationalHours,
      'landmark': landmark,
    };
  }
}
