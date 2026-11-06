// firebase_messaging 17 menandai getToken/onTokenRefresh/deleteToken deprecated
// demi API FID (register/onRegistered). Backend (firebase-admin) mengirim ke
// registration token FCM klasik, jadi API token tetap dipakai sampai backend
// ikut beralih ke FID.
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'backend.dart';

/// Wajib fungsi top-level. Push dari backend bertipe "notification", sehingga
/// saat aplikasi di background/tertutup Android menampilkannya sendiri; handler
/// ini cukup memastikan Firebase terinisialisasi.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Push notification (FCM) untuk event dari pengguna lain: pertemuan,
/// N-03 Barter Alert, dan N-06 Claim Status Alert. Notifikasi terjadwal
/// (N-01, N-02, N-05, N-07) tetap ditangani [NotificationService].
///
/// Payload `data` dari backend: `{ type: meetup|barter|claim, id, status, item_id? }`.
class PushService {
  PushService._();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    // Harus sama dengan meta-data default_notification_channel_id di AndroidManifest.
    'campusshift_push',
    'Aktivitas Transaksi',
    description: 'Ajakan pertemuan, tawaran barter, dan status klaim hibah',
    importance: Importance.high,
  );

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static bool _ready = false;
  static StreamSubscription<String>? _refreshSub;

  /// Dipanggil saat pengguna mengetuk push (aplikasi dari background/tertutup).
  /// Diisi oleh layer UI bila ingin membuka layar tujuan berdasarkan `data`.
  static void Function(Map<String, dynamic> data)? onTap;

  /// Dipanggil sekali di `main()`. Aman di Web/test: kegagalan diabaikan dan
  /// aplikasi tetap berjalan tanpa push (data tetap tersedia lewat /sync).
  static Future<void> init() async {
    if (kIsWeb || _ready) return;
    try {
      await Firebase.initializeApp(); // membaca android/app/google-services.json
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);

      // Saat aplikasi di foreground FCM tidak menampilkan notifikasi sendiri.
      FirebaseMessaging.onMessage.listen(_showForeground);

      FirebaseMessaging.onMessageOpenedApp.listen((m) => onTap?.call(m.data));
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        // Ditunda agar onTap sempat dipasang setelah widget tree siap.
        Future.microtask(() => onTap?.call(initial.data));
      }

      _ready = true;
    } catch (e) {
      debugPrint('PushService.init gagal: $e');
    }
  }

  /// Daftarkan token perangkat ke backend. Panggil setelah login berhasil dan
  /// saat sesi dipulihkan (aplikasi dibuka dalam kondisi sudah login).
  static Future<void> registerDevice() async {
    if (!_ready) return;
    try {
      // Android 13+: memunculkan dialog izin notifikasi (NFR-06: penolakan
      // izin tidak menghentikan aplikasi).
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _sendToken(token);

      _refreshSub ??= FirebaseMessaging.instance.onTokenRefresh.listen(
        _sendToken,
      );
    } catch (e) {
      debugPrint('PushService.registerDevice gagal: $e');
    }
  }

  /// Hapus token dari backend. Panggil SEBELUM JWT dihapus saat logout, agar
  /// perangkat berhenti menerima push akun ini.
  static Future<void> unregisterDevice() async {
    if (!_ready) return;
    try {
      await _refreshSub?.cancel();
      _refreshSub = null;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && await Backend.isOnline()) {
        await Backend.client.delete(
          '/users/me/fcm-token',
          body: {'token': token},
        );
      }
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('PushService.unregisterDevice gagal: $e');
    }
  }

  static Future<void> _sendToken(String token) async {
    if (!await Backend.isOnline()) return;
    try {
      await Backend.client.post(
        '/users/me/fcm-token',
        body: {'token': token, 'platform': 'android'},
      );
    } catch (e) {
      debugPrint('PushService: gagal mengirim token: $e');
    }
  }

  static Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _local.show(
      // ID notifikasi Android harus muat di int 32-bit.
      id:
          (message.messageId ?? '${DateTime.now().microsecondsSinceEpoch}')
              .hashCode &
          0x7fffffff,
      title: notification.title,
      body: notification.body,
      payload: jsonEncode(message.data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
