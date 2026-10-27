import 'package:flutter/material.dart';

/// Palet warna terpusat CampuShift sesuai PRD v1.3 & Pedoman Desain.
abstract final class AppColors {
  static const Color primary = Color(0xFF0F766E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFCCFBF1);
  static const Color onPrimaryContainer = Color(0xFF134E4A);

  static const Color accent = Color(0xFFF59E0B);
  static const Color onAccent = Color(0xFF1C1917);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color outline = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF15803D);
  static const Color successContainer = Color(0xFFDCFCE7);
}

/// Skala jarak (spacing) terpusat CampuShift.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double base = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Skala radius sudut (border radius) terpusat CampuShift.
abstract final class AppRadius {
  static const BorderRadius small = BorderRadius.all(Radius.circular(8));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius large = BorderRadius.all(Radius.circular(16));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));

  static const double smallValue = 8.0;
  static const double mediumValue = 12.0;
  static const double largeValue = 16.0;
  static const double pillValue = 999.0;
}

/// Elevasi dan bayangan tipis konsisten (NFR-03).
abstract final class AppElevation {
  static const double card = 0;
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0F0F172A), // 6% opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

/// Durasi animasi standar (Motion section 2.5).
abstract final class AppDurations {
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration screen = Duration(milliseconds: 300);
  static const Curve inCurve = Curves.easeOutCubic;
  static const Curve outCurve = Curves.easeInCubic;
}
