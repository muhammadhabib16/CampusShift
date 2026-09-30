import 'package:flutter/material.dart';

import '../models/item.dart';


class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)?.settings.arguments as Item?;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Barang'),
        ),
        body: const Center(
          child: Text('Data barang tidak ditemukan.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text('Detail Barang'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: 80,
                  color: Color(0xFF0D9488),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              item.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.subtitle,
                style: const TextStyle(
                  color: Color(0xFF0D9488),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              item.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/catatan',
                    arguments: item,
                  );
                },
                child: const Text('Tambah Catatan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}