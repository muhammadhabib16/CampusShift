import 'package:flutter/foundation.dart';

import '../models/listing_summary.dart';
import '../services/home_service.dart';

/// State Beranda. View hanya membaca daftar listing dari sini.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._service);

  final HomeService _service;

  List<ListingSummary> _latestListings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ListingSummary> get latestListings => _latestListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadLatestListings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _latestListings = await _service.getLatestListings();
    } catch (e) {
      _errorMessage = 'Gagal memuat barang terbaru';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
