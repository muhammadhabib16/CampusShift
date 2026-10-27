import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_strings.dart';
import '../models/barter_item.dart';
import '../models/handover_token_model.dart';
import '../models/listing_summary.dart';
import '../models/meetup.dart';
import '../services/meetup_repository.dart';
import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../utils/formatters.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/home_view_model.dart';
import 'barter/widgets/barter_item_selection_sheet.dart';
import 'handover/serah_terima_qr_screen.dart';
import 'katalog_hibah_screen.dart';
import 'listing/add_listing_screen.dart';
import 'safe_meet/meetup_form_screen.dart';
import 'safe_meet/my_meetups_screen.dart';
import 'safe_meet/safe_meet_directory_screen.dart';

/// Indeks tab di bottom navigation MainScreen.
const int katalogTabIndex = 1;
const int barterTabIndex = 2;

class _CategoryStyle {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  const _CategoryStyle(this.label, this.icon, this.bgColor, this.iconColor);
}

const Map<String, _CategoryStyle> _categoryStyles = {
  'Buku & Referensi': _CategoryStyle(
    'Buku & Referensi',
    Icons.menu_book_rounded,
    Color(0xFFEFF6FF),
    Color(0xFF1D4ED8),
  ),
  'Furnitur Kos': _CategoryStyle(
    'Furnitur Kos',
    Icons.weekend_rounded,
    Color(0xFFFFFBEB),
    Color(0xFFB45309),
  ),
  'Elektronik': _CategoryStyle(
    'Elektronik',
    Icons.devices_other_rounded,
    Color(0xFFF5F3FF),
    Color(0xFF6D28D9),
  ),
  'Alat Perkuliahan': _CategoryStyle(
    'Alat Kuliah',
    Icons.construction_rounded,
    Color(0xFFECFDF5),
    Color(0xFF047857),
  ),
};

