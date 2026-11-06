import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../viewmodels/auth_view_model.dart';

/// Ubah profil: foto (kamera/galeri), nama, nomor telepon, dan bio.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static const int bioMaxLength = 160;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _bio;
  late final String _initialBio;
  File? _newPhoto;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    _name = TextEditingController(text: user?.fullName ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _initialBio = user?.bio ?? '';
    _bio = TextEditingController(text: _initialBio);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Ambil dari kamera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Pilih dari galeri'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked == null || !mounted) return;
      final file = File(picked.path);
      if (await file.length() > 5 * 1024 * 1024) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            'Foto terlalu besar. Maksimal 5 MB, coba foto lain.',
          );
        }
        return;
      }
      setState(() => _newPhoto = file);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        source == ImageSource.camera
            ? 'Kamera tidak dapat dibuka. Izinkan akses kamera di pengaturan HP.'
            : 'Galeri tidak dapat dibuka. Izinkan akses foto di pengaturan HP.',
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthViewModel>();
    final bio = _bio.text.trim();
    final ok = await auth.updateProfile(
      fullName: _name.text,
      phone: _phone.text,
      bio: bio == _initialBio.trim() ? null : bio,
      photoPath: _newPhoto?.path,
    );
    if (!mounted) return;
    final message =
        auth.message ?? (ok ? 'Profil diperbarui' : 'Gagal memperbarui profil');
    if (ok) {
      AppSnackBar.showSuccess(context, message);
      Navigator.of(context).pop(true);
    } else {
      AppSnackBar.showError(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.currentUser;
    final ImageProvider? photo = _newPhoto != null
        ? FileImage(_newPhoto!)
        : (user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ubah Profil'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: auth.isLoading ? null : _pickPhoto,
                    child: Stack(
                      children: [
                        ProfileAvatar(
                          name: _name.text,
                          image: photo,
                          radius: 52,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.photo_camera_rounded,
                              size: 18,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: auth.isLoading ? null : _pickPhoto,
                    child: Text(
                      photo == null
                          ? 'Tambah foto profil'
                          : 'Ganti foto profil',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nama lengkap',
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final len = (v ?? '').trim().length;
                      return len < 3 || len > 60
                          ? 'Nama harus 3–60 karakter'
                          : null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor telepon (opsional)',
                      hintText: '08xxxxxxxxxx',
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return null;
                      final digits = value.replaceAll(RegExp(r'\D'), '');
                      final validStart = RegExp(r'^(08|\+62)').hasMatch(value);
                      return validStart &&
                              digits.length >= 10 &&
                              digits.length <= 14
                          ? null
                          : 'Diawali 08 atau +62, 10–14 digit';
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _bio,
                    maxLength: EditProfileScreen.bioMaxLength,
                    maxLines: 3,
                    minLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Bio (opsional)',
                      hintText: 'Contoh: Mahasiswa Teknik Sipil 2022, biasa COD di Perpustakaan Pusat.',
                      alignLabelWithHint: true,
                    ),
                  ),
                  Text(
                    'Bio tampil di profil publikmu dan dapat dilihat pengguna lain.',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: 'Simpan Profil',
              icon: Icons.check_rounded,
              isLoading: auth.isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

}
