import 'package:flutter/material.dart';
import 'safe_meet/meetup_form_screen.dart';
import 'safe_meet/my_meetups_screen.dart';
import 'safe_meet/safe_meet_directory_screen.dart';

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
              child: _buildAppBar(context),
            ),
            // Banner Modul 2 Safe-Meet Point Highlight
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildSafeMeetBanner(context),
              ),
            ),
            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildQuickActions(context),
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
            // Product List (Bisa di-tap untuk Ajukan Pertemuan COD)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 230,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => _buildProductCard(context, index),
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

  Widget _buildAppBar(BuildContext context) {
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
          // Tombol Shortcut Langsung ke Pertemuan Saya
          IconButton(
            tooltip: 'Jadwal Pertemuan Saya',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyMeetupsScreen()),
              );
            },
            icon: const Icon(Icons.event_note_rounded, color: Color(0xFF0D9488)),
          ),
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

  // Banner Modul 2 Safe-Meet Point Highlight
  Widget _buildSafeMeetBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Modul 2 • Safe-Meet Point',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.verified_user_rounded, color: Colors.white70, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Transaksi COD Aman di Kampus',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gunakan titik temu resmi (pos satpam, perpus, rektorat) yang terpantau CCTV & aman.',
            style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SafeMeetDirectoryScreen()),
                  );
                },
                icon: const Icon(Icons.map_rounded, size: 16, color: Color(0xFF0D9488)),
                label: const Text(
                  'Buka Peta Titik Temu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0D9488)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyMeetupsScreen()),
                  );
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white),
                label: const Text(
                  'Jadwal Saya',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
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
                    'Halo, Mahasiswa!',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  Text(
                    'Bayu Mutawakkil',
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
              _buildQuickActionItem(
                icon: Icons.sell_rounded,
                label: 'Jual',
                color: const Color(0xFF0D9488),
                onTap: () {},
              ),
              _buildQuickActionItem(
                icon: Icons.swap_horiz_rounded,
                label: 'Barter',
                color: Colors.orange,
                onTap: () {},
              ),
              _buildQuickActionItem(
                icon: Icons.shield_rounded,
                label: 'Titik Temu',
                color: Colors.teal.shade700,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SafeMeetDirectoryScreen()),
                  );
                },
              ),
              _buildQuickActionItem(
                icon: Icons.event_available_rounded,
                label: 'Jadwal Temu',
                color: Colors.blue.shade700,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyMeetupsScreen()),
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
      borderRadius: BorderRadius.circular(14),
      child: Column(
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
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    final List<Map<String, dynamic>> products = [
      {
        'id': 1,
        'name': 'Buku Kalkulus Purcell Ed. 9',
        'category': 'Akademik • Matematika',
        'price': 'Rp 85.000',
        'owner': 'Muhammad Racha',
        'ownerId': 2,
        'icon': Icons.menu_book_rounded,
        'color': Colors.blue.shade100,
      },
      {
        'id': 2,
        'name': 'Laptop Stand Adjustable',
        'category': 'Elektronik • Alat Kuliah',
        'price': 'Rp 120.000',
        'owner': 'Fadel Muhammad',
        'ownerId': 3,
        'icon': Icons.laptop_mac_rounded,
        'color': Colors.purple.shade100,
      },
      {
        'id': 3,
        'name': 'Kursi Lipat Kuliah',
        'category': 'Furnitur Kos',
        'price': 'Rp 75.000',
        'owner': 'Muhammad Habib',
        'ownerId': 4,
        'icon': Icons.chair_rounded,
        'color': Colors.orange.shade100,
      },
      {
        'id': 4,
        'name': 'Headphone Sony WH-1000',
        'category': 'Elektronik',
        'price': 'Rp 350.000',
        'owner': 'Ahmad Zaky',
        'ownerId': 5,
        'icon': Icons.headphones_rounded,
        'color': Colors.green.shade100,
      },
      {
        'id': 5,
        'name': 'Kamus Bahasa Inggris Oxford',
        'category': 'Buku & Referensi',
        'price': 'Rp 45.000',
        'owner': 'Rafi Pratama',
        'ownerId': 6,
        'icon': Icons.library_books_rounded,
        'color': Colors.red.shade100,
      },
    ];

    final product = products[index];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Tampilkan Dialog Detail Barang & Tombol Ajukan Pertemuan COD (FR-07.1)
        _showProductDetailModal(context, product);
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
      ),
    );
  }

  void _showProductDetailModal(BuildContext context, Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: product['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(product['icon'] as IconData, size: 28, color: Colors.black45),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] as String,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          product['price'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Penjual: ${product['owner']} • Kategori: ${product['category']}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Divider(height: 24),
              const Text(
                'Ingin membeli barang ini secara COD di tempat yang aman?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Alur FR-07.1: Ajukan Pertemuan langsung dari detail barang
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MeetupFormScreen(
                          itemId: product['id'] as int,
                          itemTitle: product['name'] as String,
                          itemPrice: product['price'] as String,
                          itemType: 'Jual',
                          ownerId: product['ownerId'] as int,
                          ownerName: product['owner'] as String,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                  label: const Text(
                    'Ajukan Pertemuan COD di Safe-Meet Point',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(IconData icon, String label, Color bgColor, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
