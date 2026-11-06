import '../models/grant_claim.dart';
import 'api_client.dart';
import 'backend.dart';
import 'social_grant_service.dart';

/// Klaim Hibah Sosial (Modul 5) — kontrak `be-campusshift/src/routes/claim.routes.js`:
/// - `POST   /claims`              { item_id, urgency_category, justification_text }
/// - `GET    /claims/me`           klaim milik pemohon
/// - `GET    /items/:id/claims`    antrean klaim satu barang (khusus donatur)
/// - `PUT    /claims/:id`          sunting klaim Pending
/// - `DELETE /claims/:id`          hapus klaim Pending
/// - `PUT    /claims/:id/approve`  donatur menyetujui
/// - `PUT    /claims/:id/reject`   donatur menolak { reason? }
/// - `PUT    /claims/:id/cancel`   batalkan klaim Approved { reason? }
///
/// Bila pengguna sudah login, semua operasi memakai backend dan error dari
/// server (mis. batas 3 klaim aktif) diteruskan ke ViewModel. Data lokal
/// `_claimsDb` hanya dipakai pada mode demo tanpa login.
class GrantClaimService {
  GrantClaimService({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          Backend.client;

  final ApiClient _apiClient;

  Future<bool> _isLoggedIn() async {
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }

  static List<GrantClaim> _parseList(dynamic body) {
    final data = ApiClient.unwrap(body);
    if (data is! List) return [];
    return data
        .map((e) => GrantClaim.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static GrantClaim _parseOne(dynamic body) {
    final data = ApiClient.unwrap(body);
    return GrantClaim.fromJson(Map<String, dynamic>.from(data as Map));
  }

  static void _sortQueue(List<GrantClaim> list) {
    list.sort((a, b) {
      final cmpUrgency = a.urgencyPriority.compareTo(b.urgencyPriority);
      if (cmpUrgency != 0) return cmpUrgency;
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  static String _validateJustification(String justification) {
    final trimmed = justification.trim();
    if (trimmed.length < 100) {
      throw Exception('Justifikasi kebutuhan wajib minimal 100 karakter.');
    }
    if (trimmed.length > 1000) {
      throw Exception('Justifikasi kebutuhan maksimal 1.000 karakter.');
    }
    return trimmed;
  }

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
    if (await _isLoggedIn()) {
      return _parseList(await _apiClient.get('/claims/me'));
    }

    if (applicantUserId.isEmpty) return List.from(_claimsDb);
    return _claimsDb.where((c) => c.applicantUserId == applicantUserId).toList();
  }

  Future<List<GrantClaim>> fetchQueueForItem(String itemId) async {
    final List<GrantClaim> list;
    if (await _isLoggedIn()) {
      list = _parseList(await _apiClient.get('/items/$itemId/claims'));
    } else {
      list = _claimsDb.where((c) => c.itemId == itemId).toList();
    }
    _sortQueue(list);
    return list;
  }

  /// Antrean seluruh barang Hibah milik donatur yang login. Backend belum
  /// punya endpoint gabungan, jadi antrean tiap barang diambil satu per satu.
  Future<List<GrantClaim>> fetchAllDonorQueue({String? donorUserId}) async {
    final List<GrantClaim> list = [];
    if (await _isLoggedIn()) {
      final myGrants = await SocialGrantService().fetchDonorGrants('');
      final queues = await Future.wait(
        myGrants.map((g) => _apiClient.get('/items/${g.id}/claims')),
      );
      for (final body in queues) {
        list.addAll(_parseList(body));
      }
    } else {
      list.addAll(
        _claimsDb.where((c) {
          if (donorUserId == null || donorUserId.isEmpty) return true;
          return c.donorUserId == donorUserId;
        }),
      );
    }
    _sortQueue(list);
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
      throw Exception('Anda tidak dapat mengklaim barang hibah milik sendiri.');
    }
    final trimmed = _validateJustification(justification);

    if (await _isLoggedIn()) {
      final itemIdInt = int.tryParse(itemId);
      if (itemIdInt == null) {
        throw Exception('Barang hibah tidak valid. Muat ulang daftar hibah.');
      }
      return _parseOne(
        await _apiClient.post(
          '/claims',
          body: {
            'item_id': itemIdInt,
            'urgency_category': urgency,
            'justification_text': trimmed,
          },
        ),
      );
    }

    final duplicate = _claimsDb.any(
      (c) =>
          c.itemId == itemId &&
          c.applicantUserId == applicantUserId &&
          (c.status == 'Pending' || c.status == 'Approved'),
    );
    if (duplicate) {
      throw Exception('Anda sudah memiliki klaim aktif pada barang hibah ini.');
    }

    final activeCount = _claimsDb
        .where((c) => c.applicantUserId == applicantUserId && c.isActiveClaim)
        .length;
    if (activeCount >= 3) {
      throw Exception(
        'Batas maksimal 3 klaim aktif (Pending/Approved) telah tercapai.',
      );
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
    _claimsDb.insert(0, newClaim);
    return newClaim;
  }

  Future<GrantClaim> updatePendingClaim({
    required String claimId,
    required String urgency,
    required String justification,
  }) async {
    final trimmed = _validateJustification(justification);

    if (await _isLoggedIn()) {
      return _parseOne(
        await _apiClient.put(
          '/claims/$claimId',
          body: {'urgency_category': urgency, 'justification_text': trimmed},
        ),
      );
    }

    final index = _localIndex(claimId);
    final current = _claimsDb[index];
    if (current.status != 'Pending') {
      throw Exception('Klaim yang sudah ${current.status} tidak dapat disunting.');
    }
    final updated = current.copyWith(
      urgency: urgency,
      justification: trimmed,
      updatedAt: DateTime.now(),
    );
    _claimsDb[index] = updated;
    return updated;
  }

  Future<void> deletePendingClaim(String claimId) async {
    if (await _isLoggedIn()) {
      await _apiClient.delete('/claims/$claimId');
      return;
    }

    final index = _localIndex(claimId);
    if (_claimsDb[index].status != 'Pending') {
      throw Exception('Hanya klaim berstatus Pending yang dapat dihapus permanen.');
    }
    _claimsDb.removeAt(index);
  }

  Future<GrantClaim> cancelApprovedClaim(String claimId, {String? reason}) async {
    if (await _isLoggedIn()) {
      return _parseOne(
        await _apiClient.put(
          '/claims/$claimId/cancel',
          body: {if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim()},
        ),
      );
    }

    final index = _localIndex(claimId);
    final current = _claimsDb[index];
    if (current.status != 'Approved') {
      throw Exception(
        'Hanya klaim berstatus Approved yang dapat dibatalkan. Gunakan Hapus untuk klaim Pending.',
      );
    }
    final updated = current.copyWith(status: 'Cancelled', updatedAt: DateTime.now());
    _claimsDb[index] = updated;
    SocialGrantService.updateLocalGrantStatus(current.itemId, 'Available');
    return updated;
  }

  Future<GrantClaim> approveClaim(String claimId) async {
    if (await _isLoggedIn()) {
      return _parseOne(await _apiClient.put('/claims/$claimId/approve'));
    }

    final index = _localIndex(claimId);
    final target = _claimsDb[index];
    if (target.status != 'Pending') {
      throw Exception('Hanya klaim berstatus Pending yang dapat disetujui.');
    }

    final now = DateTime.now();
    late GrantClaim approvedClaim;
    for (var i = 0; i < _claimsDb.length; i++) {
      final item = _claimsDb[i];
      if (item.itemId != target.itemId) continue;
      if (item.id == claimId) {
        approvedClaim = item.copyWith(status: 'Approved', updatedAt: now);
        _claimsDb[i] = approvedClaim;
      } else if (item.status == 'Pending') {
        _claimsDb[i] = item.copyWith(
          status: 'Rejected',
          rejectionReason: 'Donatur telah menyetujui pemohon lain pada barang ini.',
          updatedAt: now,
        );
      }
    }
    SocialGrantService.updateLocalGrantStatus(target.itemId, 'Reserved');
    return approvedClaim;
  }

  Future<GrantClaim> rejectClaim(String claimId, {String? reason}) async {
    final trimmedReason =
        (reason != null && reason.trim().isNotEmpty) ? reason.trim() : null;

    if (await _isLoggedIn()) {
      return _parseOne(
        await _apiClient.put(
          '/claims/$claimId/reject',
          body: {'reason': ?trimmedReason},
        ),
      );
    }

    final index = _localIndex(claimId);
    final current = _claimsDb[index];
    if (current.status != 'Pending') {
      throw Exception('Hanya klaim berstatus Pending yang dapat ditolak.');
    }
    final updated = current.copyWith(
      status: 'Rejected',
      rejectionReason: trimmedReason,
      updatedAt: DateTime.now(),
    );
    _claimsDb[index] = updated;
    return updated;
  }

  /// Menautkan klaim ke jadwal pengambilan (Safe Meet). Backend mencatat
  /// relasi ini dari sisi meetup (`claim_id`), jadi di sini cukup lokal.
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

  int _localIndex(String claimId) {
    final index = _claimsDb.indexWhere((c) => c.id == claimId);
    if (index == -1) throw Exception('Data klaim tidak ditemukan.');
    return index;
  }
}
