import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/listing_summary.dart';
import '../utils/formatters.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/home_view_model.dart';
import 'barter/widgets/barter_item_selection_sheet.dart';

/// Tampilan tiap kategori (PRD FR-01). Dipakai kartu kategori dan kartu barang.
class _CategoryStyle {
  final String label;
  final IconData icon;
  final MaterialColor color;
  const _CategoryStyle(this.label, this.icon, this.color);
}

const Map<String, _CategoryStyle> _categoryStyles = {
  'Buku & Referensi': _CategoryStyle('Buku & Refere..', Icons.menu_book_rounded, Colors.blue),
  'Furnitur Kos': _CategoryStyle('Furnitur Kos', Icons.weekend_rounded, Colors.orange),
  'Elektronik': _CategoryStyle('Elektronik', Icons.devices_other_rounded, Colors.purple),
  'Alat Perkuliahan': _CategoryStyle('Alat Kuliah', Icons.construction_rounded, Colors.green),
};

const _defaultCategoryStyle = _CategoryStyle('Lainnya', Icons.inventory_2_outlined, Colors.grey);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();
    final listings = homeViewModel.latestListings;
    final displayName = context.watch<AuthViewModel>().displayName;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(child: _buildAppBar()),
            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildQuickActions(displayName),
              ),
            ),
            // Barang Terbaru
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Barang Terbaru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Color(0xFF0D9488),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Product List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 252,
                child: homeViewModel.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                      )
                    : homeViewModel.errorMessage != null
                        ? Center(child: Text(homeViewModel.errorMessage!))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: const Text(
                  'Kategori Populer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                delegate: SliverChildListDelegate([
                  for (final style in _categoryStyles.values)
                    _buildCategoryCard(
                      style.icon,
                      style.label,
                      style.color.shade50,
                      style.color,
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.recycling,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'CampuShift',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D9488),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, color: Colors.black54),
          ),
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.black54),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D9488),
                      shape: BoxShape.circle,
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

  Widget _buildQuickActions(String displayName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF0D9488),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Halo, Mahasiswa Unand!',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                Icons.sell_rounded,
                'Jual',
                const Color(0xFF0D9488),
              ),
              _buildQuickActionItem(
                Icons.swap_horiz_rounded,
                'Barter',
                Colors.orange,
              ),
              _buildQuickActionItem(
                Icons.favorite_rounded,
                'Donasi',
                Colors.pink,
              ),
              _buildQuickActionItem(
                Icons.location_on_rounded,
                'Peta',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, ListingSummary listing) {
    final style = _categoryStyles[listing.category] ?? _defaultCategoryStyle;
    return GestureDetector(
      onTap: () {
        BarterItemSelectionSheet.show(context);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: style.color.shade100,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  style.icon,
                  size: 48,
                  color: Colors.black38,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.faculty,
                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(listing.price),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488),
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

  Widget _buildCategoryCard(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: iconColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
