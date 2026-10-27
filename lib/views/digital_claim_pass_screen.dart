import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/grant_claim.dart';
import '../models/social_grant.dart';
import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../utils/formatters.dart';

/// Layar Bukti Digital Claim Pass — bukti pengambilan setelah klaim disetujui (FR-24),
/// ditunjukkan oleh pemohon ke donatur saat serah terima barang hibah di kampus.
class DigitalClaimPassScreen extends StatelessWidget {
  const DigitalClaimPassScreen({
    super.key,
    required this.claim,
    required this.grant,
    required this.recipientName,
  });

  final GrantClaim claim;
  final SocialGrant grant;
  final String recipientName;

  @override
  Widget build(BuildContext context) {
    final code = claim.digitalClaimPassCode ?? '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pass Pengambilan Hibah'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          children: [
            // Kartu Gaya Tiket Digital
            Container(
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
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                      horizontal: AppSpacing.lg,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.largeValue),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: AppColors.onPrimary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'DIGITAL CLAIM PASS',
                          style: TextStyle(
                            color: AppColors.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            claim.approval == ClaimApproval.approved
                                ? 'PAS KLAIM AKTIF'
                                : 'MENUNGGU VERIFIKASI',
                            style: const TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
                          color: index.isEven
                              ? AppColors.outline
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),

                  // Rincian Transaksi Hibah
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        _PassRow(label: 'BARANG HIBAH', value: grant.itemName),
                        const SizedBox(height: AppSpacing.md),
                        _PassRow(
                          label: 'DONATUR RESMI',
                          value: grant.donorName,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _PassRow(
                          label: 'PENERIMA TERVERIFIKASI',
                          value: recipientName,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _PassRow(
                          label: 'TANGGAL PERSETUJUAN',
                          value: formatTanggalWib(claim.createdAt),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(color: AppColors.outline),
                        const SizedBox(height: AppSpacing.lg),

                        // QR Code Serah Terima
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.medium,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            boxShadow: AppElevation.softShadow,
                          ),
                          child: QrImageView(
                            data: code,
                            version: QrVersions.auto,
                            size: 170,
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
                        const SizedBox(height: AppSpacing.md),

                        const Text(
                          'KODE SERAH TERIMA HIBAH',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: code));
                            AppSnackBar.showSuccess(
                              context,
                              'Kode $code disalin ke papan klip',
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                code,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  letterSpacing: 1.0,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              const Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        Text(
                          'Tunjukkan layar ini kepada Donatur saat bertemu di Safe-Meet Point untuk diverifikasi.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tombol Tutup
            AppPrimaryButton(
              label: 'Kembali',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
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
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
