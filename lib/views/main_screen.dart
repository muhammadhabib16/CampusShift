import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/meetup_repository.dart';
import '../viewmodels/auth_view_model.dart';
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
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz_rounded),
            label: 'Barter',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
