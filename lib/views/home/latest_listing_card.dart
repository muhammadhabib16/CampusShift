import 'package:flutter/material.dart';

import '../../models/barter_item.dart';
import '../../models/listing_summary.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../barter/widgets/barter_item_selection_sheet.dart';
import '../safe_meet/meetup_form_screen.dart';
import 'category_style.dart';

/// Kartu barang di bagian "Barang Terbaru". Mengetuknya membuka pilihan
/// transaksi (pertemuan COD atau barter).
class LatestListingCard extends StatelessWidget {
  const LatestListingCard({super.key, required this.listing});

  final ListingSummary listing;

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.of(listing.category);
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 104,
                width: double.infinity,
                color: style.bgColor,
                child: listing.photoUrl != null
                    ? Image.network(
                        listing.photoUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null ? child : _buildCardIcon(style),
                        errorBuilder: (_, _, _) => _buildCardIcon(style),
                      )
                    : _buildCardIcon(style),
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

  Widget _buildCardIcon(CategoryStyle style) => Center(
    child: Icon(
      style.icon,
      size: 40,
      color: style.iconColor.withValues(alpha: 0.6),
    ),
  );

  void _showProductDetailModal(
    BuildContext context,
    ListingSummary listing,
    CategoryStyle style,
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
              UserLink(
                userId: listing.ownerId,
                name: listing.ownerName,
                prefix: 'Penjual: ',
                suffix: ' • Kategori: ${listing.category}',
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
}
