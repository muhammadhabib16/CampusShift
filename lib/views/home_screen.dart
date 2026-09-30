import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../widgets/state_views.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemRepository _repository = ItemRepository();

  List<Item> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _repository.fetchItems();

      if (!mounted) return;

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // =========================
            // APP BAR
            // =========================
            SliverToBoxAdapter(
              child: _buildAppBar(),
            ),

            // =========================
            // QUICK ACTIONS
            // =========================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildQuickActions(),
              ),
            ),

            // =========================
            // BARANG TERBARU TITLE
            // =========================
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

            // =========================
            // PRODUCT STATE
            // =========================
            _buildProductState(),

            // =========================
            // KATEGORI POPULER
            // =========================
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
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                delegate: SliverChildListDelegate([
                  _buildCategoryCard(
                    Icons.menu_book_rounded,
                    'Buku & Referensi',
                    Colors.blue.shade50,
                    Colors.blue,
                  ),
                  _buildCategoryCard(
                    Icons.weekend_rounded,
                    'Furnitur Kos',
                    Colors.orange.shade50,
                    Colors.orange,
                  ),
                  _buildCategoryCard(
                    Icons.devices_other_rounded,
                    'Elektronik',
                    Colors.purple.shade50,
                    Colors.purple,
                  ),
                  _buildCategoryCard(
                    Icons.construction_rounded,
                    'Alat Kuliah',
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

  // =========================================================
  // PRODUCT STATE
  // =========================================================

  Widget _buildProductState() {
    // =========================
    // LOADING
    // =========================
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 220,
          child: LoadingView(),
        ),
      );
    }

    // =========================
    // ERROR
    // =========================
    if (_errorMessage != null) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 220,
          child: ErrorView(
            message: _errorMessage!,
            onRetry: _loadItems,
          ),
        ),
      );
    }

    // =========================
    // EMPTY
    // =========================
    if (_items.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 220,
          child: EmptyView(
            message: 'Belum ada data barang.',
          ),
        ),
      );
    }

    // =========================
    // SUCCESS
    // =========================
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            4,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return _buildProductCard(_items[index]);
          },
        ),
      ),
    );
  }

  // =========================================================
  // APP BAR
  // =========================================================

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16,
      ),
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
            icon: const Icon(
              Icons.search_rounded,
              color: Colors.black54,
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black54,
                ),
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

  // =========================================================
  // QUICK ACTIONS
  // =========================================================

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
                backgroundColor:
                    const Color(0xFF0D9488).withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF0D9488),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Halo, Mahasiswa SALUD!',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
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

  // =========================================================
  // QUICK ACTION ITEM
  // =========================================================

  Widget _buildQuickActionItem(
    IconData icon,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: color,
            size: 26,
          ),
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

  // =========================================================
  // PRODUCT CARD
  // =========================================================

  Widget _buildProductCard(Item item) {
    IconData icon = Icons.inventory_2_rounded;
    Color color = Colors.teal.shade100;

    if (item.subtitle.toLowerCase().contains('buku')) {
      icon = Icons.menu_book_rounded;
      color = Colors.blue.shade100;
    } else if (item.subtitle.toLowerCase().contains('elektronik')) {
      icon = Icons.devices_other_rounded;
      color = Colors.purple.shade100;
    } else if (item.subtitle.toLowerCase().contains('furnitur')) {
      icon = Icons.chair_rounded;
      color = Colors.orange.shade100;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail',
          arguments: item,
        );
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
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
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
                    item.title,
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
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'GRATIS',
                    style: TextStyle(
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

  // =========================================================
  // CATEGORY CARD
  // =========================================================

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

          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),

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