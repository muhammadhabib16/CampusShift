import 'package:flutter/foundation.dart';
import '../models/handover_token_model.dart';
import '../models/handover_proof_model.dart';
import '../models/meetup.dart';
import '../models/review_model.dart';
import '../services/handover_service.dart';
import '../services/meetup_repository.dart';

/// ViewModel Utama Modul 4: Serah Terima QR & Reputasi (FR-17 s/d FR-22).
/// Mengimplementasikan pola MVVM: View hanya membaca data dan meneruskan aksi pengguna ke sini.
class HandoverViewModel extends ChangeNotifier {
  final HandoverService _service = HandoverService();
  final MeetupRepository _meetupRepo = MeetupRepository();

  // --- State Utama ---
  List<Meetup> _confirmedMeetups = [];
  HandoverTokenModel? _activeToken;
  List<HandoverProofModel> _completedProofs = [];
  List<ReviewModel> _receivedReviews = [];
  List<ReviewModel> _myReviews = [];

  // --- UI States ---
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  bool _handoverSuccess = false;
  HandoverProofModel? _lastCompletedProof;

  // Getters
  List<Meetup> get confirmedMeetups => _confirmedMeetups;
  HandoverTokenModel? get activeToken => _activeToken;
  List<HandoverProofModel> get completedProofs => _completedProofs;
  List<ReviewModel> get receivedReviews => _receivedReviews;
  List<ReviewModel> get myReviews => _myReviews;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get handoverSuccess => _handoverSuccess;
  HandoverProofModel? get lastCompletedProof => _lastCompletedProof;

  /// Perhitungan Rata-rata Skor Reputasi (BR-25)
  double get averageRating {
    if (_receivedReviews.isEmpty) return 0.0;
    final total = _receivedReviews.fold(0, (sum, r) => sum + r.rating);
    return total / _receivedReviews.length;
  }

  /// Distribusi Bintang (1 s/d 5)
  Map<int, int> get ratingDistribution {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _receivedReviews) {
      if (dist.containsKey(r.rating)) {
        dist[r.rating] = (dist[r.rating] ?? 0) + 1;
      }
    }
    return dist;
  }

  // ===========================================================================
  // DATA LOADING
  // ===========================================================================

  Future<void> loadInitialData([int currentUserId = 1]) async {
    _isLoading = true;
    notifyListeners();

    try {
      _meetupRepo.ensureInitialized();
      _confirmedMeetups = _meetupRepo
          .getAllMeetups()
          .where((m) => m.isDikonfirmasi)
          .toList();

      _completedProofs = await _service.getCompletedTransactions();
      _receivedReviews = await _service.getReviewsForUser(currentUserId);
      _myReviews = await _service.getMyReviews(currentUserId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memuat data serah terima.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshConfirmedMeetups() async {
    _meetupRepo.ensureInitialized();
    _confirmedMeetups = _meetupRepo
        .getAllMeetups()
        .where((m) => m.isDikonfirmasi)
        .toList();
    notifyListeners();
  }

  Future<void> refreshProofsAndReviews([int currentUserId = 1]) async {
    _completedProofs = await _service.getCompletedTransactions();
    _receivedReviews = await _service.getReviewsForUser(currentUserId);
    _myReviews = await _service.getMyReviews(currentUserId);
    notifyListeners();
  }

  // ===========================================================================
  // FR-17: CREATE & DELETE QR SESSION
  // ===========================================================================

  /// Create QR Token (Masa berlaku 5 menit, BR-21)
  Future<void> createQrSession(int meetupId) async {
    _isLoading = true;
    _handoverSuccess = false;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeToken = await _service.createQrSession(meetupId: meetupId);
      _successMessage = 'Token QR aktif (Masa berlaku 5 menit)';
    } catch (e) {
      _errorMessage = 'Gagal membuat sesi QR.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete / Batalkan Sesi QR (Token dihapus, pertemuan tetap Dikonfirmasi, BR-21)
  Future<bool> cancelQrSession(int meetupId, String tokenId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _service.cancelQrSession(
        meetupId: meetupId,
        tokenId: tokenId,
      );
      if (success) {
        _activeToken = _activeToken?.copyWith(status: 'cancelled');
        _successMessage = 'Sesi QR berhasil dibatalkan. Token dihapus.';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Gagal membatalkan sesi QR.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Polling Status Token per 3 detik (FR-21)
  Future<void> checkTokenStatus(int meetupId) async {
    if (_activeToken == null) return;
    try {
      final res = await _service.checkTokenStatus(
        meetupId: meetupId,
        tokenId: _activeToken!.tokenId,
      );
      final status = res['status'];
      if (status == 'used' && !_handoverSuccess) {
        _handoverSuccess = true;
        _activeToken = _activeToken?.copyWith(status: 'used');
        await refreshConfirmedMeetups();
        await refreshProofsAndReviews();
        notifyListeners();
      } else if (status == 'expired' && !_activeToken!.isExpired) {
        _activeToken = _activeToken?.copyWith(status: 'expired');
        notifyListeners();
      }
    } catch (_) {}
  }

  // ===========================================================================
  // FR-18: SCAN & VALIDASI QR
  // ===========================================================================

  Future<Map<String, dynamic>> validateAndCompleteHandover({
    required int meetupId,
    required String tokenString,
    required int scannerUserId,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _service.validateAndCompleteHandover(
        meetupId: meetupId,
        tokenString: tokenString,
        scannerUserId: scannerUserId,
      );

      if (res['success'] == true) {
        _lastCompletedProof = res['proof'] as HandoverProofModel;
        _handoverSuccess = true;
        await refreshConfirmedMeetups();
        await refreshProofsAndReviews(scannerUserId);
        return res;
      } else {
        _errorMessage = res['message'];
        return res;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem saat validasi.';
      return {'success': false, 'message': _errorMessage};
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // FR-20: ULASAN
  // ===========================================================================

  Future<Map<String, dynamic>> submitReview({
    required int meetupId,
    required String proofNumber,
    required int reviewerId,
    required String reviewerName,
    required String reviewerNim,
    required int targetUserId,
    required String targetUserName,
    required int rating,
    required String comment,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final res = await _service.submitReview(
        meetupId: meetupId,
        proofNumber: proofNumber,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        reviewerNim: reviewerNim,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        rating: rating,
        comment: comment,
      );

      if (res['success'] == true) {
        await refreshProofsAndReviews(reviewerId);
      }
      return res;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
    required int currentUserId,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final res = await _service.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );

      if (res['success'] == true) {
        await refreshProofsAndReviews(currentUserId);
      }
      return res;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Simulasi helper
  void simulateScanSuccess(int meetupId) {
    _service.simulateScanSuccess(meetupId);
    _handoverSuccess = true;
    notifyListeners();
  }

  void simulateExpired(int meetupId) {
    _service.simulateExpired(meetupId);
    notifyListeners();
  }
}