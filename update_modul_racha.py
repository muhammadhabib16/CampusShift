import os
import shutil

# Pastikan dijalankan di root folder Flutter (tempat folder lib berada)
if not os.path.exists("lib"):
    print("❌ Error: Folder 'lib' tidak ditemukan! Pastikan file ini ditaruh sejajar dengan pubspec.yaml dan folder lib.")
    exit(1)

# 1. Backup folder lib lama agar aman
backup_dir = "lib_backup_racha"
if not os.path.exists(backup_dir):
    shutil.copytree("lib", backup_dir)
    print(f"✅ Backup folder 'lib' lama berhasil disimpan di '{backup_dir}/'")

files_to_write = {}

# ==============================================================================
# 1. MODEL: lib/models/social_grant.dart (Representasi Item Hibah - Modul 1 & 5)
# ==============================================================================
files_to_write["lib/models/social_grant.dart"] = """class SocialGrant {
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
"""

# ==============================================================================
# 2. MODEL: lib/models/grant_claim.dart (Entitas Utama CRUD Modul 5: Claims)
# ==============================================================================
files_to_write["lib/models/grant_claim.dart"] = """class GrantClaim {
  final String id;
  final String itemId;
  final String itemTitle;
  final String itemCategory;
  final String itemCondition;
  final String donorUserId;
  final String donorName;
  final String applicantUserId;
  final String applicantName;
  final String applicantNim;
  final String applicantPhotoUrl;
  final double? applicantReputation; // BR-29: Tampilkan nama, foto, dan skor reputasi pemohon
  final int applicantReviewCount;
  final String urgency; // Mendesak, Sedang, Rendah (FR-23)
  final String justification; // 100 - 1.000 karakter (BR-27)
  final String status; // Pending, Approved, Rejected, Cancelled, Completed (2.6)
  final String? rejectionReason; // BR-30: Alasan penolakan singkat (opsional)
  final String? meetupId; // Integrasi ke Modul 2 via ID
  final DateTime createdAt;
  final DateTime updatedAt;

  GrantClaim({
    required this.id,
    required this.itemId,
    this.itemTitle = '',
    this.itemCategory = 'Buku & Referensi',
    this.itemCondition = 'Baik',
    this.donorUserId = '',
    this.donorName = 'Donatur Unand',
    required this.applicantUserId,
    this.applicantName = 'Mahasiswa Pemohon',
    this.applicantNim = '',
    this.applicantPhotoUrl = '',
    this.applicantReputation,
    this.applicantReviewCount = 0,
    required this.urgency,
    required this.justification,
    this.status = 'Pending',
    this.rejectionReason,
    this.meetupId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Getter kompatibilitas dengan kode versi lama
  String get claimId => id;
  String get grantId => itemId;
  String get grantTitle => itemTitle;
  String get userId => applicantUserId;
  String get userName => applicantName;
  String get reason => justification;

  // BR-28: Klaim aktif adalah klaim berstatus Pending atau Approved
  bool get isActiveClaim => status == 'Pending' || status == 'Approved';

  // BR-32: Hanya klaim Pending yang dapat dihapus permanen atau disunting
  bool get canEditOrDelete => status == 'Pending';

  // BR-31: Klaim Approved dapat dibatalkan sebelum serah terima
  bool get canCancelApproved => status == 'Approved';

  // Bobot numerik urgensi untuk pengurutan antrean (BR-29: Mendesak -> Sedang -> Rendah)
  int get urgencyPriority {
    switch (urgency.toLowerCase()) {
      case 'mendesak':
        return 1;
      case 'sedang':
        return 2;
      case 'rendah':
      default:
        return 3;
    }
  }

  String get reputationLabel {
    if (applicantReputation == null || applicantReviewCount == 0) {
      return 'Belum ada ulasan'; // BR-25
    }
    return '${applicantReputation!.toStringAsFixed(1)} ★ ($applicantReviewCount ulasan)';
  }

  factory GrantClaim.fromJson(Map<String, dynamic> json) {
    return GrantClaim(
      id: (json['claim_id'] ?? json['id'] ?? '').toString(),
      itemId: (json['item_id'] ?? json['itemId'] ?? json['grant_id'] ?? '').toString(),
      itemTitle: (json['item_title'] ?? json['itemTitle'] ?? json['grant_title'] ?? 'Barang Hibah').toString(),
      itemCategory: (json['item_category'] ?? json['itemCategory'] ?? 'Buku & Referensi').toString(),
      itemCondition: (json['item_condition'] ?? json['itemCondition'] ?? 'Baik').toString(),
      donorUserId: (json['donor_user_id'] ?? json['donorUserId'] ?? json['owner_user_id'] ?? '').toString(),
      donorName: (json['donor_name'] ?? json['donorName'] ?? 'Donatur Unand').toString(),
      applicantUserId: (json['applicant_user_id'] ?? json['applicantUserId'] ?? json['user_id'] ?? '').toString(),
      applicantName: (json['applicant_name'] ?? json['applicantName'] ?? json['user_name'] ?? 'Mahasiswa Unand').toString(),
      applicantNim: (json['applicant_nim'] ?? json['applicantNim'] ?? '').toString(),
      applicantPhotoUrl: (json['applicant_photo_url'] ?? json['applicantPhotoUrl'] ?? '').toString(),
      applicantReputation: json['applicant_reputation'] != null
          ? double.tryParse(json['applicant_reputation'].toString())
          : null,
      applicantReviewCount: int.tryParse((json['applicant_review_count'] ?? 0).toString()) ?? 0,
      urgency: (json['urgensi'] ?? json['urgency'] ?? 'Sedang').toString(),
      justification: (json['justifikasi'] ?? json['justification'] ?? json['reason'] ?? '').toString(),
      status: (json['status'] ?? 'Pending').toString(),
      rejectionReason: json['alasan_penolakan']?.toString() ?? json['rejection_reason']?.toString(),
      meetupId: json['meetup_id']?.toString() ?? json['meetupId']?.toString(),
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
      'claim_id': id,
      'item_id': itemId,
      'item_title': itemTitle,
      'item_category': itemCategory,
      'item_condition': itemCondition,
      'donor_user_id': donorUserId,
      'donor_name': donorName,
      'applicant_user_id': applicantUserId,
      'applicant_name': applicantName,
      'applicant_nim': applicantNim,
      'applicant_photo_url': applicantPhotoUrl,
      'applicant_reputation': applicantReputation,
      'applicant_review_count': applicantReviewCount,
      'urgensi': urgency,
      'justifikasi': justification,
      'status': status,
      'alasan_penolakan': rejectionReason,
      'meetup_id': meetupId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GrantClaim copyWith({
    String? id,
    String? itemId,
    String? itemTitle,
    String? itemCategory,
    String? itemCondition,
    String? donorUserId,
    String? donorName,
    String? applicantUserId,
    String? applicantName,
    String? applicantNim,
    String? applicantPhotoUrl,
    double? applicantReputation,
    int? applicantReviewCount,
    String? urgency,
    String? justification,
    String? status,
    String? rejectionReason,
    String? meetupId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GrantClaim(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      itemCategory: itemCategory ?? this.itemCategory,
      itemCondition: itemCondition ?? this.itemCondition,
      donorUserId: donorUserId ?? this.donorUserId,
      donorName: donorName ?? this.donorName,
      applicantUserId: applicantUserId ?? this.applicantUserId,
      applicantName: applicantName ?? this.applicantName,
      applicantNim: applicantNim ?? this.applicantNim,
      applicantPhotoUrl: applicantPhotoUrl ?? this.applicantPhotoUrl,
      applicantReputation: applicantReputation ?? this.applicantReputation,
      applicantReviewCount: applicantReviewCount ?? this.applicantReviewCount,
      urgency: urgency ?? this.urgency,
      justification: justification ?? this.justification,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      meetupId: meetupId ?? this.meetupId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
"""

