import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import '../../theme/status_style.dart';
import '../../utils/formatters.dart';

/// Badge status terpusat CampuShift dengan warna teks, latar, dan ikon resmi (Section 2.2).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.compact = false});

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = StatusStyles.of(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs + 2 : AppSpacing.sm + 2,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: compact ? 12 : 14, color: style.textColor),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: style.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tag harga terpusat dengan penanda Rupiah atau badge "Gratis / Hibah" (Section 4.3).
class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.price,
    this.isGrant = false,
    this.fontSize = 15,
    this.color,
  });

  final int price;
  final bool isGrant;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (isGrant || price <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7), // Accent container
          borderRadius: AppRadius.pill,
        ),
        child: const Text(
          'Gratis (Hibah)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(
              0xFFB45309,
            ), // OnAccent / Amber dark for 4.5:1 contrast
          ),
        ),
      );
    }

    return Text(
      formatRupiah(price),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.primary,
        letterSpacing: -0.2,
      ),
    );
  }
}
