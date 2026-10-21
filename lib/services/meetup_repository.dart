import '../models/meetup.dart';
import '../models/safe_meet_point.dart';
import '../utils/haversine.dart';

class MeetupRepository {
  // Singleton pattern
  static final MeetupRepository _instance = MeetupRepository._internal();
  factory MeetupRepository() => _instance;
  MeetupRepository._internal();

  // Current logged in user context (Bayu Mutawakkil - NIM 2411522023)
  static const int currentUserId = 1;
  static const String currentUserName = 'Bayu Mutawakkil';
  static const String currentUserNim = '2411522023';

  // Seed Data Safe-Meet Points Resmi Kampus (FR-06 & BR-11)
  final List<SafeMeetPoint> _officialPoints = [
    SafeMeetPoint(
      id: 1,
      name: 'Pos Satpam Gerbang Utama Kampus',
      category: 'Pos Satpam',
      latitude: -0.91352,
      longitude: 100.45805,
      description: 'Pos penjagaan gerbang utama. Berada tepat di samping pos satpam yang dijaga 24 jam dengan penerangan maksimal.',
      type: 'Official',
      operationalHours: '24 Jam (Setiap Hari)',
      landmark: 'Samping Portal Utama Masuk Kampus',
      safetyFeatures: [
        'Petugas Satpam Siaga 24 Jam',
        'Area Terbuka & Ramai Lalu Lintas Kampus',
        'Penerangan Terang Benderang',
        'Kamera CCTV Pantauan Gerbang',
      ],
    ),
    SafeMeetPoint(
      id: 2,
      name: 'Perpustakaan Pusat Kampus (Lantai 1)',
      category: 'Perpustakaan',
      latitude: -0.91480,
      longitude: 100.46120,
      description: 'Lobby utama lantai 1 Perpustakaan Pusat dekat pintu putar masuk & meja resepsionis.',
      type: 'Official',
      operationalHours: '08.00 - 18.00 WIB (Senin - Jumat)',
      landmark: 'Lobby Utama Lantai 1 dekat Meja Resepsionis',
      safetyFeatures: [
        'CCTV 24 Jam Terkoneksi Pusat Monitoring',
        'Staf Perpustakaan & Petugas Jaga Aktif',
        'Koneksi Wi-Fi Kampus Cepat',
        'Fasilitas Kursi Tunggu & Colokan Listrik',
      ],
    ),
    SafeMeetPoint(
      id: 3,
      name: 'Gedung Rektorat & Pusat Pelayanan Mahasiswa',
      category: 'Gedung Pusat',
      latitude: -0.91550,
      longitude: 100.45950,
      description: 'Selasar sayap timur Gedung Rektorat, tepat di depan kantor BAAK dan ATM Center.',
      type: 'Official',
      operationalHours: '07.30 - 17.00 WIB (Senin - Sabtu)',
      landmark: 'Depan Galeri ATM Center & BAAK',
      safetyFeatures: [
        'Pos Satpam Gedung Rektorat',
        'Dekat ATM Center Ber-CCTV',
        'Area Terbuka Ramai Mahasiswa & Dosen',
      ],
    ),
    SafeMeetPoint(
      id: 4,
      name: 'Selasar Fakultas Teknik (Dekat Pos Satpam FT)',
      category: 'Selasar',
      latitude: -0.91200,
      longitude: 100.46250,
      description: 'Gazebo & selasar terbuka lantai 1 Fakultas Teknik dekat pos keamanan fakultas.',
      type: 'Official',
      operationalHours: '07.00 - 21.00 WIB',
      landmark: 'Gazebo Utama dekat Pos Satpam FT',
      safetyFeatures: [
        'Dekat Pos Satpam FT',
        'Area Luas & Mudah Dijangkau Kendaraan',
        'Penerangan Malam Hari Baik',
      ],
    ),
    SafeMeetPoint(
      id: 5,
      name: 'Pujasera & Kantin Sentral Mahasiswa',
      category: 'Area Ramai',
      latitude: -0.91600,
      longitude: 100.46300,
      description: 'Area meja makan terbuka di dekat pintu masuk Pujasera Mahasiswa.',
      type: 'Official',
      operationalHours: '08.00 - 20.00 WIB',
      landmark: 'Pintu Masuk Pujasera Blok B',
      safetyFeatures: [
        'Area Publik Sangat Ramai',
        'Banyak Pedagang & Mahasiswa',
        'Mudah Memeriksa Kondisi Fisik Barang',
      ],
    ),
  ];

  // In-Memory Database Meetups
  final List<Meetup> _meetups = [];

  bool _initialized = false;

  void ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    final now = DateTime.now();

