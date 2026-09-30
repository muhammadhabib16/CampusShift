import 'package:flutter/material.dart';
import 'safe_meet_detail_screen.dart';
import 'suggest_location_screen.dart';

class SafeMeetScreen extends StatelessWidget {
  const SafeMeetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locations = [
      _Location(
        name: 'Perpustakaan Pusat UI',
        distance: '150m',
        safety: 'Sangat Aman',
        description: 'CCTV & ramai',
        icon: Icons.local_library,
      ),
      _Location(
        name: 'Kantin Sastra FIB UI',
        distance: '320m',
        safety: 'Aman',
        description: 'Area ramai',
        icon: Icons.restaurant,
      ),
      _Location(
        name: 'Gedung Rektorat',
        distance: '450m',
        safety: 'Cukup Aman',
        description: 'Dekat penjagaan satpam',
        icon: Icons.account_balance,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Titik Temu Aman'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Guna mencegah penipuan dan menjamin keselamatan, '
                    'kami merekomendasikan melakukan transaksi COD di titik '
                    'temu berlogo perisai berikut.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...locations.map(
            (location) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SafeMeetDetailScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          location.icon,
                          color: Colors.indigo,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('📍 ${location.distance}'),
                            const SizedBox(height: 8),
                            Text(
                              '✓ ${location.safety} (${location.description})',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SuggestLocationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Usulkan Titik Temu Baru'),
          ),
        ],
      ),
    );
  }
}

class _Location {
  final String name;
  final String distance;
  final String safety;
  final String description;
  final IconData icon;

  const _Location({
    required this.name,
    required this.distance,
    required this.safety,
    required this.description,
    required this.icon,
  });
}