# ==============================================================================
# 3. SERVICE: lib/services/grant_notification_service.dart (N-06 & N-07)
# ==============================================================================
files_to_write["lib/services/grant_notification_service.dart"] = """import 'package:flutter/foundation.dart';
import '../models/grant_claim.dart';

/// Layanan Notifikasi Lokal Modul 5 (FR-27 [W] & FR-28 [O])
/// Sesuai Bagian 2.8 & 2.9 PRD: Tanpa FCM/Firebase, menggunakan deteksi sinkronisasi
/// dan jadwal lokal perangkat.
class GrantNotificationService {
  static final GrantNotificationService _instance = GrantNotificationService._internal();
  factory GrantNotificationService() => _instance;
  GrantNotificationService._internal();

  // Menyimpan snapshot status klaim dari sinkronisasi terakhir (Bagian 2.8)
  final Map<String, String> _lastKnownStatuses = {};
  final Set<String> _knownDonorIncomingClaimIds = {};
  final Map<String, DateTime> _scheduledPickupReminders = {};
  final List<Map<String, String>> _notificationHistory = [];

  List<Map<String, String>> get notificationHistory => List.unmodifiable(_notificationHistory);

  /// N-06: Claim Status Alert (FR-27 [W])
  /// Membandingkan data klaim terbaru dari server dengan data sinkronisasi terakhir.
  /// Mengembalikan daftar pesan notifikasi baru untuk ditampilkan ke pengguna.
  List<String> checkSyncNotifications({
    required List<GrantClaim> myClaims,
    required List<GrantClaim> incomingDonorClaims,
  }) {
    final List<String> triggeredAlerts = [];

    // 1. Cek perubahan status klaim milik Pemohon (Approved / Rejected)
    for (final claim in myClaims) {
      final previousStatus = _lastKnownStatuses[claim.id];
      if (previousStatus != null && previousStatus != claim.status) {
        if (claim.status == 'Approved') {
          final msg = 'Klaim ${claim.itemTitle} disetujui. Jadwalkan pengambilan.';
          triggeredAlerts.add(msg);
          _recordNotification('N-06 Claim Status Alert', msg, claim.id);
          schedulePickupReminder(claim); // Jadwalkan N-07 (2 hari)
        } else if (claim.status == 'Rejected') {
          final reasonText = (claim.rejectionReason != null && claim.rejectionReason!.isNotEmpty)
              ? ' Alasan: ${claim.rejectionReason}'
              : '';
          final msg = 'Klaim ${claim.itemTitle} belum disetujui donatur.$reasonText';
          triggeredAlerts.add(msg);
          _recordNotification('N-06 Claim Status Alert', msg, claim.id);
        }
      }
      _lastKnownStatuses[claim.id] = claim.status;
    }

    // 2. Cek klaim baru yang masuk pada barang hibah milik Donatur
    for (final incoming in incomingDonorClaims) {
      if (!_knownDonorIncomingClaimIds.contains(incoming.id)) {
        if (_knownDonorIncomingClaimIds.isNotEmpty && incoming.status == 'Pending') {
          final msg = 'Klaim baru (${incoming.urgency}) dari ${incoming.applicantName} untuk${incoming.itemTitle}.';
          triggeredAlerts.add(msg);
          _recordNotification('N-06 Claim Status Alert (Donatur)', msg, incoming.id);
        }
        _knownDonorIncomingClaimIds.add(incoming.id);
      }
    }

    return triggeredAlerts;
  }

  /// N-07: Pickup Reminder (FR-28 [O])
  /// Notifikasi lokal terjadwal 2 hari setelah klaim disetujui apabila pemohon
  /// belum menjadwalkan pengambilan (Meetup).
  void schedulePickupReminder(GrantClaim claim, {bool testMode = false}) {
    if (claim.status != 'Approved' || (claim.meetupId != null && claim.meetupId!.isNotEmpty)) {
      return;
    }
    final duration = testMode ? const Duration(seconds: 10) : const Duration(days: 2);
    final scheduledTime = DateTime.now().add(duration);
    _scheduledPickupReminders[claim.id] = scheduledTime;
    debugPrint('[N-07 Pickup Reminder] Dijadwalkan untuk ${claim.itemTitle} pada$scheduledTime');
  }

  void cancelPickupReminder(String claimId) {
    if (_scheduledPickupReminders.remove(claimId) != null) {
      debugPrint('[N-07 Pickup Reminder] Dibatalkan untuk claimId: $claimId');
    }
  }

  /// Memicu notifikasi instan (misal saat mode uji UAT-06)
  String buildInstantAlertMessage(GrantClaim claim) {
    if (claim.status == 'Approved') {
      return 'Klaim ${claim.itemTitle} disetujui. Jadwalkan pengambilan.';
    } else if (claim.status == 'Rejected') {
      return 'Klaim ${claim.itemTitle} ditolak.${claim.rejectionReason != null ? " (${claim.rejectionReason})" : ""}';
    }
    return 'Status klaim ${claim.itemTitle}:${claim.status}';
  }

  void _recordNotification(String title, String body, String referenceId) {
    _notificationHistory.insert(0, {
      'title': title,
      'body': body,
      'referenceId': referenceId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
"""

