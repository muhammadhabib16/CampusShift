import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/validators.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  final TextEditingController _fullNameController =
      TextEditingController();

  final TextEditingController _nimController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.register(
        fullName: _fullNameController.text.trim(),
        nim: _nimController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Registrasi berhasil',
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Registrasi gagal',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D9488);
    const backgroundColor = Color(0xFFF8FAFB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Daftar Akun',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Buat Akun CampusShift',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Lengkapi data berikut untuk membuat akun.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Nama lengkap
                    TextFormField(
                      controller: _fullNameController,
                      textCapitalization:
                          TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          Validators.minLength(
                        value,
                        3,
                        fieldName: 'Nama lengkap',
                      ),
                    ),

                    const SizedBox(height: 18),

                    // NIM
                    TextFormField(
                      controller: _nimController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'NIM',
                        hintText: 'Masukkan NIM',
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final requiredError =
                            Validators.requiredField(
                          value,
                          fieldName: 'NIM',
                        );

                        if (requiredError != null) {
                          return requiredError;
                        }

                        if (!RegExp(r'^\d+$')
                            .hasMatch(value!.trim())) {
                          return 'NIM hanya boleh berisi angka';
                        }

                        if (value.trim().length < 10) {
                          return 'NIM minimal 10 digit';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Masukkan email',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: Validators.email,
                    ),

                    const SizedBox(height: 18),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Minimal 8 karakter',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: Validators.password,
                    ),

                    const SizedBox(height: 18),

                    // Konfirmasi password
                    TextFormField(
                      controller:
                          _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _register();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        hintText: 'Masukkan ulang password',
                        prefixIcon: const Icon(
                          Icons.lock_reset_outlined,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final requiredError =
                            Validators.requiredField(
                          value,
                          fieldName:
                              'Konfirmasi password',
                        );

                        if (requiredError != null) {
                          return requiredError;
                        }

                        if (value !=
                            _passwordController.text) {
                          return 'Password tidak sama';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 26),

                    // Register button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed:
                            _isLoading ? null : _register,
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}