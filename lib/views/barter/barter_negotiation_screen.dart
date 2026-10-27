import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../viewmodels/barter_view_model.dart';
import 'widgets/barter_visuals.dart';

class BarterNegotiationScreen extends StatefulWidget {
  const BarterNegotiationScreen({super.key});

  @override
  State<BarterNegotiationScreen> createState() =>
      _BarterNegotiationScreenState();
}

class _BarterNegotiationScreenState extends State<BarterNegotiationScreen> {
  late final TextEditingController _cashAdditionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cashAdditionController = TextEditingController(
      text: context.read<BarterViewModel>().suggestedTopUp.toString(),
    );
  }

  @override
  void dispose() {
    _cashAdditionController.dispose();
    super.dispose();
  }

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<BarterViewModel>();
    final success = await viewModel.submitProposal(
      _cashAdditionController.text.trim(),
    );
    if (!mounted) return;

    if (success) {
      AppSnackBar.showSuccess(
        context,
        'Penawaran barter berhasil dikirim ke mitra!',
      );
      Navigator.pop(context);
    } else {
      AppSnackBar.showError(
        context,
        viewModel.errorMessage ?? 'Gagal mengirim penawaran barter.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BarterViewModel>();
    final offeredItem = viewModel.selectedItem;
    final targetItem = viewModel.targetItem;
    final difference = viewModel.priceDifference;
    final isSubmitting = viewModel.isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Negosiasi Barter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Langkah Berikutnya (Section 4.3)
              const StepBanner(
                title: 'Sesuaikan Tawaran Pertukaran',
                description: 'Tambahkan cash top-up jika terdapat selisih nilai barang agar kedua belah pihak merasa adil.',
                stepNumber: 1,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Kartu Komparasi Dua Barang Berdampingan (Section 5.4)
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildItemColumn(
                          'Barang Kamu',
                          offeredItem?.name ?? '-',
                          offeredItem == null ? 0 : offeredItem.price,
                          BarterVisuals.iconForCategory(
                            offeredItem?.category ?? '',
                          ),
                          AppColors.primary,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 24,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        ),
                        _buildItemColumn(
                          'Barang Mitra',
                          targetItem?.name ?? '-',
                          targetItem == null ? 0 : targetItem.price,
                          BarterVisuals.iconForCategory(
                            targetItem?.category ?? '',
                          ),
                          AppColors.accent,
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.outline),
                    // Baris Selisih Nilai Barang
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selisih Nilai Taksiran:',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          difference > 0
                              ? '- ${formatRupiah(difference)} (Kamu kurang)'
                              : '+ ${formatRupiah(-difference)} (Kamu berlebih)',
                          style: TextStyle(
                            fontSize: 13,
                            color: difference > 0
                                ? AppColors.error
                                : AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Input Cash Top-Up
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cash Top-Up Tunai Tambahan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Nominal uang tunai yang akan diserahkan saat bertemu di Safe-Meet Point.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _cashAdditionController,
                      label: 'Nominal Top-Up (Rp)',
                      hintText: 'Contoh: 20000',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Text(
                          'Rp',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      validator: viewModel.validateTopUp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline)),
          boxShadow: AppElevation.softShadow,
        ),
        child: SafeArea(
          child: AppPrimaryButton(
            label: 'Kirim Penawaran Barter',
            icon: Icons.send_rounded,
            isLoading: isSubmitting,
            onPressed: _submitProposal,
          ),
        ),
      ),
    );
  }

  Widget _buildItemColumn(
    String roleLabel,
    String name,
    int price,
    IconData icon,
    Color badgeColor,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadius.medium,
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              roleLabel,
              style: TextStyle(
                fontSize: 10,
                color: badgeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          PriceTag(price: price, fontSize: 13),
        ],
      ),
    );
  }
}
