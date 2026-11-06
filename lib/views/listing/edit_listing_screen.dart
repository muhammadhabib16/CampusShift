import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/listing_options.dart';

import '../../models/item_model.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
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
  final List<File> _images = [];

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  late String _selectedCategory;
  late String _listingType;
  late bool _isBarterOpen;
  late String _selectedCondition;

  late final List<String> _categories;
  late final List<String> _conditions;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _priceController = TextEditingController(
      text: widget.item.price.toString(),
    );
    _descController = TextEditingController(text: widget.item.description);

    // Nilai resmi backend; data lama dinormalisasi agar lolos validasi.
    _categories = ListingOptions.categories;
    _conditions = ListingOptions.conditions;

    _selectedCategory = ListingOptions.normalizeCategory(widget.item.category);
    _listingType = widget.item.listingType == 'Hibah' ? 'Hibah' : 'Jual';
    _isBarterOpen = widget.item.isBarterOpen;
    _selectedCondition = ListingOptions.normalizeCondition(widget.item.condition);
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
      AppSnackBar.showInfo(context, 'Maksimal 3 foto tambahan.');
      return;
    }
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      // Foto kamera asli bisa >5 MB (batas server BR-03) dan lambat diunggah.
      // Resolusi 1600px cukup untuk melihat kondisi barang (~200–600 KB).
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 75,
    );
    if (photo != null) {
      setState(() => _images.add(File(photo.path)));
    }
  }

  void _removePhoto(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedPrice = int.tryParse(_priceController.text.trim()) ?? 0;
    final data = {
      'judul': _titleController.text.trim(),
      'deskripsi': _descController.text.trim(),
      'kategori': _selectedCategory,
      'tipe_listing': _listingType,
      'harga': _listingType == 'Hibah' ? 0 : parsedPrice,
      'terbuka_untuk_barter': _listingType == 'Jual' ? _isBarterOpen : false,
      'kondisi': _selectedCondition,
    };

    final viewModel = context.read<ItemViewModel>();
    final success = await viewModel.updateListing(
      widget.item.id,
      data,
      _images,
    );

    if (!mounted) return;

    if (success) {
      AppSnackBar.showSuccess(context, 'Listing berhasil diperbarui!');
      Navigator.pop(context);
    } else {
      AppSnackBar.showError(
        context,
        viewModel.errorMessage.isNotEmpty
            ? viewModel.errorMessage
            : 'Gagal memperbarui listing. Periksa koneksi Anda.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ItemViewModel>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Listing Barang',
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
            // Foto Tambahan Kondisi Fisik
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PhotoPickerGrid(
                    imageCount: _images.length,
                    minPhotos: 0,
                    maxPhotos: 3,
                    imageFiles: _images,
                    onPick: _takePhoto,
                    onRemoveAt: _removePhoto,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Opsional: Tambahkan foto baru jika ingin memperbarui foto kondisi fisik.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
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
                        return 'Judul minimal 5 karakter';
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
                    items: _categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
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
                        final price = int.tryParse((value ?? '').trim());
                        if (price == null || price < 1000 || price > 50000000) {
                          return 'Rentang Rp 1.000 – Rp 50.000.000';
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
              child: RadioGroup<String>(
                groupValue: _selectedCondition,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCondition = val);
                  }
                },
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
                                activeColor: AppColors.primary,
                              ),
                              Expanded(
                                child: Text(
                                  ListingOptions.conditionLabel(cond),
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
            ),
            const SizedBox(height: AppSpacing.lg),

            // Deskripsi Transparan
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _descController,
                    label: 'Deskripsi Transparan *',
                    hintText:
                        'Jelaskan riwayat pemakaian, kelengkapan, dan cacat/goresan bila ada…',
                    maxLines: 5,
                    maxLength: 1000,
                    showCounter: true,
                    validator: (value) {
                      if (value == null || value.trim().length < 20) {
                        return 'Deskripsi minimal 20 karakter';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            AppPrimaryButton(
              label: 'Simpan Perubahan',
              icon: Icons.check_circle_outline,
              isLoading: isLoading,
              onPressed: _submitUpdate,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
