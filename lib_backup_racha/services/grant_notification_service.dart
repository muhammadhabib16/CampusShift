import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notifikasi lokal khusus Modul 5 (FR-25: Donation Claim Approval Alert).
///
/// PENTING untuk dipahami & dijelaskan saat code review:
/// karena FCM dilarang (lihat Aturan_Project_Mobile_2026.md & PRD 2.6),
/// notifikasi TIDAK bisa langsung "didorong" real-time ke HP pemohon saat
/// donatur menekan approve di HP lain. Solusi lokal-saja yang dipakai:
/// setiap kali GrantClaimViewModel melakukan refresh/poll status klaim
/// milik user (mis. saat buka halaman "Klaim Saya" atau saat app resume),
/// bandingkan status lama vs status baru dari server — kalau berubah dari
/// Pending menjadi Approved, baru panggil showClaimApproved() di bawah ini.
class GrantNotificationService {
  GrantNotificationService(this._plugin);
  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> showClaimApproved({
    required String itemName,
    required String claimPassCode,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'grant_claim_channel',
        'Status Klaim Hibah',
        channelDescription: 'Notifikasi persetujuan klaim hibah CampuShift',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(
      id: claimPassCode.hashCode,
      title: 'Klaim hibah disetujui!',
      body: 'Pengajuan untuk "$itemName" diterima. Tunjukkan kode $claimPassCode saat pengambilan.',
      notificationDetails: details,
    );
  }
}
