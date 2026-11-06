import 'package:flutter/material.dart';

import '../../core/app_tabs.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../katalog_hibah_screen.dart';
import '../listing/add_listing_screen.dart';
import '../safe_meet/safe_meet_directory_screen.dart';

/// Kartu sapaan pengguna dan pintasan Jual / Barter / Hibah / Titik Temu.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.displayName, this.onSelectTab});

  final String displayName;
  final ValueChanged<int>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryContainer,
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat datang kembali,',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                icon: Icons.sell_rounded,
                label: 'Jual',
                color: AppColors.primary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddListingScreen()),
                  );
                },
              ),
              _buildQuickActionItem(
                icon: Icons.swap_horiz_rounded,
                label: 'Barter',
                color: AppColors.accent,
                onTap: () => onSelectTab?.call(AppTabs.barter),
              ),
              _buildQuickActionItem(
                icon: Icons.volunteer_activism_rounded,
                label: 'Hibah',
                color: const Color(0xFF6D28D9),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const KatalogHibahScreen(),
                    ),
                  );
                },
              ),
              _buildQuickActionItem(
                icon: Icons.shield_rounded,
                label: 'Titik Temu',
                color: const Color(0xFF047857),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SafeMeetDirectoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppRadius.medium,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
