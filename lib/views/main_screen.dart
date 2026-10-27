import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/meetup_repository.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/home_view_model.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'barter/barter_list_screen.dart';
import 'listing/catalog_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(onSelectTab: _selectTab),
    const CatalogScreen(),
    const BarterListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Pertemuan (Modul 2) dicatat atas nama pengguna yang login. Pada mode uji
    // tanpa server, data pengguna kosong dan nilai bawaan repository dipakai.
    final user = context.read<AuthViewModel>().currentUser;
    if (user != null) {
      MeetupRepository.setCurrentUser(
        id: int.tryParse(user.id) ?? MeetupRepository.currentUserId,
        name: user.fullName,
        nim: user.nim,
      );
    }

    // Sinkronisasi: Muat data "Barang Terbaru" dari Modul 1 (Naufal)
    // agar Home Screen menampilkan listing terkini dari ItemService.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadLatestListings();
    });
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Beranda'),
                _buildNavItem(1, Icons.grid_view_rounded, Icons.grid_view_outlined, 'Katalog'),
                _buildNavItem(2, Icons.swap_horiz_rounded, Icons.swap_horiz_outlined, 'Barter'),
                _buildNavItem(3, Icons.person_rounded, Icons.person_outlined, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _selectTab(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? const Color(0xFF0D9488) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF0D9488) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
