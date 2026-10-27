import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/item_model.dart';
import '../../viewmodels/item_viewmodel.dart';
import 'add_listing_screen.dart';
import 'item_detail_screen.dart';
import 'my_items_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Katalog Barang',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Tombol Barang Saya — sinkron dengan Profile "Listing Saya"
          IconButton(
            tooltip: 'Barang Saya',
            icon: const Icon(Icons.inventory_2_outlined, color: Color(0xFF0D9488)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyItemsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filter Icon
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari buku, kalkulator, meja...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (val) => viewModel.updateFilter(query: val),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.tune, color: Color(0xFF0D9488)),
                  onPressed: () => _showFilterBottomSheet(context, viewModel),
                ),
              ],
            ),
          ),

          // Horizontal Chips Kategori
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children:
                  [
                        'Semua Kategori',
                        'Buku & Referensi',
                        'Elektronik & Gadget',
                        'Furnitur Kos',
                        'Alat Perkuliahan',
                      ]
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: viewModel.selectedCategory == category,
                            onSelected: (selected) {
                              if (selected) {
                                viewModel.updateFilter(category: category);
                              }
                            },
                            selectedColor: const Color(0xFF0D9488)
                                .withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: viewModel.selectedCategory == category
                                  ? const Color(0xFF0D9488)
                                  : Colors.black,
                              fontWeight: viewModel.selectedCategory == category
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Grid View Katalog
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage.isNotEmpty
                ? Center(child: Text(viewModel.errorMessage))
                : RefreshIndicator(
                    onRefresh: () => viewModel.fetchCatalog(),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
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
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text(
          'Pasang Listing',
          style: TextStyle(color: Colors.white),
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  item.photoUrls.isNotEmpty
                      ? item.photoUrls.first
                      : 'https://via.placeholder.com/150',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.condition,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.swap_horiz, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Barter',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Bottom Sheet Filter Sesuai Figma
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Pencarian',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {
                  widget.viewModel.resetFilter();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.refresh, color: Color(0xFF0D9488)),
                label: const Text(
                  'Reset',
                  style: TextStyle(color: Color(0xFF0D9488)),
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Tipe Jalur Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
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
                    selectedColor: const Color(0xFF0D9488),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _tempType = type);
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Rentang Harga Mahasiswa',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Slider(
            value: _tempMaxPrice,
            min: 0,
            max: 500000,
            divisions: 50,
            activeColor: const Color(0xFF0D9488),
            label:
                'Maks Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(_tempMaxPrice)}',
            onChanged: (val) {
              setState(() => _tempMaxPrice = val);
            },
          ),
          const Text(
            'Aturan BR-02: Khusus barang tipe Hibah, harga otomatis Rp 0.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                widget.viewModel.updateFilter(
                  type: _tempType,
                  max: _tempMaxPrice,
                );
                Navigator.pop(context);
              },
              child: const Text(
                'Terapkan Filter',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