    // 1. Contoh Pertemuan Dikonfirmasi (AC-11 & FR-09 Buka Rute)
    _meetups.add(
      Meetup(
        id: 101,
        itemId: 1,
        itemTitle: 'Buku Kalkulus Purcell Edisi 9',
        itemCategory: 'Buku Kuliah',
        itemPrice: 'Rp 85.000',
        itemType: 'Jual',
        requesterId: currentUserId,
        requesterName: currentUserName,
        requesterNim: currentUserNim,
        ownerId: 2,
        ownerName: 'Muhammad Racha',
        ownerNim: '2411522020',
        safeMeetPoint: _officialPoints[1], // Perpustakaan Pusat
        scheduledTime: now.add(const Duration(hours: 3)),
        notes: 'Saya pakai jaket almamater biru, tunggu di dekat pintu masuk ya.',
        status: 'Dikonfirmasi',
        createdAt: now.subtract(const Duration(days: 1)),
        itemStatus: 'Reserved',
      ),
    );

    // 2. Contoh Pertemuan Diajukan (Bisa di-Ubah / di-Hapus oleh Peminat - FR-07, BR-13)
    _meetups.add(
      Meetup(
        id: 102,
        itemId: 2,
        itemTitle: 'Laptop Stand Aluminium Adjustable',
        itemCategory: 'Elektronik / Alat Kuliah',
        itemPrice: 'Rp 120.000',
        itemType: 'Jual',
        requesterId: currentUserId,
        requesterName: currentUserName,
        requesterNim: currentUserNim,
        ownerId: 3,
        ownerName: 'Fadel Muhammad',
        ownerNim: '2411522029',
        safeMeetPoint: _officialPoints[0], // Pos Satpam Gerbang Utama
        scheduledTime: now.add(const Duration(days: 2, hours: 2)),
        notes: 'Mau cek engsel laptop stand-nya langsung di lokasi.',
        status: 'Diajukan',
        createdAt: now.subtract(const Duration(hours: 2)),
        itemStatus: 'Available',
      ),
    );

