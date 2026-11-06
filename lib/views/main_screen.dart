import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_tabs.dart';
import '../models/user.dart';
import '../services/connectivity_service.dart';
import '../services/meetup_repository.dart';
import '../services/notification_center.dart';
import '../shared/widgets/offline_banner.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/barter_view_model.dart';
import '../viewmodels/grant_claim_viewmodel.dart';
import '../viewmodels/handover_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/item_viewmodel.dart';
import 'barter/barter_list_screen.dart';
import 'home_screen.dart';
import 'listing/catalog_screen.dart';
import 'profile_screen.dart';

/// Kerangka utama setelah login: empat tab dengan navigasi bawah.
///
/// Tanggung jawab layar ini:
/// 1. Mengikat data pengguna yang login ke modul yang membutuhkannya.
/// 2. Memuat data awal semua tab.
/// 3. Memuat ulang data saat koneksi kembali setelah offline.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = AppTabs.home;
  NotificationCenter? _notifications;

  late final List<Widget> _screens = [
    HomeScreen(onSelectTab: _selectTab),
    const CatalogScreen(),
    const BarterListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;

    // Harus sebelum frame pertama: layar pertemuan membaca ID ini saat build.
    if (user != null) _bindMeetupUser(user);

    ConnectivityService.instance.onReconnect = _reloadAfterReconnect;

    // ViewModel memanggil notifyListeners, jadi ditunda setelah build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeViewModel>().loadLatestListings();
      if (user != null) _loadSignedInData(user);
    });
  }

  @override
  void dispose() {
    if (ConnectivityService.instance.onReconnect == _reloadAfterReconnect) {
      ConnectivityService.instance.onReconnect = null;
    }
    _notifications
      ?..stop()
      ..onSelectTab = null;
    super.dispose();
  }

  /// Pertemuan dicatat atas nama pengguna yang login. Pada mode uji tanpa
  /// server, nilai bawaan repository tetap dipakai.
  void _bindMeetupUser(User user) {
    MeetupRepository.setCurrentUser(
      id: int.tryParse(user.id) ?? MeetupRepository.currentUserId,
      name: user.fullName,
      nim: user.nim,
    );
  }

  /// Data milik pengguna. ViewModel bisa dibuat sebelum login, sehingga
  /// dimuat ulang di sini dari server.
  void _loadSignedInData(User user) {
    context.read<AuthViewModel>().refreshProfile();
    MeetupRepository().refresh();
    context.read<ItemViewModel>().fetchMyItems();
    context.read<BarterViewModel>().loadInitialData();
    context.read<HandoverViewModel>().loadInitialData(int.tryParse(user.id));
    context.read<GrantClaimViewModel>().setCurrentUser(
      userId: user.id,
      userName: user.fullName,
    );
    _notifications = context.read<NotificationCenter>()
      ..onSelectTab = _selectTab
      ..start(user.id);
  }

  void _reloadAfterReconnect() {
    if (!mounted) return;
    context.read<HomeViewModel>().loadLatestListings();
    context.read<ItemViewModel>().fetchCatalog();
    if (context.read<AuthViewModel>().currentUser == null) return;
    MeetupRepository().refresh();
    context.read<ItemViewModel>().fetchMyItems();
    context.read<BarterViewModel>().loadInitialData();
    _notifications?.refresh();
  }

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OfflineBanner(),
          NavigationBar(
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
        ],
      ),
    );
  }
}
