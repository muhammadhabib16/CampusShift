import 'package:flutter/material.dart';

/// Pemetaan data barter ke tampilan (ikon & warna). Ditempatkan di lapisan
/// View agar Model tetap bebas dari kode UI.
class BarterVisuals {
  BarterVisuals._();

  static IconData iconForCategory(String category) {
    switch (category) {
      case 'Alat Perkuliahan':
        return Icons.calculate;
      case 'Elektronik':
        return Icons.tablet_mac;
      case 'Furnitur Kos':
        return Icons.desk;
      case 'Buku & Referensi':
        return Icons.menu_book;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  static Color colorForCondition(String condition) {
    switch (condition) {
      case 'Baru':
      case 'Sangat Baik':
      case 'Baik':
        return Colors.green;
      case 'Cukup':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static Color colorForDealStatus(String status) {
    switch (status) {
      case 'Menunggu':
      case 'Negosiasi':
        return Colors.orange;
      case 'Terkunci':
        return const Color(0xFF0D9488);
      case 'Selesai':
        return Colors.green;
      case 'Ditolak':
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
