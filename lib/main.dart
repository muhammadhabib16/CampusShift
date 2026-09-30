import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'views/detail_screen.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';
import 'views/not_found_screen.dart';
import 'views/catatan_form_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusShift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
        ),
      ),

      initialRoute: AppRoutes.login,

      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.detail: (context) => const DetailScreen(),
        AppRoutes.catatan: (context) => const CatatanFormScreen(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
        );
      },
    );
  }
}