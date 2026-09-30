import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Tidak Ditemukan'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Halaman tidak ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text('Kembali ke Login'),
            ),
          ],
        ),
      ),
    );
  }
}