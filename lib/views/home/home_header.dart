import 'package:flutter/material.dart';

import '../../core/app_tabs.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../safe_meet/my_meetups_screen.dart';

/// Baris atas Beranda: logo, pintasan jadwal, pencarian, dan notifikasi.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.small,
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CampuShift',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Universitas Andalas',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Jadwal Pertemuan Saya',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyMeetupsScreen()),
              );
            },
            icon: const Icon(
              Icons.event_note_rounded,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            tooltip: 'Cari di Katalog',
            onPressed: () => onSelectTab?.call(AppTabs.catalog),
            icon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          const NotificationBell(),
        ],
      ),
    );
  }
}
