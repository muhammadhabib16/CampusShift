import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/safe_meet_point.dart';
import '../../services/location_service.dart';
import '../../services/meetup_repository.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import 'safe_meet_detail_screen.dart';

class SafeMeetDirectoryScreen extends StatefulWidget {
  final bool isPickerMode;

  const SafeMeetDirectoryScreen({super.key, this.isPickerMode = false});

  @override
  State<SafeMeetDirectoryScreen> createState() =>
      _SafeMeetDirectoryScreenState();
}

class _SafeMeetDirectoryScreenState extends State<SafeMeetDirectoryScreen> {
  final MeetupRepository _repository = MeetupRepository();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  bool _isMapView = false;
  bool _isLoadingGps = false;
  bool _gpsActive = true;
  String? _gpsWarningMessage;

  double? _userLat = -0.9144;
  double? _userLng = 100.4601;

  List<SafeMeetPoint> _allPoints = [];
  List<SafeMeetPoint> _filteredPoints = [];
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    _loadPoints();
    await _detectGps(showFeedback: false);
  }

  void _loadPoints() {
    setState(() {
      _allPoints = _repository.getSafeMeetPoints(
        userLat: _gpsActive ? _userLat : null,
        userLng: _gpsActive ? _userLng : null,
      );
      _applyFilter();
    });
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredPoints = _allPoints.where((point) {
        final matchesQuery =
            point.name.toLowerCase().contains(query) ||
            point.category.toLowerCase().contains(query) ||
            point.description.toLowerCase().contains(query);
        final matchesCat =
            _selectedCategory == 'Semua' || point.category == _selectedCategory;
        return matchesQuery && matchesCat;
      }).toList();
    });
  }

  Future<void> _detectGps({bool showFeedback = true}) async {
    setState(() {
      _isLoadingGps = true;
    });

    final result = await LocationService.getCurrentLocation();

    setState(() {
      _isLoadingGps = false;
      if (result.hasLocation) {
        _gpsActive = true;
        _userLat = result.position!.latitude;
        _userLng = result.position!.longitude;
        _gpsWarningMessage = null;
      } else {
        _gpsWarningMessage = result.errorMessage ?? 'Izin lokasi tidak aktif. Jarak ditampilkan "—" dan titik temu diurutkan berdasarkan abjad nama.';
      }
    });

    _loadPoints();

    if (showFeedback && mounted) {
      if (_gpsActive) {
        AppSnackBar.showSuccess(
          context,
          'GPS Aktif: Titik temu terurut dari lokasi terdekat.',
        );
      } else {
        AppSnackBar.showInfo(
          context,
          'GPS Nonaktif: Menampilkan titik temu secara alfabetis.',
        );
      }
    }
  }

  void _toggleGpsSimulation() {
    setState(() {
      _gpsActive = !_gpsActive;
      if (_gpsActive) {
        _userLat = -0.9144;
        _userLng = 100.4601;
        _gpsWarningMessage = null;
      } else {
        _userLat = null;
        _userLng = null;
        _gpsWarningMessage = 'Mode Uji AC-08: GPS dinonaktifkan. Jarak ditampilkan "—" dan daftar diurutkan menurut abjad nama tanpa crash.';
      }
    });

    _loadPoints();

    if (_gpsActive) {
      AppSnackBar.showSuccess(
        context,
        'Mode AC-07 Aktif: Lokasi GPS terdeteksi, titik temu terurut dari terdekat.',
      );
    } else {
      AppSnackBar.showInfo(
        context,
        'Mode AC-08 Aktif: GPS dimatikan, jarak "—", urut alfabetis.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isPickerMode
                  ? 'Pilih Titik Temu Resmi'
                  : 'Direktori Safe-Meet Point',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Universitas Andalas (Kampus Limau Manis)',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isMapView
                ? 'Lihat Tampilan Daftar'
                : 'Lihat Tampilan Peta',
            icon: Icon(
              _isMapView ? Icons.view_list_rounded : Icons.map_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() => _isMapView = !_isMapView);
            },
          ),
          IconButton(
            tooltip: 'Simulasi GPS (AC-07 / AC-08)',
            icon: Icon(
              _gpsActive ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
              color: _gpsActive ? AppColors.primary : AppColors.error,
            ),
            onPressed: _toggleGpsSimulation,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_gpsActive || _gpsWarningMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 10,
              ),
              color: const Color(0xFFFEF3C7),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFB45309),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _gpsWarningMessage ?? 'Izin lokasi tidak aktif. Jarak ditampilkan "—" (AC-08).',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF78350F),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _detectGps(showFeedback: true),
                    child: const Text(
                      'Nyalakan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

          // Search Bar & Filter Kategori
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilter(),
                  decoration: InputDecoration(
                    hintText: 'Cari titik temu resmi (satpam, perpus, dll)…',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilter();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.pill,
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                          'Semua',
                          'Pos Satpam',
                          'Perpustakaan',
                          'Gedung Pusat',
                          'Selasar',
                          'Area Ramai',
                        ].map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.sm,
                            ),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: AppColors.primaryContainer,
                              backgroundColor: AppColors.surfaceVariant,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.onPrimaryContainer
                                    : AppColors.textSecondary,
                              ),
                              onSelected: (val) {
                                setState(() {
                                  _selectedCategory = cat;
                                  _applyFilter();
                                });
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outline),

          // Area Tampilan Peta atau Daftar
          Expanded(
            child: _isLoadingGps
                ? const LoadingState(label: 'Mendeteksi posisi GPS…')
                : _isMapView
                ? _buildInteractiveMap()
                : _buildPointsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMap() {
    final centerLat = _userLat ?? -0.9144;
    final centerLng = _userLng ?? 100.4601;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(centerLat, centerLng),
            initialZoom: 16.0,
            minZoom: 13.0,
            maxZoom: 18.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.campusshift',
            ),
            MarkerLayer(
              markers: [
                if (_gpsActive && _userLat != null && _userLng != null)
                  Marker(
                    point: LatLng(_userLat!, _userLng!),
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ..._filteredPoints.map((point) {
                  return Marker(
                    point: LatLng(point.latitude, point.longitude),
                    width: 48,
                    height: 48,
                    child: GestureDetector(
                      onTap: () => _showPointPreviewBottomSheet(point),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),

        // Floating Control Buttons
        Positioned(
          bottom: 20,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'recenter_campus',
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                child: const Icon(Icons.school_rounded),
                onPressed: () {
                  _mapController.move(const LatLng(-0.9144, 100.4601), 16.0);
                },
              ),
              const SizedBox(height: 8),
              if (_gpsActive && _userLat != null && _userLng != null)
                FloatingActionButton.small(
                  heroTag: 'my_location',
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.my_location_rounded),
                  onPressed: () {
                    _mapController.move(LatLng(_userLat!, _userLng!), 16.5);
                  },
                ),
            ],
          ),
        ),

        // Map Legend Indicator
        Positioned(
          top: 12,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.94),
              borderRadius: AppRadius.pill,
              boxShadow: AppElevation.softShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_filteredPoints.length} Titik Temu Resmi',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsList() {
    if (_filteredPoints.isEmpty) {
      return const EmptyState(
        title: 'Tidak Ada Titik Temu',
        description:
            'Tidak ada safe-meet point yang sesuai dengan filter pencarian.',
        icon: Icons.location_off_rounded,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _filteredPoints.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final point = _filteredPoints[index];
        return _buildPointCard(point);
      },
    );
  }

  Widget _buildPointCard(SafeMeetPoint point) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () {
        if (widget.isPickerMode) {
          Navigator.of(context).pop(point);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SafeMeetDetailScreen(point: point),
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.medium,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            point.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _gpsActive
                                ? const Color(0xFFDCFCE7)
                                : AppColors.surfaceVariant,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.near_me_rounded,
                                size: 12,
                                color: _gpsActive
                                    ? const Color(0xFF15803D)
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatJarak(point.distanceInMeters),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _gpsActive
                                      ? const Color(0xFF15803D)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      point.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            point.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: 4,
            children: point.safetyFeatures.take(2).map((feat) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    feat,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          if (widget.isPickerMode) ...[
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: 'Pilih Titik Temu Ini',
              onPressed: () => Navigator.of(context).pop(point),
            ),
          ],
        ],
      ),
    );
  }

  void _showPointPreviewBottomSheet(SafeMeetPoint point) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
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
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '📍 ${formatJarak(point.distanceInMeters)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                point.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                point.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      label: 'Lihat Detail',
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SafeMeetDetailScreen(point: point),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppPrimaryButton(
                      label: widget.isPickerMode
                          ? 'Pilih Titik Ini'
                          : 'Buka Titik',
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        if (widget.isPickerMode) {
                          Navigator.of(context).pop(point);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  SafeMeetDetailScreen(point: point),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
