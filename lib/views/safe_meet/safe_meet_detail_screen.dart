import 'package:flutter/material.dart';
import 'schedule_meet_screen.dart';

class SafeMeetDetailScreen extends StatelessWidget {
  const SafeMeetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Titik Temu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Icon(Icons.photo_camera_back_outlined, size: 60),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Perpustakaan Pusat UI',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gedung Crystal of Knowledge, Kampus UI Depok, '
            'Pondok Cina, Beji, Kota Depok.',
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.location_on_outlined,
            title: 'Jarak',
            value: '450m dari posisimu (Haversine Precision)',
          ),
          const SizedBox(height: 18),
          const Text(
            'Foto Titik Temu / Patokan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('FOTO TITIK TEMU / PATOKAN'),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Fitur Keamanan / Kondisi Lokasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const _SafetyItem('Kamera CCTV 24 Jam aktif memonitor area'),
          const _SafetyItem('Dekat dengan Pos Penjagaan Satpam PLK UI'),
          const _SafetyItem('Area terbuka sangat ramai oleh lalu lalang mahasiswa'),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.map_outlined),
            label: const Text('Gunakan Titik Ini di Google Maps'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScheduleMeetScreen(),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('Jadwalkan Pertemuan'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: '$title\n',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SafetyItem extends StatelessWidget {
  final String text;

  const _SafetyItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
