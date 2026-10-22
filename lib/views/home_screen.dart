import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/barter_item.dart';
import '../models/handover_token_model.dart';
import '../models/listing_summary.dart';
import '../models/meetup.dart';
import '../services/meetup_repository.dart';
import '../utils/formatters.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/home_view_model.dart';
import 'barter/widgets/barter_item_selection_sheet.dart';
import 'handover/serah_terima_qr_screen.dart';
import 'katalog_hibah_screen.dart';
import 'listing/add_listing_screen.dart';
import 'safe_meet/meetup_form_screen.dart';
import 'safe_meet/my_meetups_screen.dart';
import 'safe_meet/safe_meet_directory_screen.dart';

/// Indeks tab di bottom navigation MainScreen.
const int katalogTabIndex = 1;
const int barterTabIndex = 2;

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
  const HomeScreen({super.key, this.onSelectTab});

  /// Berpindah tab di MainScreen (misalnya ke Katalog atau Barter).
  final ValueChanged<int>? onSelectTab;

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
            SliverToBoxAdapter(child: _buildAppBar(context)),
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
                child: _buildQuickActions(context, displayName),
              ),
            ),
            // Banner Pertemuan Aktif (Modul 4: Serah Terima QR)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildActiveMeetupCard(context),
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
                      onPressed: () => onSelectTab?.call(katalogTabIndex),
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
            // Product List (bisa di-tap untuk Ajukan Pertemuan COD atau Barter)
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
                child: const Icon(
                  Icons.recycling,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'CampuShift',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  Text(
                    'Universitas Andalas',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                ],
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
            tooltip: 'Cari di Katalog',
            onPressed: () => onSelectTab?.call(katalogTabIndex),
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
            'Transaksi COD Aman di Kampus Unand',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gunakan titik temu resmi Unand (pos satpam, perpus, rektorat) yang terpantau CCTV & aman.',
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

  Widget _buildQuickActions(BuildContext context, String displayName) {
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
                icon: Icons.sell_rounded,
                label: 'Jual',
                color: const Color(0xFF0D9488),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddListingScreen()),
                  );
                },
              ),
              _buildQuickActionItem(
                icon: Icons.swap_horiz_rounded,
                label: 'Barter',
                color: Colors.orange,
                onTap: () => onSelectTab?.call(barterTabIndex),
              ),
              _buildQuickActionItem(
                icon: Icons.volunteer_activism_rounded,
                label: 'Hibah',
                color: Colors.purple,
                onTap: () {
                  final nim = context.read<AuthViewModel>().currentUser?.nim ?? '';
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => KatalogHibahScreen(currentUserNim: nim),
                    ),
                  );
                },
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
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ListingSummary listing) {
    final style = _categoryStyles[listing.category] ?? _defaultCategoryStyle;
    return GestureDetector(
      onTap: () {
        // Detail singkat barang: ajukan pertemuan COD (FR-07) atau barter (FR-11)
        _showProductDetailModal(context, listing, style);
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

  void _showProductDetailModal(BuildContext context, ListingSummary listing, _CategoryStyle style) {
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
                      color: style.color.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(style.icon, size: 28, color: Colors.black45),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatRupiah(listing.price),
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
                'Penjual: ${listing.ownerName} • Kategori: ${listing.category}',
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
                          itemId: int.tryParse(listing.id) ?? 0,
                          itemTitle: listing.title,
                          itemPrice: formatRupiah(listing.price),
                          itemType: 'Jual',
                          ownerId: listing.ownerId,
                          ownerName: listing.ownerName,
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
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    BarterItemSelectionSheet.show(
                      context,
                      target: BarterItem(
                        id: listing.id,
                        name: listing.title,
                        price: listing.price,
                        category: listing.category,
                        condition: listing.condition,
                      ),
                    );
                  },
                  icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF0D9488)),
                  label: const Text(
                    'Tukar (Barter)',
                    style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0D9488)),
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

  Widget _buildCategoryCard(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
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

  /// Kartu pertemuan Dikonfirmasi terdekat (Modul 2) untuk membuka sesi QR
  /// serah terima (Modul 4). Ikut diperbarui saat data pertemuan berubah.
  Widget _buildActiveMeetupCard(BuildContext context) {
    final repository = MeetupRepository();
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final meetup = repository.getNextConfirmedMeetup();
        return _buildMeetupCardContent(context, meetup);
      },
    );
  }

  Widget _buildMeetupCardContent(BuildContext context, Meetup? meetup) {
    return Container(
      padding: const EdgeInsets.all(14),
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
                  children: [
                    Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'MODUL 4 • SERAH TERIMA QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (meetup != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Dikonfirmasi',
                    style: TextStyle(
                      color: Color(0xFF15803D),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            meetup?.itemTitle ?? 'Belum ada pertemuan terkonfirmasi',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                meetup == null ? Icons.info_outline_rounded : Icons.location_on_outlined,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  meetup == null
                      ? 'Sesi QR tersedia setelah pemilik mengonfirmasi pertemuan.'
                      : '${meetup.safeMeetPoint.name} • ${meetup.formattedShortDateTime}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => meetup == null
                        ? const MyMeetupsScreen()
                        : SerahTerimaQrScreen(
                            meetupDetail: MeetupDetailModel.fromMeetup(
                              meetup,
                              viewerId: MeetupRepository.currentUserId,
                            ),
                          ),
                  ),
                );
              },
              icon: Icon(
                meetup == null ? Icons.event_note_rounded : Icons.qr_code_rounded,
                size: 18,
              ),
              label: Text(
                meetup == null ? 'Lihat Jadwal Pertemuan Saya' : 'Buka Sesi QR Serah Terima (FR-17)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F766E),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
