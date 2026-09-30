import 'package:flutter/material.dart';

/// Model barang. Isinya sama dengan data yang sebelumnya ditulis langsung
/// di HomeScreen (name, category, price, icon, color).
class Product {
  final int id;
  final String name;
  final String category;
  final String price;
  final IconData icon;
  final Color color;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
  });
}
