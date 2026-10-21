import os
import shutil

if not os.path.exists("lib"):
    print("❌ Error: Folder 'lib' tidak ditemukan! Taruh file ini sejajar dengan pubspec.yaml.")
    exit(1)

backup_dir = "lib_backup_racha"
if not os.path.exists(backup_dir):
    shutil.copytree("lib", backup_dir)
    print(f"✅ Backup folder 'lib' lama berhasil disimpan di '{backup_dir}/'")

files_to_write = {}

# ==============================================================================
# 1. lib/main.dart (Dengan Rute Terpusat sesuai TEAM_GUIDELINES.md Bagian 3)
# ==============================================================================
files_to_write["lib/main.dart"] = """import 'package:flutter/material.dart';
import 'views/splash_screen.dart';
import 'views/katalog_hibah_screen.dart';
import 'views/ajukan_klaim_screen.dart';
import 'views/daftar_detail_klaim_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampuShift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/katalog-hibah': (context) => const KatalogHibahScreen(),
        '/ajukan-klaim': (context) => const AjukanKlaimScreen(),
        '/kelola-klaim': (context) => const DaftarDetailKlaimScreen(),
      },
    );
  }
}
"""

# ==============================================================================
# 2. lib/views/home_screen.dart (Terintegrasi ke Modul 5 Hibah & Konteks Unand)
# ==============================================================================
files_to_write["lib/views/home_screen.dart"] = """import 'package:flutter/material.dart';
import 'katalog_hibah_screen.dart';
import 'daftar_detail_klaim_screen.dart';

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
            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildQuickActions(context),
              ),
            ),
            // Banner Pintasan Modul 5: Hibah & Klaim Berbasis Kebutuhan
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildHibahBanner(context),
              ),
            ),
            // Barang Terbaru
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Barang Terbaru di Unand',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KatalogHibahScreen()),
                        );
                      },
                      child: const Text(
                        'Lihat Katalog Hibah',
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
                height: 225,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => _buildProductCard(context, index),
                ),
              ),
            ),
            // Kategori Populer (Sesuai FR-01 PRD)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Kategori Barang (FR-01)',
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
                  _buildCategoryCard(
                    context,
                    Icons.menu_book_rounded,
                    'Buku & Referensi',
                    Colors.blue.shade50,
                    Colors.blue,
                  ),
                  _buildCategoryCard(
                    context,
                    Icons.weekend_rounded,
                    'Furnitur Kos',
                    Colors.orange.shade50,
                    Colors.orange,
                  ),
                  _buildCategoryCard(
                    context,
                    Icons.devices_other_rounded,
                    'Elektronik',
                    Colors.purple.shade50,
                    Colors.purple,
                  ),
                  _buildCategoryCard(
                    context,
                    Icons.construction_rounded,
                    'Alat Perkuliahan',
                    Colors.green.shade50,
                    Colors.green,
                  ),
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
            tooltip: 'Cari di Katalog Hibah',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KatalogHibahScreen()),
              );
            },
            icon: const Icon(Icons.search_rounded, color: Colors.black54),
          ),
          IconButton(
            tooltip: 'Status Klaim & Notifikasi (N-06)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DaftarDetailKlaimScreen()),
              );
            },
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, Mahasiswa Universitas Andalas!',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    Text(
                      'Muhammad Racha Ardiwinata',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Modul 1: Katalog Jual COD')),
                  );
                },
              ),
              _buildQuickActionItem(
                icon: Icons.swap_horiz_rounded,
                label: 'Barter',
                color: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Modul 3: Barter & Cash Top-Up')),
                  );
                },
              ),
              _buildQuickActionItem(
                icon: Icons.volunteer_activism_rounded,
                label: 'Hibah',
                color: Colors.pink,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KatalogHibahScreen()),
                  );
                },
              ),
              _buildQuickActionItem(
                icon: Icons.assignment_ind_rounded,
                label: 'Klaim Saya',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DaftarDetailKlaimScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHibahBanner(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KatalogHibahScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 34),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modul 5: Hibah & Klaim Kebutuhan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Ajukan klaim barang kuliah gratis atau kelola antrean prioritas donatur Unand.',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
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
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Buku Kalkulus Purcell Edisi 9',
        'category': 'Unand • Buku & Referensi',
        'price': 'Hibah (Rp 0)',
        'icon': Icons.menu_book_rounded,
        'color': Colors.teal.shade100,
        'isHibah': true,
      },
      {
        'name': 'Meja Belajar Lipat Kayu Kos',
        'category': 'Unand • Furnitur Kos',
        'price': 'Hibah (Rp 0)',
        'icon': Icons.table_restaurant_rounded,
        'color': Colors.orange.shade100,
        'isHibah': true,
      },
      {
        'name': 'Jas Lab Ukuran L + Kacamata',
        'category': 'Unand • Alat Perkuliahan',
        'price': 'Hibah (Rp 0)',
        'icon': Icons.science_rounded,
        'color': Colors.blue.shade100,
        'isHibah': true,
      },
      {
        'name': 'Kalkulator Saintifik Casio fx-991EX',
        'category': 'Unand • Elektronik',
        'price': 'Rp 150.000 (Barter)',
        'icon': Icons.calculate_rounded,
        'color': Colors.purple.shade100,
        'isHibah': false,
      },
      {
        'name': 'Kursi Lipat Kuliah Mahasiswa',
        'category': 'Unand • Furnitur Kos',
        'price': 'Rp 75.000',
        'icon': Icons.chair_rounded,
        'color': Colors.green.shade100,
        'isHibah': false,
      },
    ];

    final product = products[index];
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KatalogHibahScreen()),
        );
      },
      child: Container(
        width: 165,
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
              height: 105,
              decoration: BoxDecoration(
                color: product['color'] as Color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  product['icon'] as IconData,
                  size: 46,
                  color: Colors.black45,
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
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product['price'] as String,
                    style: const TextStyle(
                      fontSize: 12.5,
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
    BuildContext context,
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KatalogHibahScreen()),
        );
      },
      child: Container(
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
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: iconColor.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""

# ==============================================================================
# 3. Ambil seluruh file Modul 5 lainnya jika sudah dibuat oleh update_modul_racha.py
# ==============================================================================
for rel_path, content in files_to_write.items():
    dir_name = os.path.dirname(rel_path)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)
    with open(rel_path, "w", encoding="utf-8") as f:
        f.write(content.strip() + "\n")
    print(f"✔ Berhasil memperbarui: {rel_path}")

print("\n🎉 main.dart dan home_screen.dart sudah terhubung ke Modul 5 (Katalog Hibah & Klaim Saya)!")