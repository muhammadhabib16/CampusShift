import 'package:campusshift/viewmodels/social_grant_viewmodel.dart';
import 'package:campusshift/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Import Service Notifikasi Modul 1 (Milik Naufal)
import 'services/notification_service.dart';

// Import Services & Config dari teman-teman (Branch Dev)
import 'services/api_client.dart';
import 'services/api_config.dart';
import 'services/barter_service.dart';
import 'services/grant_claim_service.dart';
import 'services/grant_notification_service.dart';
import 'services/home_service.dart';
import 'services/social_grant_service.dart';

// Import ViewModels dari teman-teman (Branch Dev)
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/barter_view_model.dart';
import 'viewmodels/grant_claim_viewmodel.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/item_viewmodel.dart';

void main() async {
  // Wajib ditambahkan jika main() menggunakan async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal (bawaan dari import teman Anda)
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi notifikasi lokal (Modul 1)
  await NotificationService.init();

  // ApiClient bersama untuk service-service Modul 5
  final apiClient = ApiClient(
    baseUrl: ApiConfig.baseUrl,
    getToken: () => null, // Token akan di-set setelah login
  );

  // Plugin notifikasi lokal untuk Modul 5 (FR-25)
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  runApp(
    MultiProvider(
      providers: [
        // Provider untuk Modul 1 Anda
        ChangeNotifierProvider(create: (_) => ItemViewModel()),

        // Provider milik teman-teman
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => BarterViewModel(BarterService())),
        ChangeNotifierProvider(create: (_) => HomeViewModel(HomeService())),
        ChangeNotifierProvider(
          create: (_) => GrantClaimViewModel(
            GrantClaimService(apiClient),
            GrantNotificationService(notificationsPlugin),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SocialGrantViewModel(SocialGrantService(apiClient)),
        ),
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
        ),
      ),

      // === BYPASS TAMPILAN MODUL 1 ===
      // Cukup hilangkan comment (//) pada SATU halaman yang ingin di-tes,
      // dan berikan comment (//) pada halaman lainnya.
      home: const SplashScreen(),
      // home: const CatalogScreen(),
      // home: const AddListingScreen(),
      // home: const MyItemsScreen(),
    );
  }
}
