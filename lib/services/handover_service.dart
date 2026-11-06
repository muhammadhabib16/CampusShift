import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/handover_proof_model.dart';
import '../models/handover_token_model.dart';
import '../models/review_model.dart';
import 'api_client.dart';
import 'backend.dart';
import 'meetup_repository.dart';

/// Service Utama Modul 4: Serah Terima QR & Reputasi (FR-17 s/d FR-22).
/// Mengimplementasikan seluruh Aturan Bisnis (BR-21 s/d BR-26) dan Kriteria Penerimaan (AC-20 s/d AC-26).
///
/// Saat pengguna login, token QR, validasi, riwayat, dan ulasan memakai
/// backend (`/api/handover`, `/api/reviews`, `/api/users/:id`). Token dibuat
/// dan diverifikasi oleh server sehingga dua HP berbeda bisa saling memindai.
/// Implementasi lokal di bawah hanya untuk mode tanpa login (demo).
class HandoverService {
  static final HandoverService _instance = HandoverService._internal();
  factory HandoverService() => _instance;
  HandoverService._internal();

  // In-memory token cache untuk sesi aktif
  final Map<int, HandoverTokenModel> _activeTokens = {};

  // Riwayat terakhir dari server (sumber "ulasan saya").
  List<HandoverProofModel> _serverProofs = [];

  // Local notifications plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _notificationsInitialized = false;

