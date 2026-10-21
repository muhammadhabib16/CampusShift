import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/safe_meet_point.dart';
import '../../services/maps_launcher_service.dart';
import 'meetup_form_screen.dart';

class SafeMeetDetailScreen extends StatelessWidget {
  final SafeMeetPoint point;

  const SafeMeetDetailScreen({
    super.key,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Titik Temu Resmi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card dengan Thumbnail Peta
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(point.latitude, point.longitude),
                initialZoom: 16.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none, // Static preview map
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.campusshift',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(point.latitude, point.longitude),
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.shield, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Judul dan Kategori
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        point.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 12, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Resmi Kampus (Official)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  point.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  point.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
                const Divider(height: 24),
                // Indikator Jarak Haversine
                Row(
                  children: [
                    const Icon(Icons.near_me_rounded, color: Color(0xFF0D9488), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Jarak dari Posisimu: ',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Text(
                      point.formattedDistance,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                    if (point.distanceInMeters != null)
                      Text(
                        ' (Haversine)',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Detail Operasional & Patokan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panduan & Keamanan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.access_time_filled_rounded,
                  'Jam Operasional Disarankan',
                  point.operationalHours,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  Icons.pin_drop_rounded,
                  'Patokan Lokasi',
                  point.landmark.isNotEmpty ? point.landmark : 'Dekat Pos Satpam / Lobby Utama',
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  Icons.my_location,
                  'Koordinat GPS Presisi',
                  '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
                ),
                const Divider(height: 24),
                const Text(
                  'Fasilitas Keamanan Titik Resmi (BR-07):',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...point.safetyFeatures.map((feat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF0D9488), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feat,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Buka Rute Google Maps (FR-09 & AC-12)
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () async {
                final success = await MapsLauncherService.openNavigation(
                  latitude: point.latitude,
                  longitude: point.longitude,
                  destinationTitle: point.name,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Membuka rute navigasi Google Maps menuju ${point.name} (AC-12)'
                          : 'Gagal membuka aplikasi peta eksternal.'),
                      backgroundColor: const Color(0xFF0D9488),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.directions_rounded, color: Color(0xFF0D9488)),
              label: const Text(
                'Buka Rute Navigasi Google Maps',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol Ajukan Pertemuan di Sini (FR-07.1)
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MeetupFormScreen(
                      initialSafeMeetPoint: point,
                      itemId: 2,
                      itemTitle: 'Laptop Stand Aluminium Adjustable',
                      itemPrice: 'Rp 120.000',
                      itemType: 'Jual',
                      ownerId: 3,
                      ownerName: 'Fadel Muhammad',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
              label: const Text(
                'Ajukan Pertemuan di Titik Ini',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0D9488)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
