import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../theme/app_tokens.dart';

/// SnackBar terpusat CampuShift dengan 3 varian: Sukses, Error, dan Info (Section 4.3).
abstract final class AppSnackBar {
  static void showSuccess(BuildContext context, String message) {
    _showCustom(
      context,
      message: message,
      bgColor: const Color(0xFFDCFCE7),
      textColor: const Color(0xFF15803D),
      icon: Icons.check_circle_outline,
    );
  }

  static void showError(BuildContext context, String message) {
    _showCustom(
      context,
      message: message,
      bgColor: const Color(0xFFFEE2E2),
      textColor: const Color(0xFFB91C1C),
      icon: Icons.error_outline,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showCustom(
      context,
      message: message,
      bgColor: const Color(0xFFCCFBF1),
      textColor: const Color(0xFF0F766E),
      icon: Icons.info_outline,
    );
  }

  /// Kompatibilitas mundur
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (isError) {
      showError(context, message);
    } else {
      showInfo(context, message);
    }
  }

  static void _showCustom(
    BuildContext context, {
    required String message,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.medium),
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 3,
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog konfirmasi aksi destruktif terpusat (Section 4.3).
/// - Hapus: tombol merah dengan ikon tong sampah.
/// - Batal: tombol netral dengan ikon batal.
/// Keduanya menjelaskan konsekuensinya dengan jelas.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = AppStrings.confirm,
  String cancelLabel = AppStrings.cancel,
  bool destructive = false,
  IconData? confirmIcon,
}) async {
  final icon =
      confirmIcon ??
      (destructive ? Icons.delete_outline : Icons.check_circle_outline);

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.large),
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: destructive
                  ? AppColors.errorContainer
                  : AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              destructive ? Icons.warning_amber_rounded : Icons.info_outline,
              color: destructive ? AppColors.error : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.45,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(ctx).pop(false),
          icon: const Icon(Icons.close_rounded, size: 18),
          label: Text(cancelLabel),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(100, 42),
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.outline),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.medium),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(ctx).pop(true),
          icon: Icon(icon, size: 18, color: Colors.white),
          label: Text(confirmLabel),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 42),
            backgroundColor: destructive ? AppColors.error : AppColors.primary,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.medium),
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}
