import 'package:flutter/material.dart';

class SuggestLocationScreen extends StatefulWidget {
  const SuggestLocationScreen({super.key});

  @override
  State<SuggestLocationScreen> createState() => _SuggestLocationScreenState();
}

class _SuggestLocationScreenState extends State<SuggestLocationScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  bool cctv = false;
  bool publicArea = false;
  bool security = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usulkan Titik Temu Baru')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Nama Lokasi Titik Temu',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Contoh: Selasar Perpustakaan FT UI',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Deskripsi Lokasi / Petunjuk',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Masukkan petunjuk spesifik bagi pelamar, '
                  'cth: Dekat mesin fotokopi...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Gedung / Area Terdekat',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: 'Fakultas Teknik (FT)',
            items: const [
              DropdownMenuItem(
                value: 'Fakultas Teknik (FT)',
                child: Text('Fakultas Teknik (FT)'),
              ),
              DropdownMenuItem(
                value: 'Perpustakaan Pusat UI',
                child: Text('Perpustakaan Pusat UI'),
              ),
              DropdownMenuItem(
                value: 'Gedung Rektorat',
                child: Text('Gedung Rektorat'),
              ),
            ],
            onChanged: (_) {},
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Foto Lokasi (Opsional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Unggah Foto Lokasi'),
          ),
          const SizedBox(height: 18),

          const Text(
            'Kriteria Keamanan (Minimal Pilih 1)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tercover Area CCTV Aktif Kampus'),
            value: cctv,
            onChanged: (v) => setState(() => cctv = v ?? false),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Merupakan Area Publik Ramai Mahasiswa'),
            value: publicArea,
            onChanged: (v) => setState(() => publicArea = v ?? false),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sangat Dekat dengan Pos Keamanan / Satpam'),
            value: security,
            onChanged: (v) => setState(() => security = v ?? false),
          ),
          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: (cctv || publicArea || security)
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Usulan titik temu berhasil dikirim.'),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.send),
            label: const Text('Kirim Usulan'),
          ),
        ],
      ),
    );
  }
}
