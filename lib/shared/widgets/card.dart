import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// Kartu standar CampuShift: radius 16, border outline, bayangan tipis, dan ripple effect.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.onTap,
    this.color = AppColors.surface,
    this.borderColor = AppColors.outline,
    this.borderRadius = AppRadius.large,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final BorderRadius borderRadius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding ?? EdgeInsets.zero, child: child);

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: content,
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: 1),
        boxShadow: showShadow ? AppElevation.softShadow : null,
      ),
      child: Material(color: Colors.transparent, child: content),
    );
  }
}
