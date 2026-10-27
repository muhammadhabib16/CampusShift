import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';

/// Avatar profil dengan fallback inisial di atas latar primaryContainer (Section 4.3).
class AvatarWithName extends StatelessWidget {
  const AvatarWithName({
    super.key,
    required this.name,
    this.imageUrl,
    this.subtitle,
    this.radius = 20,
    this.trailing,
    this.onTap,
  });

  final String name;
  final String? imageUrl;
  final String? subtitle;
  final double radius;
  final Widget? trailing;
  final VoidCallback? onTap;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryContainer,
      foregroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
          ? NetworkImage(imageUrl!)
          : null,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimaryContainer,
        ),
      ),
    );

    Widget content = Row(
      children: [
        avatar,
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name.isEmpty ? 'Mahasiswa Unand' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.medium,
        child: content,
      );
    }

    return content;
  }
}

/// Tampilan bintang reputasi atau input interaktif dengan skor desimal dan ulasan (Section 4.3).
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 18,
    this.interactive = false,
    this.onRatingChanged,
    this.showText = true,
  });

  final double rating;
  final int? reviewCount;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    if (interactive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starValue = index + 1.0;
          final isFilled = rating >= starValue;
          return IconButton(
            iconSize: size,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(),
            icon: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFilled ? AppColors.accent : const Color(0xFFCBD5E1),
            ),
            onPressed: () => onRatingChanged?.call(starValue),
          );
        }),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.star_rounded, color: AppColors.accent, size: size),
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            formatSkor(rating, reviewCount),
            style: TextStyle(
              fontSize: size * 0.72,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
