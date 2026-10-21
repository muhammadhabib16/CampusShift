import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/handover_view_model.dart';
import 'handover/handover_meetup_list_screen.dart';
import 'handover/profil_reputasi_screen.dart';
import 'handover/riwayat_transaksi_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final handoverViewModel = context.watch<HandoverViewModel>();
    final user = authViewModel.currentUser;

    final avgRating = handoverViewModel.averageRating;
    final reviewCount = handoverViewModel.receivedReviews.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 56,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authViewModel.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIM: ${user?.nim ?? '-'} • Universitas Andalas',
                    style: const TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                  const SizedBox(height: 10),

                  // Reputasi Dinamis (FR-20.2 & BR-25)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilReputasiScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            reviewCount == 0
                                ? 'Belum ada ulasan'
                                : 'Reputasi ${avgRating.toStringAsFixed(1)}/5.0 ($reviewCount ulasan)',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFFB45309),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB45309), size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat('14', 'Barang\nDijual'),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.grey.shade200,
                      ),
                      _buildStat(
                        '${handoverViewModel.completedProofs.length}',
                        'Transaksi\nSelesai',
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.grey.shade200,
                      ),
                      _buildStat(
                        '${handoverViewModel.confirmedMeetups.length}',
                        'Meetup\nAktif',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMenuGroup([
                    ProfileMenuItem(
                      icon: Icons.qr_code_2_rounded,
                      label: 'Serah Terima QR (Meetup COD)',
                      color: const Color(0xFF0D9488),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HandoverMeetupListScreen()),
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'Riwayat Transaksi & Bukti Digital',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RiwayatTransaksiScreen()),
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.star_rate_rounded,
                      label: 'Profil Reputasi & Ulasan',
                      color: Colors.amber.shade700,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfilReputasiScreen()),
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.edit_rounded,
                      label: 'Edit Profil',
                      color: const Color(0xFF0D9488),
                    ),
                    ProfileMenuItem(
                      icon: Icons.list_alt_rounded,
                      label: 'Listing Saya',
                      color: Colors.blue,
                    ),
                    ProfileMenuItem(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Barter Saya',
                      color: Colors.purple,
                    ),
                    ProfileMenuItem(
                      icon: Icons.settings_rounded,
                      label: 'Pengaturan',
                      color: Colors.grey,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuGroup([
                    ProfileMenuItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Bantuan & FAQ',
                      color: Colors.blue,
                    ),
                    ProfileMenuItem(
                      icon: Icons.shield_outlined,
                      label: 'Kebijakan Privasi',
                      color: Colors.green,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Logout Button
                  GestureDetector(
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      await context.read<AuthViewModel>().logout();
                      navigator.pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Keluar',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D9488),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _buildMenuGroup(List<ProfileMenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        separatorBuilder: (_, i) =>
            Divider(height: 1, indent: 56, color: Colors.grey.shade100),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 20, color: item.color),
            ),
            title: Text(
              item.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black26,
              size: 20,
            ),
            onTap: item.onTap,
          );
        },
      ),
    );
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}