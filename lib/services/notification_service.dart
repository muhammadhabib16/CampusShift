import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Hindari error jika dijalankan di Web (Chrome)
    if (kIsWeb) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  // Simulasi Notifikasi Stale Alert (FR-05)
  static Future<void> scheduleStaleListingAlert(String itemName) async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'stale_alert_channel',
          'Stale Listing Alerts',
          channelDescription: 'Notifikasi untuk barang yang lama belum terjual',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // Simulasi delay 5 detik untuk testing (Sesuai PRD aslinya 14 hari)
    await Future.delayed(const Duration(seconds: 5));

    await _notificationsPlugin.show(
      0, // ID notifikasi
      'Listing Belum Laku! 💡',
      'Barang "$itemName" milikmu sudah 14 hari belum ada peminat. Coba turunin harganya atau update deskripsi!',
      platformDetails,
    );
  }
}
