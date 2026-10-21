import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsLauncherService {
  // Membuka navigasi ke koordinat titik temu (FR-09 & AC-12)
  static Future<bool> openNavigation({
    required double latitude,
    required double longitude,
    String destinationTitle = 'Safe-Meet Point',
  }) async {
    // 1. Coba intent resmi aplikasi Google Maps (Android navigation)
    final googleMapsAppUri = Uri.parse(
      'google.navigation:q=$latitude,$longitude&mode=d',
    );

    // 2. Coba geo URI universal (kompatibel multi-platform / map apps)
    final encodedTitle = Uri.encodeComponent(destinationTitle);
    final geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude($encodedTitle)');

    // 3. Fallback browser web Google Maps resmi
    final webMapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&destination_place_id=$encodedTitle',
    );

    try {
      if (await canLaunchUrl(googleMapsAppUri)) {
        return await launchUrl(googleMapsAppUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(geoUri)) {
        return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback browser (AC-12)
        return await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching map intent: $e, falling back to browser URL');
      try {
        return await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
      } catch (e2) {
        debugPrint('Failed to launch web maps: $e2');
        return false;
      }
    }
  }
}
