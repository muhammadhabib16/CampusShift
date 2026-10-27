import 'package:flutter/material.dart';

import '../../../theme/app_tokens.dart';
import '../../../theme/status_style.dart';

/// Pemetaan data barter ke tampilan (ikon & warna).
class BarterVisuals {
  BarterVisuals._();

  static IconData iconForCategory(String category) {
    switch (category) {
      case 'Alat Perkuliahan':
        return Icons.calculate_outlined;
      case 'Elektronik':
        return Icons.devices_other_rounded;
      case 'Furnitur Kos':
        return Icons.weekend_outlined;
      case 'Buku & Referensi':
        return Icons.menu_book_rounded;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  static Color colorForCondition(String condition) {
    switch (condition) {
      case 'Baru':
      case 'Sangat Baik':
      case 'Baik':
        return AppColors.success;
      case 'Cukup':
        return const Color(0xFFB45309);
      default:
        return AppColors.textSecondary;
    }
  }

  static Color colorForDealStatus(String status) {
    return StatusStyles.of(status).textColor;
  }
}
