import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/grant_claim.dart';
import '../models/social_grant.dart';

/// Layar "digital-claim-pass" — bukti setelah klaim disetujui (hasil FR-24),
/// ditunjukkan pemohon ke donatur saat serah terima barang.
class DigitalClaimPassScreen extends StatelessWidget {
  const DigitalClaimPassScreen({
    super.key,
    required this.claim,
    required this.grant,
    required this.recipientName,
  });

  final GrantClaim claim;
  final SocialGrant grant;

  /// Dioper dari luar modul (profil user), sama seperti currentUserNim di
  /// AjukanKlaimScreen — menjaga low coupling antar modul.
  final String recipientName;

  @override
  Widget build(BuildContext context) {
    final code = claim.digitalClaimPassCode ?? '-';
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pass Pengambilan',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFFE9F7F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF0D9488),
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text('CLAIM PASS',
                      style:
                          TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xFFD4F0EA), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      claim.approval == ClaimApproval.approved ? 'AKTIF' : 'MENUNGGU',
                      style: const TextStyle(
                          color: Color(0xFF0D9488), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  _PassRow(label: 'NAMA BARANG', value: grant.itemName),
                  const SizedBox(height: 12),
                  _PassRow(label: 'DONATUR', value: grant.donorName),
                  const SizedBox(height: 12),
                  _PassRow(label: 'PENERIMA KLAIM', value: recipientName),
                  const SizedBox(height: 12),
                  _PassRow(label: 'TANGGAL DISETUJUI', value: _formatDate(claim.createdAt)),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  // Paket `qr_flutter` perlu ditambah ke pubspec.yaml khusus
                  // Modul 5 (beda dari `mobile_scanner` yang dipakai Modul 4
                  // untuk SCAN, ini untuk MEMBUAT/menampilkan QR).
                  QrImageView(data: code, version: QrVersions.auto, size: 160),
                  const SizedBox(height: 16),
                  const Text('KODE SERAH TERIMA', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(code,
                      style: const TextStyle(
                          color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Text(
                    'Tunjukkan Claim Pass ini kepada Donatur saat serah terima barang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _PassRow extends StatelessWidget {
  const _PassRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}
