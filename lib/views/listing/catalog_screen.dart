import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_strings.dart';
import '../../models/item_model.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../viewmodels/item_viewmodel.dart';
import 'add_listing_screen.dart';
import 'item_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemViewModel>(context, listen: false).fetchCatalog();
    });
  }

  void _showFilterBottomSheet(BuildContext context, ItemViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ItemViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Katalog Barang',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Filter Lanjutan',
            icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
            onPressed: () => _showFilterBottomSheet(context, viewModel),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar yang Menonjol di Atas (Section 5.2)
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari buku, kalkulator, meja…',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.pill,
                        borderSide: const BorderSide(color: AppColors.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.pill,
                        borderSide: const BorderSide(color: AppColors.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.pill,
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (val) => viewModel.updateFilter(query: val),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Chips Kategori
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children:
                    [
                      'Semua Kategori',
                      'Buku & Referensi',
                      'Elektronik & Gadget',
                      'Furnitur Kos',
                    ].map((category) {
                      final isSelected = viewModel.selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              viewModel.updateFilter(category: category);
                            }
                          },
                          selectedColor: AppColors.primaryContainer,
                          backgroundColor: AppColors.surfaceVariant,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.onPrimaryContainer
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.outline),

          // Grid View Katalog (3 Kondisi: Loading, Kosong, Error)
          Expanded(
            child: viewModel.isLoading
                ? const LoadingState(label: 'Memuat katalog barang…')
                : viewModel.errorMessage.isNotEmpty
                ? ErrorState(
                    message: viewModel.errorMessage,
                    onRetry: () => viewModel.fetchCatalog(),
                  )
                : viewModel.catalogItems.isEmpty
                ? EmptyState(
                    title: AppStrings.emptyListingTitle,
                    description: AppStrings.emptyListingDesc,
                    actionLabel: 'Pasang Listing',
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddListingScreen(),
                        ),
                      );
                    },
                  )
                : RefreshIndicator(
                    onRefresh: () => viewModel.fetchCatalog(),
                    color: AppColors.primary,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                          ),
                      itemCount: viewModel.catalogItems.length,
                      itemBuilder: (context, index) {
                        final item = viewModel.catalogItems[index];
                        return _buildItemCard(context, item);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 3,
        icon: const Icon(Icons.add_a_photo_outlined, size: 20),
        label: const Text(
          'Pasang Listing',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddListingScreen()),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, ItemModel item) {
    final isGrant = item.listingType == 'Hibah';

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: item.photoUrls.isNotEmpty
                      ? Image.network(
                          item.photoUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    item.condition,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (item.isBarterOpen)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: AppRadius.pill,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          color: AppColors.onAccent,
                          size: 12,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Barter',
                          style: TextStyle(
                            color: AppColors.onAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                PriceTag(price: item.price, isGrant: isGrant, fontSize: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 36,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// Widget Bottom Sheet Filter Sesuai PRD
class FilterBottomSheet extends StatefulWidget {
  final ItemViewModel viewModel;
  const FilterBottomSheet({super.key, required this.viewModel});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _tempType;
  late double _tempMaxPrice;

  @override
  void initState() {
    super.initState();
    _tempType = widget.viewModel.selectedType;
    _tempMaxPrice = widget.viewModel.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Pencarian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              AppTextButton(
                label: 'Reset',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  widget.viewModel.resetFilter();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.outline),
          const SizedBox(height: AppSpacing.sm),

          const Text(
            'Tipe Jalur Transaksi',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children:
                [
                  'Semua Transaksi',
                  'Jual (COD Tunai)',
                  'Hibah (Rp0 Gratis)',
                  'Terbuka Barter',
                ].map((type) {
                  final isSelected = _tempType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    selectedColor: AppColors.primaryContainer,
                    backgroundColor: AppColors.surfaceVariant,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.onPrimaryContainer
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _tempType = type);
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Batas Harga Maksimal',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Text(
                formatRupiah(_tempMaxPrice.toInt()),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Slider(
            value: _tempMaxPrice,
            min: 0,
            max: 500000,
            divisions: 50,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.outline,
            onChanged: (val) {
              setState(() => _tempMaxPrice = val);
            },
          ),
          const Text(
            'Catatan BR-02: Khusus barang tipe Hibah, harga otomatis Rp 0.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),

          AppPrimaryButton(
            label: 'Terapkan Filter',
            onPressed: () {
              widget.viewModel.updateFilter(
                type: _tempType,
                max: _tempMaxPrice,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
