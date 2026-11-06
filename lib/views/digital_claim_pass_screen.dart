import 'package:flutter/material.dart';
import '../models/grant_claim.dart';
import '../theme/app_tokens.dart';

/// Sesuai PRD Bagian 3.2 (Out of Scope):
/// "Digital Claim Pass terpisah ditiadakan; bukti pengambilan hibah menggunakan
/// penjadwalan Safe-Meet Point (Modul 2) dan serah terima QR (Modul 4)."
/// File ini dipertahankan agar import pada main.dart/home_screen.dart tidak error.
class DigitalClaimPassScreen extends StatelessWidget {
  final GrantClaim? claim;

  const DigitalClaimPassScreen({super.key, this.claim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pengambilan Hibah'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  claim?.itemTitle ?? 'Pengambilan Barang Hibah',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sesuai PRD v1.4 terbaru, pengambilan barang hibah yang telah Approved '
                  'dijadwalkan di Safe-Meet Point Unand dan divalidasi saat bertemu '
                  'dengan memindai Kode QR sekali pakai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, height: 1.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Kembali ke Detail Klaim'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
