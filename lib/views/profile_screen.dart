import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_strings.dart';
import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../viewmodels/auth_view_model.dart';
import 'login_screen.dart';
import 'safe_meet/my_meetups_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Keluar dari Akun',
      message: 'Apakah kamu yakin ingin keluar? Sesi login di perangkat ini akan berakhir dan kamu harus masuk kembali.',
      confirmLabel: 'Keluar',
      cancelLabel: AppStrings.cancel,
      destructive: true,
      confirmIcon: Icons.logout_rounded,
    );

    if (!confirmed || !context.mounted) return;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    await context.read<AuthViewModel>().logout();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.onPrimary,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Text('Berhasil keluar dari akun.'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;
    final displayName = authViewModel.displayName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          children: [
            // Kartu Identitas Profil (AvatarWithName & Reputasi)
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  AvatarWithName(
                    name: displayName,
                    subtitle: 'NIM: ${user?.nim ?? '-'} • Universitas Andalas',
                    radius: 36,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: AppColors.outline),
                  const SizedBox(height: AppSpacing.md),
                  // Baris Skor Reputasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Skor Reputasi Mahasiswa',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      RatingStars(rating: 4.8, reviewCount: 14, size: 20),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Ringkasan Aktivitas Sirkular
            AppCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('12', 'Listing Aktif'),
                  Container(width: 1, height: 36, color: AppColors.outline),
                  _buildStatItem('28', 'Transaksi'),
                  Container(width: 1, height: 36, color: AppColors.outline),
                  _buildStatItem('9', 'Barter Sukses'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Menu Transaksi & Layanan
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.event_note_rounded,
                    title: 'Jadwal & Serah Terima QR',
                    subtitle: 'Modul 2 & 4: Pertemuan dan QR COD',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyMeetupsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(indent: 56, color: AppColors.outline),
                  _buildMenuItem(
                    context,
                    icon: Icons.inventory_2_outlined,
                    title: 'Barang Saya (Listing)',
                    subtitle: 'Kelola barang jual, barter, dan hibah',
                    color: const Color(0xFF1D4ED8),
                    onTap: () {
                      AppSnackBar.showInfo(
                        context,
                        'Buka tab Katalog untuk mengelola listing.',
                      );
                    },
                  ),
                  const Divider(indent: 56, color: AppColors.outline),
                  _buildMenuItem(
                    context,
                    icon: Icons.swap_horiz_rounded,
                    title: 'Riwayat Tawaran Barter',
                    subtitle: 'Tawaran masuk dan keluar',
                    color: AppColors.accent,
                    onTap: () {
                      AppSnackBar.showInfo(
                        context,
                        'Buka tab Barter pada navigasi bawah.',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Menu Pengaturan & Bantuan
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Pusat Bantuan & Panduan',
                    subtitle: 'FAQ transaksi aman di kampus Unand',
                    color: AppColors.textSecondary,
                    onTap: () {
                      AppSnackBar.showInfo(
                        context,
                        'Pusat bantuan sedang disiapkan.',
                      );
                    },
                  ),
                  const Divider(indent: 56, color: AppColors.outline),
                  _buildMenuItem(
                    context,
                    icon: Icons.shield_outlined,
                    title: 'Kebijakan Privasi & Keamanan',
                    subtitle: 'Ketentuan Safe-Meet Point & Verifikasi NIM',
                    color: AppColors.success,
                    onTap: () {
                      AppSnackBar.showInfo(
                        context,
                        'Kebijakan privasi terverifikasi Unand.',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tombol Keluar (Destruktif dengan ConfirmDialog)
            AppSecondaryButton(
              label: 'Keluar dari Akun',
              icon: Icons.logout_rounded,
              isDestructive: true,
              onPressed: () => _handleLogout(context),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.medium,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}
