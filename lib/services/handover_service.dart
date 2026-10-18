import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/handover_token_model.dart';

class HandoverService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/handover';
    }
    return 'http://127.0.0.1:3000/api/handover';
  }

  // Fallback in-memory session cache for offline / demo mode
  static final Map<String, HandoverTokenModel> _localSessions = {};

  /// Helper untuk generate token acak berformat TKN-CS-XXXX-XX (One-time Nonce)
  static String generateRandomToken() {
    final random = Random();
    final numPart = (1000 + random.nextInt(9000)).toString();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final codePart = '${chars[random.nextInt(chars.length)]}${random.nextInt(10)}';
    return 'TKN-CS-$numPart-$codePart';
  }

  /// FR-17 [W] Point 1: CREATE QR Session
  /// Membuat token acak sekali pakai yang berlaku 5 menit.
  /// BR-21: Hanya 1 token aktif per pertemuan, pembuatan token baru menonaktifkan token lama.
  static Future<Map<String, dynamic>> createQrSession({
    required String meetupId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('jwt_token');

      final url = Uri.parse('$baseUrl/session');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
            },
            body: jsonEncode({
              'meetup_id': meetupId,
              'validity_seconds': 300, // 5 menit
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final tokenModel = HandoverTokenModel.fromJson(data['data']);
        _localSessions[meetupId] = tokenModel;
        return {
          'success': true,
          'token': tokenModel,
          'message': data['message'] ?? 'Sesi QR berhasil dibuat',
        };
      }
    } catch (_) {
      // Backend offline / development fallback
    }

    // Fallback offline / local generator sesuai BR-21 & FR-17
    final now = DateTime.now();
    final newToken = HandoverTokenModel(
      tokenId: 'TOK-${DateTime.now().millisecondsSinceEpoch}',
      meetupId: meetupId,
      token: generateRandomToken(),
      issuedAt: now,
      expiresAt: now.add(const Duration(minutes: 5)),
      status: 'active',
      proofNumber: 'PRF-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-${1000 + Random().nextInt(9000)}',
    );

    _localSessions[meetupId] = newToken;

    return {
      'success': true,
      'token': newToken,
      'message': 'Token QR baru berhasil dibuat (Masa berlaku 5 menit)',
    };
  }

  /// FR-17 [W] Point 2: DELETE / Batalkan Sesi QR
  /// Membatalkan sesi QR yang sedang aktif (misalnya karena QR terbuka tidak sengaja
  /// atau pertemuan ditunda); token dihapus dari server sehingga QR langsung tidak berlaku.
  /// BR-21: Membatalkan sesi QR menghapus token aktif tanpa mengubah status pertemuan.
  static Future<Map<String, dynamic>> cancelQrSession({
    required String meetupId,
    required String tokenId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('jwt_token');

      final url = Uri.parse('$baseUrl/session/$tokenId');
      final response = await http
          .delete(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
            },
            body: jsonEncode({'meetup_id': meetupId}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _localSessions.remove(meetupId);
        return {
          'success': true,
          'message': data['message'] ?? 'Sesi QR berhasil dibatalkan',
        };
      }
    } catch (_) {
      // Backend offline fallback
    }

    // Update status local session menjadi cancelled / dihapus
    if (_localSessions.containsKey(meetupId)) {
      final current = _localSessions[meetupId]!;
      _localSessions[meetupId] = current.copyWith(status: 'cancelled');
    }

    return {
      'success': true,
      'message': 'Sesi QR dibatalkan. Token dihapus dan tidak berlaku lagi.',
    };
  }

  /// FR-21 [W]: Periksa status token secara berkala (interval 3 detik)
  /// Mengembalikan status terkini: 'active', 'expired', 'used', 'cancelled'
  static Future<Map<String, dynamic>> checkTokenStatus({
    required String meetupId,
    required String tokenId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('jwt_token');

      final url = Uri.parse('$baseUrl/status/$meetupId?token_id=$tokenId');
      final response = await http.get(
        url,
        headers: {
          if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] ?? 'active';
        return {
          'success': true,
          'status': status,
          'proof_number': data['proof_number'],
          'message': data['message'],
        };
      }
    } catch (_) {
      // Offline fallback check
    }

    final local = _localSessions[meetupId];
    if (local == null) {
      return {'success': true, 'status': 'cancelled'};
    }

    if (local.status == 'cancelled') {
      return {'success': true, 'status': 'cancelled'};
    }

    if (local.status == 'used') {
      return {
        'success': true,
        'status': 'used',
        'proof_number': local.proofNumber,
      };
    }

    if (local.isExpired) {
      return {'success': true, 'status': 'expired'};
    }

    return {'success': true, 'status': 'active'};
  }

  /// Simulasi Peminat berhasil scan QR (Untuk keperluan testing & demonstrasi)
  static void simulateScanSuccess(String meetupId) {
    if (_localSessions.containsKey(meetupId)) {
      final current = _localSessions[meetupId]!;
      _localSessions[meetupId] = current.copyWith(
        status: 'used',
        usedAt: DateTime.now(),
      );
    }
  }

  /// Simulasi Token Kedaluwarsa
  static void simulateExpired(String meetupId) {
    if (_localSessions.containsKey(meetupId)) {
      final current = _localSessions[meetupId]!;
      _localSessions[meetupId] = current.copyWith(
        status: 'expired',
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );
    }
  }

  /// Dapatkan sesi aktif saat ini bila ada
  static HandoverTokenModel? getCachedSession(String meetupId) {
    return _localSessions[meetupId];
  }
}
