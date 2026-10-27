import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/app_strings.dart';
import '../../models/handover_token_model.dart';
import '../../services/handover_service.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';

/// Layar Serah Terima QR & Bukti Digital (Modul 4: Fadel).
/// Mengimplementasikan alur FR-17 (QR Token sekali pakai 5 menit),
/// BR-21 (polling status 3s), pembatalan sesi, bukti serah terima tiket,
/// dan form ulasan reputasi FR-20.
class SerahTerimaQrScreen extends StatefulWidget {
  final MeetupDetailModel? meetupDetail;

  const SerahTerimaQrScreen({super.key, this.meetupDetail});

  @override
  State<SerahTerimaQrScreen> createState() => _SerahTerimaQrScreenState();
}

class _SerahTerimaQrScreenState extends State<SerahTerimaQrScreen>
    with SingleTickerProviderStateMixin {
  late MeetupDetailModel _meetup;
  HandoverTokenModel? _tokenModel;
  bool _isLoading = true;
  String _sessionState = 'active'; // 'active', 'expired', 'used', 'cancelled'

  Timer? _countdownTimer;
  Timer? _statusCheckTimer;
  int _currentScenarioTab =
      0; // 0: Aktif (3s), 1: Kedaluwarsa, 2: Sukses Selesai

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _meetup = widget.meetupDetail ?? MeetupDetailModel.sample();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initSession();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  /// Inisialisasi atau load sesi QR (FR-17 Point 1: Create)
  Future<void> _initSession() async {
    setState(() => _isLoading = true);
    final result = await HandoverService.createQrSession(
      meetupId: _meetup.meetupId,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final token = result['token'] as HandoverTokenModel;
      setState(() {
        _tokenModel = token;
        _sessionState = 'active';
        _isLoading = false;
        _currentScenarioTab = 0;
      });
      _startTimers();
    } else {
      setState(() => _isLoading = false);
      AppSnackBar.showError(
        context,
        result['message'] ?? 'Gagal membuat sesi QR',
      );
    }
  }

  /// Mulai countdown timer per detik dan polling status per 3 detik (FR-21 / BR-21)
  void _startTimers() {
    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();

    // Timer per detik untuk update visual countdown dan auto-refresh bila kedaluwarsa
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _tokenModel == null) return;

      if (_tokenModel!.isExpired) {
        timer.cancel();
        _onTokenExpired();
      } else {
        setState(() {}); // re-render countdown & progress bar
      }
    });

    // Polling status setiap 3 detik sesuai FR-21 / BR-21
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      if (!mounted || _tokenModel == null || _sessionState != 'active') return;

      final statusRes = await HandoverService.checkTokenStatus(
        meetupId: _meetup.meetupId,
        tokenId: _tokenModel!.tokenId,
      );

      if (!mounted) return;

      final newStatus = statusRes['status'] ?? 'active';
      if (newStatus == 'used' && _sessionState != 'used') {
        _onHandoverSuccess(
          statusRes['proof_number'] ?? _tokenModel?.proofNumber,
        );
      } else if (newStatus == 'expired' && _sessionState != 'expired') {
        _onTokenExpired();
      } else if (newStatus == 'cancelled' && _sessionState != 'cancelled') {
        setState(() {
          _sessionState = 'cancelled';
        });
      }
    });
  }

  /// Handler saat token kedaluwarsa (FR-17)
  void _onTokenExpired() {
    setState(() {
      _sessionState = 'expired';
      _currentScenarioTab = 1;
    });

    AppSnackBar.showInfo(
      context,
      'Masa berlaku QR 5 menit telah habis. Memperbarui otomatis...',
    );

    // Auto refresh setelah 2 detik agar pengguna melihat transisinya
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _sessionState == 'expired') {
        _refreshQrToken(isAuto: true);
      }
    });
  }

  /// Perbarui token QR (Create token baru, menonaktifkan token lama sesuai BR-21)
  Future<void> _refreshQrToken({bool isAuto = false}) async {
    setState(() => _isLoading = true);
    final result = await HandoverService.createQrSession(
      meetupId: _meetup.meetupId,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final token = result['token'] as HandoverTokenModel;
      setState(() {
        _tokenModel = token;
        _sessionState = 'active';
        _isLoading = false;
        _currentScenarioTab = 0;
      });
      _startTimers();

      AppSnackBar.showSuccess(
        context,
        isAuto
            ? 'QR diperbarui otomatis dengan token baru'
            : 'QR berhasil diperbarui (Token baru dibuat)',
      );
    } else {
      setState(() => _isLoading = false);
    }
  }

  /// FR-17 Point 2: Batalkan Sesi QR dengan ConfirmDialog
  Future<void> _confirmCancelSession() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Batalkan Sesi QR?',
      message: 'Token aktif akan dihapus dari server sehingga kode QR tidak berlaku lagi. Status pertemuan tetap Dikonfirmasi dan Anda dapat membuat sesi baru kapan saja.',
      confirmLabel: 'Ya, Batalkan Sesi',
      cancelLabel: AppStrings.cancel,
      destructive: true,
      confirmIcon: Icons.cancel_outlined,
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      _countdownTimer?.cancel();
      _statusCheckTimer?.cancel();

      final res = await HandoverService.cancelQrSession(
        meetupId: _meetup.meetupId,
        tokenId: _tokenModel?.tokenId ?? '',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _sessionState = 'cancelled';
      });

      AppSnackBar.showInfo(
        context,
        res['message'] ?? 'Sesi QR berhasil dibatalkan',
      );
    }
  }

  /// Handler serah terima sukses (FR-21)
  void _onHandoverSuccess(String? proofNumber) {
    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();

    setState(() {
      _sessionState = 'used';
      _currentScenarioTab = 2;
    });

    _showSuccessBottomSheet(proofNumber ?? 'PRF-202610-8942');
  }

  /// Switcher Simulasi Skenario Handover (BR-19 • BR-20 • BR-21)
  void _switchScenario(int index) {
    if (_isLoading) return;
    setState(() => _currentScenarioTab = index);

    if (index == 0) {
      if (_sessionState != 'active') {
        _refreshQrToken();
      }
    } else if (index == 1) {
      HandoverService.simulateExpired(_meetup.meetupId);
      _countdownTimer?.cancel();
      setState(() => _sessionState = 'expired');
    } else if (index == 2) {
      HandoverService.simulateScanSuccess(_meetup.meetupId);
      _onHandoverSuccess(_tokenModel?.proofNumber);
    }
  }

  /// Salin token ke clipboard
  void _copyTokenToClipboard() {
    if (_tokenModel == null) return;
    Clipboard.setData(ClipboardData(text: _tokenModel!.token));
    AppSnackBar.showSuccess(
      context,
      'Token "${_tokenModel!.token}" disalin ke papan klip',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Serah Terima QR'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: _showHelpDialog,
            tooltip: 'Panduan Serah Terima QR',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: _isLoading
          ? const LoadingState(label: 'Menyiapkan sesi QR terenkripsi...')
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SIMULASI SKENARIO HANDOVER (Header Banner)
                  _buildSimulationBanner(),
                  const SizedBox(height: AppSpacing.md),

                  // TITIK TEMU KAMPUS TERVERIFIKASI
                  _buildMeetingPointCard(),
                  const SizedBox(height: AppSpacing.md),

                  // ITEM & PARTNER CARD
                  _buildItemAndPartnerCard(),
                  const SizedBox(height: AppSpacing.md),

                  // QR CODE & HANDOVER SESSION CARD (CORE FR-17)
                  _buildQrSessionCard(),
                  const SizedBox(height: AppSpacing.lg),

                  // PROTOKOL SERAH TERIMA AMAN
                  _buildSafetyProtocolCard(),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }

  /// Banner Simulasi Skenario Handover (BR-19 • BR-20 • BR-21)
  Widget _buildSimulationBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.primary, size: 16),
              SizedBox(width: AppSpacing.xs),
              Text(
                'SIMULASI SKENARIO SERAH TERIMA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              Spacer(),
              Text(
                'BR-19 • BR-20 • BR-21',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildScenarioPill(
                  index: 0,
                  label: '1. Aktif (3s)',
                  isSelected: _currentScenarioTab == 0,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _buildScenarioPill(
                  index: 1,
                  label: '2. Kedaluwarsa',
                  isSelected: _currentScenarioTab == 1,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _buildScenarioPill(
                  index: 2,
                  label: '3. Sukses',
                  isSelected: _currentScenarioTab == 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioPill({
    required int index,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _switchScenario(index),
      child: AnimatedContainer(
        duration: AppDurations.quick,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.small,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
          ),
          boxShadow: isSelected ? AppElevation.softShadow : null,
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  /// Card 1: Titik Temu Kampus Terverifikasi
  Widget _buildMeetingPointCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.small,
                ),
                child: const Icon(
                  Icons.videocam_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'TITIK TEMU TERVERIFIKASI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const StatusBadge(status: 'Dikonfirmasi'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _meetup.locationTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            _meetup.locationSub,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadius.small,
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Jadwal:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${_meetup.scheduledDate}, ${_meetup.scheduledTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: AppRadius.pill,
                  ),
                  child: const Text(
                    'Tepat Waktu',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card 2: Informasi Barang & Profil Pembeli
  Widget _buildItemAndPartnerCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadius.medium,
                  border: Border.all(color: AppColors.outline),
                ),
                child: const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 30,
                  ),
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
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: AppRadius.small,
                          ),
                          child: Text(
                            _meetup.itemCategory,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: AppRadius.small,
                          ),
                          child: Text(
                            _meetup.itemGrade,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6D28D9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _meetup.itemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _meetup.itemPrice,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(color: AppColors.outline),
          ),
          Row(
            children: [
              Expanded(
                child: AvatarWithName(
                  name: _meetup.partnerName,
                  subtitle:
                      'NIM: ${_meetup.partnerNim} • ${_meetup.partnerFaculty}',
                  radius: 20,
                ),
              ),
              RatingStars(
                rating: _meetup.partnerRating,
                reviewCount: _meetup.partnerCompletedDeals,
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card 3: QR Code Section (FR-17 Core Component)
  Widget _buildQrSessionCard() {
    final token = _tokenModel;

    // Jika sesi dibatalkan
    if (_sessionState == 'cancelled' || token == null) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Sesi QR Telah Dibatalkan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Token telah dinonaktifkan dari server (FR-17). Status pertemuan tetap Dikonfirmasi dan Anda dapat membuat sesi baru.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'Buat Sesi QR Baru',
              icon: Icons.qr_code_2_rounded,
              onPressed: () => _refreshQrToken(),
            ),
          ],
        ),
      );
    }

    // Jika sesi sudah berhasil divalidasi
    if (_sessionState == 'used') {
      return _buildSuccessCard(token);
    }

    final isExpired = _sessionState == 'expired' || token.isExpired;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Header Status & Polling 3s
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isExpired ? AppColors.accent : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    isExpired
                        ? '• QR Kedaluwarsa'
                        : '• Menunggu Peminat Memindai QR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isExpired ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  Icon(
                    Icons.sync_rounded,
                    color: AppColors.textSecondary,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Cek tiap 3s',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Countdown Pill
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isExpired
                  ? const Color(0xFFFEF3C7)
                  : AppColors.primaryContainer,
              borderRadius: AppRadius.pill,
              border: Border.all(
                color: isExpired ? const Color(0xFFFDE68A) : AppColors.outline,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 15,
                  color: isExpired
                      ? const Color(0xFFB45309)
                      : AppColors.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  isExpired
                      ? 'Kedaluwarsa (Memperbarui otomatis...)'
                      : 'Kedaluwarsa dalam: ${token.formattedRemainingTime}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isExpired
                        ? const Color(0xFFB45309)
                        : AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // QR Code Frame dengan border primary
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.large,
                  border: Border.all(
                    color: isExpired ? AppColors.outline : AppColors.primary,
                    width: 2,
                  ),
                  boxShadow: AppElevation.softShadow,
                ),
                child: Opacity(
                  opacity: isExpired ? 0.2 : 1.0,
                  child: QrImageView(
                    data: token.token,
                    version: QrVersions.auto,
                    size: 190.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.textPrimary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // Expired Overlay
              if (isExpired)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.85),
                    borderRadius: AppRadius.medium,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_off_outlined,
                        color: AppColors.onPrimary,
                        size: 32,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'QR Kedaluwarsa',
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Token habis masa berlaku 5 menit',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton.icon(
                        onPressed: () => _refreshQrToken(),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Perbarui Sekarang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Token Nonce Sekali Pakai
          const Text(
            'TOKEN OTENTIKASI SEKALI PAKAI (ONE-TIME NONCE)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.small,
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.vpn_key_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  token.token,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: token.progressRatio,
              minHeight: 6,
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(
                isExpired ? AppColors.accent : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Text(
            'Tunjukkan layar ini kepada ${_meetup.partnerName} untuk dipindai saat bertemu di Safe-Meet Point.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action Buttons: Perbarui & Salin
          Row(
            children: [
              Expanded(
                child: AppSecondaryButton(
                  label: 'Perbarui QR',
                  icon: Icons.refresh_rounded,
                  onPressed: () => _refreshQrToken(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadius.medium,
                  border: Border.all(color: AppColors.outline),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: _copyTokenToClipboard,
                  tooltip: 'Salin Token',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Tombol Batalkan Sesi QR
          AppSecondaryButton(
            label: 'Batalkan Sesi QR',
            icon: Icons.cancel_outlined,
            isDestructive: true,
            onPressed: _confirmCancelSession,
          ),
        ],
      ),
    );
  }

  /// Card saat transaksi serah terima berhasil (Gaya Tiket Digital)
  Widget _buildSuccessCard(HandoverTokenModel token) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.outline),
        boxShadow: AppElevation.softShadow,
      ),
      child: Column(
        children: [
          // Header Tiket
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.largeValue),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BUKTI SERAH TERIMA DIGITAL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onPrimaryContainer,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        token.proofNumber ?? 'PRF-202610-8942',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: () {
                    final proof = token.proofNumber ?? 'PRF-202610-8942';
                    Clipboard.setData(ClipboardData(text: proof));
                    AppSnackBar.showSuccess(
                      context,
                      'Nomor bukti $proof disalin ke papan klip',
                    );
                  },
                  tooltip: 'Salin Nomor Bukti',
                ),
              ],
            ),
          ),

          // Garis Putus-Putus Perforasi Tiket
          Row(
            children: List.generate(
              30,
              (index) => Expanded(
                child: Container(
                  height: 2,
                  color: index.isEven ? AppColors.outline : Colors.transparent,
                ),
              ),
            ),
          ),

          // Isi Tiket
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 38,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Serah Terima Berhasil!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'QR telah divalidasi oleh ${_meetup.partnerName}. Transaksi dinyatakan Selesai sesuai BR-24.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: 'Beri Ulasan untuk ${_meetup.partnerName}',
                  icon: Icons.star_rounded,
                  onPressed: () => _showReviewBottomSheet(_meetup.partnerName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card 4: Protokol Serah Terima Aman
  Widget _buildSafetyProtocolCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Protokol Serah Terima Aman',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildProtocolStep(
            number: '1',
            title: 'Inspeksi Kondisi Fisik',
            description: 'Persilakan peminat memeriksa kelengkapan barang sebelum kode QR dipindai.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildProtocolStep(
            number: '2',
            title: 'Terima Pembayaran / Barang Barter',
            description: 'Pastikan Anda telah memegang uang pas atau barang tukar sebelum scan QR.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildProtocolStep(
            number: '3',
            title: 'Verifikasi Instan',
            description: 'Setelah dipindai, status otomatis Selesai dan tidak dapat dibatalkan sepihak (BR-20).',
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: description,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom sheet dialog serah terima berhasil
  void _showSuccessBottomSheet(String proofNumber) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.largeValue),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Serah Terima Berhasil!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Barang "${_meetup.itemName}" telah sah diserahkan ke ${_meetup.partnerName}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.small,
              ),
              child: Text(
                'No. Bukti: $proofNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'Tutup',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  /// Form Ulasan & Reputasi (FR-20)
  void _showReviewBottomSheet(String partnerName) {
    double selectedRating = 5.0;
    final reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.largeValue),
        ),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.xl,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ulas $partnerName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Beri nilai untuk membangun rasa percaya di komunitas CampuShift.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: RatingStars(
                    rating: selectedRating,
                    interactive: true,
                    size: 36,
                    onRatingChanged: (newRating) {
                      setModalState(() => selectedRating = newRating);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Ulasan Transaksi',
                  hintText:
                      'Tuliskan pengalaman bertransaksi dengan rekan ini...',
                  controller: reviewController,
                  maxLines: 3,
                  maxLength: 500,
                  showCounter: true,
                ),
                const SizedBox(height: AppSpacing.md),
                AppPrimaryButton(
                  label: 'Kirim Ulasan',
                  icon: Icons.send_rounded,
                  onPressed: () {
                    Navigator.pop(ctx);
                    AppSnackBar.showSuccess(
                      this.context,
                      'Ulasan berhasil dikirim. Terima kasih telah menjaga keamanan kampus!',
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Dialog Panduan & Aturan Bisnis Serah Terima (BR-21, BR-22, FR-17)
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.large),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Aturan Serah Terima QR',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FR-17 & BR-21 Aturan Token QR:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                '• Token berlaku 5 menit (sekali pakai).\n'
                '• Hanya ada 1 token aktif per pertemuan.\n'
                '• Meminta token baru menonaktifkan token sebelumnya.\n'
                '• Membatalkan sesi menghapus token aktif tanpa mengubah status pertemuan.\n'
                '• Layar memeriksa status ke server tiap 3 detik (FR-21).',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}
