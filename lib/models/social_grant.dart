enum GrantAvailability { active, archived }

GrantAvailability availabilityFromString(String value) {
  switch (value) {
    case 'Archived':
      return GrantAvailability.archived;
    default:
      return GrantAvailability.active;
  }
}

String availabilityToString(GrantAvailability status) {
  return status == GrantAvailability.archived ? 'Archived' : 'Active';
}

/// Model untuk data hibah/donasi barang (FR-21).
/// Merepresentasikan entity "Social Grants" pada PRD 2.5 Data Requirements.
class SocialGrant {
  SocialGrant({
    required this.id,
    required this.donorUserId,
    required this.donorName,
    required this.itemName,
    required this.academicCategory,
    required this.description,
    required this.photoUrl,
    required this.quota,
    required this.availability,
    required this.createdAt,
  });

  final String id;
  final String donorUserId; // hanya ID user — dipakai utk referensi (low coupling)
  final String donorName; // label tampilan saja, di-join oleh backend, bukan dipakai utk referensi
  final String itemName;
  final String academicCategory;
  final String description;
  final String photoUrl;
  final int quota;
  final GrantAvailability availability;
  final DateTime createdAt;

  factory SocialGrant.fromJson(Map<String, dynamic> json) => SocialGrant(
        id: json['id'].toString(),
        donorUserId: json['donor_user_id'].toString(),
        donorName: json['donor_name'] as String? ?? '-',
        itemName: json['item_name'] as String,
        academicCategory: json['academic_category'] as String,
        description: json['description'] as String,
        photoUrl: json['photo_url'] as String,
        quota: json['quota'] as int,
        availability: availabilityFromString(json['availability_status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'item_name': itemName,
        'academic_category': academicCategory,
        'description': description,
        'quota': quota,
        'availability_status': availabilityToString(availability),
      };
}
