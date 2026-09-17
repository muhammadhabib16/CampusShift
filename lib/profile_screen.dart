import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Mellisa Annie',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'NIM: 12022004123 • Universitas Indonesia',
                    style: TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Reputasi 4.3/5.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                      _buildStat('28', 'Transaksi'),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.grey.shade200,
                      ),
                      _buildStat('9', 'Barter\nBerhasil'),
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
                    ProfileMenuItem(icon: Icons.edit_rounded, label: 'Edit Profil', color: const Color(0xFF0D9488)),
                    ProfileMenuItem(icon: Icons.list_alt_rounded, label: 'Listing Saya', color: Colors.blue),
                    ProfileMenuItem(icon: Icons.receipt_long_rounded, label: 'Riwayat Transaksi', color: Colors.orange),
                    ProfileMenuItem(icon: Icons.swap_horiz_rounded, label: 'Barter Saya', color: Colors.purple),
                    ProfileMenuItem(icon: Icons.settings_rounded, label: 'Pengaturan', color: Colors.grey),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuGroup([
                    ProfileMenuItem(icon: Icons.help_outline_rounded, label: 'Bantuan & FAQ', color: Colors.blue),
                    ProfileMenuItem(icon: Icons.shield_outlined, label: 'Kebijakan Privasi', color: Colors.green),
                  ]),
                  const SizedBox(height: 12),
                  // Logout Button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
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
        separatorBuilder: (_, i) => Divider(
          height: 1,
          indent: 56,
          color: Colors.grey.shade100,
        ),
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
            onTap: () {},
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

  const ProfileMenuItem({required this.icon, required this.label, required this.color});
}
