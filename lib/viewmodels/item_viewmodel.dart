import 'dart:io';

import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/item_service.dart';

class ItemViewModel extends ChangeNotifier {
  List<ItemModel> _catalogItems = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Filter States
  String _searchQuery = '';
  String _selectedCategory = 'Semua Kategori';
  String _selectedType = 'Semua Transaksi';
  double _minPrice = 0;
  double _maxPrice = 250000; // Default max di Figma

  List<ItemModel> get catalogItems => _catalogItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get selectedType => _selectedType;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;

  Future<void> fetchCatalog() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Data mentah dari service (Mock)
      final items = await ItemService.getCatalog(
        search: _searchQuery,
        category: _selectedCategory,
        type: _selectedType,
      );

      // Filter lokal untuk rentang harga (karena mock data)
      _catalogItems = items.where((item) {
        if (item.listingType == 'Hibah')
          return true; // Hibah selalu lolos filter harga
        return item.price >= _minPrice && item.price <= _maxPrice;
      }).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFilter({
    String? query,
    String? category,
    String? type,
    double? min,
    double? max,
  }) {
    if (query != null) _searchQuery = query;
    if (category != null) _selectedCategory = category;
    if (type != null) _selectedType = type;
    if (min != null) _minPrice = min;
    if (max != null) _maxPrice = max;
    fetchCatalog();
  }

  void resetFilter() {
    _searchQuery = '';
    _selectedCategory = 'Semua Kategori';
    _selectedType = 'Semua Transaksi';
    _minPrice = 0;
    _maxPrice = 250000;
    fetchCatalog();
  }

  Future<bool> addListing(Map<String, dynamic> data, List<File> images) async {
    _isLoading = true;
    notifyListeners();
    bool success = false;
    try {
      success = await ItemService.createListing(data, images);
      if (success) {
        await fetchCatalog();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }
}
