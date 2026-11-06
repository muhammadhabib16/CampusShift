import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../models/public_profile.dart';
import '../models/review_model.dart';
import '../services/meetup_repository.dart';
import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../viewmodels/public_profile_view_model.dart';
import 'listing/item_detail_screen.dart';

/// Profil publik pengguna lain: identitas, reputasi, barang yang sedang
/// tersedia, dan ulasan yang diterima. Dibuka dari kartu pemilik barang.
class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({
    super.key,
    required this.userId,
    this.fallbackName = 'Mahasiswa Unand',
    this.viewModel,
  });

  final int userId;

  /// Nama yang ditampilkan selama profil dimuat.
  final String fallbackName;

  /// Untuk pengujian; bila null dibuat otomatis.
  final PublicProfileViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PublicProfileViewModel>(
      create: (_) =>
          (viewModel ?? PublicProfileViewModel(userId: userId))..load(),
      child: _PublicProfileBody(fallbackName: fallbackName),
    );
  }
}

class _PublicProfileBody extends StatelessWidget {
  const _PublicProfileBody({required this.fallbackName});

  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PublicProfileViewModel>();
    final profile = vm.profile;

    Widget body;
    if (profile == null && vm.isLoading) {
      body = const Center(child: LoadingState(label: 'Memuat profil…'));
    } else if (profile == null) {
      body = Center(
        child: ErrorState(
          title: 'Profil belum dapat dimuat',
          message: vm.errorMessage ?? 'Coba lagi beberapa saat lagi.',
          onRetry: vm.load,
        ),
      );
    } else {
      body = RefreshIndicator(
        color: AppColors.primary,
        onRefresh: vm.load,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (profile.id == MeetupRepository.currentUserId) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.medium,
                ),
                child: const Text(
                  'Ini profil publikmu, seperti yang dilihat pengguna lain.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _Header(profile: profile),
            const SizedBox(height: AppSpacing.md),
            _Stats(profile: profile),
            if (profile.reviews.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _Distribution(profile: profile),
            ],
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(title: 'Barang tersedia (${vm.listings.length})'),
            const SizedBox(height: AppSpacing.sm),
            if (vm.listings.isEmpty)
              const _EmptyNote(text: 'Belum ada barang yang sedang ditawarkan.')
            else
              SizedBox(
                height: 196,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.listings.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (_, i) => _ListingCard(item: vm.listings[i]),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(title: 'Ulasan diterima (${profile.reviewCount})'),
            const SizedBox(height: AppSpacing.sm),
            if (profile.reviews.isEmpty)
              const _EmptyNote(
                text: 'Belum ada ulasan. Ulasan muncul setelah serah terima selesai.',
              )
            else
              for (final review in profile.reviews) ...[
                _ReviewTile(review: review),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(profile?.fullName ?? fallbackName),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: body,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final joined = profile.joinedAt == null
        ? null
        : DateFormat('MMMM yyyy', 'id_ID').format(profile.joinedAt!);
    final identity = Row(
      children: [
        ProfileAvatar(
          name: profile.fullName,
          imageUrl: profile.photoUrl,
          radius: 32,
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      profile.nim.isEmpty
                          ? 'Mahasiswa Universitas Andalas'
                          : 'NIM ${profile.nim} · Unand',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (joined != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Bergabung sejak $joined',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          identity,
          if (profile.bio.isNotEmpty) ...[
            const Divider(height: AppSpacing.xl, color: AppColors.outline),
            Text(
              profile.bio,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final avg = profile.averageRating;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _stat(
              avg == null ? '—' : avg.toStringAsFixed(1).replaceAll('.', ','),
              'Skor reputasi',
              icon: avg == null ? null : Icons.star_rounded,
            ),
            const VerticalDivider(color: AppColors.outline),
            _stat('${profile.reviewCount}', 'Ulasan'),
            const VerticalDivider(color: AppColors.outline),
            _stat('${profile.completedDeals}', 'Transaksi selesai'),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label, {IconData? icon}) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.accent, size: 20),
                const SizedBox(width: 2),
              ],
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Distribution extends StatelessWidget {
  const _Distribution({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final dist = profile.ratingDistribution;
    final total = profile.reviews.length;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          for (final star in const [5, 4, 3, 2, 1])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    child: Text(
                      '$star',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : (dist[star] ?? 0) / total,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${dist[star] ?? 0}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final isGrant = item.listingType == 'Hibah';
    return SizedBox(
      width: 150,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 100,
                width: double.infinity,
                color: AppColors.surfaceVariant,
                child: item.photoUrls.isNotEmpty
                    ? Image.network(
                        item.photoUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  PriceTag(price: item.price, isGrant: isGrant, fontSize: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: UserLink(
                  userId: review.reviewerId,
                  name: review.reviewerName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                DateFormat('d MMM yyyy', 'id_ID').format(review.createdAt),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: i <= review.rating
                      ? AppColors.accent
                      : AppColors.outline,
                ),
              if (review.isEdited) ...[
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Diedit',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}
