import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Hindari error jika dijalankan di Web (Chrome) atau lingkungan test
    if (kIsWeb) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(settings: initSettings);
    } catch (_) {
      // Abaikan bila platform tidak mendukung plugin notifikasi lokal
    }
  }

  /// Batas umur listing tanpa pembaruan sebelum diingatkan (FR-05).
  static const Duration staleAfter = Duration(days: 14);

  /// Listing Available yang terakhir dibuat/disunting >= 14 hari lalu.
  static List<ItemModel> staleListings(List<ItemModel> items, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    return items
        .where(
          (i) =>
              i.status == 'Available' &&
              i.lastListingUpdateAt != null &&
              reference.difference(i.lastListingUpdateAt!) >= staleAfter,
        )
        .toList();
  }

  /// FR-05 Stale Alert: dipanggil setiap data "Barang Saya" dimuat. Satu
  /// notifikasi per listing per periode pembaruan (tidak berulang setiap buka
  /// aplikasi); menyunting listing memulai periode 14 hari yang baru.
  static Future<void> checkStaleListings(List<ItemModel> items) async {
    if (kIsWeb) return;
    final stale = staleListings(items);
    if (stale.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'stale_alert_channel',
            'Stale Listing Alerts',
            channelDescription:
                'Notifikasi untuk barang yang lama belum terjual',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      for (final item in stale) {
        final key =
            'stale_alert_${item.id}_${item.lastListingUpdateAt!.millisecondsSinceEpoch}';
        if (prefs.getBool(key) == true) continue;

        final days = DateTime.now().difference(item.lastListingUpdateAt!).inDays;
        await _notificationsPlugin.show(
          id: 50000 + (int.tryParse(item.id) ?? item.id.hashCode) % 10000,
          title: 'Listing Belum Laku 💡',
          body:
              'Barang "${item.title}" sudah $days hari belum ada peminat. Coba sesuaikan harga atau perbarui deskripsi.',
          notificationDetails: platformDetails,
        );
        await prefs.setBool(key, true);
      }
    } catch (_) {
      // Abaikan bila platform/plugin tidak tersedia (mis. widget test).
    }
  }
}