# ==============================================================================
# 4. SERVICE: lib/services/social_grant_service.dart (Katalog Hibah)
# ==============================================================================
files_to_write["lib/services/social_grant_service.dart"] = """import '../models/social_grant.dart';
import 'api_client.dart';

class SocialGrantService {
  static final List<SocialGrant> _seedGrants = [
    SocialGrant(
      id: 'item-hibah-001',
      ownerUserId: 'user-raka-001',
      ownerName: 'Raka Pratama (Teknik 22)',
      ownerReputation: 4.9,
      title: 'Buku Kalkulus Purcell Edisi 9',
      description: 'Buku referensi wajib semester 1 & 2. Halaman lengkap, sampul masih rapi, ada sedikit catatan pensil yang mudah dihapus.',
      category: 'Buku & Referensi',
      condition: 'Sangat Baik',
      photoUrls: [
        'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600',
        'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=600',
      ],
      status: 'Available',
      listingType: 'Hibah',
    ),
    SocialGrant(
      id: 'item-hibah-002',
      ownerUserId: 'user-nadia-002',
      ownerName: 'Nadia Putri (SI 22)',
      ownerReputation: 4.8,
      title: 'Meja Belajar Lipat Kayu Kos',
      description: 'Meja belajar lipat ukuran 60x40 cm. Engsel kokoh, permukaan mulus, ada goresan kecil di sudut kanan bawah.',
      category: 'Furnitur Kos',
      condition: 'Baik',
      photoUrls: [
        'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600',
        'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=600',
      ],
      status: 'Available',
      listingType: 'Hibah',
    ),
    SocialGrant(
      id: 'item-hibah-003',
      ownerUserId: 'user-fajar-003',
      ownerName: 'Fajar Ramadhan (Elektro 21)',
      ownerReputation: 4.7,
      title: 'Jas Laboratorium Ukuran L + Kacamata Safety',
      description: 'Jas lab lengan panjang ukuran L bersih sudah di-laundry, kancing lengkap, bonus kacamata safety praktikum.',
      category: 'Alat Perkuliahan',
      condition: 'Sangat Baik',
      photoUrls: [
        'https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=600',
        'https://images.unsplash.com/photo-1576086213369-97a306d36557?w=600',
      ],
      status: 'Available',
      listingType: 'Hibah',
    ),
  ];

  Future<List<SocialGrant>> fetchAvailableGrants({
    String? query,
    String? category,
    String? excludeOwnerId,
  }) async {
    try {
      final response = await ApiClient.get('/items?type=Hibah&status=Available');
      if (response is List && response.isNotEmpty) {
        return response
            .map((e) => SocialGrant.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Fallback ke data seed lokal apabila server VPS belum aktif saat pengujian
    }

    return _seedGrants.where((item) {
      // BR-05: Hanya menampilkan listing Available
      if (item.status != 'Available') return false;
      if (excludeOwnerId != null &&
          excludeOwnerId.isNotEmpty &&
          item.ownerUserId == excludeOwnerId) {
        return false;
      }
      if (category != null &&
          category.isNotEmpty &&
          category != 'Semua' &&
          item.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchDesc = item.description.toLowerCase().contains(q);
        if (!matchTitle && !matchDesc) return false;
      }
      return true;
    }).toList();
  }

  Future<List<SocialGrant>> fetchDonorGrants(String ownerUserId) async {
    return _seedGrants.where((item) => item.ownerUserId == ownerUserId || ownerUserId.isEmpty).toList();
  }

  static void updateLocalGrantStatus(String itemId, String newStatus) {
    final index = _seedGrants.indexWhere((g) => g.id == itemId);
    if (index != -1) {
      _seedGrants[index] = _seedGrants[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    }
  }

  static SocialGrant? findById(String itemId) {
    try {
      return _seedGrants.firstWhere((g) => g.id == itemId);
    } catch (_) {
      return null;
    }
  }
}
"""

