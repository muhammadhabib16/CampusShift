import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'services/api_client.dart';
import 'services/barter_service.dart';
import 'services/grant_claim_service.dart';
import 'services/grant_notification_service.dart';
import 'services/home_service.dart';
import 'services/social_grant_service.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/barter_view_model.dart';
import 'viewmodels/grant_claim_viewmodel.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/item_viewmodel.dart';
import 'viewmodels/social_grant_viewmodel.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Format tanggal Indonesia untuk jadwal pertemuan (Modul 2).
  await initializeDateFormatting('id_ID', null);
  runApp(
    // ViewModel didaftarkan di atas MaterialApp agar dapat diakses semua layar.
    // Modul lain menambahkan ViewModel-nya di daftar ini.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel(HomeService())..loadLatestListings()),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
        ChangeNotifierProvider(create: (_) => BarterViewModel(BarterService())..loadInitialData()),
        // Modul 5 (Hibah): token diambil dari AuthViewModel saat request dikirim.
        ChangeNotifierProvider(
          create: (context) => SocialGrantViewModel(SocialGrantService(_apiClient(context))),
        ),
        ChangeNotifierProvider(
          create: (context) => GrantClaimViewModel(
            GrantClaimService(_apiClient(context)),
            GrantNotificationService(FlutterLocalNotificationsPlugin()),
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

/// Klien HTTP Modul 5. Host mengikuti AuthService (emulator Android: 10.0.2.2).
ApiClient _apiClient(BuildContext context) {
  return ApiClient(
    baseUrl: kIsWeb ? 'http://127.0.0.1:5000/api' : 'http://10.0.2.2:5000/api',
    getToken: () => context.read<AuthViewModel>().token,
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
      home: const SplashScreen(),
    );
  }
}
