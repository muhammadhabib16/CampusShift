import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/meetup.dart';
import '../../services/maps_launcher_service.dart';
import '../../services/meetup_repository.dart';
import 'meetup_form_screen.dart';

class MeetupDetailScreen extends StatefulWidget {
  final int meetupId;

  const MeetupDetailScreen({
    super.key,
    required this.meetupId,
  });

  @override
  State<MeetupDetailScreen> createState() => _MeetupDetailScreenState();
}

class _MeetupDetailScreenState extends State<MeetupDetailScreen> {
  final MeetupRepository _repository = MeetupRepository();

  Meetup? _meetup;

  @override
  void initState() {
    super.initState();
    _loadMeetup();
  }

  void _loadMeetup() {
    setState(() {
      _meetup = _repository.getMeetupById(widget.meetupId);
    });
  }

  // Aksi Batalkan Pertemuan Dikonfirmasi (BR-10, AC-11)
  Future<void> _handleCancel() async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pertemuan?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sesuai aturan BR-10, membatalkan pertemuan Dikonfirmasi pada jalur Jual akan mengembalikan status barang menjadi "Available".',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Alasan pembatalan...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.cancelMeetup(
        widget.meetupId,
        reason: reasonController.text.trim().isNotEmpty
            ? reasonController.text.trim()
            : 'Dibatalkan oleh pihak terkait',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pertemuan dibatalkan. Status barang kembali "Available" (BR-10).'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadMeetup();
      }
    }
  }

  // Aksi Hapus Ajakan Diajukan (BR-13, AC-11)
  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Ajakan Permanen?'),
        content: const Text(
          'Ajakan akan dihapus permanen dari sistem dan hilang dari daftar penjual (Aturan BR-13 & AC-11).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteMeetup(widget.meetupId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajakan pertemuan berhasil dihapus permanen (AC-11).'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_meetup == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pertemuan')),
        body: const Center(child: Text('Pertemuan tidak ditemukan.')),
      );
    }

    final m = _meetup!;

    Color statusColor;
    Color statusBgColor;
    String statusDesc;

    switch (m.status) {
      case 'Dikonfirmasi':
        statusColor = Colors.green.shade800;
        statusBgColor = Colors.green.shade50;
        statusDesc = 'Pertemuan telah disepakati kedua pihak. Harap hadir tepat waktu di Safe-Meet Point resmi kampus.';
        break;
      case 'Diajukan':
        statusColor = Colors.orange.shade800;
        statusBgColor = Colors.orange.shade50;
        statusDesc = 'Ajakan pertemuan sedang menunggu konfirmasi atau penolakan dari pemilik barang.';
        break;
      case 'Dibatalkan':
        statusColor = Colors.red.shade800;
        statusBgColor = Colors.red.shade50;
        statusDesc = 'Pertemuan ini telah dibatalkan.';
        break;
      default:
        statusColor = Colors.blue.shade800;
        statusBgColor = Colors.blue.shade50;
        statusDesc = 'Transaksi serah terima telah selesai.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Pertemuan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Status Pertemuan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  m.isDikonfirmasi
                      ? Icons.check_circle_rounded
                      : m.isDiajukan
                          ? Icons.access_time_filled_rounded
                          : Icons.cancel_rounded,
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${m.status}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusDesc,
                        style: TextStyle(fontSize: 12, color: statusColor.withValues(alpha: 0.9), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Peta Miniatur Titik Temu
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(m.safeMeetPoint.latitude, m.safeMeetPoint.longitude),
                initialZoom: 16.5,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.campusshift',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(m.safeMeetPoint.latitude, m.safeMeetPoint.longitude),
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
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

          // Info Safe-Meet Point
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
                    const Icon(Icons.shield_rounded, color: Color(0xFF0D9488), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Lokasi Safe-Meet Point Resmi',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const Spacer(),
                    Text(
                      '📍 ${m.safeMeetPoint.formattedDistance}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  m.safeMeetPoint.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  m.safeMeetPoint.description,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Info Jadwal & Pengingat (FR-10, BR-12)
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
                  'Waktu Pertemuan Disepakati',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: Color(0xFF0D9488), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        m.formattedDateTime,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Meeting Reminder Info (FR-10)
                Row(
                  children: [
                    Icon(
                      Icons.alarm_on_rounded,
                      size: 20,
                      color: m.isDikonfirmasi ? Colors.green.shade700 : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        m.isDikonfirmasi
                            ? 'Meeting Reminder aktif: Notifikasi lokal dijadwalkan 30 menit sebelum pertemuan (FR-10).'
                            : 'Meeting Reminder akan aktif otomatis setelah pertemuan Dikonfirmasi.',
                        style: TextStyle(
                          fontSize: 12,
                          color: m.isDikonfirmasi ? Colors.green.shade900 : Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Info Barang & Pihak Terkait
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
                  'Rincian Transaksi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildRow('Barang', m.itemTitle),
                _buildRow('Harga', m.itemPrice),
                _buildRow('Jalur', m.itemType),
                _buildRow('Peminat', '${m.requesterName} (${m.requesterNim})'),
                _buildRow('Pemilik', '${m.ownerName} (${m.ownerNim})'),
                if (m.notes.isNotEmpty) ...[
                  const Divider(height: 16),
                  const Text('Catatan Peminat:', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(m.notes, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Aksi Buka Rute Google Maps (FR-09 & AC-12)
          if (m.isDikonfirmasi) ...[
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  MapsLauncherService.openNavigation(
                    latitude: m.safeMeetPoint.latitude,
                    longitude: m.safeMeetPoint.longitude,
                    destinationTitle: m.safeMeetPoint.name,
                  );
                },
                icon: const Icon(Icons.directions_rounded, color: Colors.white),
                label: const Text(
                  'Buka Rute Navigasi Google Maps (AC-12)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
              ),
            ),
            const SizedBox(height: 10),
            // Tombol Batalkan Pertemuan Dikonfirmasi (BR-10, AC-11)
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _handleCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Batalkan Pertemuan (Kembali Available - BR-10)'),
              ),
            ),
          ],

          if (m.isDiajukan) ...[
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.of(context).push<Meetup>(
                    MaterialPageRoute(
                      builder: (_) => MeetupFormScreen(existingMeetup: m),
                    ),
                  );
                  if (updated != null) _loadMeetup();
                },
                icon: const Icon(Icons.edit_calendar_rounded),
                label: const Text('Ubah Titik Temu atau Jadwal (FR-07.3)'),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0D9488)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _handleDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Hapus Ajakan Permanen (BR-13 & AC-11)',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
