import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/validators.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Login gagal',
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
                    const SizedBox(height: 20),

                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Selamat Datang di CampusShift',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Masuk untuk melanjutkan ke CampusShift.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Email / NIM
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email atau NIM',
                        hintText: 'Masukkan email atau NIM',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
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
                          fieldName: 'Email atau NIM',
                        );

                        if (requiredError != null) {
                          return requiredError;
                        }

                        final input = value!.trim();

                        // Jika berupa NIM, minimal 10 digit.
                        if (RegExp(r'^\d+$').hasMatch(input)) {
                          if (input.length < 10) {
                            return 'NIM minimal 10 digit';
                          }

                          return null;
                        }

                        // Jika bukan NIM, validasi sebagai email.
                        return Validators.email(input);
                      },
                    ),

                    const SizedBox(height: 18),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _login();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Masukkan password',
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: Validators.password,
                    ),

                    const SizedBox(height: 24),

                    // Login button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _login,
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
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum punya akun? ',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                          child: const Text(
                            'Daftar',
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