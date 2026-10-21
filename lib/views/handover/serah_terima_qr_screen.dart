import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/meetup.dart';
import '../../models/handover_token_model.dart';
import '../../viewmodels/handover_view_model.dart';
import '../../services/meetup_repository.dart';
import 'riwayat_transaksi_screen.dart';
import 'review_form_screen.dart';

/// FR-17 [W]: Pemilik Barang dapat mengelola sesi QR serah terima pada pertemuan berstatus Dikonfirmasi.
/// 1. Create: Menampilkan QR; server membuat token acak sekali pakai yang berlaku 5 menit dan diperbarui otomatis saat kedaluwarsa.
/// 2. Delete: Membatalkan sesi QR yang sedang aktif; token dihapus dari server sehingga QR langsung tidak berlaku (BR-21).
class SerahTerimaQrScreen extends StatefulWidget {
  final Meetup? meetup;

  const SerahTerimaQrScreen({super.key, this.meetup});

  @override
  State<SerahTerimaQrScreen> createState() => _SerahTerimaQrScreenState();
}

class _SerahTerimaQrScreenState extends State<SerahTerimaQrScreen>
    with SingleTickerProviderStateMixin {
  late Meetup _meetup;
  Timer? _countdownTimer;
  Timer? _pollingTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Mengambil meetup dari parameter atau mencari meetup berstatus Dikonfirmasi di MeetupRepository
    final repo = MeetupRepository();
    repo.ensureInitialized();
    final confirmed = repo
        .getAllMeetups()
        .where((m) => m.isDikonfirmasi)
        .toList();

    _meetup =
        widget.meetup ??
        (confirmed.isNotEmpty
            ? confirmed.first
            : Meetup(
                id: 101,
                itemId: 1,
                itemTitle: 'Buku Kalkulus Purcell Edisi 9',
                itemCategory: 'Buku Kuliah',
                itemPrice: 'Rp 85.000',
                itemType: 'Jual',
                requesterId: 1,
                requesterName: 'Bayu Mutawakkil',
                requesterNim: '2411522023',
                ownerId: 3,
                ownerName: 'Fadel Muhammad',
                ownerNim: '2411522029',
                safeMeetPoint: repo.getSafeMeetPoints().first,
                scheduledTime: DateTime.now().add(const Duration(hours: 2)),
                status: 'Dikonfirmasi',
                createdAt: DateTime.now().subtract(const Duration(days: 1)),
              ));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  /// Inisialisasi pembuatan sesi QR (FR-17.1)
  Future<void> _initSession() async {
    final vm = context.read<HandoverViewModel>();
    await vm.createQrSession(_meetup.id);
    _startTimers();
  }

  void _startTimers() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();

    // 1. Timer Countdown per detik (FR-17.1)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final vm = context.read<HandoverViewModel>();
      final token = vm.activeToken;

      if (token == null) return;

      if (token.isExpired) {
        timer.cancel();
        _onTokenExpired();
      } else {
        setState(() {}); // Re-render countdown text & progress
      }
    });

    // 2. Polling per 3 detik untuk deteksi otomatis pemindaian mitra (FR-21)
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) return;
      final vm = context.read<HandoverViewModel>();
      if (vm.activeToken == null || vm.activeToken!.status != 'active') return;

      await vm.checkTokenStatus(_meetup.id);

      if (!mounted) return;
      if (vm.handoverSuccess) {
        timer.cancel();
        _countdownTimer?.cancel();
        _showSuccessDialog();
      }
    });
  }

  /// FR-17.1: QR diperbarui otomatis saat kedaluwarsa (5 menit)
  void _onTokenExpired() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Masa berlaku QR 5 menit telah habis. Memperbarui otomatis... (FR-17)',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final vm = context.read<HandoverViewModel>();
        vm.createQrSession(_meetup.id).then((_) {
          if (mounted) _startTimers();
        });
      }
    });
  }

  /// FR-17.2: Delete / Batalkan Sesi QR yang Sedang Aktif
  Future<void> _handleCancelSession() async {
    final vm = context.read<HandoverViewModel>();
    final token = vm.activeToken;
    if (token == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Batalkan Sesi QR?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Token aktif akan dihapus dari server sehingga QR langsung tidak berlaku (FR-17 & BR-21). Status pertemuan tetap Dikonfirmasi dan Anda dapat membuat sesi baru kapan saja.',
          style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan Sesi'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      _countdownTimer?.cancel();
      _pollingTimer?.cancel();
      final success = await vm.cancelQrSession(_meetup.id, token.tokenId);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sesi QR dibatalkan. Token dihapus dan QR tidak berlaku (FR-17 & BR-21).',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Dialog Sukses Serah Terima (FR-21)
  void _showSuccessDialog() {
    final vm = context.read<HandoverViewModel>();
    final proof = vm.lastCompletedProof;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF0D9488),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Serah Terima Berhasil! 🎉',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Barang "${_meetup.itemTitle}" telah resmi diterima oleh ${_meetup.requesterName}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCCFBF1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFF0D9488),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nomor Bukti Digital (BR-24):',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        Text(
                          proof?.proofNumber ??
                              vm.activeToken?.proofNumber ??
                              'PRF-202610-8942',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Buka layar review untuk peminat (FR-20)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewFormScreen(
                        meetupId: _meetup.id,
                        proofNumber: proof?.proofNumber ?? 'PRF-202610-8942',
                        targetUserId: _meetup.requesterId,
                        targetUserName: _meetup.requesterName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.star_rounded, color: Colors.white),
                label: const Text(
                  'Beri Ulasan Mitra (FR-20)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RiwayatTransaksiScreen(),
                    ),
                  );
                },
                child: const Text('Lihat Riwayat & Bukti (FR-19)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sheet Pengujian UAT & Demonstrasi (UAT-07 & UAT-08)
  void _openTestingModal() {
    final vm = context.read<HandoverViewModel>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.science_rounded, color: Color(0xFF0D9488)),
                SizedBox(width: 8),
                Text(
                  'Mode Pengujian UAT (Dosen / Tim)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Gunakan tombol di bawah untuk menguji skenario edge cases tanpa memerlukan 2 HP:',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.timer_off_rounded,
                color: Colors.orange,
              ),
              title: const Text('Simulasi Token Kedaluwarsa (UAT-07)'),
              subtitle: const Text(
                'Membuat token lewat 5 menit untuk menguji penolakan & auto-refresh',
              ),
              onTap: () {
                Navigator.pop(ctx);
                vm.simulateExpired(_meetup.id);
                _onTokenExpired();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF0D9488),
              ),
              title: const Text('Simulasi Peminat Berhasil Scan (AC-20)'),
              subtitle: const Text(
                'Menyelesaikan serah terima via polling otomatis 3 detik (FR-21)',
              ),
              onTap: () {
                Navigator.pop(ctx);
                vm.simulateScanSuccess(_meetup.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HandoverViewModel>();
    final token = vm.activeToken;
    final isCancelled = token?.status == 'cancelled';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0F172A),
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Serah Terima QR',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Mode Pengujian UAT',
            icon: const Icon(Icons.science_outlined, color: Color(0xFF0D9488)),
            onPressed: _openTestingModal,
          ),
        ],
      ),
      body: vm.isLoading && token == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D9488)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. KARTU TITIK TEMU KAMPUS RESMI
                  _buildSafeMeetPointCard(),
                  const SizedBox(height: 14),

                  // 2. KARTU BARANG & MITRA PEMINAT
                  _buildItemAndPartnerCard(),
                  const SizedBox(height: 14),

                  // 3. KARTU SESI QR UTAMA (CORE FR-17)
                  _buildQrSessionCard(token, isCancelled),
                  const SizedBox(height: 16),

                  // 4. PROTOKOL SERAH TERIMA AMAN MAHASISWA
                  _buildSafetyProtocolCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSafeMeetPointCard() {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
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
                    const Text(
                      'TITIK TEMU RESMI UNAND',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D9488),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'CCTV Siaga',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _meetup.safeMeetPoint.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _meetup.safeMeetPoint.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemAndPartnerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF0D9488),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _meetup.itemTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_meetup.itemCategory} • ${_meetup.itemPrice}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D9488),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF0D9488)
                        .withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF0D9488),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Peminat: ${_meetup.requesterName} (${_meetup.requesterNim})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _meetup.itemType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrSessionCard(HandoverTokenModel? token, bool isCancelled) {
    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red.shade600, size: 54),
            const SizedBox(height: 12),
            const Text(
              'Sesi QR Telah Dibatalkan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Token telah dihapus dari server (FR-17.2). Pertemuan tetap Dikonfirmasi. Tekan tombol di bawah untuk membuat sesi QR baru.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _initSession,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Buat Sesi QR Baru (FR-17.1)',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
              ),
            ),
          ],
        ),
      );
    }

    final remainingSec = token?.remainingSeconds ?? 300;
    final mins = (remainingSec ~/ 60).toString().padLeft(2, '0');
    final secs = (remainingSec % 60).toString().padLeft(2, '0');
    final progress = token?.progressRatio ?? 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D9488),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SESI QR AKTIF (SATU KALI PAKAI - BR-21)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D9488),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tampilan QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: token != null
                ? QrImageView(
                    data: '${token.token}|${_meetup.id}',
                    version: QrVersions.auto,
                    size: 210,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF0D9488),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF0F172A),
                    ),
                  )
                : const SizedBox(
                    height: 210,
                    child: Center(child: CircularProgressIndicator()),
                  ),
          ),
          const SizedBox(height: 16),

          // Token Text & Salin
          InkWell(
            onTap: () {
              if (token != null) {
                Clipboard.setData(ClipboardData(text: token.token));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Token "${token.token}" disalin!'),
                    backgroundColor: const Color(0xFF0D9488),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    token?.token ?? 'TKN-CS-XXXX-XX',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Countdown Timer 5 Menit (FR-17.1)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: Color(0xFF0D9488),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Berlaku: $mins:$secs',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '(Otomatis refresh jika habis)',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress < 0.2 ? Colors.red : const Color(0xFF0D9488),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tombol Batalkan Sesi QR (FR-17.2 Delete)
          OutlinedButton.icon(
            onPressed: _handleCancelSession,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: Colors.red,
            ),
            label: const Text(
              'Batalkan Sesi QR (Hapus Token - FR-17.2)',
              style: TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyProtocolCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Protokol Serah Terima Aman Kampus:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          SizedBox(height: 6),
          Text(
            '• Pastikan barang diperiksa bersama peminat sebelum konfirmasi.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          SizedBox(height: 3),
          Text(
            '• Tunjukkan QR ini kepada peminat untuk dipindai melalui kamera aplikasi.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          SizedBox(height: 3),
          Text(
            '• Sistem akan otomatis menyelesaikan transaksi begitu pemindaian valid.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