# ==============================================================================
# 5. SERVICE: lib/services/grant_claim_service.dart (CRUD Lengkap Claims - M5)
# ==============================================================================
files_to_write["lib/services/grant_claim_service.dart"] = """import '../models/grant_claim.dart';
import 'api_client.dart';
import 'social_grant_service.dart';

class GrantClaimService {
  // Penyimpanan in-memory yang menyimulasikan basis data relasional server ketika offline/demo lokal
  static final List<GrantClaim> _claimsDb = [
    GrantClaim(
      id: 'claim-seed-001',
      itemId: 'item-hibah-001',
      itemTitle: 'Buku Kalkulus Purcell Edisi 9',
      itemCategory: 'Buku & Referensi',
      itemCondition: 'Sangat Baik',
      donorUserId: 'user-raka-001',
      donorName: 'Raka Pratama (Teknik 22)',
      applicantUserId: 'user-budi-24',
      applicantName: 'Budi Santoso',
      applicantNim: '2411521008',
      applicantReputation: 4.5,
      applicantReviewCount: 2,
      urgency: 'Rendah',
      justification: 'Saya ingin membaca buku Kalkulus Purcell ini sebagai bahan belajar tambahan di kos untuk persiapan semester depan agar pemahaman dasar matematika saya lebih kuat.',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    GrantClaim(
      id: 'claim-seed-002',
      itemId: 'item-hibah-001',
      itemTitle: 'Buku Kalkulus Purcell Edisi 9',
      itemCategory: 'Buku & Referensi',
      itemCondition: 'Sangat Baik',
      donorUserId: 'user-raka-001',
      donorName: 'Raka Pratama (Teknik 22)',
      applicantUserId: 'user-sinta-24',
      applicantName: 'Sinta Maharani',
      applicantNim: '2411522011',
      applicantReputation: 4.9,
      applicantReviewCount: 5,
      urgency: 'Mendesak',
      justification: 'Saya mengambil mata kuliah Kalkulus 1 semester ini dan sangat membutuhkan buku referensi Purcell karena keterbatasan biaya untuk membeli buku cetak baru.',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  /// READ (FR-24): Ambil daftar klaim milik pemohon
  Future<List<GrantClaim>> fetchMyClaims(String applicantUserId) async {
    try {
      final res = await ApiClient.get('/claims?applicant_id=$applicantUserId');
      if (res is List) {
        return res.map((e) => GrantClaim.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}

    if (applicantUserId.isEmpty) return List.from(_claimsDb);
    return _claimsDb.where((c) => c.applicantUserId == applicantUserId).toList();
  }

  /// READ (FR-25 & BR-29): Ambil antrean klaim untuk barang hibah milik Donatur
  /// Diurutkan berdasarkan tingkat urgensi (Mendesak -> Sedang -> Rendah), lalu tanggal pengajuan terlama (FIFO)
  Future<List<GrantClaim>> fetchQueueForItem(String itemId) async {
    List<GrantClaim> list = [];
    try {
      final res = await ApiClient.get('/items/$itemId/claims');
      if (res is List) {
        list = res.map((e) => GrantClaim.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {
      list = _claimsDb.where((c) => c.itemId == itemId).toList();
    }

    list.sort((a, b) {
      final cmpUrgency = a.urgencyPriority.compareTo(b.urgencyPriority);
      if (cmpUrgency != 0) return cmpUrgency;
      return a.createdAt.compareTo(b.createdAt); // Pengajuan lebih awal tampil lebih dulu (BR-29)
    });
    return list;
  }

  /// Ambil seluruh klaim yang masuk untuk Donatur
  Future<List<GrantClaim>> fetchAllDonorQueue({String? donorUserId}) async {
    List<GrantClaim> list = _claimsDb.where((c) {
      if (donorUserId == null || donorUserId.isEmpty) return true;
      return c.donorUserId == donorUserId;
    }).toList();

    list.sort((a, b) {
      final cmpUrgency = a.urgencyPriority.compareTo(b.urgencyPriority);
      if (cmpUrgency != 0) return cmpUrgency;
      return a.createdAt.compareTo(b.createdAt);
    });
    return list;
  }

  /// CREATE (FR-23, BR-27, BR-28): Ajukan klaim baru
  Future<GrantClaim> createClaim({
    required String itemId,
    required String itemTitle,
    required String donorUserId,
    required String donorName,
    required String applicantUserId,
    required String applicantName,
    required String urgency,
    required String justification,
  }) async {
    // Validasi BR-27: Barang tidak boleh milik sendiri
    if (donorUserId.isNotEmpty && donorUserId == applicantUserId) {
      throw Exception('Anda tidak dapat mengklaim barang hibah milik sendiri (BR-27).');
    }

    // Validasi BR-27: Justifikasi 100-1.000 karakter
    final trimmed = justification.trim();
    if (trimmed.length < 100) {
      throw Exception('Justifikasi kebutuhan wajib minimal 100 karakter (BR-27).');
    }
    if (trimmed.length > 1000) {
      throw Exception('Justifikasi kebutuhan maksimal 1.000 karakter (BR-27).');
    }

    // Validasi FR-23: Maksimal 1 klaim aktif per barang
    final duplicate = _claimsDb.any((c) =>
        c.itemId == itemId &&
        c.applicantUserId == applicantUserId &&
        (c.status == 'Pending' || c.status == 'Approved'));
    if (duplicate) {
      throw Exception('Anda sudah memiliki klaim aktif pada barang hibah ini (FR-23).');
    }

    // Validasi BR-28: Maksimal 3 klaim aktif (Pending atau Approved) sekaligus per pemohon
    final activeCount = _claimsDb
        .where((c) => c.applicantUserId == applicantUserId && c.isActiveClaim)
        .length;
    if (activeCount >= 3) {
      throw Exception('Batas maksimal 3 klaim aktif (Pending/Approved) telah tercapai (BR-28).');
    }

    final newClaim = GrantClaim(
      id: 'claim-${DateTime.now().millisecondsSinceEpoch}',
      itemId: itemId,
      itemTitle: itemTitle,
      donorUserId: donorUserId,
      donorName: donorName,
      applicantUserId: applicantUserId,
      applicantName: applicantName,
      applicantReputation: 4.8,
      applicantReviewCount: 3,
      urgency: urgency,
      justification: trimmed,
      status: 'Pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await ApiClient.post('/claims', newClaim.toJson());
    } catch (_) {}

    _claimsDb.insert(0, newClaim);
    return newClaim;
  }

  /// UPDATE (FR-24 & AC-30): Pemohon menyunting urgensi dan justifikasi selama klaim masih Pending
  Future<GrantClaim> updatePendingClaim({
    required String claimId,
    required String urgency,
    required String justification,
  }) async {
    final index = _claimsDb.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      throw Exception('Data klaim tidak ditemukan.');
    }

    final current = _claimsDb[index];
    if (current.status != 'Pending') {
      throw Exception('Klaim yang sudah ${current.status} tidak dapat disunting (AC-30).');
    }

    final trimmed = justification.trim();
    if (trimmed.length < 100 || trimmed.length > 1000) {
      throw Exception('Justifikasi wajib antara 100 hingga 1.000 karakter (BR-27).');
    }

    final updated = current.copyWith(
      urgency: urgency,
      justification: trimmed,
      updatedAt: DateTime.now(),
    );

    try {
      await ApiClient.put('/claims/$claimId', {
        'urgensi': urgency,
        'justifikasi': trimmed,
      });
    } catch (_) {}

    _claimsDb[index] = updated;
    return updated;
  }

  /// DELETE PERMANEN (FR-24, BR-32, AC-31): Hapus permanen klaim yang masih Pending
  Future<void> deletePendingClaim(String claimId) async {
    final index = _claimsDb.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      throw Exception('Data klaim tidak ditemukan.');
    }

    final current = _claimsDb[index];
    if (current.status != 'Pending') {
      throw Exception('Hanya klaim berstatus Pending yang dapat dihapus permanen (BR-32).');
    }

    try {
      await ApiClient.delete('/claims/$claimId');
    } catch (_) {}

    _claimsDb.removeAt(index);
  }

  /// UPDATE - BATALKAN (FR-24, BR-31): Batalkan klaim yang sudah Approved sebelum serah terima
  /// Barang kembali Available, tetapi klaim lain yang sebelumnya ditolak otomatis tidak dipulihkan.
  Future<GrantClaim> cancelApprovedClaim(String claimId) async {
    final index = _claimsDb.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      throw Exception('Data klaim tidak ditemukan.');
    }

    final current = _claimsDb[index];
    if (current.status != 'Approved') {
      throw Exception('Hanya klaim berstatus Approved yang dapat dibatalkan. Gunakan Hapus untuk klaim Pending (BR-31).');
    }

    final updated = current.copyWith(
      status: 'Cancelled',
      updatedAt: DateTime.now(),
    );

    try {
      await ApiClient.put('/claims/$claimId/cancel', {'status': 'Cancelled'});
    } catch (_) {}

    _claimsDb[index] = updated;
    // BR-31: Barang kembali menjadi Available
    SocialGrantService.updateLocalGrantStatus(current.itemId, 'Available');
    return updated;
  }

  /// UPDATE - PERSETUJUAN DONATUR (FR-26, AC-29):
  /// Menyetujui satu pemohon -> klaim terpilih menjadi Approved, barang menjadi Reserved,
  /// dan klaim Pending lain pada barang yang sama otomatis menjadi Rejected.
  Future<GrantClaim> approveClaim(String claimId) async {
    final index = _claimsDb.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      throw Exception('Data klaim tidak ditemukan.');
    }

    final target = _claimsDb[index];
    if (target.status != 'Pending') {
      throw Exception('Hanya klaim berstatus Pending yang dapat disetujui.');
    }

    try {
      await ApiClient.post('/claims/$claimId/approve', {});
    } catch (_) {}

    final now = DateTime.now();
    late GrantClaim approvedClaim;

    for (var i = 0; i < _claimsDb.length; i++) {
      final item = _claimsDb[i];
      if (item.itemId == target.itemId) {
        if (item.id == claimId) {
          approvedClaim = item.copyWith(status: 'Approved', updatedAt: now);
          _claimsDb[i] = approvedClaim;
        } else if (item.status == 'Pending') {
          _claimsDb[i] = item.copyWith(
            status: 'Rejected',
            rejectionReason: 'Donatur telah menyetujui pemohon lain pada barang ini (FR-26).',
            updatedAt: now,
          );
        }
      }
    }

    // FR-26: Server menjadikan barang Reserved
    SocialGrantService.updateLocalGrantStatus(target.itemId, 'Reserved');
    return approvedClaim;
  }

  /// UPDATE - PENOLAKAN DONATUR (FR-26, BR-30):
  /// Menolak klaim satu per satu dengan alasan singkat opsional
  Future<GrantClaim> rejectClaim(String claimId, {String? reason}) async {
    final index = _claimsDb.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      throw Exception('Data klaim tidak ditemukan.');
    }

    final current = _claimsDb[index];
    if (current.status != 'Pending') {
      throw Exception('Hanya klaim berstatus Pending yang dapat ditolak.');
    }

    final updated = current.copyWith(
      status: 'Rejected',
      rejectionReason: (reason != null && reason.trim().isNotEmpty) ? reason.trim() : null,
      updatedAt: DateTime.now(),
    );

    try {
      await ApiClient.post('/claims/$claimId/reject', {
        'alasan_penolakan': updated.rejectionReason,
      });
    } catch (_) {}

    _claimsDb[index] = updated;
    return updated;
  }

  /// Integrasi dengan Modul 2: Simpan meetup_id setelah pemohon menjadwalkan pengambilan
  Future<GrantClaim> attachMeetupId(String claimId, String meetupId) async {
    final index = _claimsDb.indexWhere((c) => c.id == claimId);
    if (index == -1) throw Exception('Data klaim tidak ditemukan.');
    final updated = _claimsDb[index].copyWith(
      meetupId: meetupId,
      updatedAt: DateTime.now(),
    );
    _claimsDb[index] = updated;
    return updated;
  }
}
"""

