import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/safe_meet_point.dart';
import '../../services/location_service.dart';
import '../../services/meetup_repository.dart';
import 'safe_meet_detail_screen.dart';

class SafeMeetDirectoryScreen extends StatefulWidget {
  final bool isPickerMode;

  const SafeMeetDirectoryScreen({
    super.key,
    this.isPickerMode = false,
  });

  @override
  State<SafeMeetDirectoryScreen> createState() => _SafeMeetDirectoryScreenState();
}

class _SafeMeetDirectoryScreenState extends State<SafeMeetDirectoryScreen> {
  final MeetupRepository _repository = MeetupRepository();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  bool _isMapView = false;
  bool _isLoadingGps = false;
  bool _gpsActive = true;
  String? _gpsWarningMessage;

  // Koordinat simulasi posisi pengguna (default kampus untuk demo)
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
        final matchesQuery = point.name.toLowerCase().contains(query) ||
            point.category.toLowerCase().contains(query) ||
            point.description.toLowerCase().contains(query);
        final matchesCat = _selectedCategory == 'Semua' || point.category == _selectedCategory;
        return matchesQuery && matchesCat;
      }).toList();
    });
  }

  // Mendeteksi GPS riil perangkat (AC-07, AC-08)
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
        // Fallback jika GPS mati atau izin ditolak (AC-08)
        _gpsWarningMessage = result.errorMessage ??
            'Izin lokasi tidak aktif. Jarak ditampilkan "—" dan titik temu diurutkan berdasarkan abjad nama.';
      }
    });

    _loadPoints();

    if (showFeedback && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_gpsActive
              ? 'GPS Aktif: Titik temu diurutkan dari yang terdekat (Haversine).'
              : 'GPS Nonaktif / Izin Ditolak: Menampilkan daftar berdasarkan nama.'),
          backgroundColor: _gpsActive ? const Color(0xFF0D9488) : Colors.orange.shade800,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Toggle simulasi GPS untuk kebutuhan demo AC-07 dan AC-08 di depan dosen
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
        _gpsWarningMessage =
            'Mode Uji AC-08: GPS dinonaktifkan. Jarak ditampilkan "—" dan daftar diurutkan menurut abjad nama tanpa crash.';
      }
    });

    _loadPoints();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_gpsActive
            ? 'Mode AC-07 Aktif: Lokasi GPS terdeteksi, titik temu terurut dari terdekat.'
            : 'Mode AC-08 Aktif: GPS dimatikan, jarak "—", urut alfabetis.'),
        backgroundColor: _gpsActive ? const Color(0xFF0D9488) : Colors.orange.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isPickerMode ? 'Pilih Titik Temu Resmi' : 'Direktori Titik Temu',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Text(
              'Universitas Andalas (Limau Manis)',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF0D9488),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // Switch Tampilan Daftar <-> Peta
          IconButton(
            tooltip: _isMapView ? 'Lihat Daftar' : 'Lihat Peta',
            icon: Icon(
              _isMapView ? Icons.view_list_rounded : Icons.map_rounded,
              color: const Color(0xFF0D9488),
            ),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
          // Tombol Uji GPS (AC-07 / AC-08)
          IconButton(
            tooltip: 'Simulasi GPS (AC-07 / AC-08)',
            icon: Icon(
              _gpsActive ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
              color: _gpsActive ? const Color(0xFF0D9488) : Colors.red,
            ),
            onPressed: _toggleGpsSimulation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Status GPS (AC-08)
          if (!_gpsActive || _gpsWarningMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.amber.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade800, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _gpsWarningMessage ??
                          'Izin lokasi tidak aktif. Jarak ditampilkan "—" (AC-08).',
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _detectGps(showFeedback: true),
                    child: const Text('Nyalakan'),
                  ),
                ],
              ),
            ),

          // Search Bar & Filter Kategori
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilter(),
                  decoration: InputDecoration(
                    hintText: 'Cari titik temu resmi (satpam, perpus, dll)...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.black45),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF0D9488)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilter();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Semua',
                      'Pos Satpam',
                      'Perpustakaan',
                      'Gedung Pusat',
                      'Selasar',
                      'Area Ramai'
                    ].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              _selectedCategory = cat;
                              _applyFilter();
                            });
                          },
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          selectedColor: const Color(0xFF0D9488),
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Content Area: Peta Interaktif (flutter_map) ATAU Daftar List
          Expanded(
            child: _isLoadingGps
                ? const Center(child: CircularProgressIndicator())
                : _isMapView
                    ? _buildInteractiveMap()
                    : _buildPointsList(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PETA INTERAKTIF FLUTTER_MAP (FR-06 & AC-07)
  // ==========================================
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
            // OpenStreetMap Standard Tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.campusshift',
            ),
            // Marker Titik Temu Resmi Kampus & Posisi Mahasiswa
            MarkerLayer(
              markers: [
                // Marker Posisi User (Jika GPS aktif)
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

                // Marker Safe-Meet Points Resmi
                ..._filteredPoints.map((point) {
                  return Marker(
                    point: LatLng(point.latitude, point.longitude),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => _showPointPreviewBottomSheet(point),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 26,
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
                backgroundColor: Colors.white,
                child: const Icon(Icons.school, color: Color(0xFF0D9488)),
                onPressed: () {
                  _mapController.move(const LatLng(-0.9144, 100.4601), 16.0);
                },
              ),
              const SizedBox(height: 8),
              if (_gpsActive && _userLat != null && _userLng != null)
                FloatingActionButton.small(
                  heroTag: 'my_location',
                  backgroundColor: const Color(0xFF0D9488),
                  child: const Icon(Icons.my_location, color: Colors.white),
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
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield, color: Color(0xFF0D9488), size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_filteredPoints.length} Titik Temu Resmi',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // DAFTAR LIST TITIK TEMU (FR-06 & BR-11)
  // ==========================================
  Widget _buildPointsList() {
    if (_filteredPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.location_off_rounded, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Tidak ada titik temu resmi ditemukan.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPoints.length,
      itemBuilder: (context, index) {
        final point = _filteredPoints[index];
        return _buildPointCard(point);
      },
    );
  }

  Widget _buildPointCard(SafeMeetPoint point) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (widget.isPickerMode) {
            // Jika mode picker saat mengajukan pertemuan: kembalikan result ke form
            Navigator.of(context).pop(point);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SafeMeetDetailScreen(point: point),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF0D9488),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                point.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Jarak presisi Haversine (BR-11, AC-07, AC-08)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _gpsActive ? const Color(0xFFF0FDF4) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _gpsActive ? Colors.green.shade200 : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.near_me_rounded,
                                    size: 12,
                                    color: _gpsActive ? Colors.green.shade700 : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    point.formattedDistance,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _gpsActive ? Colors.green.shade800 : Colors.black54,
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
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                point.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: point.safetyFeatures.take(2).map((feat) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF0D9488)),
                      const SizedBox(width: 4),
                      Text(
                        feat,
                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  );
                }).toList(),
              ),
              if (widget.isPickerMode) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(point),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Pilih Titik Temu Ini', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      point.category,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '📍 ${point.formattedDistance}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                point.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(point.description, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SafeMeetDetailScreen(point: point),
                          ),
                        );
                      },
                      child: const Text('Lihat Detail'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        if (widget.isPickerMode) {
                          Navigator.of(context).pop(point);
                        } else {
                          // Buka form pertemuan
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SafeMeetDetailScreen(point: point),
                            ),
                          );
                        }
                      },
                      child: Text(
                        widget.isPickerMode ? 'Pilih Titik Ini' : 'Buka Titik',
                        style: const TextStyle(color: Colors.white),
                      ),
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