  /// Inisialisasi plugin notifikasi lokal (FR-21 & FR-22)
  Future<void> initNotifications() async {
    if (_notificationsInitialized) return;
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings: initSettings);
    _notificationsInitialized = true;
  }

  /// Helper untuk generate token acak berformat TKN-CS-XXXX-XX (One-time Nonce)
  static String generateRandomToken() {
    final random = Random();
    final numPart = (1000 + random.nextInt(9000)).toString();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final codePart =
        '${chars[random.nextInt(chars.length)]}${chars[random.nextInt(chars.length)]}';
    return 'TKN-CS-$numPart-$codePart';
  }

  // ===========================================================================
  // FR-17 [W] Kelola Sesi QR: CREATE & DELETE
  // ===========================================================================

  /// FR-17 Point 1 [Create]: Menampilkan QR; server membuat token acak sekali pakai
  /// yang berlaku 5 menit dan QR diperbarui otomatis saat kedaluwarsa.
  /// BR-21: Hanya 1 token aktif per pertemuan, pembuatan token baru menonaktifkan token lama.
  Future<HandoverTokenModel> createQrSession({required int meetupId}) async {
    if (await Backend.isOnline()) {
      final token = HandoverTokenModel.fromJson(
        Backend.map(
          await Backend.client.post(
            '/handover/session',
            body: {'meetup_id': meetupId},
          ),
        ),
      );
      _activeTokens[meetupId] = token;
      return token;
    }

    final now = DateTime.now();
    final proofNo =
        'PRF-${now.year}${now.month.toString().padLeft(2, '0')}-${1000 + Random().nextInt(9000)}';

    final newToken = HandoverTokenModel(
      tokenId: 'TOK-${now.millisecondsSinceEpoch}',
      meetupId: meetupId.toString(),
      token: generateRandomToken(),
      issuedAt: now,
      expiresAt: now.add(const Duration(minutes: 5)),
      status: 'active',
      proofNumber: proofNo,
    );

    // Menyimpan token aktif (otomatis mengganti token lama jika ada - BR-21)
    _activeTokens[meetupId] = newToken;

    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'active_token_$meetupId',
      jsonEncode(newToken.toJson()),
    );

    return newToken;
  }

  /// FR-17 Point 2 [Delete]: Membatalkan sesi QR yang sedang aktif
  /// (misalnya karena QR terbuka tidak sengaja atau pertemuan ditunda);
  /// token dihapus dari server sehingga QR langsung tidak berlaku.
  /// BR-21: Membatalkan sesi QR menghapus token aktif tanpa mengubah status pertemuan.
  Future<bool> cancelQrSession({
    required int meetupId,
    required String tokenId,
  }) async {
    if (await Backend.isOnline()) {
      await Backend.client.delete('/handover/session/$tokenId');
      _activeTokens.remove(meetupId);
      return true;
    }

    if (_activeTokens.containsKey(meetupId)) {
      final current = _activeTokens[meetupId]!;
      _activeTokens[meetupId] = current.copyWith(status: 'cancelled');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_token_$meetupId');
    return true;
  }

  /// FR-21 [W]: Periksa status token secara berkala (polling 3 detik)
  /// Mengembalikan status terkini: 'active', 'expired', 'used', 'cancelled'
  Future<Map<String, dynamic>> checkTokenStatus({
    required int meetupId,
    required String tokenId,
  }) async {
    if (await Backend.isOnline()) {
      final data = Backend.map(
        await Backend.client.get(
          '/handover/status/$meetupId',
          query: {'token_id': tokenId},
        ),
      );
      return {
        'status': (data['status'] ?? 'cancelled').toString(),
        'proof_number': data['proof_number'],
      };
    }

    final token = _activeTokens[meetupId];
    if (token == null || token.status == 'cancelled') {
      return {'status': 'cancelled', 'proof_number': null};
    }

    if (token.status == 'used') {
      return {'status': 'used', 'proof_number': token.proofNumber};
    }

    if (token.isExpired) {
      return {'status': 'expired', 'proof_number': null};
    }

    return {'status': 'active', 'proof_number': null};
  }

  // ===========================================================================
  // FR-18 [W] & BR-22 & BR-23: VALIDASI & PENYELESAIAN SERAH TERIMA
  // ===========================================================================

  /// Validasi token QR yang dipindai oleh Peminat (FR-18 & BR-22).
  /// Menampilkan pesan spesifik saat gagal (BR-22, AC-21, AC-22).
  /// Saat valid, mengubah pertemuan -> Selesai dan barang -> Completed (BR-23).
  Future<Map<String, dynamic>> validateAndCompleteHandover({
    required int meetupId,
    required String tokenString,
    required int scannerUserId,
  }) async {
    if (await Backend.isOnline()) {
      // Server memeriksa BR-22 (kedaluwarsa, sudah dipakai, bukan pertemuan
      // Anda) lalu menyelesaikan pertemuan & barang dalam satu transaksi.
      final int verifiedMeetupId;
      try {
        final result = Backend.map(
          await Backend.client.post(
            '/handover/verify',
            body: {
              'token': tokenString.trim(),
              // Opsional: tanpa ID, server mencari pertemuan dari token.
              if (meetupId > 0) 'meetup_id': meetupId,
            },
          ),
        );
        verifiedMeetupId = Backend.toInt(result['meetup_id'], meetupId);
      } on ApiException catch (e) {
        return {'success': false, 'message': e.message};
      }
      await MeetupRepository().refresh();
      final proof = HandoverProofModel.fromServer(
        Backend.map(
          await Backend.client.get('/handover/history/$verifiedMeetupId'),
        ),
      );
      await _triggerHandoverSuccessNotification(proof);
      return {
        'success': true,
        'proof': proof,
        'message': 'Serah terima berhasil diverifikasi!',
      };
    }

    final repo = MeetupRepository();
    repo.ensureInitialized();

    final allMeetups = repo.getAllMeetups();
    final meetupIndex = allMeetups.indexWhere((m) => m.id == meetupId);

    if (meetupIndex == -1) {
      return {'success': false, 'message': 'Pertemuan tidak ditemukan.'};
    }

    final meetup = allMeetups[meetupIndex];

    // Validasi 1: Status pertemuan harus Dikonfirmasi
    if (!meetup.isDikonfirmasi && !meetup.isSelesai) {
      return {
        'success': false,
        'message': 'Pertemuan belum berstatus Dikonfirmasi.',
      };
    }

    final activeToken = _activeTokens[meetupId];

    // Validasi 2: Apakah token pernah dibuat?
    if (activeToken == null || activeToken.status == 'cancelled') {
      return {
        'success': false,
        'message': 'Sesi QR telah dibatalkan oleh pemilik barang.',
      };
    }

    // Validasi 3: Apakah token sudah pernah digunakan?
    if (activeToken.status == 'used') {
      return {
        'success': false,
        'message': 'QR sudah digunakan', // BR-22
      };
    }

    // Validasi 4: Apakah token cocok?
    if (activeToken.token.trim().toUpperCase() !=
        tokenString.trim().toUpperCase()) {
      return {
        'success': false,
        'message': 'Kode QR tidak valid untuk pertemuan ini.',
      };
    }

    // Validasi 5: Apakah token kedaluwarsa? (AC-21)
    if (activeToken.isExpired) {
      return {
        'success': false,
        'message': 'QR kedaluwarsa, minta pemilik memperbarui', // BR-22, AC-21
      };
    }

    // Validasi 6: Apakah pemindai adalah Peminat pada pertemuan ini? (AC-22)
    if (scannerUserId != meetup.requesterId) {
      return {
        'success': false,
        'message': 'QR bukan untuk pertemuan Anda', // BR-22, AC-22
      };
    }

    // SEMUA VALIDASI LOLOS -> PROSES PENYELESAIAN (BR-23 & BR-24)
    final completedMeetup = await repo.completeMeetup(meetupId);

    // Tandai token used
    final now = DateTime.now();
    _activeTokens[meetupId] = activeToken.copyWith(status: 'used', usedAt: now);

    // Buat bukti serah terima immutable (BR-24)
    final proof = HandoverProofModel(
      proofNumber:
          activeToken.proofNumber ??
          'PRF-${now.year}${now.month.toString().padLeft(2, '0')}-${1000 + Random().nextInt(9000)}',
      meetupId: meetupId,
      itemId: completedMeetup.itemId,
      itemTitle: completedMeetup.itemTitle,
      itemPrice: completedMeetup.itemPrice,
      itemType: completedMeetup.itemType,
      ownerId: completedMeetup.ownerId,
      ownerName: completedMeetup.ownerName,
      ownerNim: completedMeetup.ownerNim,
      requesterId: completedMeetup.requesterId,
      requesterName: completedMeetup.requesterName,
      requesterNim: completedMeetup.requesterNim,
      safeMeetPointName: completedMeetup.safeMeetPoint.name,
      validatedAt: now,
      tokenString: activeToken.token,
      verificationHash:
          'UNAND-SHA256-${(now.millisecondsSinceEpoch ^ meetupId).toRadixString(16).toUpperCase()}',
    );

    // Simpan bukti ke persistent SharedPreferences (FR-19)
    await _saveProofToStorage(proof);

    // Picu Notifikasi Lokal N-04 (Handover Success Alert, FR-21)
    await _triggerHandoverSuccessNotification(proof);

    return {
      'success': true,
      'proof': proof,
      'message': 'Serah terima berhasil diverifikasi!',
    };
  }

  // ===========================================================================
  // FR-19 [W] & BR-24: RIWAYAT TRANSAKSI & BUKTI SERAH TERIMA
  // ===========================================================================

  Future<void> _saveProofToStorage(HandoverProofModel proof) async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getStringList('handover_proofs') ?? [];
    existingJson.insert(0, jsonEncode(proof.toJson()));
    await prefs.setStringList('handover_proofs', existingJson);
  }

  Future<List<HandoverProofModel>> getCompletedTransactions() async {
    if (await Backend.isOnline()) {
      final proofs = Backend.list(
        await Backend.client.get('/handover/history'),
      ).map(HandoverProofModel.fromServer).toList();
      _serverProofs = proofs;
      return proofs;
    }

    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList('handover_proofs') ?? [];
    if (listJson.isEmpty) {
      // Inisialisasi seed bukti selesai jika belum ada
      final seed = _getSeedProofs();
      await prefs.setStringList(
        'handover_proofs',
        seed.map((p) => jsonEncode(p.toJson())).toList(),
      );
      return seed;
    }
    return listJson
        .map((str) => HandoverProofModel.fromJson(jsonDecode(str)))
        .toList();
  }

  List<HandoverProofModel> _getSeedProofs() {
    final now = DateTime.now();
    return [
      HandoverProofModel(
        proofNumber: 'PRF-202610-8812',
        meetupId: 99,
        itemId: 10,
        itemTitle: 'Modul Praktikum Algoritma & Pemrograman',
        itemPrice: 'Rp 45.000',
        itemType: 'Jual',
        ownerId: 3,
        ownerName: 'Fadel Muhammad',
        ownerNim: '2411522029',
        requesterId: 1,
        requesterName: 'Bayu Mutawakkil',
        requesterNim: '2411522023',
        safeMeetPointName: 'Perpustakaan Pusat Kampus (Lantai 1)',
        validatedAt: now.subtract(const Duration(days: 2)),
        tokenString: 'TKN-CS-8812-FA',
        verificationHash: 'UNAND-SHA256-8812FA99B',
      ),
    ];
  }

  // ===========================================================================
  // FR-20 [W] & BR-25 & BR-26: KELOLA ULASAN & SKOR REPUTASI
  // ===========================================================================

  /// FR-20.1: Create Review (1 ulasan per pihak per transaksi, rating 1-5 wajib, komentar maks 500)
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
    // Validasi BR-25
    if (rating < 1 || rating > 5) {
      return {
        'success': false,
        'message': 'Rating wajib diisi antara 1 sampai 5 bintang.',
      };
    }
    if (comment.length > 500) {
      return {
        'success': false,
        'message': 'Komentar ulasan maksimal 500 karakter.',
      };
    }

    if (await Backend.isOnline()) {
      try {
        final review = ReviewModel.fromServer(
          Backend.map(
            await Backend.client.post(
              '/reviews',
              body: {
                'meetup_id': meetupId,
                'rating': rating,
                if (comment.trim().isNotEmpty) 'comment': comment.trim(),
              },
            ),
          ),
          proofNumber: proofNumber,
          targetUserName: targetUserName,
        );
        return {
          'success': true,
          'review': review,
          'message': 'Ulasan berhasil disimpan!',
        };
      } on ApiException catch (e) {
        return {'success': false, 'message': e.message};
      }
    }

    final allReviews = await getAllReviews();

    // Validasi AC-23: Satu ulasan per pihak per transaksi
    final alreadyReviewed = allReviews.any(
      (r) => r.meetupId == meetupId && r.reviewerId == reviewerId,
    );
    if (alreadyReviewed) {
      return {
        'success': false,
        'message':
            'Anda sudah memberikan ulasan untuk transaksi ini. Silakan gunakan menu Edit Ulasan.',
      };
    }

    final newReview = ReviewModel(
      id: 'REV-${DateTime.now().millisecondsSinceEpoch}',
      meetupId: meetupId,
      proofNumber: proofNumber,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      reviewerNim: reviewerNim,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      isEdited: false,
    );

    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList('user_reviews') ?? [];
    listJson.insert(0, jsonEncode(newReview.toJson()));
    await prefs.setStringList('user_reviews', listJson);

    return {
      'success': true,
      'review': newReview,
      'message': 'Ulasan berhasil disimpan!',
    };
  }

  /// FR-20.3: Update Review (Maksimal 1 kali dalam 7 hari, BR-26 & AC-24)
  Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) {
      return {'success': false, 'message': 'Rating wajib 1-5 bintang.'};
    }
    if (comment.length > 500) {
      return {
        'success': false,
        'message': 'Komentar ulasan maksimal 500 karakter.',
      };
    }

    if (await Backend.isOnline()) {
      // BR-26 (sekali sunting, maks. 7 hari) diperiksa server.
      try {
        final review = ReviewModel.fromServer(
          Backend.map(
            await Backend.client.put(
              '/reviews/$reviewId',
              body: {'rating': rating, 'comment': comment.trim()},
            ),
          ),
        );
        return {
          'success': true,
          'review': review,
          'message': 'Ulasan berhasil diperbarui dan ditandai Diedit.',
        };
      } on ApiException catch (e) {
        return {'success': false, 'message': e.message};
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList('user_reviews') ?? [];
    final reviews = listJson
        .map((e) => ReviewModel.fromJson(jsonDecode(e)))
        .toList();

    final index = reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) {
      return {'success': false, 'message': 'Ulasan tidak ditemukan.'};
    }

    final target = reviews[index];

    // Validasi BR-26 & AC-24: Hanya 1 kali sunting & dalam 7 hari
    if (target.isEdited) {
      return {
        'success': false,
        'message':
            'Ulasan hanya dapat disunting satu kali.',
      };
    }

    final days = DateTime.now().difference(target.createdAt).inDays;
    if (days >= 7) {
      return {
        'success': false,
        'message':
            'Batas waktu penyuntingan 7 hari telah lewat.',
      };
    }

    final updated = target.copyWith(
      rating: rating,
      comment: comment,
      updatedAt: DateTime.now(),
      isEdited: true, // Ditandai "Diedit" (BR-26)
    );

    reviews[index] = updated;
    await prefs.setStringList(
      'user_reviews',
      reviews.map((r) => jsonEncode(r.toJson())).toList(),
    );

    return {
      'success': true,
      'review': updated,
      'message': 'Ulasan berhasil diperbarui dan ditandai Diedit.',
    };
  }

  /// Semua ulasan tersimpan
  Future<List<ReviewModel>> getAllReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList('user_reviews') ?? [];
    if (listJson.isEmpty) {
      final seed = _getSeedReviews();
      await prefs.setStringList(
        'user_reviews',
        seed.map((r) => jsonEncode(r.toJson())).toList(),
      );
      return seed;
    }
    return listJson
        .map((str) => ReviewModel.fromJson(jsonDecode(str)))
        .toList();
  }

  List<ReviewModel> _getSeedReviews() {
    final now = DateTime.now();
    return [
      ReviewModel(
        id: 'REV-001',
        meetupId: 99,
        proofNumber: 'PRF-202610-8812',
        reviewerId: 1,
        reviewerName: 'Bayu Mutawakkil',
        reviewerNim: '2411522023',
        targetUserId: 3,
        targetUserName: 'Fadel Muhammad',
        rating: 5,
        comment:
            'Barang sangat mulus dan sesuai deskripsi. Tepat waktu di Perpustakaan Pusat Unand!',
        createdAt: now.subtract(const Duration(days: 2)),
        isEdited: false,
      ),
      ReviewModel(
        id: 'REV-002',
        meetupId: 98,
        proofNumber: 'PRF-202610-7711',
        reviewerId: 2,
        reviewerName: 'Muhammad Racha',
        reviewerNim: '2411522020',
        targetUserId: 3,
        targetUserName: 'Fadel Muhammad',
        rating: 5,
        comment:
            'Respon cepat dan ramah, transaksi barter berjalan lancar tanpa kendala.',
        createdAt: now.subtract(const Duration(days: 5)),
        isEdited: true, // contoh ulasan diedit
      ),
      ReviewModel(
        id: 'REV-003',
        meetupId: 99,
        proofNumber: 'PRF-202610-8812',
        reviewerId: 3,
        reviewerName: 'Fadel Muhammad',
        reviewerNim: '2411522029',
        targetUserId: 1,
        targetUserName: 'Bayu Mutawakkil',
        rating: 5,
        comment:
            'Pembeli sangat kooperatif dan datang tepat waktu di titik Safe-Meet kampus.',
        createdAt: now.subtract(const Duration(days: 2)),
        isEdited: false,
      ),
    ];
  }

  /// Ulasan yang DITERIMA oleh seorang pengguna (untuk profil reputasi publik - FR-20.2, BR-25)
  Future<List<ReviewModel>> getReviewsForUser(int userId) async {
    if (await Backend.isOnline()) {
      // FR-20: profil publik berisi seluruh ulasan yang diterima.
      final profile = Backend.map(await Backend.client.get('/users/$userId'));
      final name = (profile['full_name'] ?? 'Mitra Transaksi').toString();
      return (profile['reviews'] as List? ?? const [])
          .map(
            (e) => ReviewModel.fromServer(
              Map<String, dynamic>.from(e as Map),
              targetUserName: name,
            ),
          )
          .toList();
    }
    final all = await getAllReviews();
    return all.where((r) => r.targetUserId == userId).toList();
  }

  /// Ulasan yang DIBERIKAN oleh pengguna yang sedang login
  Future<List<ReviewModel>> getMyReviews(int currentUserId) async {
    if (await Backend.isOnline()) {
      // Diambil dari riwayat transaksi (`my_review` tiap bukti).
      final proofs = _serverProofs.isNotEmpty
          ? _serverProofs
          : await getCompletedTransactions();
      return [
        for (final p in proofs)
          if (p.myReview != null)
            ReviewModel(
              id: p.myReview!.id,
              meetupId: p.meetupId,
              proofNumber: p.proofNumber,
              reviewerId: p.myReview!.reviewerId,
              reviewerName: p.myReview!.reviewerName,
              reviewerNim: '',
              targetUserId: p.myReview!.targetUserId,
              targetUserName: p.myReview!.targetUserId == p.ownerId
                  ? p.ownerName
                  : p.requesterName,
              rating: p.myReview!.rating,
              comment: p.myReview!.comment,
              createdAt: p.myReview!.createdAt,
              updatedAt: p.myReview!.updatedAt,
              isEdited: p.myReview!.isEdited,
              serverCanEdit: p.myReview!.serverCanEdit,
            ),
      ];
    }
    final all = await getAllReviews();
    return all.where((r) => r.reviewerId == currentUserId).toList();
  }

  // ===========================================================================
  // NOTIFIKASI LOKAL (FR-21 & FR-22)
  // ===========================================================================

  Future<void> _triggerHandoverSuccessNotification(
    HandoverProofModel proof,
  ) async {
    try {
      await initNotifications();
      const androidDetails = AndroidNotificationDetails(
        'handover_channel',
        'Serah Terima CampuShift',
        channelDescription: 'Notifikasi penyelesaian serah terima dan ulasan',
        importance: Importance.high,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: proof.meetupId,
        title: 'Serah Terima Berhasil! 🎉',
        body:
            'Barang "${proof.itemTitle}" telah diserahterimakan. Berikan ulasan untuk ${proof.ownerName}!',
        notificationDetails: notificationDetails,
      );
    } catch (_) {
      // Ignored on platforms without notification support
    }
  }

  // ===========================================================================
  // HELPER SIMULASI (Untuk kemudahan pengujian UAT & demonstrasi)
  // ===========================================================================

  void simulateScanSuccess(int meetupId) {
    if (_activeTokens.containsKey(meetupId)) {
      final current = _activeTokens[meetupId]!;
      final now = DateTime.now();
      _activeTokens[meetupId] = current.copyWith(
        status: 'used',
        usedAt: now,
      );

      final repo = MeetupRepository();
      repo.ensureInitialized();
      final meetup = repo.getMeetupById(meetupId);
      if (meetup != null && !meetup.isSelesai) {
        unawaited(
          repo.completeMeetup(meetupId).then((completedMeetup) async {
            final proof = HandoverProofModel(
              proofNumber:
                  current.proofNumber ??
                  'PRF-${now.year}${now.month.toString().padLeft(2, '0')}-${1000 + Random().nextInt(9000)}',
              meetupId: meetupId,
              itemId: completedMeetup.itemId,
              itemTitle: completedMeetup.itemTitle,
              itemPrice: completedMeetup.itemPrice,
              itemType: completedMeetup.itemType,
              ownerId: completedMeetup.ownerId,
              ownerName: completedMeetup.ownerName,
              ownerNim: completedMeetup.ownerNim,
              requesterId: completedMeetup.requesterId,
              requesterName: completedMeetup.requesterName,
              requesterNim: completedMeetup.requesterNim,
              safeMeetPointName: completedMeetup.safeMeetPoint.name,
              validatedAt: now,
              tokenString: current.token,
              verificationHash:
                  'UNAND-SHA256-${(now.millisecondsSinceEpoch ^ meetupId).toRadixString(16).toUpperCase()}',
            );
            await _saveProofToStorage(proof);
          }),
        );
      }
    }
  }

  void simulateExpired(int meetupId) {
    if (_activeTokens.containsKey(meetupId)) {
      final current = _activeTokens[meetupId]!;
      _activeTokens[meetupId] = current.copyWith(
        status: 'expired',
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );
    }
  }

  HandoverTokenModel? getCachedSession(int meetupId) {
    return _activeTokens[meetupId];
  }
}
