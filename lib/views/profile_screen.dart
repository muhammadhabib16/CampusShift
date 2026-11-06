import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_strings.dart';
import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/handover_view_model.dart';
import '../viewmodels/item_viewmodel.dart';
import 'barter/barter_list_screen.dart';
import 'edit_profile_screen.dart';
import 'handover/handover_meetup_list_screen.dart';
import 'handover/profil_reputasi_screen.dart';
import 'handover/riwayat_transaksi_screen.dart';
import 'listing/my_items_screen.dart';
import 'login_screen.dart';
import 'safe_meet/my_meetups_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// FR-A03: ubah foto, nama, telepon, dan bio lewat `PUT /users/me`.
  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  /// FR-A04: ganti kata sandi lewat `PUT /users/me/password`.
  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final auth = context.read<AuthViewModel>();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Kata Sandi'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Kata Sandi Lama'),
                validator: (v) =>
                    (v ?? '').isEmpty ? 'Kata sandi lama wajib diisi' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Kata Sandi Baru'),
                validator: (v) =>
                    (v ?? '').length < 8 ? 'Minimal 8 karakter' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved != true || !context.mounted) return;
    final ok = await auth.changePassword(
      currentPassword: currentController.text,
      newPassword: newController.text,
    );
    if (!context.mounted) return;
    final message = auth.message ?? (ok ? 'Kata sandi diganti' : 'Gagal mengganti kata sandi');
    ok
        ? AppSnackBar.showSuccess(context, message)
        : AppSnackBar.showError(context, message);
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Keluar dari Akun',
      message:
          'Apakah kamu yakin ingin keluar? Sesi login di perangkat ini akan berakhir dan kamu harus masuk kembali.',
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
    final handoverViewModel = context.watch<HandoverViewModel>();
    final user = authViewModel.currentUser;
    final displayName = authViewModel.displayName;
    final avgRating = handoverViewModel.averageRating;
    final reviewCount = handoverViewModel.receivedReviews.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: const [NotificationBell()],
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
                    imageUrl: user?.photoUrl,
                    subtitle: 'NIM: ${user?.nim ?? '-'} • Lihat profil publik',
                    radius: 36,
                    onTap: () => openUserProfile(
                      context,
                      userId: user?.id,
                      name: displayName,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if ((user?.bio ?? '').isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        user!.bio,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _openEditProfile(context),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          user?.photoUrl == null
                              ? 'Tambah foto profil & bio'
                              : 'Tambah bio',
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: AppColors.outline),
                  const SizedBox(height: AppSpacing.md),
                  // Baris Skor Reputasi (FR-20.2 & BR-25)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfilReputasiScreen(),
                        ),
                      );
                    },
                    borderRadius: AppRadius.small,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Skor Reputasi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: RatingStars(
                              rating: avgRating,
                              reviewCount: reviewCount,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  _buildStatItem(
                    '${context.watch<ItemViewModel>().myItems.where((i) => i.status == 'Available').length}',
                    'Listing Aktif',
                  ),
                  Container(width: 1, height: 36, color: AppColors.outline),
                  _buildStatItem(
                    '${handoverViewModel.completedProofs.length}',
                    'Transaksi',
                  ),
                  Container(width: 1, height: 36, color: AppColors.outline),
                  _buildStatItem(
                    '${handoverViewModel.confirmedMeetups.length}',
                    'Meetup Aktif',
                  ),
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
                    title: 'Jadwal Pertemuan Saya',
                    subtitle: 'Ajakan pertemuan COD yang dikirim & diterima',
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
                    icon: Icons.qr_code_2_rounded,
                    title: 'Serah Terima QR',
                    subtitle: 'Tampilkan atau pindai QR saat bertemu',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HandoverMeetupListScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(indent: 56, color: AppColors.outline),
                  _buildMenuItem(
                    context,
                    icon: Icons.receipt_long_rounded,
                    title: 'Riwayat Transaksi & Bukti Digital',
                    subtitle: 'Bukti serah terima resmi & ulasan',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RiwayatTransaksiScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(indent: 56, color: AppColors.outline),
                  _buildMenuItem(
                    context,
                    icon: Icons.star_rate_rounded,
                    title: 'Profil Reputasi & Ulasan',
                    subtitle: 'Skor kepercayaan & ulasan mahasiswa',
                    color: Colors.amber.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfilReputasiScreen(),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyItemsScreen(),
                        ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BarterListScreen(),
                        ),
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
                    icon: Icons.manage_accounts_outlined,
                    title: 'Ubah Profil',
                    subtitle: 'Foto, nama, nomor telepon, dan bio',
                    color: AppColors.primary,
                    onTap: () => _openEditProfile(context),
                  ),
                  const Divider(indent: 56, color: AppColors.outline),
                  _buildMenuItem(
                    context,
                    icon: Icons.lock_reset_rounded,
                    title: 'Ganti Kata Sandi',
                    subtitle: 'Perbarui kata sandi akun',
                    color: AppColors.primary,
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  const Divider(indent: 56, color: AppColors.outline),
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
