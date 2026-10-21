import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/item_model.dart';
import '../../viewmodels/item_viewmodel.dart';

class EditListingScreen extends StatefulWidget {
  final ItemModel item;
  const EditListingScreen({super.key, required this.item});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<File> _images =
      []; // Untuk mockup, kita abaikan gambar lama dari web

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  late String _selectedCategory;
  late String _listingType;
  late bool _isBarterOpen;
  late String _selectedCondition;

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

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data dari widget.item (data lama)
    _titleController = TextEditingController(text: widget.item.title);
    _priceController = TextEditingController(
      text: widget.item.price.toString(),
    );
    _descController = TextEditingController(text: widget.item.description);

    _selectedCategory = widget.item.category;
    _listingType = widget.item.listingType;
    _isBarterOpen = widget.item.isBarterOpen;
    _selectedCondition = widget.item.condition;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maksimal 3 foto tambahan')));
      return;
    }
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (photo != null) setState(() => _images.add(File(photo.path)));
  }

  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'judul': _titleController.text,
        'deskripsi': _descController.text,
        'kategori': _selectedCategory,
        'tipe_listing': _listingType,
        'harga': _listingType == 'Hibah' ? 0 : int.parse(_priceController.text),
        'terbuka_untuk_barter': _listingType == 'Jual' ? _isBarterOpen : false,
        'kondisi': _selectedCondition,
      };

      final viewModel = Provider.of<ItemViewModel>(context, listen: false);
      bool success = await viewModel.updateListing(
        widget.item.id,
        data,
        _images,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing berhasil diperbarui!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Listing Barang')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Foto Tambahan Kondisi Fisik',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              '(Abaikan jika tidak ingin mengubah foto)',
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Listing *',
                border: OutlineInputBorder(),
              ),
              maxLength: 80,
              validator: (value) =>
                  value!.length < 5 ? 'Minimal 5 karakter (BR-01)' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
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
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Jual (COD Tunai)'),
                    value: 'Jual',
                    groupValue: _listingType,
                    activeColor: const Color(0xFF0D9488),
                    onChanged: (val) => setState(() => _listingType = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Hibah (Rp 0)'),
                    value: 'Hibah',
                    groupValue: _listingType,
                    activeColor: const Color(0xFF0D9488),
                    onChanged: (val) {
                      setState(() {
                        _listingType = val!;
                        _isBarterOpen = false;
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
                  if (price == null || price < 1000 || price > 50000000)
                    return 'Rentang Rp 1.000 - Rp 50.000.000 (BR-02)';
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Terbuka untuk Barter'),
                subtitle: const Text('Izinkan mahasiswa lain menukar barang'),
                value: _isBarterOpen,
                activeColor: const Color(0xFF0D9488),
                onChanged: (val) => setState(() => _isBarterOpen = val),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Kondisi Fisik',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ..._conditions.map(
              (cond) => RadioListTile<String>(
                title: Text(cond),
                value: cond,
                groupValue: _selectedCondition,
                activeColor: const Color(0xFF0D9488),
                onChanged: (val) => setState(() => _selectedCondition = val!),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 5,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Transparan *',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.length < 20 ? 'Minimal 20 karakter (BR-01)' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: context.watch<ItemViewModel>().isLoading
                  ? null
                  : _submitUpdate,
              child: context.watch<ItemViewModel>().isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Simpan Perubahan',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
