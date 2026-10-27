import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_images.length >= 3) {
      AppSnackBar.showInfo(context, 'Maksimal 3 foto kondisi fisik.');
      return;
    }
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (photo != null) {
      setState(() {
        _images.add(File(photo.path));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitListing() async {
    // Validasi BR-03 (Minimal 2 foto)
    if (_images.length < 2) {
      AppSnackBar.showError(
        context,
        'Minimal 2 foto kondisi fisik wajib dilampirkan (BR-03).',
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final data = {
        'judul': _titleController.text.trim(),
        'deskripsi': _descController.text.trim(),
        'kategori': _selectedCategory,
        'tipe_listing': _listingType,
        'harga': _listingType == 'Hibah'
            ? 0
            : int.parse(_priceController.text.trim()),
        'terbuka_untuk_barter': _listingType == 'Jual' ? _isBarterOpen : false,
        'kondisi': _selectedCondition,
      };

      final viewModel = Provider.of<ItemViewModel>(context, listen: false);
      final success = await viewModel.addListing(data, _images);

      if (!mounted) return;

      if (success) {
        AppSnackBar.showSuccess(context, 'Listing berhasil dipublikasikan!');
        Navigator.pop(context);
      } else {
        AppSnackBar.showError(
          context,
          viewModel.errorMessage.isNotEmpty
              ? viewModel.errorMessage
              : 'Gagal mempublikasikan listing. Periksa koneksi Anda.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ItemViewModel>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Pasang Listing Barang',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Banner Langkah Berikutnya (Section 4.3)
            const StepBanner(
              title: 'Lengkapi Informasi Barang',
              description: 'Foto fisik asli dan deskripsi yang transparan meningkatkan kepercayaan calon peminat di kampus Unand.',
              stepNumber: 1,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Foto Kondisi Fisik (BR-01, BR-03, Section 5.2)
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PhotoPickerGrid(
                    imageCount: _images.length,
                    minPhotos: 2,
                    maxPhotos: 3,
                    imageFiles: _images,
                    onPick: _takePhoto,
                    onRemoveAt: _removePhoto,
                  ),
                  if (_images.length < 2) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: AppRadius.small,
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Peringatan BR-03: Minimal 2 foto fisik wajib diunggah.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Identitas & Kategori
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _titleController,
                    label: 'Judul Listing *',
                    hintText: 'Contoh: Kalkulator Ilmiah Casio fx-991EX',
                    maxLength: 80,
                    showCounter: true,
                    validator: (value) {
                      if (value == null || value.trim().length < 5) {
                        return 'Judul minimal 5 karakter (BR-01)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  const Text(
                    'Kategori Perlengkapan *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tipe Transaksi & Nominal Harga
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jalur Transaksi *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Jual (COD Tunai)'),
                          selected: _listingType == 'Jual',
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: TextStyle(
                            color: _listingType == 'Jual'
                                ? AppColors.onPrimaryContainer
                                : AppColors.textSecondary,
                            fontWeight: _listingType == 'Jual'
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _listingType = 'Jual');
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Hibah (Rp0 Gratis)'),
                          selected: _listingType == 'Hibah',
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: TextStyle(
                            color: _listingType == 'Hibah'
                                ? AppColors.onPrimaryContainer
                                : AppColors.textSecondary,
                            fontWeight: _listingType == 'Hibah'
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _listingType = 'Hibah';
                                _isBarterOpen = false;
                                _priceController.text = '0';
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_listingType == 'Jual') ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _priceController,
                      label: 'Nominal Harga COD (Rp) *',
                      hintText: 'Contoh: 45000',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Text(
                          'Rp',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final price = int.tryParse(value ?? '');
                        if (price == null || price < 1000 || price > 50000000) {
                          return 'Rentang Rp 1.000 – Rp 50.000.000 (BR-02)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Terbuka untuk Barter',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Izinkan mahasiswa lain mengajukan tukar barang',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: _isBarterOpen,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isBarterOpen = val),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Kondisi Fisik
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kondisi Fisik Barang *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ..._conditions.map((cond) {
                    final isSelected = _selectedCondition == cond;
                    return InkWell(
                      onTap: () => setState(() => _selectedCondition = cond),
                      borderRadius: AppRadius.medium,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: cond,
                              groupValue: _selectedCondition,
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedCondition = val);
                              },
                            ),
                            Expanded(
                              child: Text(
                                cond,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Deskripsi Transparan (BR-01, max 1000)
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _descController,
                    label: 'Deskripsi Transparan *',
                    hintText: 'Jelaskan riwayat pemakaian, kelengkapan, dan cacat/goresan bila ada…',
                    maxLines: 5,
                    maxLength: 1000,
                    showCounter: true,
                    validator: (value) {
                      if (value == null || value.trim().length < 20) {
                        return 'Deskripsi minimal 20 karakter (BR-01)';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tombol Publikasikan Listing
            AppPrimaryButton(
              label: 'Publikasikan Listing',
              icon: Icons.check_circle_outline,
              isLoading: isLoading,
              onPressed: _submitListing,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
