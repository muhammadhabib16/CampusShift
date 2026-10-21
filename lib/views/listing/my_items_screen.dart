import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/item_model.dart';
import '../../viewmodels/item_viewmodel.dart';
import 'edit_listing_screen.dart'; // Import layar edit

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
      Provider.of<ItemViewModel>(context, listen: false).fetchMyItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ItemViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Barang Saya',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0D9488),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0D9488),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Tersedia'),
            Tab(text: 'Dipesan'),
            Tab(text: 'Diarsipkan'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
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
      return const Center(
        child: Text(
          'Belum ada barang di kategori ini.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(context, items[index]);
      },
    );
  }

  Widget _buildItemCard(BuildContext context, ItemModel item) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final viewModel = Provider.of<ItemViewModel>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              Image.network(
                item.photoUrls.isNotEmpty
                    ? item.photoUrls.first
                    : 'https://via.placeholder.com/150',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.listingType == 'Hibah'
                            ? 'Hibah Gratis'
                            : currencyFormatter.format(item.price),
                        style: const TextStyle(
                          color: Color(0xFF0D9488),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      _showDeleteDialog(context, viewModel, item.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  label: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
                if (item.status == 'Available')
                  TextButton.icon(
                    onPressed: () {
                      viewModel.changeItemStatus(item.id, 'Archived');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Listing diarsipkan.')),
                      );
                    },
                    icon: const Icon(
                      Icons.archive_outlined,
                      color: Colors.orange,
                      size: 16,
                    ),
                    label: const Text(
                      'Arsipkan',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  )
                else if (item.status == 'Archived')
                  TextButton.icon(
                    onPressed: () {
                      viewModel.changeItemStatus(item.id, 'Available');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Listing diaktifkan kembali.'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.unarchive_outlined,
                      color: Colors.green,
                      size: 16,
                    ),
                    label: const Text(
                      'Aktifkan',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                if (item.status != 'Completed')
                  TextButton.icon(
                    onPressed: () {
                      // Navigasi ke Halaman Edit dengan membawa data barang saat ini
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditListingScreen(item: item),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.blue,
                      size: 16,
                    ),
                    label: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ItemViewModel viewModel,
    String itemId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Permanen?'),
        content: const Text(
          'Listing ini akan dihapus secara permanen dan tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              viewModel.deleteMyItem(itemId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Listing berhasil dihapus.')),
              );
            },
            child: const Text(
              'Ya, Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
