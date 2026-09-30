import 'package:flutter/material.dart';

class BarterConfirmationScreen extends StatelessWidget {
  const BarterConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Konfirmasi Barter',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Asset Terkunci
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0D9488), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Asset Terkunci',
                        style: TextStyle(
                          color: Color(0xFF0D9488),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.lock_outline, color: const Color(0xFF0D9488), size: 18),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAssetItem('Casio FX-991EX', Icons.calculate),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.swap_horiz, color: Colors.grey.shade400, size: 24),
                      ),
                      _buildAssetItem('Fisika Dasar', Icons.menu_book),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Rincian Kesepakatan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rincian Kesepakatan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Tambahan Tunai', 'Rp 55.000', valueColor: const Color(0xFF0D9488)),
                  const Divider(height: 24, color: Color(0xFFEEEEEE)),
                  _buildDetailRow('Titik Temu (Safe Point)', 'Perpustakaan Pusat UI'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Tanggal COD', 'Kamis, 15 Okt 2026'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Waktu', '13:00 WIB'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Biometric Auth
            GestureDetector(
              onTap: () {
                // Handle auth
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kesepakatan Berhasil Dikunci!')),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4F1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.fingerprint, size: 48, color: const Color(0xFF0D9488)),
                    const SizedBox(height: 16),
                    const Text(
                      'Otorisasi dengan Biometrik untuk Mengunci\nKesepakatan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetItem(String name, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.grey.shade500, size: 20),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color valueColor = Colors.black87}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}
