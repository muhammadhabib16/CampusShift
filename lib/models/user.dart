/// Data pengguna yang sedang login (Modul Pendukung: Autentikasi).
class User {
  final String id;
  final String fullName;
  final String nim;
  final String email;
  final String phone;

  /// Bio singkat (maks. 160 karakter), tampil di profil publik.
  final String bio;

  /// URL foto profil; null bila belum ada.
  final String? photoUrl;

  const User({
    required this.id,
    required this.fullName,
    required this.nim,
    required this.email,
    this.phone = '',
    this.bio = '',
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['user_id'] ?? json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['name'] ?? '').toString(),
      nim: (json['nim'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      photoUrl: _nonEmpty(json['profile_photo_url']),
    );
  }

  static String? _nonEmpty(dynamic v) {
    final s = v?.toString() ?? '';
    return s.isEmpty ? null : s;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'nim': nim,
    'email': email,
    'phone': phone,
    'bio': bio,
    'profile_photo_url': photoUrl,
  };
}
