import 'package:flutter/material.dart';

/// Gaya visual status terpusat (Section 2.2 PRD CampuShift).
class StatusStyle {
  const StatusStyle({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.icon,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final IconData icon;

  /// Getter kompatibilitas mundur
  Color get color => textColor;
}

/// Pemetaan terpusat status ke label, warna teks, latar, dan ikon.
abstract final class StatusStyles {
  static const StatusStyle available = StatusStyle(
    label: 'Tersedia',
    textColor: Color(0xFF15803D),
    backgroundColor: Color(0xFFDCFCE7),
    icon: Icons.check_circle_outline,
  );

  static const StatusStyle reserved = StatusStyle(
    label: 'Dalam Kesepakatan',
    textColor: Color(0xFFB45309),
    backgroundColor: Color(0xFFFEF3C7),
    icon: Icons.handshake_outlined,
  );

  static const StatusStyle completed = StatusStyle(
    label: 'Selesai',
    textColor: Color(0xFF1D4ED8),
    backgroundColor: Color(0xFFDBEAFE),
    icon: Icons.verified_outlined,
  );

  static const StatusStyle archived = StatusStyle(
    label: 'Diarsipkan',
    textColor: Color(0xFF475569),
    backgroundColor: Color(0xFFF1F5F9),
    icon: Icons.inventory_2_outlined,
  );

  static const StatusStyle cancelled = StatusStyle(
    label: 'Dibatalkan',
    textColor: Color(0xFF475569),
    backgroundColor: Color(0xFFF1F5F9),
    icon: Icons.cancel_outlined,
  );

  static const StatusStyle rejected = StatusStyle(
    label: 'Ditolak',
    textColor: Color(0xFFB91C1C),
    backgroundColor: Color(0xFFFEE2E2),
    icon: Icons.block,
  );

  static const StatusStyle pending = StatusStyle(
    label: 'Menunggu',
    textColor: Color(0xFF6D28D9),
    backgroundColor: Color(0xFFEDE9FE),
    icon: Icons.schedule,
  );

  static const StatusStyle negotiating = StatusStyle(
    label: 'Negosiasi',
    textColor: Color(0xFF6D28D9),
    backgroundColor: Color(0xFFEDE9FE),
    icon: Icons.forum_outlined,
  );

  static const StatusStyle locked = StatusStyle(
    label: 'Dikonfirmasi',
    textColor: Color(0xFF0F766E),
    backgroundColor: Color(0xFFCCFBF1),
    icon: Icons.lock_outline,
  );

  static StatusStyle of(String raw) {
    final key = raw.trim().toLowerCase();
    switch (key) {
      case 'available':
      case 'tersedia':
        return available;

      case 'reserved':
      case 'dalam kesepakatan':
        return reserved;

      case 'completed':
      case 'selesai':
        return completed;

      case 'archived':
      case 'diarsipkan':
        return archived;

      case 'cancelled':
      case 'dibatalkan':
        return cancelled;

      case 'rejected':
      case 'ditolak':
        return rejected;

      case 'pending':
      case 'diajukan':
      case 'menunggu':
        return pending;

      case 'negotiating':
      case 'negosiasi':
        return negotiating;

      case 'locked':
      case 'terkunci':
      case 'dikonfirmasi':
      case 'approved':
      case 'disetujui':
        return locked;

      default:
        return StatusStyle(
          label: raw.isEmpty ? 'Status' : raw,
          textColor: const Color(0xFF475569),
          backgroundColor: const Color(0xFFF1F5F9),
          icon: Icons.info_outline,
        );
    }
  }
}
