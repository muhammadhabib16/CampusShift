import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/barter_service.dart';
import 'services/home_service.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/barter_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/item_viewmodel.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(
    // ViewModel didaftarkan di atas MaterialApp agar dapat diakses semua layar.
    // Modul lain menambahkan ViewModel-nya di daftar ini.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel(HomeService())..loadLatestListings()),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
        ChangeNotifierProvider(create: (_) => BarterViewModel(BarterService())..loadInitialData()),
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
      home: const SplashScreen(),
    );
  }
}
