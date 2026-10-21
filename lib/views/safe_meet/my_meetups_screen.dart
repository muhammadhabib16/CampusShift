import 'package:flutter/material.dart';
import '../../models/meetup.dart';
import '../../services/maps_launcher_service.dart';
import '../../services/meetup_repository.dart';
import 'meetup_detail_screen.dart';
import 'meetup_form_screen.dart';

class MyMeetupsScreen extends StatefulWidget {
  const MyMeetupsScreen({super.key});

  @override
  State<MyMeetupsScreen> createState() => _MyMeetupsScreenState();
}

class _MyMeetupsScreenState extends State<MyMeetupsScreen> with SingleTickerProviderStateMixin {
  final MeetupRepository _repository = MeetupRepository();
  late TabController _tabController;

  // Role toggle untuk kebutuhan demo (Peminat vs Pemilik)
  bool _isViewingAsRequester = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  // ==========================================
  // AKSI: HAPUS AJAKAN DIAJUKAN (FR-07.4, BR-13, AC-11)
  // ==========================================
  Future<void> _handleDelete(Meetup meetup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Ajakan Pertemuan?'),
        content: const Text(
          'Ajakan yang masih Diajukan akan dihapus secara permanen dan hilang dari daftar kedua pihak (Aturan BR-13 & AC-11).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus Permanen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _repository.deleteMeetup(meetup.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ajakan pertemuan berhasil dihapus permanen (AC-11).'),
              backgroundColor: Color(0xFF0D9488),
            ),
          );
          _refresh();
        }
      }
    }
  }

  // ==========================================
  // AKSI: KONFIRMASI OLEH PEMILIK (FR-08, AC-10)
  // ==========================================
  Future<void> _handleConfirm(Meetup meetup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Jadwal Pertemuan?'),
        content: Text(
          'Menyetujui pertemuan di ${meetup.safeMeetPoint.name} pada ${meetup.formattedShortDateTime}.\n\n'
          'Sesuai aturan FR-08 & AC-10, barang akan berstatus "Reserved" dan ajakan pertemuan lain untuk barang ini otomatis Dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Konfirmasi (AC-10)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.confirmMeetup(meetup.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pertemuan Dikonfirmasi! Status barang menjadi Reserved (AC-10).'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        _refresh();
      }
    }
  }

  // ==========================================
  // AKSI: BATALKAN PERTEMUAN DIKONFIRMASI (FR-07.3, BR-10, AC-11)
  // ==========================================
  Future<void> _handleCancel(Meetup meetup) async {
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
              'Membatalkan pertemuan Dikonfirmasi pada jalur Jual akan mengembalikan status barang menjadi "Available" (Aturan BR-10).',
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
            child: const Text('Batalkan Pertemuan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.cancelMeetup(
        meetup.id,
        reason: reasonController.text.trim().isNotEmpty
            ? reasonController.text.trim()
            : 'Dibatalkan oleh pengguna',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pertemuan dibatalkan. Status barang kembali "Available" (BR-10).'),
            backgroundColor: Colors.orange,
          ),
        );
        _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allMeetups = _isViewingAsRequester
        ? _repository.getMeetupsAsRequester()
        : _repository.getMeetupsAsOwner();

    final diajukanList = allMeetups.where((m) => m.isDiajukan).toList();
    final dikonfirmasiList = allMeetups.where((m) => m.isDikonfirmasi).toList();
    final riwayatList = allMeetups.where((m) => m.isDibatalkan || m.isSelesai).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Jadwal Pertemuan Saya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(98),
          child: Column(
            children: [
              // Role Toggle Bar (Peminat vs Pemilik)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      'Tinjau Sebagai: ',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const Spacer(),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('Peminat (Pembeli)', style: TextStyle(fontSize: 11)),
                          icon: Icon(Icons.person_pin_circle_outlined, size: 14),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Pemilik (Penjual)', style: TextStyle(fontSize: 11)),
                          icon: Icon(Icons.storefront_outlined, size: 14),
                        ),
                      ],
                      selected: {_isViewingAsRequester},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _isViewingAsRequester = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF0D9488),
                labelColor: const Color(0xFF0D9488),
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: 'Semua (${allMeetups.length})'),
                  Tab(text: 'Diajukan (${diajukanList.length})'),
                  Tab(text: 'Dikonfirmasi (${dikonfirmasiList.length})'),
                  Tab(text: 'Riwayat (${riwayatList.length})'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMeetupList(allMeetups),
          _buildMeetupList(diajukanList),
          _buildMeetupList(dikonfirmasiList),
          _buildMeetupList(riwayatList),
        ],
      ),
    );
  }

  Widget _buildMeetupList(List<Meetup> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.event_busy_rounded, size: 52, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Belum ada pertemuan pada kategori ini.',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final meetup = list[index];
        return _buildMeetupCard(meetup);
      },
    );
  }

  Widget _buildMeetupCard(Meetup meetup) {
    Color statusColor;
    Color statusBgColor;

    switch (meetup.status) {
      case 'Dikonfirmasi':
        statusColor = Colors.green.shade800;
        statusBgColor = Colors.green.shade50;
        break;
      case 'Diajukan':
        statusColor = Colors.orange.shade800;
        statusBgColor = Colors.orange.shade50;
        break;
      case 'Dibatalkan':
        statusColor = Colors.red.shade800;
        statusBgColor = Colors.red.shade50;
        break;
      case 'Selesai':
        statusColor = Colors.blue.shade800;
        statusBgColor = Colors.blue.shade50;
        break;
      default:
        statusColor = Colors.grey.shade800;
        statusBgColor = Colors.grey.shade100;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MeetupDetailScreen(meetupId: meetup.id),
            ),
          ).then((_) => _refresh());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status Badge & Item Type
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      meetup.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (meetup.itemStatus == 'Reserved')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Reserved (AC-10)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade800,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    'Jalur ${meetup.itemType}',
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Info Barang
              Text(
                meetup.itemTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Mitra: ${_isViewingAsRequester ? meetup.ownerName : meetup.requesterName}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Divider(height: 20),

              // Safe-Meet Point & Jadwal Waktu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF0D9488)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meetup.safeMeetPoint.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF0D9488)),
                  const SizedBox(width: 8),
                  Text(
                    meetup.formattedShortDateTime,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),

              if (meetup.cancellationReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Alasan: ${meetup.cancellationReason}',
                    style: TextStyle(fontSize: 11, color: Colors.red.shade900),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Action Buttons Berdasarkan Status dan Peran (FR-07, FR-08, BR-10, BR-13, AC-10, AC-11)
              Row(
                children: [
                  // Aksi Khusus Status Diajukan
                  if (meetup.isDiajukan) ...[
                    if (_isViewingAsRequester) ...[
                      // Peminat: Ubah Jadwal (FR-07.3)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final updated = await Navigator.of(context).push<Meetup>(
                              MaterialPageRoute(
                                builder: (_) => MeetupFormScreen(existingMeetup: meetup),
                              ),
                            );
                            if (updated != null) _refresh();
                          },
                          icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                          label: const Text('Ubah Jadwal'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0D9488),
                            side: const BorderSide(color: Color(0xFF0D9488)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Peminat: Hapus Permanen (FR-07.4, BR-13, AC-11)
                      IconButton(
                        tooltip: 'Hapus Ajakan Permanen (BR-13)',
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _handleDelete(meetup),
                      ),
                    ] else ...[
                      // Pemilik: Tolak Ajakan
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await _repository.rejectMeetup(meetup.id);
                            _refresh();
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Pemilik: Konfirmasi (FR-08 & AC-10)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleConfirm(meetup),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
                          child: const Text('Konfirmasi', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ],

                  // Aksi Khusus Status Dikonfirmasi (AC-11: Pada Dikonfirmasi HANYA tersedia opsi Batalkan)
                  if (meetup.isDikonfirmasi) ...[
                    // Tombol Buka Rute Google Maps (FR-09 & AC-12)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          MapsLauncherService.openNavigation(
                            latitude: meetup.safeMeetPoint.latitude,
                            longitude: meetup.safeMeetPoint.longitude,
                            destinationTitle: meetup.safeMeetPoint.name,
                          );
                        },
                        icon: const Icon(Icons.directions_rounded, size: 16, color: Colors.white),
                        label: const Text('Buka Rute (AC-12)', style: TextStyle(color: Colors.white, fontSize: 12)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tombol Batalkan Pertemuan Dikonfirmasi (BR-10, AC-11)
                    OutlinedButton(
                      onPressed: () => _handleCancel(meetup),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Batalkan'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
