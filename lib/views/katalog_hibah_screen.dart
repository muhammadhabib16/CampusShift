import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/social_grant.dart';
import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../viewmodels/social_grant_viewmodel.dart';
import 'ajukan_klaim_screen.dart';

/// Layar Katalog Hibah — FR-21 (telusuri katalog hibah aktif).
/// Menggunakan design system seragam: Material 3, AppCard, PriceTag (Hibah),
/// serta penanganan 3 kondisi layar (Loading, Empty, Error) sesuai PRD 2.10.
class KatalogHibahScreen extends StatefulWidget {
  const KatalogHibahScreen({super.key, required this.currentUserNim});

  /// Dioper dari luar modul (hasil AuthViewModel milik Modul Pendukung)
  final String currentUserNim;

  @override
  State<KatalogHibahScreen> createState() => _KatalogHibahScreenState();
}

class _KatalogHibahScreenState extends State<KatalogHibahScreen> {
  static const _categories = [
    'Semua',
    'Buku',
    'Elektronik',
    'Furnitur',
    'Alat Kuliah',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocialGrantViewModel>().loadGrants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SocialGrantViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Katalog Hibah Sosial'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => vm.loadGrants(category: vm.selectedCategory),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Hero Banner SDG 12
            const SliverToBoxAdapter(child: _HeroBanner()),

            // Category Chips
            SliverToBoxAdapter(child: _CategoryChips(categories: _categories)),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // 3 Kondisi Layar (PRD 2.10)
            if (vm.isLoading)
              const SliverFillRemaining(
                child: LoadingState(label: 'Memuat katalog hibah aktif…'),
              )
            else if (vm.errorMessage != null)
              SliverFillRemaining(
                child: ErrorState(
                  title: 'Gagal Memuat Hibah',
                  message: vm.errorMessage!,
                  onRetry: () => vm.loadGrants(category: vm.selectedCategory),
                ),
              )
            else if (vm.grants.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.volunteer_activism_rounded,
                  title: 'Belum Ada Barang Hibah',
                  description: 'Saat ini belum ada donasi aktif pada kategori yang dipilih. Silakan periksa kategori lain.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _GrantCard(
                      grant: vm.grants[i],
                      currentUserNim: widget.currentUserNim,
                    ),
                    childCount: vm.grants.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.large,
        boxShadow: AppElevation.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.pill,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.eco_rounded, color: AppColors.primary, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'SDG 12: Konsumsi Berkelanjutan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Berbagi untuk Sesama Mahasiswa',
            style: TextStyle(
              color: AppColors.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Dukung sirkularitas kampus Unand dengan mengalihkan perlengkapan kuliah secara gratis bagi yang membutuhkan.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.categories});
  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SocialGrantViewModel>();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final label = categories[i];
          final value = label == 'Semua' ? null : label;
          final selected = vm.selectedCategory == value;

          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) =>
                context.read<SocialGrantViewModel>().setCategory(value),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              color: selected ? AppColors.onPrimary : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.pill,
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.outline,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

class _GrantCard extends StatelessWidget {
  const _GrantCard({required this.grant, required this.currentUserNim});
  final SocialGrant grant;
  final String currentUserNim;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AjukanKlaimScreen(grant: grant, currentUserNim: currentUserNim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Foto Barang
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.largeValue),
                  ),
                  child: grant.photoUrl.isEmpty
                      ? Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(
                            Icons.volunteer_activism_outlined,
                            color: AppColors.primary,
                            size: 36,
                          ),
                        )
                      : Image.network(
                          grant.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                ),
                // Badge Kategori Akademik
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withValues(alpha: 0.75),
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      grant.academicCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Detail Informasi Hibah
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grant.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        grant.donorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // PriceTag dengan badge hibah gratis
                    const PriceTag(price: 0, isGrant: true),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.small,
                      ),
                      child: Text(
                        'Kuota: ${grant.quota}',
                        style: const TextStyle(
                          color: AppColors.onPrimaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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
    );
  }
}
