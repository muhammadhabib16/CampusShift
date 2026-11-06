import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_strings.dart';
import '../core/app_tabs.dart';
import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/item_viewmodel.dart';
import 'home/active_meetup_card.dart';
import 'home/category_card.dart';
import 'home/category_style.dart';
import 'home/home_header.dart';
import 'home/latest_listing_card.dart';
import 'home/quick_actions.dart';
import 'home/safe_meet_banner.dart';

/// Beranda: menyusun bagian-bagian di folder `home/` menjadi satu halaman
/// yang dapat di-refresh.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();
    final displayName = context.watch<AuthViewModel>().displayName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: homeViewModel.loadLatestListings,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: HomeHeader(onSelectTab: onSelectTab)),
              const _Section(child: SafeMeetBanner()),
              _Section(
                child: QuickActions(
                  displayName: displayName,
                  onSelectTab: onSelectTab,
                ),
              ),
              const _Section(child: ActiveMeetupCard()),
              _Section(
                top: AppSpacing.xl,
                bottom: AppSpacing.xs,
                child: SectionHeader(
                  title: 'Barang Terbaru',
                  actionLabel: AppStrings.seeAll,
                  onAction: () =>
                      _openCatalog(context, category: _allCategories),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: _LatestListings(viewModel: homeViewModel),
                ),
              ),
              const _Section(
                top: AppSpacing.xl,
                bottom: AppSpacing.sm,
                child: SectionHeader(title: 'Kategori Populer'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 2.8,
                  ),
                  delegate: SliverChildListDelegate([
                    for (final entry in homeCategoryStyles.entries)
                      CategoryCard(
                        style: entry.value,
                        onTap: () => _openCatalog(context, category: entry.key),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const String _allCategories = 'Semua Kategori';

  /// Buka tab Katalog dengan filter kategori yang dipilih. Filter lain
  /// (kata kunci, jenis, harga) direset agar hasilnya tidak tersaring
  /// oleh pencarian sebelumnya.
  void _openCatalog(BuildContext context, {required String category}) {
    context.read<ItemViewModel?>()?.resetFilter(category: category);
    onSelectTab?.call(AppTabs.catalog);
  }
}

/// Satu bagian Beranda dengan margin samping standar.
class _Section extends StatelessWidget {
  const _Section({
    required this.child,
    this.top = AppSpacing.lg,
    this.bottom = 0,
  });

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, top, AppSpacing.lg, bottom),
        child: child,
      ),
    );
  }
}

/// Daftar horizontal "Barang Terbaru" beserta state memuat, error, dan kosong.
class _LatestListings extends StatelessWidget {
  const _LatestListings({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(child: LoadingState(label: 'Memuat barang terbaru…'));
    }
    final error = viewModel.errorMessage;
    if (error != null) {
      return Center(
        child: Text(
          error,
          style: const TextStyle(color: AppColors.error, fontSize: 13),
        ),
      );
    }
    final listings = viewModel.latestListings;
    if (listings.isEmpty) {
      return const Center(
        child: Text(
          AppStrings.emptyListingTitle,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: listings.length,
      itemBuilder: (context, index) =>
          LatestListingCard(listing: listings[index]),
    );
  }
}