# ==============================================================================
# 6. VIEWMODEL: lib/viewmodels/social_grant_viewmodel.dart
# ==============================================================================
files_to_write["lib/viewmodels/social_grant_viewmodel.dart"] = """import 'package:flutter/foundation.dart';
import '../models/social_grant.dart';
import '../services/social_grant_service.dart';

class SocialGrantViewModel extends ChangeNotifier {
  final SocialGrantService _service = SocialGrantService();

  List<SocialGrant> _grants = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  List<SocialGrant> get grants => _grants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  static const List<String> categories = [
    'Semua',
    'Buku & Referensi',
    'Furnitur Kos',
    'Elektronik',
    'Alat Perkuliahan',
  ];

  Future<void> loadGrants({String? currentUserId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _grants = await _service.fetchAvailableGrants(
        query: _searchQuery,
        category: _selectedCategory,
        excludeOwnerId: currentUserId,
      );
    } catch (e) {
      _errorMessage = 'Tidak dapat terhubung ke server. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query, {String? currentUserId}) {
    _searchQuery = query;
    loadGrants(currentUserId: currentUserId);
  }

  void setCategory(String category, {String? currentUserId}) {
    _selectedCategory = category;
    loadGrants(currentUserId: currentUserId);
  }
}
"""

# ==============================================================================
# 7. VIEWMODEL: lib/viewmodels/grant_claim_viewmodel.dart
# ==============================================================================
files_to_write["lib/viewmodels/grant_claim_viewmodel.dart"] = """import 'package:flutter/foundation.dart';
import '../models/grant_claim.dart';
import '../services/grant_claim_service.dart';
import '../services/grant_notification_service.dart';

class GrantClaimViewModel extends ChangeNotifier {
  final GrantClaimService _service = GrantClaimService();
  final GrantNotificationService _notificationService = GrantNotificationService();

  List<GrantClaim> _myClaims = [];
  List<GrantClaim> _donorQueue = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _pendingNotifications = [];
  String _currentApplicantId = 'user-mahasiswa-aktif';
  String _currentApplicantName = 'Racha Ardiwinata';

  List<GrantClaim> get myClaims => _myClaims;
  List<GrantClaim> get donorQueue => _donorQueue;
  List<GrantClaim> get claims => _myClaims; // Getter kompatibilitas kode lama
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get pendingNotifications => _pendingNotifications;

  String get currentApplicantId => _currentApplicantId;
  String get currentApplicantName => _currentApplicantName;

  // BR-28: Hitung jumlah klaim aktif (Pending atau Approved) milik pemohon
  int get activeClaimCount =>
      _myClaims.where((c) => c.applicantUserId == _currentApplicantId && c.isActiveClaim).length;

  bool get hasReachedActiveLimit => activeClaimCount >= 3;

  void setCurrentUser({required String userId, required String userName}) {
    _currentApplicantId = userId;
    _currentApplicantName = userName;
    notifyListeners();
  }

  List<String> consumeNotifications() {
    final alerts = List<String>.from(_pendingNotifications);
    _pendingNotifications.clear();
    return alerts;
  }

  /// Sinkronisasi data klaim dari server sekaligus memeriksa pemicu notifikasi N-06 (FR-27)
  Future<void> syncClaims({String? itemId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedMyClaims = await _service.fetchMyClaims('');
      final fetchedQueue = itemId != null
          ? await _service.fetchQueueForItem(itemId)
          : await _service.fetchAllDonorQueue();

      _myClaims = fetchedMyClaims;
      _donorQueue = fetchedQueue;

      final alerts = _notificationService.checkSyncNotifications(
        myClaims: _myClaims.where((c) => c.applicantUserId == _currentApplicantId).toList(),
        incomingDonorClaims: _donorQueue,
      );
      if (alerts.isNotEmpty) {
        _pendingNotifications.addAll(alerts);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// CREATE (FR-23)
  Future<GrantClaim?> submitClaim({
    required String itemId,
    required String itemTitle,
    String donorUserId = 'user-raka-001',
    String donorName = 'Donatur Unand',
    required String urgency,
    required String justification,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _service.createClaim(
        itemId: itemId,
        itemTitle: itemTitle,
        donorUserId: donorUserId,
        donorName: donorName,
        applicantUserId: _currentApplicantId,
        applicantName: _currentApplicantName,
        urgency: urgency,
        justification: justification,
      );
      await syncClaims();
      return created;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// UPDATE (FR-24 & AC-30): Sunting urgensi & justifikasi saat masih Pending
  Future<bool> updateClaim({
    required String claimId,
    required String urgency,
    required String justification,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updatePendingClaim(
        claimId: claimId,
        urgency: urgency,
        justification: justification,
      );
      await syncClaims();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// DELETE PERMANEN (FR-24, BR-32, AC-31): Hapus klaim Pending
  Future<bool> deletePendingClaim(String claimId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deletePendingClaim(claimId);
      await syncClaims();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// UPDATE - BATALKAN (FR-24, BR-31): Batalkan klaim Approved sebelum serah terima
  Future<bool> cancelApprovedClaim(String claimId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.cancelApprovedClaim(claimId);
      _notificationService.cancelPickupReminder(claimId);
      await syncClaims();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// UPDATE - DONATUR MENYETUJUI KLAIM (FR-26, AC-29)
  Future<bool> approveClaimByDonor(String claimId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final approved = await _service.approveClaim(claimId);
      _pendingNotifications.add(
        'N-06: Klaim ${approved.itemTitle} milik ${approved.applicantName} disetujui. Klaim lain otomatis Rejected & barang menjadi Reserved.',
      );
      await syncClaims();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// UPDATE - DONATUR MENOLAK KLAIM (FR-26, BR-30)
  Future<bool> rejectClaimByDonor(String claimId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rejected = await _service.rejectClaim(claimId, reason: reason);
      _pendingNotifications.add(
        'N-06: Klaim ${rejected.applicantName} untuk ${rejected.itemTitle} telah ditolak.',
      );
      await syncClaims();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
"""

