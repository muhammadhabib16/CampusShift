import 'package:flutter/material.dart';
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
