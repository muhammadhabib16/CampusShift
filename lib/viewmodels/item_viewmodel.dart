import 'dart:io';

import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/item_service.dart';
import '../services/notification_service.dart'; // Import notifikasi

class ItemViewModel extends ChangeNotifier {
  List<ItemModel> _catalogItems = [];
  List<ItemModel> _myItems = [];
  bool _isLoading = false;
  String _errorMessage = '';

  String _searchQuery = '';
  String _selectedCategory = 'Semua Kategori';
  String _selectedType = 'Semua Transaksi';
  double _minPrice = 0;
  double _maxPrice = 250000;

  List<ItemModel> get catalogItems => _catalogItems;
  List<ItemModel> get myItems => _myItems;
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
      final items = await ItemService.getCatalog(
        search: _searchQuery,
        category: _selectedCategory,
        type: _selectedType,
      );
      _catalogItems = items.where((item) {
        if (item.listingType == 'Hibah') return true;
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
        await fetchMyItems();

        // --- TRIGGER NOTIFIKASI SIMULASI FR-05 ---
        NotificationService.scheduleStaleListingAlert(data['judul']);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }

  Future<void> fetchMyItems() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    if (_myItems.isEmpty) {
      _myItems = [
        ItemModel(
          id: 'my_1',
          ownerId: 'naufal123',
          title: 'Kalkulator Saintifik Casio fx-991EX',
          description: 'Fungsi normal 100%.',
          category: 'Elektronik & Gadget',
          listingType: 'Jual',
          price: 180000,
          isBarterOpen: true,
          condition: 'Sangat Baik (Grade A)',
          photoUrls: [
            'https://via.placeholder.com/300/0D9488/FFFFFF?text=Kalkulator+Saya',
          ],
          status: 'Available',
        ),
        ItemModel(
          id: 'my_2',
          ownerId: 'naufal123',
          title: 'Meja Lipat Belajar',
          description: 'Jarang dipakai.',
          category: 'Furnitur Kos',
          listingType: 'Hibah',
          price: 0,
          isBarterOpen: false,
          condition: 'Baik (Grade B)',
          photoUrls: [
            'https://via.placeholder.com/300/0D9488/FFFFFF?text=Meja+Lipat+Saya',
          ],
          status: 'Archived',
        ),
      ];
    }
    _isLoading = false;
    notifyListeners();
  }

  void changeItemStatus(String id, String newStatus) {
    final index = _myItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final old = _myItems[index];
      _myItems[index] = ItemModel(
        id: old.id,
        ownerId: old.ownerId,
        title: old.title,
        description: old.description,
        category: old.category,
        listingType: old.listingType,
        price: old.price,
        isBarterOpen: old.isBarterOpen,
        condition: old.condition,
        photoUrls: old.photoUrls,
        status: newStatus,
      );
      notifyListeners();
    }
  }

  void deleteMyItem(String id) {
    _myItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<bool> updateListing(
    String id,
    Map<String, dynamic> data,
    List<File> images,
  ) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    final index = _myItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final old = _myItems[index];
      _myItems[index] = ItemModel(
        id: old.id,
        ownerId: old.ownerId,
        title: data['judul'],
        description: data['deskripsi'],
        category: data['kategori'],
        listingType: data['tipe_listing'],
        price: data['harga'] ?? 0,
        isBarterOpen: data['terbuka_untuk_barter'],
        condition: data['kondisi'],
        photoUrls: old.photoUrls,
        status: old.status,
      );
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
