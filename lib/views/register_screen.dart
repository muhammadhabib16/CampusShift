import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../viewmodels/auth_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  String _selectedUniversity = 'Universitas Andalas';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> _universities = [
    'Universitas Andalas',
    'Universitas Negeri Padang',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final nim = _nimController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || nim.isEmpty || email.isEmpty || password.isEmpty) {
      AppSnackBar.showError(context, 'Semua kolom pendaftaran wajib diisi.');
      return;
    }

    if (nim.length < 8) {
      AppSnackBar.showError(
        context,
        'Format NIM tidak valid (minimal 8–10 digit).',
      );
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.register(
      fullName: name,
      nim: nim,
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      AppSnackBar.showSuccess(
        context,
        authViewModel.message ?? 'Registrasi berhasil! Silakan masuk.',
      );
      Navigator.of(context).pop();
    } else {
      AppSnackBar.showError(
        context,
        authViewModel.message ?? 'Registrasi gagal. Silakan coba lagi.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Lengkapi data mahasiswa untuk bergabung ke ekosistem sirkular CampuShift.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                label: 'Nama Lengkap',
                hintText: 'Contoh: Mellisa Annie',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'NIM (Nomor Induk Mahasiswa)',
                hintText: 'Contoh: 2111522001',
                controller: _nimController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Universitas
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Universitas (Fokus Wilayah)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedUniversity,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.school_outlined, size: 20),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 14,
                      ),
                    ),
                    items: _universities.map((uni) {
                      return DropdownMenuItem(
                        value: uni,
                        child: Text(uni, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null)
                        setState(() => _selectedUniversity = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'Email Kampus Unand',
                hintText: 'nama@student.unand.ac.id',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                helperText:
                    'Wajib gunakan email berakhiran @student.unand.ac.id',
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'Kata Sandi',
                hintText: 'Minimal 8 karakter',
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppPrimaryButton(
                label: 'Daftar Akun',
                onPressed: _register,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.xl),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