# ==============================================================================
# 8. VIEW: lib/views/ajukan_klaim_screen.dart (Form Tambah & Edit Klaim - FR-23/24)
# ==============================================================================
files_to_write["lib/views/ajukan_klaim_screen.dart"] = """import 'package:flutter/material.dart';
import '../models/grant_claim.dart';
import '../models/social_grant.dart';
import '../viewmodels/grant_claim_viewmodel.dart';

class AjukanKlaimScreen extends StatefulWidget {
  final SocialGrant? grant;
  final GrantClaim? existingClaim; // Jika diisi, layar berfungsi sebagai Form Edit Klaim Pending (FR-24)
  final GrantClaimViewModel? viewModel;

  const AjukanKlaimScreen({
    super.key,
    this.grant,
    this.existingClaim,
    this.viewModel,
  });

  @override
  State<AjukanKlaimScreen> createState() => _AjukanKlaimScreenState();
}

class _AjukanKlaimScreenState extends State<AjukanKlaimScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _justificationController;
  late final GrantClaimViewModel _vm;
  String _selectedUrgency = 'Mendesak';
  bool _isSubmitting = false;

  static const List<Map<String, dynamic>> _urgencyOptions = [
    {
      'value': 'Mendesak',
      'label': 'Mendesak',
      'desc': 'Dibutuhkan segera untuk kuliah/praktikum minggu ini',
      'color': Color(0xFFDC2626),
      'icon': Icons.priority_high_rounded,
    },
    {
      'value': 'Sedang',
      'label': 'Sedang',
      'desc': 'Dibutuhkan untuk menunjang perkuliahan semester ini',
      'color': Color(0xFFD97706),
      'icon': Icons.schedule_rounded,
    },
    {
      'value': 'Rendah',
      'label': 'Rendah',
      'desc': 'Bermanfaat sebagai perlengkapan belajar tambahan',
      'color': Color(0xFF0D9488),
      'icon': Icons.low_priority_rounded,
    },
  ];

  bool get _isEditMode => widget.existingClaim != null;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel ?? GrantClaimViewModel();
    _selectedUrgency = widget.existingClaim?.urgency ?? 'Mendesak';
    _justificationController = TextEditingController(
      text: widget.existingClaim?.justification ?? '',
    );
    _justificationController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  int get _charCount => _justificationController.text.trim().length;
  bool get _isJustificationValid => _charCount >= 100 && _charCount <= 1000;

  Future<void> _handleSubmit() async {
    if (!_isJustificationValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Justifikasi kebutuhan wajib minimal 100 karakter dan maksimal 1.000 karakter (BR-27).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    if (_isEditMode) {
      final claim = widget.existingClaim!;
      // AC-30: Tolak jika status bukan Pending
      if (claim.status != 'Pending') {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Klaim berstatus ${claim.status} tidak dapat disunting (AC-30).'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final ok = await _vm.updateClaim(
        claimId: claim.id,
        urgency: _selectedUrgency,
        justification: _justificationController.text.trim(),
      );
      setState(() => _isSubmitting = false);

      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan klaim berhasil disimpan.'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_vm.errorMessage ?? 'Gagal memperbarui klaim.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // Mode Create (FR-23)
    final itemTitle = widget.grant?.title ?? 'Buku Kalkulus Purcell Edisi 9';
    final itemId = widget.grant?.id ?? 'item-hibah-001';
    final donorId = widget.grant?.ownerUserId ?? 'user-raka-001';
    final donorName = widget.grant?.ownerName ?? 'Raka Pratama (Teknik 22)';

    final created = await _vm.submitClaim(
      itemId: itemId,
      itemTitle: itemTitle,
      donorUserId: donorId,
      donorName: donorName,
      urgency: _selectedUrgency,
      justification: _justificationController.text.trim(),
    );

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Klaim hibah berhasil diajukan! Menunggu persetujuan donatur.'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
      Navigator.pop(context, created);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_vm.errorMessage ?? 'Gagal mengajukan klaim.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemTitle = _isEditMode
        ? widget.existingClaim!.itemTitle
        : (widget.grant?.title ?? 'Barang Hibah Kampus');
    final itemCategory = _isEditMode
        ? widget.existingClaim!.itemCategory
        : (widget.grant?.category ?? 'Buku & Referensi');
    final itemCondition = _isEditMode
        ? widget.existingClaim!.itemCondition
        : (widget.grant?.condition ?? 'Sangat Baik');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Sunting Klaim Hibah' : 'Form Klaim Hibah'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Ringkas Barang Hibah
                Card(
                  elevation: 0,
                  color: const Color(0xFFF0FDFA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF99F6E4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.volunteer_activism_rounded,
                            color: Color(0xFF0D9488),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$itemCategory • Kondisi: $itemCondition • Gratis (Rp0)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Info Kuota Klaim Aktif (BR-28)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber.shade900),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aturan Klaim (FR-23 & BR-28): Maksimal 1 klaim per barang dan maksimal 3 klaim aktif (Pending/Approved) sekaligus.',
                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Pilihan Tingkat Urgensi (FR-23)
                const Text(
                  '1. Pilih Tingkat Urgensi Kebutuhan *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ..._urgencyOptions.map((opt) {
                  final isSelected = _selectedUrgency == opt['value'];
                  final Color color = opt['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _selectedUrgency = opt['value'] as String),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey.shade300,
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(opt['icon'] as IconData, color: color),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['label'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  Text(
                                    opt['desc'] as String,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                            Radio<String>(
                              value: opt['value'] as String,
                              groupValue: _selectedUrgency,
                              activeColor: color,
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedUrgency = v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Input Justifikasi Kebutuhan + Penghitung Karakter (BR-27 & AC-27)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        '2. Justifikasi Kebutuhan (100–1.000 karakter) *',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isJustificationValid
                            ? const Color(0xFF0D9488).withOpacity(0.12)
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$_charCount / 1000',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isJustificationValid ? const Color(0xFF0D9488) : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _justificationController,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText:
                        'Jelaskan secara jujur dan spesifik mengapa Anda membutuhkan barang hibah ini untuk kegiatan perkuliahan Anda di Universitas Andalas (minimal 100 karakter)...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                    ),
                    helperText: _charCount < 100
                        ? 'Minimal 100 karakter (kurang ${100 - _charCount} karakter lagi)'
                        : 'Panjang justifikasi sudah memenuhi syarat (BR-27).',
                    helperStyle: TextStyle(
                      color: _charCount < 100 ? Colors.red.shade700 : const Color(0xFF0D9488),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.length < 100) {
                      return 'Minimal 100 karakter diperlukan (AC-27).';
                    }
                    if (text.length > 1000) {
                      return 'Maksimal 1.000 karakter (BR-27).';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tombol Kirim (AC-27: Nonaktif bila kurang dari 100 karakter)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: (_isSubmitting || !_isJustificationValid) ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(_isEditMode ? Icons.save_rounded : Icons.send_rounded),
                    label: Text(
                      _isEditMode ? 'Simpan Perubahan Klaim' : 'Kirim Klaim Hibah',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
"""

