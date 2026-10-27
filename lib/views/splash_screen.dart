import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_tokens.dart';
import '../viewmodels/auth_view_model.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: AppDurations.inCurve),
    );
    _animController.forward();

    _openNextScreen();
  }

  /// Setelah animasi, pengguna yang masih login langsung ke Beranda.
  Future<void> _openNextScreen() async {
    final results = await Future.wait([
      context.read<AuthViewModel>().restoreSession(),
      Future.delayed(const Duration(milliseconds: 2200)),
    ]);
    if (!mounted) return;
    final loggedIn = results.first as bool;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            loggedIn ? const MainScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2.0,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.recycling_rounded,
                          color: Colors.white,
                          size: 56,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text(
                      'CampuShift',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ekonomi Sirkular Kampusmu',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  child: Text(
                    'UNIVERSITAS ANDALAS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
