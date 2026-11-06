import 'dart:io';

import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/item_service.dart';
import '../services/notification_service.dart';
import '../utils/error_message.dart';

class ItemViewModel extends ChangeNotifier {
  static const double defaultMaxPrice = 500000;

  List<ItemModel> _catalogItems = [];
  List<ItemModel> _myItems = [];
  bool _isLoading = false;
  String _errorMessage = '';

  String _searchQuery = '';
  String _selectedCategory = 'Semua Kategori';
  String _selectedType = 'Semua Transaksi';
  double _minPrice = 0;
  double _maxPrice = defaultMaxPrice;

  List<ItemModel> get catalogItems => _catalogItems;
  List<ItemModel> get myItems => _myItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
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
      final items = await ItemService.getCatalog(
        search: _searchQuery,
        category: _selectedCategory,
        type: _selectedType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );

      _catalogItems = items.where(_matchesFilter).toList();
    } catch (e) {
      _errorMessage = errorMessageOf(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _matchesFilter(ItemModel item) {
    if (_selectedCategory != 'Semua Kategori' &&
        item.category != _selectedCategory) {
      return false;
    }

    if (_selectedType == 'Jual (COD Tunai)' && item.listingType != 'Jual') {
      return false;
    }
    if (_selectedType == 'Hibah (Rp0 Gratis)' && item.listingType != 'Hibah') {
      return false;
    }
    if (_selectedType == 'Terbuka Barter' && !item.isBarterOpen) {
      return false;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      final matchTitle = item.title.toLowerCase().contains(q);
      final matchDesc = item.description.toLowerCase().contains(q);
      if (!matchTitle && !matchDesc) return false;
    }

    // Barang Hibah selalu gratis (Rp 0), sehingga lolos filter batas harga
    if (item.listingType == 'Hibah') return true;

    if (_maxPrice < defaultMaxPrice && item.price > _maxPrice) {
      return false;
    }
    return item.price >= _minPrice;
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

  /// Mengembalikan semua filter ke bawaan. [category] opsional dipakai saat
  /// membuka Katalog dari kartu Kategori Populer di Beranda.
  void resetFilter({String category = 'Semua Kategori'}) {
    _searchQuery = '';
    _selectedCategory = category;
    _selectedType = 'Semua Transaksi';
    _minPrice = 0;
    _maxPrice = defaultMaxPrice;
    fetchCatalog();
  }

  // TAMBAH LISTING
  Future<bool> addListing(Map<String, dynamic> data, List<File> images) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    bool success = false;
    try {
      success = await ItemService.createListing(data, images);
      if (success) {
        await fetchCatalog();
        await fetchMyItems();
      }
    } catch (e) {
      _errorMessage = errorMessageOf(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }

  // FETCH BARANG SAYA
  Future<void> fetchMyItems() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _myItems = await ItemService.getMyItems();
      // FR-05: Stale Alert untuk listing Available yang 14 hari tidak
      // disunting (berbasis sinkronisasi saat data dimuat).
      NotificationService.checkStaleListings(_myItems);
    } catch (e) {
      _errorMessage = errorMessageOf(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UBAH STATUS (ARSIPKAN / AKTIFKAN)
  Future<bool> changeItemStatus(String id, String newStatus) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      if (newStatus == 'Archived') {
        await ItemService.archiveListing(id);
      } else if (newStatus == 'Available') {
        await ItemService.activateListing(id);
      }
      await fetchMyItems();
      await fetchCatalog();
      return true;
    } catch (e) {
      _errorMessage = errorMessageOf(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // HAPUS PERMANEN
  Future<bool> deleteMyItem(String id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await ItemService.deleteListing(id);
      await fetchMyItems();
      await fetchCatalog();
      return true;
    } catch (e) {
      _errorMessage = errorMessageOf(e);
      return false;
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
    _errorMessage = '';
    notifyListeners();
    bool success = false;
    try {
      success = await ItemService.updateListing(id, data, images);
      if (success) {
        await fetchCatalog();
        await fetchMyItems();
      }
    } catch (e) {
      _errorMessage = errorMessageOf(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }
}
