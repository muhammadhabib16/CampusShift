/// Data pengguna yang sedang login (Modul Pendukung: Autentikasi).
class User {
  final String id;
  final String fullName;
  final String nim;
  final String email;

  const User({
    required this.id,
    required this.fullName,
    required this.nim,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['user_id'] ?? json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['name'] ?? '') as String,
      nim: (json['nim'] ?? '').toString(),
      email: (json['email'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'nim': nim,
        'email': email,
      };
}
