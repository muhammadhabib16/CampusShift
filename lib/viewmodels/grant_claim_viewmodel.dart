import 'package:flutter/foundation.dart';
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
