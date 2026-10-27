import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/item_viewmodel.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];

  // Controllers & State variables
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedCategory = 'Buku & Referensi';
  String _listingType = 'Jual';
  bool _isBarterOpen = false;
  String _selectedCondition = 'Sangat Baik (Grade A)';

  final List<String> _categories = [
    'Buku & Referensi',
    'Elektronik & Gadget',
    'Furnitur Kos',
    'Alat Perkuliahan',
  ];
  final List<String> _conditions = [
    'Baru (Segel / Belum Terpakai)',
    'Sangat Baik (Grade A)',
    'Baik (Grade B)',
    'Cukup (Grade C)',
  ];

  Future<void> _takePhoto() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Maksimal 3 foto')));
      return;
    }
    // Menggunakan ImageSource.camera sesuai FR-02 & BR-03
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70, // Kompresi otomatis (BR-03)
    );
    if (photo != null) {
      setState(() {
        _images.add(File(photo.path));
      });
    }
  }

  void _submitListing() async {
    // Validasi BR-03 (Minimal 2 foto)
    if (_images.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal 2 foto harus dilampirkan.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final data = {
        'judul': _titleController.text,
        'deskripsi': _descController.text,
        'kategori': _selectedCategory,
        'tipe_listing': _listingType,
        'harga': _listingType == 'Hibah'
            ? 0
            : int.parse(_priceController.text), // BR-02
        'terbuka_untuk_barter': _listingType == 'Jual'
            ? _isBarterOpen
            : false, // BR-02
        'kondisi': _selectedCondition,
      };

      final viewModel = Provider.of<ItemViewModel>(context, listen: false);
      bool success = await viewModel.addListing(data, _images);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing berhasil dipublikasikan!')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(viewModel.errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Listing Barang')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sesuai desain Figma: Foto Kondisi Fisik
            const Text(
              'Foto Kondisi Fisik',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              'Khusus Kamera Langsung In-App. Minimal 2, Maksimal 3.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ..._images.map(
                  (file) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _images.remove(file)),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_images.length < 3)
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0D9488)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Color(0xFF0D9488)),
                          Text(
                            'Foto',
                            style: TextStyle(
                              color: Color(0xFF0D9488),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Sesuai desain Figma: Identitas & Kategori
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Listing *',
                border: OutlineInputBorder(),
              ),
              maxLength: 80,
              validator: (value) => value!.length < 5
                  ? 'Minimal 5 karakter (BR-01)'
                  : null, // Validasi BR-01
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori Perlengkapan *',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 24),

            // Sesuai desain Figma: Tipe Transaksi & Nominal
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Jual (COD Tunai)'),
                    value: 'Jual',
                    selected: _listingType == 'Jual',
                    activeColor: const Color(0xFF0D9488),
                    toggleable: false,
                    onChanged: (val) => setState(() => _listingType = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Hibah (Rp 0)'),
                    value: 'Hibah',
                    selected: _listingType == 'Hibah',
                    activeColor: const Color(0xFF0D9488),
                    toggleable: false,
                    onChanged: (val) {
                      setState(() {
                        _listingType = val!;
                        _isBarterOpen = false; // BR-02
                        _priceController.text = '0';
                      });
                    },
                  ),
                ),
              ],
            ),
            if (_listingType == 'Jual') ...[
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Harga *',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  int? price = int.tryParse(value ?? '0');
                  if (price == null || price < 1000 || price > 50000000) {
                    return 'Rentang Rp 1.000 - Rp 50.000.000 (BR-02)'; // BR-02
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Terbuka untuk Barter'),
                subtitle: const Text('Izinkan mahasiswa lain menukar barang'),
                value: _isBarterOpen,
                activeThumbColor: const Color(0xFF0D9488),
                onChanged: (val) => setState(() => _isBarterOpen = val),
              ),
            ],
            const SizedBox(height: 24),

            // Sesuai desain Figma: Kondisi Fisik
            const Text(
              'Kondisi Fisik',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ..._conditions.map(
              (cond) => RadioListTile<String>(
                title: Text(cond),
                value: cond,
                selected: _selectedCondition == cond,
                activeColor: const Color(0xFF0D9488),
                toggleable: false,
                onChanged: (val) => setState(() => _selectedCondition = val!),
              ),
            ),
            const SizedBox(height: 16),

            // Sesuai desain Figma: Deskripsi Transparan
            TextFormField(
              controller: _descController,
              maxLines: 5,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Transparan *',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.length < 20
                  ? 'Minimal 20 karakter (BR-01)'
                  : null, // Validasi BR-01
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: context.watch<ItemViewModel>().isLoading
                  ? null
                  : _submitListing,
              child: context.watch<ItemViewModel>().isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Publikasikan Listing',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
