import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/safe_meet_point.dart';
import '../../services/maps_launcher_service.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import 'meetup_form_screen.dart';

class SafeMeetDetailScreen extends StatelessWidget {
  final SafeMeetPoint point;

  const SafeMeetDetailScreen({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Titik Temu Resmi',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Header Card dengan Thumbnail Peta
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: AppRadius.large,
              border: Border.all(color: AppColors.outline),
              boxShadow: AppElevation.softShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(point.latitude, point.longitude),
                initialZoom: 16.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
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
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(
                          Icons.shield,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Judul dan Kategori
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        point.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: AppRadius.pill,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 12,
                            color: Color(0xFF15803D),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Resmi Kampus (Official)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  point.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  point.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const Divider(height: 24, color: AppColors.outline),

                // Indikator Jarak Haversine
                Row(
                  children: [
                    const Icon(
                      Icons.near_me_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text(
                      'Jarak dari Posisimu: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      formatJarak(point.distanceInMeters),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Detail Operasional & Patokan
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panduan & Fasilitas Keamanan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow(
                  Icons.access_time_filled_rounded,
                  'Jam Operasional Disarankan',
                  point.operationalHours,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow(
                  Icons.pin_drop_rounded,
                  'Patokan Lokasi',
                  point.landmark.isNotEmpty
                      ? point.landmark
                      : 'Dekat Pos Satpam / Lobby Utama',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow(
                  Icons.my_location,
                  'Koordinat GPS Presisi',
                  '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
                ),
                const Divider(height: 24, color: AppColors.outline),
                const Text(
                  'Fitur Keamanan Terverifikasi (BR-07):',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...point.safetyFeatures.map((feat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            feat,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Tombol Buka Rute Google Maps (FR-09 & AC-12)
          AppSecondaryButton(
            label: 'Buka Rute Navigasi Google Maps',
            icon: Icons.directions_rounded,
            onPressed: () async {
              final success = await MapsLauncherService.openNavigation(
                latitude: point.latitude,
                longitude: point.longitude,
                destinationTitle: point.name,
              );

              if (context.mounted) {
                if (success) {
                  AppSnackBar.showSuccess(
                    context,
                    'Membuka navigasi Google Maps menuju ${point.name}',
                  );
                } else {
                  AppSnackBar.showError(
                    context,
                    'Gagal membuka aplikasi navigasi eksternal.',
                  );
                }
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Tombol Ajukan Pertemuan di Sini
          AppPrimaryButton(
            label: 'Ajukan Pertemuan di Titik Ini',
            icon: Icons.calendar_month_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MeetupFormScreen(
                    initialSafeMeetPoint: point,
                    itemId: 2,
                    itemTitle: 'Laptop Stand Aluminium Adjustable',
                    itemPrice: 'Rp120.000',
                    itemType: 'Jual',
                    ownerId: 3,
                    ownerName: 'Fadel Muhammad',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
