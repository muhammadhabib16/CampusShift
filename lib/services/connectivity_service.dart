import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Status koneksi aplikasi untuk banner offline.
///
/// Dua sumber digabung:
/// 1. `connectivity_plus`: tahu cepat bila Wi-Fi / data seluler mati.
/// 2. Hasil request ke server ([ApiClient.guardNetwork] memanggil
///    [reportNetworkFailure] / [reportOnline]): menangkap kasus terhubung ke
///    Wi-Fi tetapi tidak ada internet, atau server tidak dapat dijangkau.
///
/// Saat status berubah dari offline ke online, [onReconnect] dipanggil agar
/// layar memuat ulang data.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  bool _isOffline = false;
  bool _justReconnected = false;
  bool _initialized = false;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _reconnectedTimer;

  /// Dipanggil sekali setiap kali koneksi kembali (diisi oleh MainScreen).
  VoidCallback? onReconnect;

  bool get isOffline => _isOffline;

  /// True selama beberapa detik setelah koneksi kembali (banner hijau).
  bool get justReconnected => _justReconnected;

  /// Mulai memantau jaringan perangkat. Aman di Web / widget test: kegagalan
  /// plugin diabaikan dan status hanya diperbarui dari hasil request.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final connectivity = Connectivity();
      _apply(await connectivity.checkConnectivity());
      _sub = connectivity.onConnectivityChanged.listen(_apply);
    } catch (e) {
      debugPrint('ConnectivityService.init gagal: $e');
    }
  }

  void _apply(List<ConnectivityResult> results) {
    final hasNetwork = results.any((r) => r != ConnectivityResult.none);
    _setOffline(!hasNetwork);
  }

  /// Request ke server gagal karena jaringan (timeout, DNS, socket).
  void reportNetworkFailure() => _setOffline(true);

  /// Request ke server mendapat respons (apa pun status HTTP-nya).
  void reportOnline() => _setOffline(false);

  void _setOffline(bool offline) {
    if (_isOffline == offline) return;
    final wasOffline = _isOffline;
    _isOffline = offline;

    _reconnectedTimer?.cancel();
    if (wasOffline && !offline) {
      _justReconnected = true;
      _reconnectedTimer = Timer(const Duration(seconds: 3), () {
        _justReconnected = false;
        notifyListeners();
      });
      onReconnect?.call();
    } else {
      _justReconnected = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _reconnectedTimer?.cancel();
    super.dispose();
  }
}
