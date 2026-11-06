import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/handover_token_model.dart';
import '../../models/meetup.dart';
import '../../services/meetup_repository.dart';
import '../../shared/widgets/dialogs.dart';
import '../../viewmodels/handover_view_model.dart';
import 'review_form_screen.dart';
import 'riwayat_transaksi_screen.dart';
import '../../shared/widgets/user_link.dart';
import '../../theme/app_tokens.dart';

/// FR-17 [W]: Pemilik Barang dapat mengelola sesi QR serah terima pada pertemuan berstatus Dikonfirmasi.
/// 1. Create: Menampilkan QR; server membuat token acak sekali pakai yang berlaku 5 menit dan diperbarui otomatis saat kedaluwarsa.
/// 2. Delete: Membatalkan sesi QR yang sedang aktif; token dihapus dari server sehingga QR langsung tidak berlaku (BR-21).
class SerahTerimaQrScreen extends StatefulWidget {
  final Meetup? meetup;
  final MeetupDetailModel? meetupDetail;

  const SerahTerimaQrScreen({super.key, this.meetup, this.meetupDetail});

  @override
  State<SerahTerimaQrScreen> createState() => _SerahTerimaQrScreenState();
}

class _SerahTerimaQrScreenState extends State<SerahTerimaQrScreen>
    with SingleTickerProviderStateMixin {
  late Meetup _meetup;
  bool _hasRealMeetup = false;
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
    // FR-17: hanya pemilik barang yang menampilkan QR.
    final confirmed = repo
        .getAllMeetups()
        .where(
          (m) =>
              m.isDikonfirmasi &&
              (!repo.isOnlineMode ||
                  m.ownerId == MeetupRepository.currentUserId),
        )
        .toList();

    Meetup? fromDetail;
    if (widget.meetup == null && widget.meetupDetail != null) {
      final parsedId = int.tryParse(widget.meetupDetail!.meetupId);
      if (parsedId != null) {
        fromDetail = repo.getMeetupById(parsedId);
      }
    }

    _hasRealMeetup =
        widget.meetup != null || fromDetail != null || confirmed.isNotEmpty;
    _meetup =
        widget.meetup ??
        fromDetail ??
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
    // Mode server: pertemuan contoh tidak ada di backend, jadi jangan
    // membuat sesi QR untuknya.
    if (MeetupRepository().isOnlineMode &&
        (!_hasRealMeetup ||
            _meetup.ownerId != MeetupRepository.currentUserId)) {
      AppSnackBar.showError(
        context,
        _hasRealMeetup
            ? 'QR serah terima hanya dapat ditampilkan oleh pemilik barang.'
            : 'Belum ada pertemuan Dikonfirmasi untuk barang milikmu.',
      );
      Navigator.of(context).pop();
      return;
    }
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
                'Masa berlaku QR 5 menit telah habis. Memperbarui otomatis...',
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
          'Kode QR yang sedang aktif akan langsung tidak berlaku. Status pertemuan tetap Dikonfirmasi dan Anda dapat membuat sesi baru kapan saja.',
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
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
              'Sesi QR dibatalkan. Kode QR sudah tidak berlaku.',
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
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Serah Terima Berhasil! 🎉',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Barang "${_meetup.itemTitle}" telah resmi diterima oleh ${_meetup.requesterName}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryContainer),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nomor Bukti Digital:',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          proof?.proofNumber ??
                              vm.activeToken?.proofNumber ??
                              'PRF-202610-8942',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
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
                  'Beri Ulasan Mitra',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
                child: const Text('Lihat Riwayat & Bukti'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sheet Pengujian UAT & Demonstrasi (UAT-07 & UAT-08)
  void _openTestingModal() {
    // Token mode server dibuat & diverifikasi backend; simulasi lokal tidak
    // berlaku. Gunakan HP kedua (Peminat) untuk memindai QR.
    if (MeetupRepository().isOnlineMode) {
      AppSnackBar.showInfo(
        context,
        'Simulasi hanya tersedia di mode demo. Minta peminat memindai QR ini.',
      );
      return;
    }
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
                Icon(Icons.science_rounded, color: AppColors.primary),
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
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.timer_off_rounded,
                color: Colors.orange,
              ),
              title: const Text('Simulasi Token Kedaluwarsa'),
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
                color: AppColors.primary,
              ),
              title: const Text('Simulasi Peminat Berhasil Scan'),
              subtitle: const Text(
                'Menyelesaikan serah terima otomatis dalam 3 detik',
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Serah Terima QR',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Mode Pengujian UAT',
            icon: const Icon(Icons.science_outlined, color: AppColors.primary),
            onPressed: _openTestingModal,
          ),
        ],
      ),
      body: vm.isLoading && token == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
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
        border: Border.all(color: AppColors.outline),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.primary,
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
                        color: AppColors.primary,
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _meetup.safeMeetPoint.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_meetup.itemCategory} • ${_meetup.itemPrice}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
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
                    backgroundColor: AppColors.primary
                        .withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  UserLink(
                    userId: _meetup.requesterId,
                    name: _meetup.requesterName,
                    prefix: 'Peminat: ',
                    suffix: ' (${_meetup.requesterNim})',
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
                  color: AppColors.warningContainer,
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
              'Kode QR sudah tidak berlaku. Pertemuan tetap Dikonfirmasi. Tekan tombol di bawah untuk membuat sesi QR baru.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _initSession,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Buat Sesi QR Baru',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
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
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SESI QR AKTIF (SATU KALI PAKAI)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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
              border: Border.all(color: AppColors.outline, width: 1.5),
            ),
            child: token != null
                ? QrImageView(
                    data: '${token.token}|${_meetup.id}',
                    version: QrVersions.auto,
                    size: 210,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.primary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.textPrimary,
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
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
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
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Berlaku: $mins:$secs',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '(Otomatis refresh jika habis)',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.outline,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress < 0.2 ? Colors.red : AppColors.primary,
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
              'Batalkan Sesi QR',
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
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
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          SizedBox(height: 3),
          Text(
            '• Tunjukkan QR ini kepada peminat untuk dipindai melalui kamera aplikasi.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          SizedBox(height: 3),
          Text(
            '• Sistem akan otomatis menyelesaikan transaksi begitu pemindaian valid.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
