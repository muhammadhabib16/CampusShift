import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/barter_item.dart';
import '../../models/item_model.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../viewmodels/auth_view_model.dart';
import '../barter/widgets/barter_item_selection_sheet.dart';
import '../katalog_hibah_screen.dart';
import '../safe_meet/meetup_form_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final ItemModel item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _activePhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final photos = item.photoUrls.isNotEmpty
        ? item.photoUrls
        : ['https://via.placeholder.com/600x450'];
    final isGrant = item.listingType == 'Hibah';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Barang',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Bagikan',
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              AppSnackBar.showInfo(
                context,
                'Tautan barang disalin ke papan klip.',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galeri Foto Barang dengan Indikator Titik (Section 5.2)
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    itemCount: photos.length,
                    onPageChanged: (i) => setState(() => _activePhotoIndex = i),
                    itemBuilder: (context, index) {
                      return Image.network(
                        photos[index],
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 56,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (photos.length > 1)
                    Positioned(
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            photos.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _activePhotoIndex == index ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _activePhotoIndex == index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                                borderRadius: AppRadius.pill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: Status dan Kondisi Fisik
                  Row(
                    children: [
                      StatusBadge(status: item.status),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadius.pill,
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Text(
                          'Kondisi: ${item.condition}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (item.isBarterOpen) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: AppRadius.pill,
                          ),
                          child: const Text(
                            '⇌ Buka Barter',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Judul dan Harga
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  PriceTag(price: item.price, isGrant: isGrant, fontSize: 20),
                  const SizedBox(height: AppSpacing.lg),

                  // Penjual Info
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AvatarWithName(
                      name: item.ownerName.isEmpty
                          ? 'Mahasiswa Unand'
                          : item.ownerName,
                      subtitle: 'Kategori: ${item.category}',
                      radius: 20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Zona Safe-Meet Card
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Zona Safe-Meet Kampus Unand',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Untuk keamanan transaksi, pertemuan COD hanya dapat dijadwalkan di titik resmi.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Divider(height: 20, color: AppColors.outline),
                        _buildLocationRow(
                          'Pos Satpam Utama Gedung Rektorat',
                          'Terpantau CCTV 24 Jam • Dekat Pintu Masuk',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildLocationRow(
                          'Lobi Perpustakaan Pusat (Lantai 1)',
                          'Area Terang • Buka s/d 20.00 WIB',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Deskripsi & Kondisi Fisik
                  const Text(
                    'Deskripsi & Kondisi Fisik',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.description.isEmpty
                        ? 'Tidak ada deskripsi tambahan.'
                        : item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Bar dengan SafeArea
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline)),
          boxShadow: AppElevation.softShadow,
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (item.isBarterOpen) ...[
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Tukar (Barter)',
                    icon: Icons.swap_horiz_rounded,
                    onPressed: () {
                      BarterItemSelectionSheet.show(
                        context,
                        target: BarterItem(
                          id: item.id,
                          name: item.title,
                          price: item.price,
                          category: item.category,
                          condition: item.condition,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                flex: item.isBarterOpen ? 2 : 1,
                child: AppPrimaryButton(
                  label: isGrant
                      ? 'Ajukan Klaim Hibah'
                      : 'Ajukan Pertemuan COD',
                  icon: isGrant
                      ? Icons.volunteer_activism_rounded
                      : Icons.handshake_outlined,
                  onPressed: () {
                    if (isGrant) {
                      final nim =
                          context.read<AuthViewModel>().currentUser?.nim ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              KatalogHibahScreen(currentUserNim: nim),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeetupFormScreen(
                          itemId: int.tryParse(item.id) ?? 0,
                          itemTitle: item.title,
                          itemPrice: formatRupiah(item.price),
                          itemType: 'Jual',
                          ownerId: int.tryParse(item.ownerId) ?? 0,
                          ownerName: item.ownerName.isEmpty
                              ? 'Pemilik Barang'
                              : item.ownerName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(String title, String subtitle) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