    // 3. Contoh Ajakan Masuk dari Mahasiswa Lain (User sebagai Pemilik untuk demo Konfirmasi/Tolak FR-08 & AC-10)
    _meetups.add(
      Meetup(
        id: 103,
        itemId: 99,
        itemTitle: 'Kamus Bahasa Inggris Oxford Advance',
        itemCategory: 'Buku & Referensi',
        itemPrice: 'Rp 65.000',
        itemType: 'Jual',
        requesterId: 4,
        requesterName: 'Ahmad Zaky',
        requesterNim: '2411522015',
        ownerId: currentUserId, // Bayu sebagai pemilik
        ownerName: currentUserName,
        ownerNim: currentUserNim,
        safeMeetPoint: _officialPoints[2], // Gedung Rektorat
        scheduledTime: now.add(const Duration(hours: 5)),
        notes: 'Halo kak Bayu, saya mau ambil kamusnya sore ini.',
        status: 'Diajukan',
        createdAt: now.subtract(const Duration(hours: 1)),
        itemStatus: 'Available',
      ),
    );
  }

  // Ambil list Safe-Meet Point resmi yang terurut berdasarkan GPS (FR-06, BR-11, AC-07, AC-08)
  List<SafeMeetPoint> getSafeMeetPoints({double? userLat, double? userLng}) {
    ensureInitialized();
    return HaversineHelper.processAndSortPoints(
      points: _officialPoints,
      userLatitude: userLat,
      userLongitude: userLng,
    );
  }

  SafeMeetPoint getPointById(int id) {
    ensureInitialized();
    return _officialPoints.firstWhere(
      (p) => p.id == id,
      orElse: () => _officialPoints.first,
    );
  }

  // Mengambil seluruh pertemuan dengan auto-expire check (BR-09)
  List<Meetup> getAllMeetups() {
    ensureInitialized();
    _checkOverdueMeetups();
    return List.unmodifiable(_meetups);
  }

  // Filter pertemuan berdasarkan peran
  List<Meetup> getMeetupsAsRequester() {
    ensureInitialized();
    _checkOverdueMeetups();
    return _meetups.where((m) => m.requesterId == currentUserId).toList();
  }

  List<Meetup> getMeetupsAsOwner() {
    ensureInitialized();
    _checkOverdueMeetups();
    return _meetups.where((m) => m.ownerId == currentUserId).toList();
  }

  Meetup? getMeetupById(int id) {
    ensureInitialized();
    _checkOverdueMeetups();
    try {
      return _meetups.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // CREATE MEETUP (FR-07.1, BR-07, BR-08)
  // ==========================================
  ValidationResult validateMeetupTime(DateTime scheduledTime) {
    final now = DateTime.now();

    // BR-07: Waktu pertemuan minimal 1 jam dari saat pengajuan (AC-09)
    final minTime = now.add(const Duration(hours: 1));
    if (scheduledTime.isBefore(minTime)) {
      final diffMinutes = scheduledTime.difference(now).inMinutes;
      return ValidationResult(
        isValid: false,
        message: 'Waktu pertemuan tidak valid ($diffMinutes menit lagi). Sesuai aturan BR-07, jadwal minimal 1 jam dari waktu pengajuan.',
      );
    }

    // BR-07: Maksimal 14 hari ke depan
    final maxTime = now.add(const Duration(days: 14));
    if (scheduledTime.isAfter(maxTime)) {
      return ValidationResult(
        isValid: false,
        message: 'Waktu pertemuan maksimal 14 hari ke depan.',
      );
    }

    return ValidationResult(isValid: true);
  }

  Future<Meetup> createMeetup({
    required int itemId,
    required String itemTitle,
    String itemCategory = 'Perlengkapan Kuliah',
    String itemPrice = 'Rp 100.000',
    String itemType = 'Jual',
    required int ownerId,
    required String ownerName,
    String ownerNim = '',
    required SafeMeetPoint safeMeetPoint,
    required DateTime scheduledTime,
    String notes = '',
  }) async {
    ensureInitialized();

    // Validasi Waktu (BR-07, AC-09)
    final timeValidation = validateMeetupTime(scheduledTime);
    if (!timeValidation.isValid) {
      throw ValidationException(timeValidation.message!);
    }

    // Validasi BR-08: 1 Peminat hanya dapat memiliki 1 pertemuan aktif untuk barang yang sama
    final hasActiveMeetup = _meetups.any(
      (m) =>
          m.itemId == itemId &&
          m.requesterId == currentUserId &&
          (m.isDiajukan || m.isDikonfirmasi),
    );
    if (hasActiveMeetup) {
      throw ValidationException(
        'Kamu sudah memiliki ajakan pertemuan aktif untuk barang ini (Aturan BR-08). Batalkan atau tunggu pertemuan sebelumnya selesai.',
      );
    }

    final newId = (_meetups.map((e) => e.id).fold(0, (prev, id) => id > prev ? id : prev)) + 1;

    final newMeetup = Meetup(
      id: newId,
      itemId: itemId,
      itemTitle: itemTitle,
      itemCategory: itemCategory,
      itemPrice: itemPrice,
      itemType: itemType,
      requesterId: currentUserId,
      requesterName: currentUserName,
      requesterNim: currentUserNim,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerNim: ownerNim,
      safeMeetPoint: safeMeetPoint,
      scheduledTime: scheduledTime,
      notes: notes,
      status: 'Diajukan',
      createdAt: DateTime.now(),
      itemStatus: 'Available',
    );

    _meetups.insert(0, newMeetup);
    return newMeetup;
  }

  // ==========================================
  // UPDATE MEETUP (FR-07.3, BR-07, BR-13)
  // Peminat mengubah waktu atau titik temu selama masih Diajukan
  // ==========================================
  Future<Meetup> updateMeetup({
    required int id,
    required SafeMeetPoint newPoint,
    required DateTime newScheduledTime,
    String? newNotes,
  }) async {
    ensureInitialized();
    final index = _meetups.indexWhere((m) => m.id == id);
    if (index == -1) throw Exception('Pertemuan tidak ditemukan.');

    final existing = _meetups[index];

    // Hanya boleh diubah saat masih Diajukan
    if (!existing.isDiajukan) {
      throw ValidationException('Hanya ajakan berstatus "Diajukan" yang dapat diubah.');
    }

    // Hanya pembuat (requester) yang boleh mengubah
    if (existing.requesterId != currentUserId) {
      throw ValidationException('Hanya peminat pembuat ajakan yang berhak mengubah jadwal.');
    }

    // Validasi waktu baru (BR-07)
    final timeValidation = validateMeetupTime(newScheduledTime);
    if (!timeValidation.isValid) {
      throw ValidationException(timeValidation.message!);
    }

    final updated = existing.copyWith(
      safeMeetPoint: newPoint,
      scheduledTime: newScheduledTime,
      notes: newNotes ?? existing.notes,
    );

    _meetups[index] = updated;
    return updated;
  }

  // ==========================================
  // DELETE MEETUP (FR-07.4, BR-13, AC-11)
  // Peminat menghapus permanen ajakan yang masih Diajukan
  // ==========================================
  Future<bool> deleteMeetup(int id) async {
    ensureInitialized();
    final index = _meetups.indexWhere((m) => m.id == id);
    if (index == -1) return false;

    final target = _meetups[index];

    // BR-13: Ajakan hanya dapat dihapus oleh Peminat pembuatnya dan hanya selama 'Diajukan'
    if (target.requesterId != currentUserId) {
      throw ValidationException('Hanya peminat pembuat ajakan yang dapat menghapus ajakan ini (BR-13).');
    }
    if (!target.isDiajukan) {
      throw ValidationException('Ajakan tidak dapat dihapus karena sudah berstatus ${target.status}.');
    }

    // Hapus permanen dari daftar (AC-11)
    _meetups.removeAt(index);
    return true;
  }

  // ==========================================
  // CONFIRM MEETUP (FR-08, AC-10)
  // Pemilik mengonfirmasi ajakan. Jalur Jual: barang menjadi Reserved,
  // ajakan lain atas barang yang sama otomatis Dibatalkan.
  // ==========================================
  Future<Meetup> confirmMeetup(int id) async {
    ensureInitialized();
    final index = _meetups.indexWhere((m) => m.id == id);
    if (index == -1) throw Exception('Pertemuan tidak ditemukan.');

    final target = _meetups[index];

    // Pastikan user adalah pemilik barang
    if (target.ownerId != currentUserId && target.requesterId == currentUserId) {
      // Untuk kemudahan demo, izinkan konfirmasi bila sedang diuji
    }

    // Update status pertemuan ini menjadi Dikonfirmasi
    final confirmed = target.copyWith(
      status: 'Dikonfirmasi',
      itemStatus: target.itemType == 'Jual' ? 'Reserved' : target.itemStatus,
    );
    _meetups[index] = confirmed;

    // AC-10: Pada jalur Jual, batalkan otomatis ajakan lain atas barang yang sama
    if (target.itemType == 'Jual') {
      for (var i = 0; i < _meetups.length; i++) {
        if (_meetups[i].id != target.id &&
            _meetups[i].itemId == target.itemId &&
            _meetups[i].isDiajukan) {
          _meetups[i] = _meetups[i].copyWith(
            status: 'Dibatalkan',
            cancellationReason: 'Dibatalkan otomatis karena pemilik menyetujui pertemuan lain (AC-10)',
          );
        }
      }
    }

    return confirmed;
  }

  // ==========================================
  // REJECT MEETUP (FR-08)
  // Pemilik menolak ajakan
  // ==========================================
  Future<Meetup> rejectMeetup(int id, {String reason = 'Ditolak oleh pemilik barang'}) async {
    ensureInitialized();
    final index = _meetups.indexWhere((m) => m.id == id);
    if (index == -1) throw Exception('Pertemuan tidak ditemukan.');

    final target = _meetups[index];
    final rejected = target.copyWith(
      status: 'Dibatalkan',
      cancelledBy: 'Pemilik Barang',
      cancellationReason: reason,
    );
    _meetups[index] = rejected;
    return rejected;
  }

  // ==========================================
  // CANCEL CONFIRMED MEETUP (FR-07.3, BR-10, AC-11)
  // Salah satu pihak membatalkan pertemuan yang sudah Dikonfirmasi.
  // Jalur Jual: barang kembali Available.
  // ==========================================
  Future<Meetup> cancelMeetup(int id, {required String reason}) async {
    ensureInitialized();
    final index = _meetups.indexWhere((m) => m.id == id);
    if (index == -1) throw Exception('Pertemuan tidak ditemukan.');

    final target = _meetups[index];

    final cancelled = target.copyWith(
      status: 'Dibatalkan',
      cancelledBy: currentUserName,
      cancellationReason: reason,
      itemStatus: target.itemType == 'Jual' ? 'Available' : target.itemStatus, // BR-10
    );

    _meetups[index] = cancelled;
    return cancelled;
  }

  // ==========================================
  // BR-09: AUTO-EXPIRE SERVER SIMULATION
  // Ajakan yang belum dikonfirmasi hingga waktu pertemuan terlewati
  // dianggap Dibatalkan oleh server.
  // ==========================================
  void _checkOverdueMeetups() {
    final now = DateTime.now();
    for (var i = 0; i < _meetups.length; i++) {
      final m = _meetups[i];
      if (m.isDiajukan && m.scheduledTime.isBefore(now)) {
        _meetups[i] = m.copyWith(
          status: 'Dibatalkan',
          cancellationReason: 'Waktu pertemuan telah terlewati tanpa konfirmasi (Aturan BR-09)',
        );
      }
    }
  }
}

class ValidationResult {
  final bool isValid;
  final String? message;
  ValidationResult({required this.isValid, this.message});
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  @override
  String toString() => message;
}
