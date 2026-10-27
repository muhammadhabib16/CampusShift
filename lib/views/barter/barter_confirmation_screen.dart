import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_strings.dart';
import '../../models/barter_deal.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../viewmodels/barter_view_model.dart';
import '../safe_meet/meetup_form_screen.dart';
import 'widgets/barter_visuals.dart';

/// Detail Tawaran & Konfirmasi Kesepakatan (FR-13 Dual-Confirmation).
class BarterConfirmationScreen extends StatelessWidget {
  final String dealId;
  const BarterConfirmationScreen({super.key, required this.dealId});

  Future<void> _confirm(BuildContext context, BarterDeal deal) async {
    final viewModel = context.read<BarterViewModel>();
    final success = await viewModel.confirmDeal(deal.id);
    if (!context.mounted) return;

    final updated = viewModel.dealById(deal.id);

    if (success) {
      if (updated?.status == 'Terkunci' || updated?.status == 'Locked') {
        AppSnackBar.showSuccess(
          context,
          'Kesepakatan Berhasil Dikunci (Dual-Confirmation)!',
        );
      } else {
        AppSnackBar.showInfo(
          context,
          'Konfirmasi tercatat, menunggu persetujuan ${deal.partnerName}.',
        );
      }
    } else {
      AppSnackBar.showError(
        context,
        viewModel.errorMessage ?? 'Gagal mengonfirmasi kesepakatan.',
      );
    }
  }

  Future<void> _cancelDeal(BuildContext context, BarterDeal deal) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Batalkan Tawaran Barter?',
      message: 'Apakah kamu yakin ingin membatalkan kesepakatan barter ini? Status kesepakatan akan berubah menjadi Dibatalkan.',
      confirmLabel: 'Batalkan Barter',
      cancelLabel: AppStrings.cancel,
      destructive: true,
      confirmIcon: Icons.cancel_outlined,
    );

    if (confirmed && context.mounted) {
      AppSnackBar.showInfo(context, 'Kesepakatan barter dibatalkan.');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BarterViewModel>();
    final deal = viewModel.dealById(dealId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Konfirmasi Barter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: deal == null
          ? const Center(
              child: EmptyState(
                title: 'Tawaran Tidak Ditemukan',
                description: 'Data kesepakatan barter tidak tersedia.',
              ),
            )
          : _buildContent(context, viewModel, deal),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BarterViewModel viewModel,
    BarterDeal deal,
  ) {
    final isLocked = deal.status == 'Terkunci' || deal.status == 'Locked';
    final canConfirm = viewModel.canConfirm(deal);
    final topUpPayer = deal.topUpPaidByMe ? 'Kamu' : deal.partnerName;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Banner Langkah Berikutnya (Dual-Confirmation)
          if (!isLocked) ...[
            StepBanner(
              title: 'Dual-Confirmation Barter',
              description: 'Kedua belah pihak wajib menyetujui rincian barang dan cash top-up sebelum jadwal Safe-Meet Point dapat dibuat.',
              stepNumber: 2,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Kartu Barang yang Ditukar
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLocked ? 'Status: Terkunci (Locked)' : 'Status Tawaran',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    StatusBadge(status: deal.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadius.medium,
                  ),
                  child: Row(
                    children: [
                      _buildAssetItem(
                        deal.myItem.name,
                        BarterVisuals.iconForCategory(deal.myItem.category),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      _buildAssetItem(
                        deal.partnerItem.name,
                        BarterVisuals.iconForCategory(
                          deal.partnerItem.category,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Rincian Kesepakatan
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rincian Kesepakatan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildDetailRow('Mitra Barter', deal.partnerName),
                const Divider(height: 20, color: AppColors.outline),
                _buildDetailRow(
                  'Tambahan Tunai (Top-Up)',
                  deal.cashTopUp > 0
                      ? formatRupiah(deal.cashTopUp)
                      : 'Rp0 (Tanpa Tunai)',
                  valueColor: AppColors.primary,
                ),
                if (deal.cashTopUp > 0) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Dibayar oleh', topUpPayer),
                ],
                const Divider(height: 20, color: AppColors.outline),
                _buildDetailRow(
                  'Konfirmasi Kamu',
                  deal.myConfirmed ? 'Sudah Disetujui' : 'Belum Disetujui',
                  valueColor: deal.myConfirmed
                      ? AppColors.success
                      : AppColors.accent,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Konfirmasi ${deal.partnerName}',
                  deal.partnerConfirmed
                      ? 'Sudah Disetujui'
                      : 'Menunggu Konfirmasi',
                  valueColor: deal.partnerConfirmed
                      ? AppColors.success
                      : AppColors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Banner Menunggu Konfirmasi Mitra (Section 5.4)
          if (deal.myConfirmed && !deal.partnerConfirmed && !isLocked) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.large,
                border: Border.all(color: const Color(0xFF99F6E4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Menunggu Konfirmasi Mitra',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kamu telah menyetujui. Menunggu konfirmasi dari ${deal.partnerName} untuk mengunci kesepakatan.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Tombol Aksi Utama
          if (canConfirm) ...[
            AppPrimaryButton(
              label: 'Setuju & Kunci Kesepakatan',
              icon: Icons.lock_outline,
              isLoading: viewModel.isSubmitting,
              onPressed: () => _confirm(context, deal),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSecondaryButton(
              label: 'Batalkan Tawaran',
              isDestructive: true,
              onPressed: () => _cancelDeal(context, deal),
            ),
          ] else if (isLocked) ...[
            StepBanner(
              title: 'Kesepakatan Telah Terkunci!',
              description: 'Silakan ajukan titik Safe-Meet Point dan jadwal pertemuan COD untuk serah terima barang.',
              stepNumber: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: 'Ajukan Titik Temu & Jadwal COD',
              icon: Icons.calendar_month_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeetupFormScreen(
                      itemId:
                          int.tryParse(
                            deal.partnerItem.id.replaceAll(RegExp(r'\D'), ''),
                          ) ??
                          0,
                      itemTitle:
                          '${deal.partnerItem.name} ⇄ ${deal.myItem.name}',
                      itemPrice: deal.cashTopUp > 0
                          ? 'Top-up ${formatRupiah(deal.cashTopUp)}'
                          : 'Tanpa selisih tunai',
                      itemType: 'Barter',
                      ownerId: 0,
                      ownerName: deal.partnerName,
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildAssetItem(String name, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.small,
              border: Border.all(color: AppColors.outline),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color valueColor = AppColors.textPrimary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
