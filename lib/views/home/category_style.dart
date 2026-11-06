import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// Label, ikon, dan warna tiap kategori listing di Beranda.
class CategoryStyle {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  const CategoryStyle(this.label, this.icon, this.bgColor, this.iconColor);

  /// Gaya untuk [category]; kategori tak dikenal memakai gaya "Lainnya".
  static CategoryStyle of(String category) =>
      homeCategoryStyles[category] ?? _fallbackCategoryStyle;
}

/// Key = nilai kategori resmi (mis. "Alat Perkuliahan"); label hanya
/// untuk tampilan ("Alat Kuliah").
const Map<String, CategoryStyle> homeCategoryStyles = {
  'Buku & Referensi': CategoryStyle(
    'Buku & Referensi',
    Icons.menu_book_rounded,
    Color(0xFFEFF6FF),
    Color(0xFF1D4ED8),
  ),
  'Furnitur Kos': CategoryStyle(
    'Furnitur Kos',
    Icons.weekend_rounded,
    Color(0xFFFFFBEB),
    Color(0xFFB45309),
  ),
  'Elektronik': CategoryStyle(
    'Elektronik',
    Icons.devices_other_rounded,
    Color(0xFFF5F3FF),
    Color(0xFF6D28D9),
  ),
  'Alat Perkuliahan': CategoryStyle(
    'Alat Kuliah',
    Icons.construction_rounded,
    Color(0xFFECFDF5),
    Color(0xFF047857),
  ),
};

const _fallbackCategoryStyle = CategoryStyle(
  'Lainnya',
  Icons.inventory_2_outlined,
  AppColors.surfaceVariant,
  Color(0xFF475569),
);
