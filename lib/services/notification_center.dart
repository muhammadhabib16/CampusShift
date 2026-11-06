import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend.dart';

/// Jenis sumber notifikasi, dipakai untuk ikon dan navigasi saat diketuk.
enum AppNotificationType { meetup, barter, claim, incomingClaim }

class AppNotification {
  const AppNotification({
    required this.key,
    required this.type,
    required this.refId,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });

  /// Kunci unik per perubahan status (jenis-id-status-waktu).
  final String key;
  final AppNotificationType type;
  final int refId;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) => AppNotification(
    key: key,
    type: type,
    refId: refId,
    title: title,
    body: body,
    time: time,
    isRead: isRead ?? this.isRead,
  );
}

/// Kotak masuk notifikasi dalam aplikasi (ikon lonceng di app bar).
///
/// Sumber data: `GET /sync` (PRD 2.8 / NFR-07) yang memuat pertemuan, barter,
/// klaim saya, dan klaim masuk. Setiap perubahan status yang dilakukan pihak
/// lain diubah menjadi satu entri notifikasi. Status "sudah dibaca" disimpan
/// per pengguna di SharedPreferences; data yang sudah ada saat pertama kali
/// dimuat dianggap sudah dibaca agar pengguna tidak dibanjiri notifikasi lama.
class NotificationCenter extends ChangeNotifier {
  NotificationCenter();

  static const Duration pollInterval = Duration(seconds: 60);
  static const Duration maxAge = Duration(days: 30);
  static const int maxItems = 50;

  List<AppNotification> _items = const [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  DateTime? _baseline;
  Set<String> _readKeys = {};
  Timer? _timer;

  /// Dipasang oleh MainScreen agar notifikasi barter dapat membuka tab Barter.
  void Function(int index)? onSelectTab;

  List<AppNotification> get items => _items;
  int get unreadCount => _items.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _readKey => 'notif_read_$_userId';
  String get _baselineKey => 'notif_baseline_$_userId';

  /// Mulai sinkronisasi untuk pengguna yang login (dipanggil MainScreen).
  Future<void> start(String userId) async {
    if (_userId != userId) {
      _items = const [];
      _readKeys = {};
      _baseline = null;
      _userId = userId;
      await _loadPrefs();
    }
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => refresh());
    await refresh();
  }