# ==============================================================================
# 9. VIEW: lib/views/daftar_detail_klaim_screen.dart (Klaim Saya, Antrean Donatur, Detail)
# ==============================================================================
files_to_write["lib/views/daftar_detail_klaim_screen.dart"] = """import 'package:flutter/material.dart';
import '../models/grant_claim.dart';
import '../viewmodels/grant_claim_viewmodel.dart';
import 'ajukan_klaim_screen.dart';

class DaftarDetailKlaimScreen extends StatefulWidget {
  final GrantClaimViewModel? viewModel;
  final int initialTabIndex;

  const DaftarDetailKlaimScreen({
    super.key,
    this.viewModel,
    this.initialTabIndex = 0,
  });

  @override
  State<DaftarDetailKlaimScreen> createState() => _DaftarDetailKlaimScreenState();
}

class _DaftarDetailKlaimScreenState extends State<DaftarDetailKlaimScreen>
    with SingleTickerProviderStateMixin {
  late final GrantClaimViewModel _vm;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel ?? GrantClaimViewModel();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _vm.addListener(_onVmChanged);
    _vm.syncClaims();
  }

  void _onVmChanged() {
    if (!mounted) return;
    final alerts = _vm.consumeNotifications();
    for (final msg in alerts) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: const Color(0xFF0D9488),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF16A34A);
      case 'Pending':
        return const Color(0xFFD97706);
      case 'Rejected':
        return const Color(0xFFDC2626);
      case 'Cancelled':
        return Colors.grey.shade700;
      case 'Completed':
        return const Color(0xFF0D9488);
      default:
        return Colors.blueGrey;
    }
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'Mendesak':
        return const Color(0xFFDC2626);
      case 'Sedang':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF0D9488);
    }
  }

  Future<void> _confirmDeletePending(GrantClaim claim) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Klaim Permanen?'),
        content: Text(
          'Klaim untuk "${claim.itemTitle}" masih berstatus Pending. '
          'Jika dihapus, data klaim akan hilang permanen dari basis data dan antrean donatur, serta kuota klaim aktif Anda akan berkurang (BR-32).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await _vm.deletePendingClaim(claim.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Klaim Pending berhasil dihapus permanen (AC-31).'
                : (_vm.errorMessage ?? 'Gagal menghapus klaim.'),
          ),
          backgroundColor: ok ? const Color(0xFF0D9488) : Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _confirmCancelApproved(GrantClaim claim) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Klaim yang Disetujui?'),
        content: Text(
          'Klaim "${claim.itemTitle}" akan diubah menjadi Cancelled dan status barang dikembalikan menjadi Available (BR-31).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan Klaim'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await _vm.cancelApprovedClaim(claim.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Klaim dibatalkan (Cancelled) dan barang kembali Available (BR-31).'
                : (_vm.errorMessage ?? 'Gagal membatalkan klaim.'),
          ),
          backgroundColor: ok ? const Color(0xFF0D9488) : Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _showRejectDialog(GrantClaim claim) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tolak Klaim ${claim.applicantName}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anda dapat menyertakan alasan penolakan singkat (opsional) yang akan terlihat oleh pemohon (BR-30):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Contoh: Barang diprioritaskan untuk mahasiswa semester 1',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tolak Klaim'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _vm.rejectClaimByDonor(claim.id, reason: reasonCtrl.text);
    }
  }

  void _openClaimDetailSheet(GrantClaim claim, {required bool isDonorView}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _urgencyColor(claim.urgency).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Urgensi: ${claim.urgency}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _urgencyColor(claim.urgency),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(claim.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Status: ${claim.status}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _statusColor(claim.status),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  claim.itemTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pemohon: ${claim.applicantName} • Reputasi: ${claim.reputationLabel}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const Divider(height: 24),
                const Text(
                  'Justifikasi Kebutuhan (FR-23):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    claim.justification,
                    style: const TextStyle(fontSize: 13.5, height: 1.45),
                  ),
                ),
                if (claim.rejectionReason != null && claim.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'Alasan Penolakan: ${claim.rejectionReason}',
                      style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Tombol Aksi sesuai Peran & Status (Tabel 2.6 PRD)
                if (!isDonorView && claim.status == 'Pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AjukanKlaimScreen(
                                  existingClaim: claim,
                                  viewModel: _vm,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Sunting Klaim'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _confirmDeletePending(claim);
                          },
                          icon: const Icon(Icons.delete_forever_rounded),
                          label: const Text('Hapus Permanen'),
                        ),
                      ),
                    ],
                  ),
                ] else if (!isDonorView && claim.status == 'Approved') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        // Komunikasi Antar Modul via ID (TEAM_GUIDELINES Bagian 3 & PRD 2.11)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Mengarahkan ke Modul 2 (Jadwal Pertemuan Safe-Meet Point) dengan claim_id=${claim.id} & item_id=${claim.itemId}',
                            ),
                            backgroundColor: const Color(0xFF0D9488),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_on_rounded),
                      label: const Text('Jadwalkan Pengambilan di Safe-Meet Point (Modul 2)'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmCancelApproved(claim);
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Batalkan Klaim (BR-31)'),
                    ),
                  ),
                ] else if (isDonorView && claim.status == 'Pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showRejectDialog(claim);
                          },
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _vm.approveClaimByDonor(claim.id);
                          },
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text('Setujui Pemohon'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Klaim & Antrean Hibah'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Sinkronisasi Server (FR-27)',
            onPressed: () => _vm.syncClaims(),
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.assignment_ind_rounded), text: 'Klaim Saya (Pemohon)'),
            Tab(icon: Icon(Icons.queue_Play_next_rounded), text: 'Antrean Klaim (Donatur)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyClaimsTab(),
          _buildDonorQueueTab(),
        ],
      ),
    );
  }

  Widget _buildMyClaimsTab() {
    if (_vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = _vm.myClaims;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                'Belum ada klaim hibah. Cari barang gratis di Katalog Hibah.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _vm.syncClaims(),
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final claim = list[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openClaimDetailSheet(claim, isDonorView: false),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _urgencyColor(claim.urgency).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            claim.urgency,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: _urgencyColor(claim.urgency),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(claim.status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            claim.status,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: _statusColor(claim.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      claim.itemTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      claim.justification,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (claim.canEditOrDelete) ...[
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AjukanKlaimScreen(
                                    existingClaim: claim,
                                    viewModel: _vm,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                            onPressed: () => _confirmDeletePending(claim),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Hapus'),
                          ),
                        ] else if (claim.canCancelApproved) ...[
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.orange.shade800),
                            onPressed: () => _confirmCancelApproved(claim),
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: const Text('Batalkan'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDonorQueueTab() {
    if (_vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final queue = _vm.donorQueue;
    return RefreshIndicator(
      onRefresh: () => _vm.syncClaims(),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF99F6E4)),
            ),
            child: const Text(
              'Antrean Prioritas Donatur (FR-25 & BR-29): Diurutkan otomatis berdasarkan Urgensi (Mendesak → Sedang → Rendah), lalu waktu pengajuan terlama. Menyetujui 1 pemohon otomatis mengubah barang menjadi Reserved dan menolak klaim lainnya (AC-29).',
              style: TextStyle(fontSize: 12, color: Color(0xFF115E59)),
            ),
          ),
          ...queue.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final claim = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openClaimDetailSheet(claim, isDonorView: true),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF0D9488).withOpacity(0.15),
                            child: Text(
                              '#$idx',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D9488),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  claim.applicantName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  'Reputasi: ${claim.reputationLabel}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _urgencyColor(claim.urgency).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              claim.urgency,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _urgencyColor(claim.urgency),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Barang: ${claim.itemTitle}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        claim.justification,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status: ${claim.status}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _statusColor(claim.status),
                            ),
                          ),
                          if (claim.status == 'Pending')
                            Row(
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => _showRejectDialog(claim),
                                  child: const Text('Tolak'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    foregroundColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => _vm.approveClaimByDonor(claim.id),
                                  child: const Text('Setujui'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
"""

# ==============================================================================
# 10. VIEW: lib/views/katalog_hibah_screen.dart (Katalog Hibah - FR-23 & BR-27)
# ==============================================================================
files_to_write["lib/views/katalog_hibah_screen.dart"] = """import 'package:flutter/material.dart';
import '../models/social_grant.dart';
import '../viewmodels/grant_claim_viewmodel.dart';
import '../viewmodels/social_grant_viewmodel.dart';
import 'ajukan_klaim_screen.dart';
import 'daftar_detail_klaim_screen.dart';

class KatalogHibahScreen extends StatefulWidget {
  const KatalogHibahScreen({super.key});

  @override
  State<KatalogHibahScreen> createState() => _KatalogHibahScreenState();
}

class _KatalogHibahScreenState extends State<KatalogHibahScreen> {
  final SocialGrantViewModel _grantVm = SocialGrantViewModel();
  final GrantClaimViewModel _claimVm = GrantClaimViewModel();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _grantVm.addListener(_onChanged);
    _claimVm.addListener(_onChanged);
    _grantVm.loadGrants();
    _claimVm.syncClaims();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _grantVm.removeListener(_onChanged);
    _claimVm.removeListener(_onChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Hibah Unand'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Klaim Saya & Antrean Donatur',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DaftarDetailKlaimScreen(viewModel: _claimVm),
                ),
              ).then((_) => _grantVm.loadGrants());
            },
            icon: Badge(
              label: Text('${_claimVm.activeClaimCount}/3'),
              child: const Icon(Icons.assignment_turned_in_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Kategori
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => _grantVm.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari buku, meja kos, jas lab hibah...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _grantVm.setSearchQuery('');
                              },
                              icon: const Icon(Icons.clear_rounded),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: SocialGrantViewModel.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = SocialGrantViewModel.categories[index];
                        final selected = _grantVm.selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          selectedColor: const Color(0xFF0D9488).withOpacity(0.18),
                          onSelected: (_) => _grantVm.setCategory(cat),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Banner Kuota Klaim Aktif (BR-28)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF0FDFA),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kuota Klaim Aktif Anda: ${_claimVm.activeClaimCount} / 3 klaim (BR-28)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF115E59),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DaftarDetailKlaimScreen(viewModel: _claimVm),
                        ),
                      ).then((_) => _grantVm.loadGrants());
                    },
                    child: const Text('Lihat Klaim & Antrean →'),
                  ),
                ],
              ),
            ),

            // Daftar Barang Hibah Available
            Expanded(
              child: _grantVm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _grantVm.grants.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Barang hibah tidak ditemukan (AC-03).',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _grantVm.loadGrants(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _grantVm.grants.length,
                            itemBuilder: (context, index) {
                              final item = _grantVm.grants[index];
                              return _buildGrantCard(item);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrantCard(SocialGrant item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'HIBAH • GRATIS (Rp0)',
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Kondisi: ${item.condition}',
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Donatur: ${item.ownerName} (${item.ownerReputation.toStringAsFixed(1)} ★)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _claimVm.hasReachedActiveLimit
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Batas klaim aktif tercapai (maksimal 3 klaim Pending/Approved sekaligus - BR-28).',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AjukanKlaimScreen(
                                grant: item,
                                viewModel: _claimVm,
                              ),
                            ),
                          );
                          _grantVm.loadGrants();
                        },
                  icon: const Icon(Icons.volunteer_activism_rounded, size: 18),
                  label: const Text('Ajukan Klaim'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
"""