const _defaultCategoryStyle = _CategoryStyle(
  'Lainnya',
  Icons.inventory_2_outlined,
  Color(0xFFF1F5F9),
  Color(0xFF475569),
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();
    final listings = homeViewModel.latestListings;
    final displayName = context.watch<AuthViewModel>().displayName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => homeViewModel.loadLatestListings(),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(child: _buildAppBar(context)),

              // Banner Modul 2 Safe-Meet Point Highlight
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: _buildSafeMeetBanner(context),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: _buildQuickActions(context, displayName),
                ),
              ),

              // Banner Pertemuan Aktif (Modul 4: Serah Terima QR)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: _buildActiveMeetupCard(context),
                ),
              ),

              // Header Barang Terbaru
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xs,
                  ),
                  child: SectionHeader(
                    title: 'Barang Terbaru',
                    actionLabel: AppStrings.seeAll,
                    onAction: () => onSelectTab?.call(katalogTabIndex),
                  ),
                ),
              ),

              // Daftar Barang Horizontal
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: homeViewModel.isLoading
                      ? const Center(
                          child: LoadingState(label: 'Memuat barang terbaru…'),
                        )
                      : homeViewModel.errorMessage != null
                      ? Center(
                          child: Text(
                            homeViewModel.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : listings.isEmpty
                      ? const Center(
                          child: Text(
                            AppStrings.emptyListingTitle,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xs,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: listings.length,
                          itemBuilder: (context, index) =>
                              _buildProductCard(context, listings[index]),
                        ),
                ),
              ),

              // Kategori Populer
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: const SectionHeader(title: 'Kategori Populer'),
                ),
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
                    for (final style in _categoryStyles.values)
                      _buildCategoryCard(
                        style.icon,
                        style.label,
                        style.bgColor,
                        style.iconColor,
                        () => onSelectTab?.call(katalogTabIndex),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.small,
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CampuShift',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Universitas Andalas',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Jadwal Pertemuan Saya',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyMeetupsScreen()),
              );
            },
            icon: const Icon(
              Icons.event_note_rounded,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            tooltip: 'Cari di Katalog',
            onPressed: () => onSelectTab?.call(katalogTabIndex),
            icon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeMeetBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF134E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.large,
        boxShadow: AppElevation.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: AppRadius.small,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Modul 2 • Safe-Meet Point',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.verified_user_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Transaksi COD Aman di Kampus Unand',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gunakan titik temu resmi Unand (pos satpam, perpus, rektorat) yang terpantau CCTV & aman.',
            style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.35),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SafeMeetDirectoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.map_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Peta Titik Temu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.medium,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyMeetupsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Jadwal Saya',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    side: const BorderSide(color: Colors.white70),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.medium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, String displayName) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryContainer,
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Halo, Mahasiswa Unand!',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                icon: Icons.sell_rounded,
                label: 'Jual',
                color: AppColors.primary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddListingScreen()),
                  );
                },
              ),
              _buildQuickActionItem(
                icon: Icons.swap_horiz_rounded,
                label: 'Barter',
                color: AppColors.accent,
                onTap: () => onSelectTab?.call(barterTabIndex),
              ),
              _buildQuickActionItem(
                icon: Icons.volunteer_activism_rounded,
                label: 'Hibah',
                color: const Color(0xFF6D28D9),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const KatalogHibahScreen(),
                    ),
                  );
                },
              ),
              _buildQuickActionItem(
                icon: Icons.shield_rounded,
                label: 'Titik Temu',
                color: const Color(0xFF047857),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SafeMeetDirectoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppRadius.medium,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ListingSummary listing) {
    final style = _categoryStyles[listing.category] ?? _defaultCategoryStyle;
    return GestureDetector(
      onTap: () => _showProductDetailModal(context, listing, style),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.outline),
          boxShadow: AppElevation.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 104,
              decoration: BoxDecoration(
                color: style.bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  style.icon,
                  size: 40,
                  color: style.iconColor.withValues(alpha: 0.6),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    listing.faculty,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  PriceTag(price: listing.price, fontSize: 13),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetailModal(
    BuildContext context,
    ListingSummary listing,
    _CategoryStyle style,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: style.bgColor,
                      borderRadius: AppRadius.medium,
                    ),
                    child: Icon(style.icon, size: 24, color: style.iconColor),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        PriceTag(price: listing.price, fontSize: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Penjual: ${listing.ownerName} • Kategori: ${listing.category}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Divider(height: 24, color: AppColors.outline),
              const Text(
                'Pilih jenis transaksi yang diinginkan:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.md),
              AppPrimaryButton(
                label: 'Ajukan Pertemuan COD di Safe-Meet Point',
                icon: Icons.calendar_month_rounded,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MeetupFormScreen(
                        itemId: int.tryParse(listing.id) ?? 0,
                        itemTitle: listing.title,
                        itemPrice: formatRupiah(listing.price),
                        itemType: 'Jual',
                        ownerId: listing.ownerId,
                        ownerName: listing.ownerName,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSecondaryButton(
                label: 'Tukar (Barter)',
                icon: Icons.swap_horiz_rounded,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  BarterItemSelectionSheet.show(
                    context,
                    target: BarterItem(
                      id: listing.id,
                      name: listing.title,
                      price: listing.price,
                      category: listing.category,
                      condition: listing.condition,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.outline),
          boxShadow: AppElevation.softShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: AppRadius.small,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
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
      ),
    );
  }

  Widget _buildActiveMeetupCard(BuildContext context) {
    final repository = MeetupRepository();
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final meetup = repository.getNextConfirmedMeetup();
        return _buildMeetupCardContent(context, meetup);
      },
    );
  }

  Widget _buildMeetupCardContent(BuildContext context, Meetup? meetup) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF134E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.large,
        boxShadow: AppElevation.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: AppRadius.small,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'MODUL 4 • SERAH TERIMA QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (meetup != null)
                const StatusBadge(status: 'Dikonfirmasi', compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            meetup?.itemTitle ?? 'Belum ada pertemuan terkonfirmasi',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                meetup == null
                    ? Icons.info_outline_rounded
                    : Icons.location_on_outlined,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  meetup == null
                      ? 'Sesi QR tersedia setelah pemilik mengonfirmasi pertemuan.'
                      : '${meetup.safeMeetPoint.name} • ${meetup.formattedShortDateTime}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => meetup == null
                        ? const MyMeetupsScreen()
                        : SerahTerimaQrScreen(
                            meetupDetail: MeetupDetailModel.fromMeetup(
                              meetup,
                              viewerId: MeetupRepository.currentUserId,
                            ),
                          ),
                  ),
                );
              },
              icon: Icon(
                meetup == null
                    ? Icons.event_note_rounded
                    : Icons.qr_code_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                meetup == null
                    ? 'Lihat Jadwal Pertemuan Saya'
                    : 'Buka Sesi QR Serah Terima (FR-17)',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.medium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
