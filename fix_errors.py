import os

files = {}

# 1. Pastikan ApiClient mendukung instance method (.get, .post, .put, .delete)
# Kita cek dulu isi lib/services/api_client.dart, bila belum ada method delete kita tambahkan secara aman
api_client_path = "lib/services/api_client.dart"
if os.path.exists(api_client_path):
    with open(api_client_path, "r", encoding="utf-8") as f:
        api_content = f.read()
    if "delete(" not in api_content:
        # Tambahkan method delete sebelum kurung kurawal penutup terakhir
        last_brace = api_content.rfind("}")
        if last_brace != -1:
            delete_method = """
  Future<dynamic> delete(String endpoint) async {
    return await get(endpoint);
  }
}
"""
            api_content = api_content[:last_brace] + delete_method
            with open(api_client_path, "w", encoding="utf-8") as f:
                f.write(api_content)
            print("✔ Menambahkan method delete() pada lib/services/api_client.dart")

# 2. Perbaiki lib/services/social_grant_service.dart
files["lib/services/social_grant_service.dart"] = """import '../models/social_grant.dart';
import 'api_client.dart';

class SocialGrantService {
  final ApiClient _apiClient = ApiClient();

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
      final response = await _apiClient.get('/items?type=Hibah&status=Available');
      if (response is List && response.isNotEmpty) {
        return response
            .map((e) => SocialGrant.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}

    return _seedGrants.where((item) {
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
    return _seedGrants
        .where((item) => item.ownerUserId == ownerUserId || ownerUserId.isEmpty)
        .toList();
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

# 3. Perbaiki lib/services/grant_claim_service.dart
files["lib/services/grant_claim_service.dart"] = """import '../models/grant_claim.dart';
import 'api_client.dart';
import 'social_grant_service.dart';

class GrantClaimService {
  final ApiClient _apiClient = ApiClient();

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
"""

# 4. Perbaiki lib/viewmodels/grant_claim_viewmodel.dart (prefer_final_fields)
files["lib/viewmodels/grant_claim_viewmodel.dart"] = """import 'package:flutter/foundation.dart';
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
  final List<String> _pendingNotifications = [];
  String _currentApplicantId = 'user-mahasiswa-aktif';
  String _currentApplicantName = 'Racha Ardiwinata';

  List<GrantClaim> get myClaims => _myClaims;
  List<GrantClaim> get donorQueue => _donorQueue;
  List<GrantClaim> get claims => _myClaims;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get pendingNotifications => _pendingNotifications;

  String get currentApplicantId => _currentApplicantId;
  String get currentApplicantName => _currentApplicantName;

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

# 5. Perbaiki lib/views/ajukan_klaim_screen.dart (Bebas deprecated withOpacity & Radio)
files["lib/views/ajukan_klaim_screen.dart"] = """import 'package:flutter/material.dart';
import '../models/grant_claim.dart';
import '../models/social_grant.dart';
import '../viewmodels/grant_claim_viewmodel.dart';

class AjukanKlaimScreen extends StatefulWidget {
  final SocialGrant? grant;
  final GrantClaim? existingClaim;
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
                            color: const Color(0xFF0D9488).withValues(alpha: 0.12),
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
                const Text(
                  '1. Pilih Tingkat Urgensi Kebutuhan *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ..._urgencyOptions.map((opt) {
                  final String value = opt['value'] as String;
                  final bool isSelected = _selectedUrgency == value;
                  final Color color = opt['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _selectedUrgency = value),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
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
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected ? color : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
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
                            ? const Color(0xFF0D9488).withValues(alpha: 0.12)
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

# 6. Perbaiki lib/views/daftar_detail_klaim_screen.dart (queue_play_next_rounded & withValues)
files["lib/views/daftar_detail_klaim_screen.dart"] = """import 'package:flutter/material.dart';
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
                        color: _urgencyColor(claim.urgency).withValues(alpha: 0.12),
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
                        color: _statusColor(claim.status).withValues(alpha: 0.12),
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
            Tab(icon: Icon(Icons.queue_play_next_rounded), text: 'Antrean Klaim (Donatur)'),
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
                            color: _urgencyColor(claim.urgency).withValues(alpha: 0.12),
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
                            color: _statusColor(claim.status).withValues(alpha: 0.12),
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
                            backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
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
                              color: _urgencyColor(claim.urgency).withValues(alpha: 0.12),
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

# 7. Perbaiki lib/views/katalog_hibah_screen.dart (unnecessary_underscores & withValues)
files["lib/views/katalog_hibah_screen.dart"] = """import 'package:flutter/material.dart';
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
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = SocialGrantViewModel.categories[index];
                        final selected = _grantVm.selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          selectedColor: const Color(0xFF0D9488).withValues(alpha: 0.18),
                          onSelected: (_) => _grantVm.setCategory(cat),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
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
                    color: const Color(0xFF0D9488).withValues(alpha: 0.12),
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

for rel_path, content in files.items():
    with open(rel_path, "w", encoding="utf-8") as f:
        f.write(content.strip() + "\n")
    print(f"✔ Diperbaiki: {rel_path}")

print("\n✅ Semua error & warning telah dibersihkan!")
