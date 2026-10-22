import '../models/grant_claim.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'social_grant_service.dart';

class GrantClaimService {
  final ApiClient _apiClient = ApiClient(baseUrl: ApiConfig.baseUrl, getToken: () => null);

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

  Future<List<GrantClaim>> fetchMyClaims(String applicantUserId) async {
    try {
      final res = await _apiClient.get('/claims?applicant_id=$applicantUserId');
      if (res is List) {
        return res
            .map((e) => GrantClaim.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}

    if (applicantUserId.isEmpty) return List.from(_claimsDb);
    return _claimsDb.where((c) => c.applicantUserId == applicantUserId).toList();
  }

  Future<List<GrantClaim>> fetchQueueForItem(String itemId) async {
    List<GrantClaim> list = [];
    try {
      final res = await _apiClient.get('/items/$itemId/claims');
      if (res is List) {
        list = res
            .map((e) => GrantClaim.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {
      list = _claimsDb.where((c) => c.itemId == itemId).toList();
    }

    list.sort((a, b) {
      final cmpUrgency = a.urgencyPriority.compareTo(b.urgencyPriority);
      if (cmpUrgency != 0) return cmpUrgency;
      return a.createdAt.compareTo(b.createdAt);
    });
    return list;
  }

  Future<List<GrantClaim>> fetchAllDonorQueue({String? donorUserId}) async {
    final List<GrantClaim> list = _claimsDb.where((c) {
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
    if (donorUserId.isNotEmpty && donorUserId == applicantUserId) {
      throw Exception('Anda tidak dapat mengklaim barang hibah milik sendiri (BR-27).');
    }

    final trimmed = justification.trim();
    if (trimmed.length < 100) {
      throw Exception('Justifikasi kebutuhan wajib minimal 100 karakter (BR-27).');
    }
    if (trimmed.length > 1000) {
      throw Exception('Justifikasi kebutuhan maksimal 1.000 karakter (BR-27).');
    }

    final duplicate = _claimsDb.any((c) =>
        c.itemId == itemId &&
        c.applicantUserId == applicantUserId &&
        (c.status == 'Pending' || c.status == 'Approved'));
    if (duplicate) {
      throw Exception('Anda sudah memiliki klaim aktif pada barang hibah ini (FR-23).');
    }

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
      await _apiClient.post('/claims');
    } catch (_) {}

    _claimsDb.insert(0, newClaim);
    return newClaim;
  }

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
      await _apiClient.put('/claims/$claimId');
    } catch (_) {}

    _claimsDb[index] = updated;
    return updated;
  }

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
      await _apiClient. get('/claims/$claimId/delete');
    } catch (_) {}

    _claimsDb.removeAt(index);
  }

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
      await _apiClient.put('/claims/$claimId/cancel');
    } catch (_) {}

    _claimsDb[index] = updated;
    SocialGrantService.updateLocalGrantStatus(current.itemId, 'Available');
    return updated;
  }

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
      await _apiClient.post('/claims/$claimId/approve');
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

    SocialGrantService.updateLocalGrantStatus(target.itemId, 'Reserved');
    return approvedClaim;
  }

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
      await _apiClient.post('/claims/$claimId/reject');
    } catch (_) {}

    _claimsDb[index] = updated;
    return updated;
  }

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
