import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../models/meetup.dart';
import '../../viewmodels/handover_view_model.dart';
import '../../services/meetup_repository.dart';
import 'review_form_screen.dart';

/// FR-18 [W]: Peminat memindai kode QR menggunakan kamera (mobile_scanner).
/// Server memvalidasi token cocok, belum kedaluwarsa, belum dipakai, dan dipindai Peminat (BR-22).
/// Jika valid, pertemuan menjadi Selesai dan barang Completed (BR-23).
class QrScannerScreen extends StatefulWidget {
  final Meetup? targetMeetup;

  const QrScannerScreen({super.key, this.targetMeetup});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  late int _scannerUserId;

  @override
  void initState() {
    super.initState();
    _scannerUserId = MeetupRepository.currentUserId; // Default user context login (1: Bayu)
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// Proses pemindaian kode QR (FR-18)
  Future<void> _handleBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _processToken(rawValue);
  }

  Future<void> _processToken(String rawValue) async {
    setState(() => _isProcessing = true);
    _scannerController.stop();

    // Payload bisa berupa "TOKEN|MEETUP_ID" atau hanya "TOKEN"
    String tokenString = rawValue.trim();
    int meetupId = widget.targetMeetup?.id ?? 101;

    if (rawValue.contains('|')) {
      final parts = rawValue.split('|');
      tokenString = parts[0].trim();
      final parsedId = int.tryParse(parts[1].trim());
      if (parsedId != null) meetupId = parsedId;
    }

    final vm = context.read<HandoverViewModel>();
    final result = await vm.validateAndCompleteHandover(
      meetupId: meetupId,
      tokenString: tokenString,
      scannerUserId: _scannerUserId,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final proof = vm.lastCompletedProof;
      _showSuccessDialog(proof);
    } else {
      // Validasi Gagal (BR-22 & AC-21, AC-22)
      final errorMsg = result['message'] ?? 'Validasi QR gagal.';
      _showErrorDialog(errorMsg);
    }
  }

  void _showErrorDialog(String errorMsg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 24),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Verifikasi Ditolak (BR-22)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(
          errorMsg,
          style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isProcessing = false);
              _scannerController.start();
            },
            child: const Text('Coba Pindai Lagi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(dynamic proof) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF0D9488), size: 36),
            ),
            const SizedBox(height: 14),
            const Text('Serah Terima Terverifikasi! 🎉', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Status pertemuan kini Selesai dan barang Completed (BR-23). Notifikasi N-04 telah dikirimkan ke perangkat Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
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
                  const Icon(Icons.receipt_long_rounded, color: Color(0xFF0D9488), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nomor Bukti Digital (BR-24):', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        Text(
                          proof?.proofNumber ?? 'PRF-202610-8812',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewFormScreen(
                        meetupId: widget.targetMeetup?.id ?? 101,
                        proofNumber: proof?.proofNumber ?? 'PRF-202610-8812',
                        targetUserId: widget.targetMeetup?.ownerId ?? 3,
                        targetUserName: widget.targetMeetup?.ownerName ?? 'Fadel Muhammad',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.star_rounded, color: Colors.white),
                label: const Text('Beri Ulasan Pemilik Barang (FR-20)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog Input Manual Token (Sangat berguna untuk pengujian di emulator/desktop)
  Future<void> _showManualInputDialog() async {
    final textController = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ketik Kode Token Manual', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fitur ini memudahkan pengujian di Emulator / Windows tanpa kamera fisik:',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Contoh: TKN-CS-1234-AB',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
            onPressed: () => Navigator.pop(ctx, textController.text.trim()),
            child: const Text('Verifikasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (res != null && res.isNotEmpty) {
      _processToken(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pindai QR Serah Terima', style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'Ketik Kode Manual',
            icon: const Icon(Icons.keyboard_rounded, color: Colors.white),
            onPressed: _showManualInputDialog,
          ),
          IconButton(
            tooltip: 'Flash',
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Kamera Pemindai (mobile_scanner)
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcodeDetected,
          ),

          // Overlay Viewfinder
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF0D9488), width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Petunjuk Pemindaian
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.qr_code_scanner, color: Color(0xFF0D9488), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Arahkan kamera ke QR pemilik barang di titik temu COD Unand',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _showManualInputDialog,
                  icon: const Icon(Icons.edit_note_rounded, color: Colors.white70),
                  label: const Text('Kamera tidak aktif? Ketik kode manual', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
              ],
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D9488)),
              ),
            ),
        ],
      ),
    );
  }
}