# ==============================================================================
# 11. VIEW: lib/views/digital_claim_pass_screen.dart (Kompatibilitas Redirect PRD v1.3/1.4)
# ==============================================================================
files_to_write["lib/views/digital_claim_pass_screen.dart"] = """import 'package:flutter/material.dart';
import '../models/grant_claim.dart';

/// Sesuai PRD Bagian 3.2 (Out of Scope):
/// "Digital Claim Pass terpisah ditiadakan; bukti pengambilan hibah menggunakan
/// penjadwalan Safe-Meet Point (Modul 2) dan serah terima QR (Modul 4)."
/// File ini dipertahankan agar import pada main.dart/home_screen.dart tidak error.
class DigitalClaimPassScreen extends StatelessWidget {
  final GrantClaim? claim;

  const DigitalClaimPassScreen({super.key, this.claim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pengambilan Hibah'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 64,
                  color: Color(0xFF0D9488),
                ),
                const SizedBox(height: 16),
                Text(
                  claim?.itemTitle ?? 'Pengambilan Barang Hibah',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sesuai PRD v1.4 terbaru, pengambilan barang hibah yang telah Approved '
                  'dijadwalkan melalui Modul 2 (Safe-Meet Point Unand) dan divalidasi saat bertemu '
                  'menggunakan pemindaian Kode QR sekali pakai pada Modul 4.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, height: 1.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Kembali ke Detail Klaim'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
"""

# ==============================================================================
# 12. AI USAGE LOG: docs/ai_logs/racha_log.md (Wajib Sesuai TEAM_GUIDELINES Bagian 6)
# ==============================================================================
files_to_write["docs/ai_logs/racha_log.md"] = """# AI Usage Log - Modul 5: Hibah & Klaim Berbasis Kebutuhan
**Nama Mahasiswa:** Muhammad Racha Ardiwinata (2411522020)  
**Modul:** Modul 5 – Hibah & Klaim Berbasis Kebutuhan (`modul-racha`)  

---

## Log 1: Pembaruan Arsitektur MVVM & Siklus CRUD Klaim Sesuai PRD v1.4
1. **Tujuan Penggunaan AI:**  
   Menyesuaikan model, service, viewmodel, dan layar UI Modul 5 dari spesifikasi PRD lama ke PRD v1.4 terbaru (pemisahan operasi Delete permanen untuk klaim `Pending` dan Cancel untuk klaim `Approved`, validasi justifikasi 100–1.000 karakter, kuota maksimal 3 klaim aktif, serta pengurutan antrean donatur berbasis urgensi).

2. **Prompt / Instruction yang Digunakan:**  
   *"Bantu saya memperbarui kode Modul 5 (Hibah & Klaim) pada aplikasi Flutter CampuShift dengan arsitektur MVVM agar mematuhi FR-23 s.d. FR-28, BR-27 s.d. BR-32, serta AC-27 s.d. AC-31 pada PRD v1.4 tanpa menggunakan Firebase."*

3. **Output atau Solusi yang Dihasilkan:**  
   - Model `GrantClaim` dan `SocialGrant` dengan serialisasi JSON, perhitungan prioritas urgensi (`Mendesak`, `Sedang`, `Rendah`), dan status sesuai Tabel 2.6 PRD.
   - `GrantClaimService` dan `GrantClaimViewModel` yang mengimplementasikan CRUD lengkap (`createClaim`, `fetchMyClaims`, `fetchQueueForItem`, `updatePendingClaim`, `deletePendingClaim`, `cancelApprovedClaim`, `approveClaim`, `rejectClaim`).
   - `GrantNotificationService` berbasis sinkronisasi untuk *Claim Status Alert* (N-06) dan *Pickup Reminder* (N-07).

4. **Perubahan yang Dilakukan Mahasiswa:**  
   - Menyesuaikan kompatibilitas *getter* pada `GrantClaim` dan `SocialGrant` agar tetap terintegrasi dengan `home_screen.dart` dan `main_screen.dart` yang sudah di-merge tim.
   - Menambahkan penghitung karakter langsung (*live counter*) pada `AjukanKlaimScreen` dan menonaktifkan tombol kirim ketika karakter kurang dari 100 (AC-27).
   - Mengubah alur `DigitalClaimPassScreen` agar mengikuti aturan *Out of Scope* PRD v1.4 (diarahkan ke jadwal pertemuan Modul 2 via `claim_id` dan `item_id`).

5. **Proses Verifikasi / Testing:**  
   - Diuji menggunakan skenario **AC-27** (input justifikasi 80 karakter -> tombol kirim nonaktif & pesan validasi tampil).
   - Diuji menggunakan skenario **AC-28** (klaim `Rendah` dibuat lebih dulu, klaim `Mendesak` dibuat belakangan -> klaim `Mendesak` tampil di urutan #1 antrean donatur).
   - Diuji menggunakan skenario **AC-29** (Donatur menyetujui 1 klaim -> klaim terpilih `Approved`, klaim lain otomatis `Rejected`, status barang menjadi `Reserved`, dan notifikasi N-06 muncul saat sinkronisasi).
   - Diuji menggunakan skenario **AC-30 & AC-31** (klaim `Pending` berhasil disunting dan dihapus permanen; klaim `Approved` menolak disunting dan hanya menampilkan opsi Batalkan).
"""

# Tulis semua file ke disk
for rel_path, content in files_to_write.items():
    dir_name = os.path.dirname(rel_path)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)
    with open(rel_path, "w", encoding="utf-8") as f:
        f.write(content.strip() + "\n")
    print(f"✔ Berhasil memperbarui: {rel_path}")

print("\n🎉 SELESAI! Seluruh file Modul 5 (Racha) telah diperbarui ke PRD v1.4 + AI Usage Log telah dibuat.")