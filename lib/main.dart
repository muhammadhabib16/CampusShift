import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Import Service Notifikasi Modul 1
import 'services/notification_service.dart';

// Import ViewModels
import 'viewmodels/item_viewmodel.dart';

// Import Views
import 'views/listing/catalog_screen.dart'; // Wajib diimport untuk bypass

void main() async {
  // Wajib ditambahkan jika main() menggunakan async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal (bawaan dari import teman Anda)
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi notifikasi lokal (Modul 1)
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        // Provider untuk Modul 1 Anda
        ChangeNotifierProvider(create: (_) => ItemViewModel()),

        // Catatan: Jika nanti Anda ingin menguji fitur teman,
        // aktifkan provider mereka di bawah ini:
        // ChangeNotifierProvider(create: (_) => AuthViewModel()),
        // ChangeNotifierProvider(create: (_) => BarterViewModel()),
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
      // Bypass ke CatalogScreen agar bisa langsung mencoba Tambah Listing
      home: const CatalogScreen(),
    );
  }
}
