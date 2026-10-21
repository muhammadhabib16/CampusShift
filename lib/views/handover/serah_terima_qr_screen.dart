import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/handover_token_model.dart';
import '../../services/handover_service.dart';

class SerahTerimaQrScreen extends StatefulWidget {
  final MeetupDetailModel? meetupDetail;

  const SerahTerimaQrScreen({
    super.key,
    this.meetupDetail,
  });

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
  int _currentScenarioTab = 0; // 0: Aktif (3s), 1: Kedaluwarsa, 2: Sukses Selesai

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal membuat sesi QR'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  /// Mulai countdown timer per detik dan polling status per 3 detik (FR-21)
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
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _tokenModel == null || _sessionState != 'active') return;

      final statusRes = await HandoverService.checkTokenStatus(
        meetupId: _meetup.meetupId,
        tokenId: _tokenModel!.tokenId,
      );

      if (!mounted) return;

      final newStatus = statusRes['status'] ?? 'active';
      if (newStatus == 'used' && _sessionState != 'used') {
        _onHandoverSuccess(statusRes['proof_number'] ?? _tokenModel?.proofNumber);
      } else if (newStatus == 'expired' && _sessionState != 'expired') {
        _onTokenExpired();
      } else if (newStatus == 'cancelled' && _sessionState != 'cancelled') {
        setState(() {
          _sessionState = 'cancelled';
        });
      }
    });
  }

  /// Handler saat token kedaluwarsa (FR-17: QR diperbarui otomatis saat kedaluwarsa)
  void _onTokenExpired() {
    setState(() {
      _sessionState = 'expired';
      _currentScenarioTab = 1;
    });

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
        duration: const Duration(seconds: 3),
      ),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAuto
                ? 'QR diperbarui otomatis dengan token baru'
                : 'QR berhasil diperbarui (Token baru dibuat)',
          ),
          backgroundColor: const Color(0xFF0D9488),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      setState(() => _isLoading = false);
    }
  }

  /// FR-17 Point 2: DELETE / Batalkan Sesi QR
  Future<void> _confirmCancelSession() async {
    final confirmed = await showDialog<bool>(
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
              child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan Sesi'),
          ),
        ],
      ),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Sesi QR berhasil dibatalkan'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
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
      // 1. Aktif (3s)
      if (_sessionState != 'active') {
        _refreshQrToken();
      }
    } else if (index == 1) {
      // 2. Kedaluwarsa
      HandoverService.simulateExpired(_meetup.meetupId);
      _countdownTimer?.cancel();
      setState(() => _sessionState = 'expired');
    } else if (index == 2) {
      // 3. Sukses Selesai
      HandoverService.simulateScanSuccess(_meetup.meetupId);
      _onHandoverSuccess(_tokenModel?.proofNumber);
    }
  }

  /// Salin token ke clipboard
  void _copyTokenToClipboard() {
    if (_tokenModel == null) return;
    Clipboard.setData(ClipboardData(text: _tokenModel!.token));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Token "${_tokenModel!.token}" disalin ke papan klip'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SIMULASI SKENARIO HANDOVER (Header Banner)
                  _buildSimulationBanner(),
                  const SizedBox(height: 14),

                  // TITIK TEMU KAMPUS TERVERIFIKASI
                  _buildMeetingPointCard(),
                  const SizedBox(height: 14),

                  // ITEM & PARTNER CARD
                  _buildItemAndPartnerCard(),
                  const SizedBox(height: 14),

                  // QR CODE & HANDOVER SESSION CARD (CORE FR-17)
                  _buildQrSessionCard(),
                  const SizedBox(height: 16),

                  // PROTOKOL SERAH TERIMA AMAN
                  _buildSafetyProtocolCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A), size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Serah Terima Qr',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Color(0xFF334155), size: 22),
          onPressed: _showHelpDialog,
          tooltip: 'Panduan Serah Terima QR',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF0F766E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  /// Banner Simulasi Skenario Handover (BR-19 • BR-20 • BR-21)
  Widget _buildSimulationBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: Color(0xFF0D9488), size: 16),
              const SizedBox(width: 6),
              const Text(
                'SIMULASI SKENARIO HANDOVER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              const Text(
                'BR-19 • BR-20 • BR-21',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildScenarioPill(
                  index: 0,
                  label: '1. Aktif (3s)',
                  isSelected: _currentScenarioTab == 0,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildScenarioPill(
                  index: 1,
                  label: '2. Kedaluwarsa',
                  isSelected: _currentScenarioTab == 1,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildScenarioPill(
                  index: 2,
                  label: '3. Sukses Selesai',
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F766E) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
          border: Border.all(
            color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  /// Card 1: Titik Temu Kampus Terverifikasi
  Widget _buildMeetingPointCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.videocam_outlined,
                  color: Color(0xFF0D9488),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'TITIK TEMU KAMPUS TERVERIFIKASI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D9488),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '• Pertemuan Aktif',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _meetup.locationTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFF0D9488),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _meetup.locationSub,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF0D9488),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Jadwal Janji Temu:',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 6),
                Text(
                  '${_meetup.scheduledDate}, ${_meetup.scheduledTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'On Time',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0284C7),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Item row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Icon(
                    Icons.calculate_outlined,
                    color: Colors.teal.shade700,
                    size: 34,
                  ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _meetup.itemCategory,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _meetup.itemGrade,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6D28D9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _meetup.itemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _meetup.itemPrice,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          // Partner row
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
                    child: const Icon(Icons.person, color: Color(0xFF0D9488), size: 20),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _meetup.partnerName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Color(0xFF0D9488), size: 14),
                        const Spacer(),
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          _meetup.partnerRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIM: ${_meetup.partnerNim} • ${_meetup.partnerFaculty} • ${_meetup.partnerCompletedDeals} Transaksi',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
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

    // Jika sesi dibatalkan (FR-17 Point 2 Delete / Sesi Dibatalkan)
    if (_sessionState == 'cancelled' || token == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cancel_outlined, color: Colors.red.shade600, size: 32),
            ),
            const SizedBox(height: 14),
            const Text(
              'Sesi QR Telah Dibatalkan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Token telah dihapus dari server sehingga kode QR langsung tidak dapat dipindai (FR-17 & BR-21). Status pertemuan tetap Dikonfirmasi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => _refreshQrToken(),
              icon: const Icon(Icons.qr_code_2_rounded, size: 18),
              label: const Text('Buat Sesi QR Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }

    // Jika sesi sudah sukses divalidasi (FR-21 / Used)
    if (_sessionState == 'used') {
      return _buildSuccessCard(token);
    }

    final isExpired = _sessionState == 'expired' || token.isExpired;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpired ? Colors.orange.shade300 : const Color(0xFFE2E8F0),
          width: isExpired ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Status & Cek tiap 3s
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
                        color: isExpired
                            ? Colors.orange.shade700
                            : const Color(0xFF0D9488),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isExpired
                        ? '• QR Kedaluwarsa'
                        : '• Menunggu Peminat Memindai QR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isExpired
                          ? Colors.orange.shade800
                          : const Color(0xFF0D9488),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.sync, color: Color(0xFF64748B), size: 13),
                  const SizedBox(width: 4),
                  const Text(
                    'Cek tiap 3s',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Countdown Pill (Kedaluwarsa dalam: MM:SS)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isExpired ? Colors.orange.shade50 : const Color(0xFFE6F4F1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isExpired ? Colors.orange.shade200 : const Color(0xFFCCFBF1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 15,
                  color: isExpired ? Colors.orange.shade800 : const Color(0xFF0D9488),
                ),
                const SizedBox(width: 6),
                Text(
                  isExpired
                      ? 'Kedaluwarsa (Memperbarui...)'
                      : 'Kedaluwarsa dalam: ${token.formattedRemainingTime}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isExpired
                        ? Colors.orange.shade900
                        : const Color(0xFF0D9488),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // QR Code Display
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Opacity(
                  opacity: isExpired ? 0.25 : 1.0,
                  child: QrImageView(
                    data: token.token,
                    version: QrVersions.auto,
                    size: 190.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF0F172A),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF0F172A),
                    ),
                    embeddedImage: null,
                  ),
                ),
              ),

              // Center Logo / Badge on QR
              if (!isExpired)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF0D9488),
                      size: 26,
                    ),
                  ),
                ),

              // Expired Overlay
              if (isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_off_outlined, color: Colors.white, size: 28),
                      const SizedBox(height: 6),
                      const Text(
                        'QR Kedaluwarsa',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Token kedaluwarsa setelah 5 menit',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _refreshQrToken(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Perbarui Sekarang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Token Otentikasi Sekali Pakai (One-Time Nonce)
          const Text(
            'TOKEN OTENTIKASI SEKALI PAKAI (ONE-TIME NONCE)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4F1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCCFBF1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.vpn_key_outlined,
                  size: 15,
                  color: Color(0xFF0D9488),
                ),
                const SizedBox(width: 8),
                Text(
                  token.token,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Linear Progress Bar (5 menit countdown)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: token.progressRatio,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isExpired ? Colors.orange : const Color(0xFF0D9488),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Instruksi
          Text(
            'Tunjukkan layar ini kepada ${_meetup.partnerName} untuk dipindai via aplikasi CampuShift miliknya',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),

          // Action Buttons: Perbarui QR & Copy
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => _refreshQrToken(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(
                      'Perbarui QR',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D9488),
                      backgroundColor: const Color(0xFFE6F4F1),
                      side: const BorderSide(color: Color(0xFF0D9488), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Color(0xFF0F766E), size: 20),
                  onPressed: _copyTokenToClipboard,
                  tooltip: 'Salin Token',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // FR-17 Point 2: Tombol Batalkan Sesi QR
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _confirmCancelSession,
              icon: Icon(Icons.cancel_outlined, size: 16, color: Colors.red.shade600),
              label: Text(
                'Batalkan Sesi QR',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card saat transaksi serah terima berhasil
  Widget _buildSuccessCard(HandoverTokenModel token) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF16A34A),
              size: 44,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Serah Terima Berhasil!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'QR telah berhasil divalidasi oleh ${_meetup.partnerName}. Transaksi dinyatakan Selesai.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'No. Bukti Digital (BR-24):',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                Text(
                  token.proofNumber ?? 'PRF-202610-8942',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Membuka Form Ulasan (FR-20)...'),
                  backgroundColor: Color(0xFF0D9488),
                ),
              );
            },
            icon: const Icon(Icons.star_outline_rounded, size: 18),
            label: Text('Beri Ulasan untuk ${_meetup.partnerName}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  /// Card 4: Protokol Serah Terima Aman
  Widget _buildSafetyProtocolCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, color: Color(0xFF0D9488), size: 20),
              SizedBox(width: 8),
              Text(
                'Protokol Serah Terima Aman',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Step 1
          _buildProtocolStep(
            number: '1',
            title: 'Inspeksi Kondisi',
            description:
                'Persilakan pembeli mencoba kalkulator, cek layar display dan kelengkapan tutup sebelum memindai QR.',
          ),
          const SizedBox(height: 10),

          // Step 2
          _buildProtocolStep(
            number: '2',
            title: 'Terima Uang Tunai Terlebih Dahulu',
            description:
                'Pastikan Anda telah memegang uang tunai ${_meetup.itemPrice} pas sebelum mengizinkan kode QR ini dipindai.',
          ),
          const SizedBox(height: 10),

          // Step 3
          _buildProtocolStep(
            number: '3',
            title: 'Verifikasi Instan',
            description:
                'Begitu pemindai mitra membaca kode QR, transaksi otomatis dinyatakan selesai dan sistem tidak mengizinkan pembatalan sepihak (BR-20).',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Footer: Butuh bantuan petugas jaga?
          Row(
            children: [
              const Icon(
                Icons.support_agent_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              const Text(
                'Butuh bantuan petugas jaga?',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menghubungi petugas pos satpam kampus...'),
                      backgroundColor: Color(0xFF0D9488),
                    ),
                  );
                },
                child: const Text(
                  'Panggil Petugas',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D9488),
                  ),
                ),
              ),
            ],
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
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4F1),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D9488),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.35),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                TextSpan(text: description),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
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
              child: const Icon(Icons.check, color: Color(0xFF16A34A), size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Serah Terima Berhasil!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Barang "${_meetup.itemName}" telah sah diserahkan ke ${_meetup.partnerName}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No. Bukti: $proofNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog Panduan & Aturan Bisnis Serah Terima (BR-21, BR-22, FR-17)
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFF0D9488)),
            SizedBox(width: 8),
            Text('Aturan Serah Terima QR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'FR-17 & BR-21 Aturan Token QR:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 6),
              Text(
                '• Token berlaku 5 menit (sekali pakai).\n'
                '• Hanya ada 1 token aktif per pertemuan.\n'
                '• Meminta token baru menonaktifkan token sebelumnya.\n'
                '• Membatalkan sesi menghapus token aktif tanpa mengubah status pertemuan.\n'
                '• Layar memeriksa status ke server tiap 3 detik (FR-21).',
                style: TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti', style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
