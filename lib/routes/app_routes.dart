import 'package:flutter/material.dart';
import '../models/note_form_arguments.dart';
import '../models/product.dart';
import '../views/main_screen.dart';
import '../views/note_form_screen.dart';
import '../views/product_detail_screen.dart';
import '../views/register_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String register = '/register';
  static const String home = '/home'; // MainScreen (tab pertama = HomeScreen)
  static const String productDetail = '/product-detail';
  static const String noteForm = '/note-form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case register:
        return MaterialPageRoute<void>(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const MainScreen(),
          settings: settings,
        );
      case productDetail:
        final args = settings.arguments;
        if (args is Product) {
          return MaterialPageRoute<void>(
            builder: (_) => ProductDetailScreen(product: args),
            settings: settings,
          );
        }
        return _invalidArguments(settings);
      case noteForm:
        final args = settings.arguments;
        if (args is NoteFormArguments) {
          // Bertipe String karena mengembalikan catatan lewat Navigator.pop.
          return MaterialPageRoute<String>(
            builder: (_) => NoteFormScreen(arguments: args),
            settings: settings,
          );
        }
        return _invalidArguments(settings);
    }
    return null;
  }

  static Route<dynamic> _invalidArguments(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('Data untuk halaman ${settings.name} tidak valid'),
        ),
      ),
    );
  }
}
