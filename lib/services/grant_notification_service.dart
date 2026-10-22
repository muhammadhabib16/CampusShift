import 'package:flutter/foundation.dart';
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
