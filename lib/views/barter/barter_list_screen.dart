import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_strings.dart';
import '../../models/barter_deal.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../viewmodels/barter_view_model.dart';
import 'barter_confirmation_screen.dart';
import 'widgets/barter_visuals.dart';

class BarterListScreen extends StatelessWidget {
  const BarterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text(
            'Barter Saya',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: [
              Tab(text: 'Tawaran Dikirim'),
              Tab(text: 'Tawaran Diterima'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_BarterList(sent: true), _BarterList(sent: false)],
        ),
      ),
    );
  }
}

class _BarterList extends StatelessWidget {
  final bool sent;
  const _BarterList({required this.sent});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BarterViewModel>();
    final barters = sent ? viewModel.sentDeals : viewModel.receivedDeals;

    if (barters.isEmpty) {
      return const EmptyState(
        title: AppStrings.emptyBarterTitle,
        description: AppStrings.emptyBarterDesc,
        icon: Icons.swap_horiz_rounded,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: barters.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final barter = barters[index];
        return _buildBarterCard(context, barter);
      },
    );
  }

  Widget _buildBarterCard(BuildContext context, BarterDeal data) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BarterConfirmationScreen(dealId: data.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Mitra dan Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primaryContainer,
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    data.partnerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge(status: data.status, compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Komparasi Dua Barang Berdampingan (Section 5.4)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadius.medium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAssetIcon(
                  data.myItem.name,
                  BarterVisuals.iconForCategory(data.myItem.category),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                _buildAssetIcon(
                  data.partnerItem.name,
                  BarterVisuals.iconForCategory(data.partnerItem.category),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Footer Tanggal dan Detail Link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.dateLabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Row(
                children: [
                  Text(
                    'Lihat Kesepakatan',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetIcon(String label, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
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
              label,
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
}
