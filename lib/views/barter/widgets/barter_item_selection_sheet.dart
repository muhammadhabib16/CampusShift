import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/barter_item.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../theme/app_tokens.dart';
import '../../../utils/formatters.dart';
import '../../../viewmodels/barter_view_model.dart';
import '../barter_negotiation_screen.dart';
import 'barter_visuals.dart';

class BarterItemSelectionSheet extends StatelessWidget {
  const BarterItemSelectionSheet({super.key});

  static void show(BuildContext context, {BarterItem? target}) {
    if (target != null) context.read<BarterViewModel>().setTargetItem(target);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BarterItemSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BarterViewModel>();
    final myItems = viewModel.myItems;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: AppRadius.pill,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Pilih Barang untuk Ditukar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih salah satu barang aktifmu untuk mengajukan penawaran barter.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (myItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'Kamu belum memiliki barang aktif yang bisa ditukarkan.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = myItems[index];
                final isSelected = viewModel.selectedIndex == index;

                return InkWell(
                  onTap: () => viewModel.selectItem(index),
                  borderRadius: AppRadius.medium,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer.withValues(alpha: 0.35)
                          : AppColors.surface,
                      borderRadius: AppRadius.medium,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadius.small,
                          ),
                          child: Icon(
                            BarterVisuals.iconForCategory(item.category),
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    formatRupiah(item.price),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: AppRadius.pill,
                                    ),
                                    child: Text(
                                      item.condition,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: BarterVisuals.colorForCondition(
                                          item.condition,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Radio<int>(
                          value: index,
                          groupValue: viewModel.selectedIndex,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            if (val != null) viewModel.selectItem(val);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: AppSpacing.xl),

          AppPrimaryButton(
            label: 'Lanjut ke Negosiasi Barter',
            icon: Icons.arrow_forward_rounded,
            onPressed: myItems.isEmpty
                ? null
                : () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BarterNegotiationScreen(),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
