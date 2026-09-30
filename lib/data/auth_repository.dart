class AuthRepository {
  // ================================
  // DATA DUMMY USER
  // ================================
  final List<Map<String, String>> _users = [
    {
      'fullName': 'Muhammad Racha Ardiwinata',
      'nim': '2411522020',
      'email': 'racha@gmail.com',
      'password': '12345678',
    },
    {
      'fullName': 'Bayu Mutawakkil',
      'nim': '2411522001',
      'email': 'bayu@gmail.com',
      'password': '12345678',
    },
    {
      'fullName': 'Ihsan',
      'nim': '2411522002',
      'email': 'ihsan@gmail.com',
      'password': '12345678',
    },
  ];

  // ================================
  // LOGIN
  // ================================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(
      const Duration(seconds: 1),
    );

    final input = email.trim().toLowerCase();

    Map<String, String>? user;

    for (final item in _users) {
      final itemEmail = item['email']!.toLowerCase();
      final itemNim = item['nim']!;

      if (itemEmail == input || itemNim == input) {
        user = item;
        break;
      }
    }

    if (user == null) {
      return {
        'success': false,
        'message': 'Email atau NIM tidak ditemukan.',
      };
    }

    if (user['password'] != password) {
      return {
        'success': false,
        'message': 'Password salah.',
      };
    }

    return {
      'success': true,
      'message': 'Login berhasil.',
      'user': user,
    };
  }

  // ================================
  // REGISTER
  // ================================
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String nim,
    required String email,
    required String password,
  }) async {
    await Future.delayed(
      const Duration(seconds: 1),
    );

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedNim = nim.trim();

    // Cek apakah email sudah digunakan
    final emailExists = _users.any(
      (user) =>
          user['email']!.toLowerCase() ==
          normalizedEmail,
    );

    if (emailExists) {
      return {
        'success': false,
        'message': 'Email sudah terdaftar.',
      };
    }

    // Cek apakah NIM sudah digunakan
    final nimExists = _users.any(
      (user) =>
          user['nim'] == normalizedNim,
    );

    if (nimExists) {
      return {
        'success': false,
        'message': 'NIM sudah terdaftar.',
      };
    }

    // Tambahkan user baru ke data dummy
    _users.add({
      'fullName': fullName.trim(),
      'nim': normalizedNim,
      'email': normalizedEmail,
      'password': password,
    });

    return {
      'success': true,
      'message': 'Registrasi berhasil.',
    };
  }

  // ================================
  // LOGOUT
  // ================================
  Future<void> logout() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );
  }

  // ================================
  // MENGAMBIL SEMUA USER
  // ================================
  Future<List<Map<String, String>>> getUsers() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    return List<Map<String, String>>.from(
      _users,
    );
  }
}