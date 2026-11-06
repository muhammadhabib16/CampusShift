import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import 'category_style.dart';

/// Kartu kategori di bagian "Kategori Populer".
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.style, required this.onTap});

  final CategoryStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.outline),
          boxShadow: AppElevation.softShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: style.bgColor,
                borderRadius: AppRadius.small,
              ),
              child: Icon(style.icon, color: style.iconColor, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                style.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
