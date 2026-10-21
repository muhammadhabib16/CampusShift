import 'dart:math';
import '../models/safe_meet_point.dart';

class HaversineHelper {
  // Radius bumi dalam meter
  static const double earthRadiusMeters = 6371000.0;

  // Formula Haversine standar untuk menghitung jarak antara 2 koordinat (meter)
  static double calculateDistanceMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final dLat = _degreesToRadians(endLatitude - startLatitude);
    final dLon = _degreesToRadians(endLongitude - startLongitude);

    final lat1Rad = _degreesToRadians(startLatitude);
    final lat2Rad = _degreesToRadians(endLatitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  // Menghitung dan memperbarui jarak untuk seluruh list titik temu
  // Sesuai BR-11: jika GPS tersedia, urutkan dari terdekat.
  // Jika GPS tidak tersedia, jarak = null dan urutkan menurut abjad nama.
  static List<SafeMeetPoint> processAndSortPoints({
    required List<SafeMeetPoint> points,
    double? userLatitude,
    double? userLongitude,
  }) {
    final updatedList = List<SafeMeetPoint>.from(points);

    if (userLatitude != null && userLongitude != null) {
      for (final point in updatedList) {
        point.distanceInMeters = calculateDistanceMeters(
          startLatitude: userLatitude,
          startLongitude: userLongitude,
          endLatitude: point.latitude,
          endLongitude: point.longitude,
        );
      }
      // Urutkan terdekat ke terjauh (AC-07)
      updatedList.sort((a, b) {
        final distA = a.distanceInMeters ?? double.infinity;
        final distB = b.distanceInMeters ?? double.infinity;
        return distA.compareTo(distB);
      });
    } else {
      // Tidak ada lokasi (AC-08): jarak null dan urutkan berdasarkan nama
      for (final point in updatedList) {
        point.distanceInMeters = null;
      }
      updatedList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return updatedList;
  }
}
