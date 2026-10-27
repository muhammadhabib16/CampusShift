import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final Position? position;
  final bool isServiceEnabled;
  final LocationPermission permission;
  final String? errorMessage;

  LocationResult({
    this.position,
    required this.isServiceEnabled,
    required this.permission,
    this.errorMessage,
  });

  bool get hasLocation => position != null;
}

class LocationService {
  // Koordinat default kampus (contoh: Universitas Andalas / UI / Kampus Umum)
  // sebagai acuan posisi mahasiswa
  static const double defaultCampusLat = -0.9144;
  static const double defaultCampusLng = 100.4601;

  static Future<LocationResult> getCurrentLocation({
    bool requestIfNotGranted = true,
  }) async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        return LocationResult(
          isServiceEnabled: false,
          permission: LocationPermission.unableToDetermine,
          errorMessage: 'Layanan lokasi (GPS) sedang dinonaktifkan. Aktifkan GPS pada perangkat untuk melihat jarak terdekat.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestIfNotGranted) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return LocationResult(
          isServiceEnabled: true,
          permission: permission,
          errorMessage: 'Izin akses lokasi ditolak. Aktifkan izin lokasi di pengaturan aplikasi untuk menghitung jarak titik temu.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          isServiceEnabled: true,
          permission: permission,
          errorMessage: 'Izin lokasi ditolak permanen. Buka pengaturan perangkat untuk mengizinkan akses lokasi.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return LocationResult(
        position: position,
        isServiceEnabled: true,
        permission: permission,
      );
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      return LocationResult(
        isServiceEnabled: false,
        permission: LocationPermission.unableToDetermine,
        errorMessage: 'Gagal mendeteksi lokasi: ${e.toString()}',
      );
    }
  }
}
