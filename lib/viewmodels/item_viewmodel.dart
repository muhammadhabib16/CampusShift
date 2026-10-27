import 'dart:io';

import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/item_service.dart';
import '../services/notification_service.dart';

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

  // FETCH KATALOG
  Future<void> fetchCatalog() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      // Backend sudah menangani seluruh logic filter (termasuk harga 0 untuk hibah)
      _catalogItems = await ItemService.getCatalog(
        search: _searchQuery,
        category: _selectedCategory,
        type: _selectedType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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

  // TAMBAH LISTING
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }

  // FETCH BARANG SAYA
  Future<void> fetchMyItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _myItems = await ItemService.getMyItems();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UBAH STATUS (ARSIPKAN / AKTIFKAN)
  Future<void> changeItemStatus(String id, String newStatus) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (newStatus == 'Archived') {
        await ItemService.archiveListing(id);
      } else if (newStatus == 'Available') {
        await ItemService.activateListing(id);
      }
      // Ambil data terbaru dari server setelah berhasil diubah
      await fetchMyItems();
      await fetchCatalog();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // HAPUS PERMANEN
  Future<void> deleteMyItem(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ItemService.deleteListing(id);
      // Ambil data terbaru dari server setelah berhasil dihapus
      await fetchMyItems();
      await fetchCatalog();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // EDIT LISTING
  Future<bool> updateListing(
    String id,
    Map<String, dynamic> data,
    List<File> images,
  ) async {
    _isLoading = true;
    notifyListeners();
    bool success = false;
    try {
      success = await ItemService.updateListing(id, data, images);
      if (success) {
        await fetchCatalog();
        await fetchMyItems();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }
}
