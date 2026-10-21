import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/meetup.dart';
import '../../viewmodels/handover_view_model.dart';
import '../../services/meetup_repository.dart';
import 'serah_terima_qr_screen.dart';
import 'qr_scanner_screen.dart';
import 'riwayat_transaksi_screen.dart';

/// Hub Serah Terima: Daftar Pertemuan Berstatus Dikonfirmasi yang Siap Dilakukan Serah Terima QR (FR-17 s/d FR-22).
class HandoverMeetupListScreen extends StatefulWidget {
  const HandoverMeetupListScreen({super.key});

  @override
  State<HandoverMeetupListScreen> createState() =>
      _HandoverMeetupListScreenState();
}

class _HandoverMeetupListScreenState extends State<HandoverMeetupListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUserId = MeetupRepository.currentUserId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HandoverViewModel>().refreshConfirmedMeetups();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HandoverViewModel>();
    final allConfirmed = vm.confirmedMeetups;

    // Filter peran: Pemilik vs Peminat
    final asOwner = allConfirmed
        .where((m) => m.ownerId == _currentUserId)
        .toList();
    final asRequester = allConfirmed
        .where((m) => m.requesterId == _currentUserId)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Serah Terima QR',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Riwayat Transaksi',
            icon: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF0D9488),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RiwayatTransaksiScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0D9488),
          unselectedLabelColor: Colors.black45,
          indicatorColor: const Color(0xFF0D9488),
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Sebagai Pemilik (${asOwner.length})'),
            Tab(text: 'Sebagai Peminat (${asRequester.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMeetupList(asOwner, isOwnerTab: true),
          _buildMeetupList(asRequester, isOwnerTab: false),
        ],
      ),
    );
  }

  Widget _buildMeetupList(List<Meetup> list, {required bool isOwnerTab}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOwnerTab
                  ? Icons.qr_code_rounded
                  : Icons.qr_code_scanner_rounded,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              isOwnerTab
                  ? 'Tidak Ada Pertemuan Sebagai Pemilik'
                  : 'Tidak Ada Pertemuan Sebagai Peminat',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hanya pertemuan berstatus "Dikonfirmasi" yang tampil di sini.',
              style: TextStyle(fontSize: 12, color: Colors.black38),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final m = list[i];
        final partnerName = isOwnerTab ? m.requesterName : m.ownerName;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Dikonfirmasi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ),
                  Text(
                    '${DateFormat('d MMM yyyy, HH:mm').format(m.scheduledTime)} WIB',
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                m.itemTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${m.itemType} • ${m.itemPrice}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0D9488),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      m.safeMeetPoint.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Mitra: $partnerName',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isOwnerTab) {
                      // Pemilik Barang membuka FR-17
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SerahTerimaQrScreen(meetup: m),
                        ),
                      );
                    } else {
                      // Peminat membuka FR-18
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QrScannerScreen(targetMeetup: m),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    isOwnerTab
                        ? Icons.qr_code_rounded
                        : Icons.qr_code_scanner_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    isOwnerTab
                        ? 'Tampilkan QR Serah Terima (FR-17)'
                        : 'Pindai QR Serah Terima (FR-18)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