  /// Hentikan sinkronisasi berkala (logout / MainScreen ditutup).
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _readKeys = (prefs.getStringList(_readKey) ?? const []).toSet();
      final base = prefs.getString(_baselineKey);
      _baseline = base == null ? null : DateTime.tryParse(base);
    } catch (_) {
      // SharedPreferences tidak tersedia (widget test): simpan di memori saja.
    }
  }

  Future<void> _savePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Hanya simpan kunci yang masih tampil agar daftar tidak membengkak.
      final visible = _items.map((n) => n.key).toSet();
      _readKeys.retainWhere(visible.contains);
      await prefs.setStringList(_readKey, _readKeys.toList());
      if (_baseline != null) {
        await prefs.setString(_baselineKey, _baseline!.toIso8601String());
      }
    } catch (_) {}
  }

  Future<void> refresh() async {
    if (_userId == null || _isLoading) return;
    if (!await Backend.isOnline()) {
      _items = const [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final data = Backend.map(await Backend.client.get('/sync'));
      final serverTime = Backend.toLocalTime(data['server_time']);
      final isFirstLoad = _baseline == null;
      _baseline ??= serverTime;

      final events = <AppNotification>[
        ..._list(data['meetups']).map(_fromMeetup).whereType<AppNotification>(),
        ..._list(data['barters']).map(_fromBarter).whereType<AppNotification>(),
        ..._list(data['claims']).map(_fromClaim).whereType<AppNotification>(),
        ..._list(data['incoming_claims'])
            .map(_fromIncomingClaim)
            .whereType<AppNotification>(),
      ];

      final cutoff = DateTime.now().subtract(maxAge);
      events
        ..removeWhere((n) => n.time.isBefore(cutoff))
        ..sort((a, b) => b.time.compareTo(a.time));

      _items = events
          .take(maxItems)
          .map(
            (n) => n.copyWith(
              isRead:
                  _readKeys.contains(n.key) || !n.time.isAfter(_baseline!),
            ),
          )
          .toList();
      _error = null;
      if (isFirstLoad) await _savePrefs();
    } catch (e) {
      _error = 'Gagal memuat notifikasi. Tarik ke bawah untuk mencoba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markRead(AppNotification n) {
    if (n.isRead) return;
    _readKeys.add(n.key);
    _items = [
      for (final i in _items) i.key == n.key ? i.copyWith(isRead: true) : i,
    ];
    notifyListeners();
    _savePrefs();
  }

  void markAllRead() {
    if (unreadCount == 0) return;
    _readKeys.addAll(_items.map((n) => n.key));
    _items = [for (final i in _items) i.copyWith(isRead: true)];
    notifyListeners();
    _savePrefs();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Pemetaan data /sync → notifikasi. Aksi milik pengguna sendiri dilewati.
  // ---------------------------------------------------------------------------

  static List<Map<String, dynamic>> _list(dynamic v) => v is List
      ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : const [];

  int get _me => int.tryParse(_userId ?? '') ?? -1;

  AppNotification _make(
    AppNotificationType type,
    Map<String, dynamic> json,
    String title,
    String body,
  ) {
    final id = Backend.toInt(json['id']);
    final status = '${json['status']}';
    final time = Backend.toLocalTime(json['updated_at'] ?? json['created_at']);
    return AppNotification(
      key: '${type.name}-$id-$status-${time.millisecondsSinceEpoch}',
      type: type,
      refId: id,
      title: title,
      body: body,
      time: time,
      isRead: false,
    );
  }

  static String _jadwal(dynamic value) =>
      DateFormat('EEE, d MMM • HH.mm', 'id_ID').format(Backend.toLocalTime(value));

  AppNotification? _fromMeetup(Map<String, dynamic> m) {
    final isOwner = Backend.toInt(m['owner_id']) == _me;
    final item = '"${m['item_title'] ?? 'barang'}"';
    final point = (m['safe_meet_point'] is Map)
        ? (m['safe_meet_point'] as Map)['name']
        : null;
    final where = point == null ? '' : ' di $point';
    final partner = isOwner ? m['requester_name'] : m['owner_name'];
    const t = AppNotificationType.meetup;

    switch (m['status']) {
      case 'Diajukan':
        if (!isOwner) return null;
        return _make(
          t,
          m,
          'Ajakan pertemuan baru',
          '$partner mengajak bertemu untuk $item$where, ${_jadwal(m['scheduled_time'])}.',
        );
      case 'Dikonfirmasi':
        if (isOwner) return null;
        return _make(
          t,
          m,
          'Pertemuan dikonfirmasi',
          '$partner menyetujui pertemuan untuk $item$where, ${_jadwal(m['scheduled_time'])}.',
        );
      case 'Ditolak':
        if (isOwner) return null;
        return _make(t, m, 'Ajakan pertemuan ditolak',
            '$partner menolak ajakan pertemuan untuk $item.');
      case 'Dibatalkan':
        final by = m['cancelled_by'];
        final myName = isOwner ? m['owner_name'] : m['requester_name'];
        if (by != null && by == myName) return null;
        final reason = (m['cancellation_reason'] ?? '').toString();
        return _make(t, m, 'Pertemuan dibatalkan',
            'Pertemuan untuk $item dibatalkan.${reason.isEmpty ? '' : ' Alasan: $reason'}');
      case 'Selesai':
        return _make(t, m, 'Serah terima selesai',
            'Transaksi $item selesai. Jangan lupa beri ulasan untuk $partner.');
    }
    return null;
  }

  AppNotification? _fromBarter(Map<String, dynamic> b) {
    final sentByMe = b['is_sent_by_me'] == true;
    final partner = b['partner_name'] ?? 'Mitra';
    final partnerItem = (b['partner_item'] is Map)
        ? '"${(b['partner_item'] as Map)['name']}"'
        : 'barang';
    const t = AppNotificationType.barter;

    switch (b['status']) {
      case 'Pending':
        if (sentByMe) return null;
        return _make(t, b, 'Tawaran barter baru',
            '$partner menawarkan $partnerItem untuk ditukar dengan barangmu.');
      case 'Negotiating':
        if (b['last_offer_by_me'] == true) return null;
        return _make(t, b, 'Tawaran barter diperbarui',
            '$partner mengubah tawaran pertukaran. Cek dan beri tanggapan.');
      case 'Locked':
        return _make(t, b, 'Kesepakatan barter terkunci',
            'Barter dengan $partner disepakati. Jadwalkan pertemuan COD.');
      case 'Rejected':
        if (!sentByMe) return null;
        return _make(t, b, 'Tawaran barter ditolak',
            '$partner menolak tawaran barter kamu.');
      case 'Cancelled':
        return _make(t, b, 'Barter dibatalkan',
            'Kesepakatan barter dengan $partner dibatalkan.');
      case 'Completed':
        return _make(t, b, 'Barter selesai',
            'Pertukaran dengan $partner telah selesai.');
    }
    return null;
  }

  AppNotification? _fromClaim(Map<String, dynamic> c) {
    final item = '"${c['item_title'] ?? 'barang hibah'}"';
    const t = AppNotificationType.claim;
    switch (c['status']) {
      case 'Approved':
        return _make(t, c, 'Klaim hibah disetujui',
            'Klaim $item disetujui donatur. Jadwalkan pengambilan.');
      case 'Rejected':
        final reason = (c['reason'] ?? '').toString();
        return _make(t, c, 'Klaim hibah belum disetujui',
            'Klaim $item tidak disetujui.${reason.isEmpty ? '' : ' Alasan: $reason'}');
      case 'Completed':
        return _make(t, c, 'Hibah diterima', 'Serah terima $item selesai.');
    }
    return null;
  }

  AppNotification? _fromIncomingClaim(Map<String, dynamic> c) {
    if (c['status'] != 'Pending') return null;
    final applicant = (c['applicant'] is Map)
        ? (c['applicant'] as Map)['name']
        : 'Mahasiswa';
    return _make(
      AppNotificationType.incomingClaim,
      c,
      'Klaim hibah baru',
      '$applicant mengajukan klaim untuk "${c['item_title'] ?? 'barang hibah'}".',
    );
  }
}
