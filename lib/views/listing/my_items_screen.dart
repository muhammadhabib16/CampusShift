import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_strings.dart';
import '../../models/item_model.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../viewmodels/item_viewmodel.dart';
import 'add_listing_screen.dart';
import 'edit_listing_screen.dart';
import 'item_detail_screen.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemViewModel>().fetchMyItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleChangeStatus(
    ItemModel item,
    String targetStatus,
  ) async {
    final viewModel = context.read<ItemViewModel>();
    final success = await viewModel.changeItemStatus(item.id, targetStatus);
    if (!mounted) return;

    if (success) {
      AppSnackBar.showSuccess(
        context,
        targetStatus == 'Archived'
            ? 'Listing berhasil diarsipkan.'
            : 'Listing berhasil diaktifkan kembali.',
      );
    } else {
      AppSnackBar.showError(
        context,
        viewModel.errorMessage.isNotEmpty
            ? viewModel.errorMessage
            : 'Gagal mengubah status listing.',
      );
    }
  }

  Future<void> _handleDelete(ItemModel item) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Listing Permanen?',
      message:
          'Listing "${item.title}" akan dihapus secara permanen dan tidak dapat dikembalikan.',
      confirmLabel: 'Ya, Hapus',
      cancelLabel: AppStrings.cancel,
      destructive: true,
      confirmIcon: Icons.delete_outline,
    );

    if (!confirmed || !mounted) return;

    final viewModel = context.read<ItemViewModel>();
    final success = await viewModel.deleteMyItem(item.id);
    if (!mounted) return;

    if (success) {
      AppSnackBar.showSuccess(context, 'Listing berhasil dihapus.');
    } else {
      AppSnackBar.showError(
        context,
        viewModel.errorMessage.isNotEmpty
            ? viewModel.errorMessage
            : 'Gagal menghapus listing.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ItemViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Barang Saya',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          isScrollable: true,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Tersedia'),
            Tab(text: 'Dipesan'),
            Tab(text: 'Diarsipkan'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: viewModel.isLoading
          ? const LoadingState(label: 'Memuat daftar barang Anda…')
          : viewModel.errorMessage.isNotEmpty && viewModel.myItems.isEmpty
          ? ErrorState(
              message: viewModel.errorMessage,
              onRetry: viewModel.fetchMyItems,
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildItemList(
                  viewModel.myItems
                      .where((item) => item.status == 'Available')
                      .toList(),
                ),
                _buildItemList(
                  viewModel.myItems
                      .where((item) => item.status == 'Reserved')
                      .toList(),
                ),
                _buildItemList(
                  viewModel.myItems
                      .where((item) => item.status == 'Archived')
                      .toList(),
                ),
                _buildItemList(
                  viewModel.myItems
                      .where((item) => item.status == 'Completed')
                      .toList(),
                ),
              ],
            ),
    );
  }

  Widget _buildItemList(List<ItemModel> items) {
    if (items.isEmpty) {
      return EmptyState(
        title: 'Belum Ada Barang di Kategori Ini',
        description:
            'Pasang listing barang kuliah atau kos yang sudah tidak terpakai agar bermanfaat bagi rekan mahasiswa.',
        actionLabel: 'Pasang Listing',
        onAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddListingScreen()),
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ItemViewModel>().fetchMyItems(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => _buildItemCard(context, items[index]),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, ItemModel item) {
    // Aturan BR-04: Edit dan Hapus hanya boleh jika statusnya Available atau Archived
    final canEditOrDelete =
        item.status == 'Available' || item.status == 'Archived';
    final isGrant = item.listingType == 'Hibah';

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.small,
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: item.photoUrls.isNotEmpty
                        ? Image.network(
                            item.photoUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              item.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          StatusBadge(status: item.status, compact: true),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      PriceTag(
                        price: item.price,
                        isGrant: isGrant,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Render Row Aksi hanya jika barang BUKAN berstatus Reserved atau Completed (Sesuai BR-04)
          if (canEditOrDelete) ...[
            const Divider(height: 1, color: AppColors.outline),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => _handleDelete(item),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 16,
                    ),
                    label: const Text(
                      'Hapus',
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
                  if (item.status == 'Available')
                    TextButton.icon(
                      onPressed: () => _handleChangeStatus(item, 'Archived'),
                      icon: const Icon(
                        Icons.archive_outlined,
                        color: AppColors.warning,
                        size: 16,
                      ),
                      label: const Text(
                        'Arsipkan',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else if (item.status == 'Archived')
                    TextButton.icon(
                      onPressed: () => _handleChangeStatus(item, 'Available'),
                      icon: const Icon(
                        Icons.unarchive_outlined,
                        color: AppColors.success,
                        size: 16,
                      ),
                      label: const Text(
                        'Aktifkan',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditListingScreen(item: item),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    label: const Text(
                      'Edit',
                      style: TextStyle(color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Divider(height: 1, color: AppColors.outline),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: Text(
                  item.status == 'Reserved'
                      ? 'Barang sedang dalam kesepakatan (Tidak dapat diubah/dihapus)'
                      : 'Transaksi telah selesai (Riwayat dikunci)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
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
          size: 32,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
