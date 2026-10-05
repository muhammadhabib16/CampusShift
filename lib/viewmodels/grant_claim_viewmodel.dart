import 'package:flutter/foundation.dart';
import '../models/grant_claim.dart';
import '../services/grant_claim_service.dart';
import '../services/grant_notification_service.dart';

/// State & aturan bisnis untuk layar pengajuan klaim (pemohon) dan
/// antrean/persetujuan klaim (donatur). Sengaja digabung dalam satu
/// ViewModel karena keduanya beroperasi di atas entity GrantClaim yang sama
/// — kalau nanti terasa gemuk, gampang dipecah jadi dua ViewModel terpisah.
class GrantClaimViewModel extends ChangeNotifier {
  GrantClaimViewModel(this._service, this._notifications);
  final GrantClaimService _service;
  final GrantNotificationService _notifications;

  List<GrantClaim> claimQueue = [];
  bool isLoading = false;
  String? errorMessage;

  /// FR-22: validasi panjang justifikasi minimal 100 karakter — sama
  /// seperti validasi foto di SocialGrantViewModel, ditaruh di ViewModel
  /// supaya Service tetap murni I/O.
  Future<bool> submitClaim({
    required String grantId,
    required ClaimUrgency urgency,
    required String justificationText,
    String? voiceNoteFilePath,
  }) async {
    if (justificationText.trim().length < 100) {
      errorMessage = 'Justifikasi akademik minimal 100 karakter.';
      notifyListeners();
      return false;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.submitClaim(
        grantId: grantId,
        urgency: urgency,
        justificationText: justificationText,
        voiceNoteFilePath: voiceNoteFilePath,
      );
      return true;
    } catch (e) {
      errorMessage = 'Gagal mengirim pengajuan klaim.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// FR-23: dipanggil dari sisi donatur saat membuka antrean klaim
  /// untuk satu grant tertentu.
  Future<void> loadClaimQueue(String grantId) async {
    isLoading = true;
    notifyListeners();
    try {
      claimQueue = await _service.fetchClaimQueue(grantId);
    } catch (e) {
      errorMessage = 'Gagal memuat antrean klaim.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// FR-24 + FR-25: approve lalu picu notifikasi lokal untuk pemohon.
  /// Lihat catatan keterbatasan tanpa-FCM di GrantNotificationService.
  Future<void> approveClaim(GrantClaim claim, {required String itemName}) async {
    try {
      final updated = await _service.approveClaim(claim.id);
      claimQueue = claimQueue.map((c) => c.id == updated.id ? updated : c).toList();
      notifyListeners();
      if (updated.approval == ClaimApproval.approved &&
          updated.digitalClaimPassCode != null) {
        await _notifications.showClaimApproved(
          itemName: itemName,
          claimPassCode: updated.digitalClaimPassCode!,
        );
      }
    } catch (e) {
      errorMessage = 'Gagal menyetujui klaim.';
      notifyListeners();
    }
  }

  Future<void> rejectClaim(GrantClaim claim) async {
    try {
      final updated = await _service.rejectClaim(claim.id);
      claimQueue = claimQueue.map((c) => c.id == updated.id ? updated : c).toList();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Gagal menolak klaim.';
      notifyListeners();
    }
  }
}
