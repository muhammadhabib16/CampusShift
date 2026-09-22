import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: _buildAppBar(),
            ),
            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildQuickActions(),
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
                height: 220,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => _buildProductCard(index),
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
                  _buildCategoryCard(Icons.menu_book_rounded, 'Buku & Refere..', Colors.blue.shade50, Colors.blue),
                  _buildCategoryCard(Icons.weekend_rounded, 'Furnitur Kos', Colors.orange.shade50, Colors.orange),
                  _buildCategoryCard(Icons.devices_other_rounded, 'Elektronik', Colors.purple.shade50, Colors.purple),
                  _buildCategoryCard(Icons.construction_rounded, 'Alat Kuliah', Colors.green.shade50, Colors.green),
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
                child: const Icon(Icons.recycling, color: Colors.white, size: 20),
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

  Widget _buildQuickActions() {
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
                child: const Icon(Icons.person, color: Color(0xFF0D9488), size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Halo, Mahasiswa SALUD!',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  Text(
                    'Mellisa Annie',
                    style: TextStyle(
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
              _buildQuickActionItem(Icons.sell_rounded, 'Jual', const Color(0xFF0D9488)),
              _buildQuickActionItem(Icons.swap_horiz_rounded, 'Barter', Colors.orange),
              _buildQuickActionItem(Icons.favorite_rounded, 'Donasi', Colors.pink),
              _buildQuickActionItem(Icons.location_on_rounded, 'Peta', Colors.blue),
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
          style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildProductCard(int index) {
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Buku Kalkulus Purcheti Ed. 9',
        'category': 'UI • Matematika Pusat',
        'price': 'Rp 85.000',
        'icon': Icons.menu_book_rounded,
        'color': Colors.blue.shade100,
      },
      {
        'name': 'Laptop Stand Adjustable',
        'category': 'ITB • Teknik Mesin',
        'price': 'Rp 120.000',
        'icon': Icons.laptop_mac_rounded,
        'color': Colors.purple.shade100,
      },
      {
        'name': 'Kursi Lipat Kuliah',
        'category': 'UGM • FISIPOL',
        'price': 'Rp 75.000',
        'icon': Icons.chair_rounded,
        'color': Colors.orange.shade100,
      },
      {
        'name': 'Headphone Sony WH-1000',
        'category': 'UI • Teknik Elektro',
        'price': 'Rp 350.000',
        'icon': Icons.headphones_rounded,
        'color': Colors.green.shade100,
      },
      {
        'name': 'Kamus Besar Bahasa Indonesia',
        'category': 'UNAIR • FIB',
        'price': 'Rp 45.000',
        'icon': Icons.library_books_rounded,
        'color': Colors.red.shade100,
      },
    ];

    final product = products[index];
    return Container(
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
              color: product['color'] as Color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Icon(
                product['icon'] as IconData,
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
                  product['name'] as String,
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
                  product['category'] as String,
                  style: const TextStyle(fontSize: 10, color: Colors.black45),
                ),
                const SizedBox(height: 6),
                Text(
                  product['price'] as String,
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
    );
  }

  Widget _buildCategoryCard(IconData icon, String label, Color bgColor, Color iconColor) {
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
