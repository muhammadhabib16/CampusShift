import 'package:flutter/material.dart';

class BarterListScreen extends StatelessWidget {
  const BarterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Barter Saya',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Color(0xFF0D9488),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0D9488),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Dikirim'),
              Tab(text: 'Diterima'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BarterList(type: 'dikirim'),
            _BarterList(type: 'diterima'),
          ],
        ),
      ),
    );
  }
}

class _BarterList extends StatelessWidget {
  final String type;
  const _BarterList({required this.type});

  @override
  Widget build(BuildContext context) {
    // Dummy data based on the screenshot
    final List<Map<String, dynamic>> barters = [
      {
        'user_name': 'Farhan Wijaya',
        'status': 'Menunggu',
        'status_color': Colors.orange,
        'date': 'Hari ini, 10:15 WIB',
      },
      {
        'user_name': 'Sarah Amanda',
        'status': 'Diterima',
        'status_color': Colors.green,
        'date': 'Kemarin, 14:30 WIB',
      },
      {
        'user_name': 'Rian Hidayat',
        'status': 'Selesai',
        'status_color': Colors.green,
        'date': '12 Okt 2026',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: barters.length,
      separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final barter = barters[index];
        return _buildBarterItem(barter);
      },
    );
  }

  Widget _buildBarterItem(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (User & Status)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  data['user_name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Text(
              data['status'],
              style: TextStyle(
                color: data['status_color'],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Assets
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAssetIcon('Aset Kamu', Icons.watch),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.swap_horiz, color: Colors.grey.shade400, size: 20),
            ),
            _buildAssetIcon('Aset Lawan', Icons.phone_android),
          ],
        ),
        const SizedBox(height: 12),
        // Footer (Date & Detail Link)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data['date'],
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to detail
              },
              child: const Row(
                children: [
                  Text(
                    'Lihat Detail',
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: Color(0xFF0D9488)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssetIcon(String label, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey.shade600, size: 24),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
