import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'services/barter_service.dart';
import 'services/connectivity_service.dart';
import 'services/home_service.dart';
import 'services/notification_center.dart';
import 'services/notification_service.dart';
import 'services/push_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/barter_view_model.dart';
import 'viewmodels/grant_claim_viewmodel.dart';
import 'viewmodels/handover_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/item_viewmodel.dart';
import 'viewmodels/social_grant_viewmodel.dart';
import 'views/ajukan_klaim_screen.dart';
import 'views/daftar_detail_klaim_screen.dart';
import 'views/katalog_hibah_screen.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Format tanggal Indonesia untuk jadwal pertemuan (Modul 2).
  await initializeDateFormatting('id_ID', null);
  // Inisialisasi notifikasi lokal (Modul 1).
  await NotificationService.init();
  // Push notification FCM untuk event dari pengguna lain (pertemuan, barter, klaim).
  // Token perangkat didaftarkan oleh AuthViewModel setelah login/pemulihan sesi.
  await PushService.init();
  // Pantau status jaringan untuk banner offline.
  await ConnectivityService.instance.init();
  runApp(
    // ViewModel didaftarkan di atas MaterialApp agar dapat diakses semua layar.
    // Modul lain menambahkan ViewModel-nya di daftar ini.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(HomeService())..loadLatestListings(),
        ),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
        ChangeNotifierProvider(
          create: (_) => HandoverViewModel()..loadInitialData(),
        ),
        ChangeNotifierProvider(
          create: (_) => BarterViewModel(BarterService())..loadInitialData(),
        ),
        // Modul 5 (Hibah & Klaim)
        ChangeNotifierProvider(create: (_) => SocialGrantViewModel()),
        ChangeNotifierProvider(create: (_) => GrantClaimViewModel()),
        // Kotak masuk notifikasi (ikon lonceng di app bar)
        ChangeNotifierProvider(create: (_) => NotificationCenter()),
        // Status koneksi (banner offline). Singleton, jadi pakai .value.
        ChangeNotifierProvider.value(value: ConnectivityService.instance),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampuShift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
      routes: {
        '/katalog-hibah': (context) => const KatalogHibahScreen(),
        '/ajukan-klaim': (context) => const AjukanKlaimScreen(),
        '/kelola-klaim': (context) => const DaftarDetailKlaimScreen(),
      },
    );
  }
}
