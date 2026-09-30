import 'package:flutter/material.dart';
import 'package:campusshift/models/product.dart';

class ProductRepository {
  ProductRepository._();

  /// Saklar untuk menguji status tampilan (ubah sementara saat pengujian).
  static bool simulateError = false;
  static bool simulateEmpty = false;

  // Data dipindahkan apa adanya dari HomeScreen._buildProductCard.
  static final List<Product> _items = [
    Product(
      id: 1,
      name: 'Buku Kalkulus Purcheti Ed. 9',
      category: 'UI • Matematika Pusat',
      price: 'Rp 85.000',
      icon: Icons.menu_book_rounded,
      color: Colors.blue.shade100,
    ),
    Product(
      id: 2,
      name: 'Laptop Stand Adjustable',
      category: 'ITB • Teknik Mesin',
      price: 'Rp 120.000',
      icon: Icons.laptop_mac_rounded,
      color: Colors.purple.shade100,
    ),
    Product(
      id: 3,
      name: 'Kursi Lipat Kuliah',
      category: 'UGM • FISIPOL',
      price: 'Rp 75.000',
      icon: Icons.chair_rounded,
      color: Colors.orange.shade100,
    ),
    Product(
      id: 4,
      name: 'Headphone Sony WH-1000',
      category: 'UI • Teknik Elektro',
      price: 'Rp 350.000',
      icon: Icons.headphones_rounded,
      color: Colors.green.shade100,
    ),
    Product(
      id: 5,
      name: 'Kamus Besar Bahasa Indonesia',
      category: 'UNAIR • FIB',
      price: 'Rp 45.000',
      icon: Icons.library_books_rounded,
      color: Colors.red.shade100,
    ),
  ];

  /// Meniru pemanggilan API: ada jeda, bisa kosong, bisa gagal.
  static Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data barang');
    }
    if (simulateEmpty) {
      return <Product>[];
    }
    return List<Product>.unmodifiable(_items);
  }
}
