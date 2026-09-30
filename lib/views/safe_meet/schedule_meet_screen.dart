import 'package:flutter/material.dart';

class ScheduleMeetScreen extends StatefulWidget {
  const ScheduleMeetScreen({super.key});

  @override
  State<ScheduleMeetScreen> createState() => _ScheduleMeetScreenState();
}

class _ScheduleMeetScreenState extends State<ScheduleMeetScreen> {
  DateTime selectedDate = DateTime(2026, 1, 18);
  TimeOfDay selectedTime = const TimeOfDay(hour: 13, minute: 0);
  final noteController = TextEditingController();

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2026),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) setState(() => selectedTime = time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwalkan Pertemuan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Perpustakaan Pusat UI',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Lobby Utama lantai 1 dekat pos satpam'),
          const SizedBox(height: 24),

          const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            tileColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(
              '${selectedDate.day} ${_month(selectedDate.month)} ${selectedDate.year}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDate,
          ),

          const SizedBox(height: 16),
          const Text('Jam', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            tileColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: const Icon(Icons.access_time),
            title: Text(selectedTime.format(context)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickTime,
          ),

          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Proximity Alert'),
            subtitle: const Text(
              'Kirim notifikasi otomatis saat jarakmu < 100 meter dari lokasi',
            ),
            value: true,
            onChanged: (_) {},
          ),

          const SizedBox(height: 12),
          const Text(
            'Catatan Pertemuan (Opsional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tulis catatan untuk pembeli/penjual...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 22),
          const Text(
            'Ringkasan Transaksi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _SummaryRow('Barang', 'Meja Lipat Belajar Minimalis'),
                  _SummaryRow('Harga Pembayaran', 'Rp 120.000'),
                  _SummaryRow('Metode', 'COD Cash-On-Delivery Kampus'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jadwal pertemuan berhasil dikirim.'),
                ),
              );
            },
            child: const Text('Konfirmasi & Kirim Jadwal'),
          ),
        ],
      ),
    );
  }

  String _month(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month];
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
