import 'package:flutter/foundation.dart';

import '../models/barter_deal.dart';
import '../models/barter_item.dart';
import '../services/barter_service.dart';
import '../utils/error_message.dart';

/// State dan logika Modul 3 (Barter). View hanya membaca state dari sini
/// dan meneruskan aksi pengguna, tanpa memanggil service secara langsung.
class BarterViewModel extends ChangeNotifier {
  BarterViewModel(this._service);

  final BarterService _service;

  List<BarterItem> _myItems = [];
  BarterItem? _targetItem;
  List<BarterDeal> _deals = [];
  int _selectedIndex = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<BarterItem> get myItems => _myItems;
  BarterItem? get targetItem => _targetItem;
  List<BarterDeal> get deals => _deals;
  List<BarterDeal> get sentDeals =>
      _deals.where((deal) => deal.isSentByMe).toList();
  List<BarterDeal> get receivedDeals =>
      _deals.where((deal) => !deal.isSentByMe).toList();
  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  BarterItem? get selectedItem =>
      _myItems.isEmpty ? null : _myItems[_selectedIndex];

  /// Selisih harga barang target dengan barang yang ditawarkan.
  /// Positif berarti Pengaju perlu menambah uang tunai.
  int get priceDifference {
    final offered = selectedItem;
    final target = _targetItem;
    if (offered == null || target == null) return 0;
    return target.price - offered.price;
  }

  /// Nilai awal input cash top-up: menutup selisih bila barang sendiri lebih murah.
  int get suggestedTopUp => priceDifference > 0 ? priceDifference : 0;

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _myItems = await _service.getMyActiveItems();
      // Mode server: target ditetapkan dari layar detail barang.
      _targetItem = await _service.getTargetItem() ?? _targetItem;
      _deals = await _service.getMyDeals();
      if (_selectedIndex >= _myItems.length) _selectedIndex = 0;
    } catch (e) {
      _errorMessage = errorMessageOf(e, fallback: 'Gagal memuat data barter');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memuat ulang barang milik sendiri yang dapat ditawarkan.
  Future<void> refreshMyItems() async {
    try {
      _myItems = await _service.getMyActiveItems();
      if (_selectedIndex >= _myItems.length) _selectedIndex = 0;
      notifyListeners();
    } catch (_) {}
  }

  /// Menetapkan barang milik orang lain yang akan ditawar (dari detail barang).
  void setTargetItem(BarterItem item) {
    _targetItem = item;
    notifyListeners();
  }

  void selectItem(int index) {
    if (index < 0 || index >= _myItems.length) return;
    _selectedIndex = index;
    notifyListeners();
  }

  /// Validasi input cash top-up (BR-16). Mengembalikan pesan galat atau null bila valid.
  String? validateTopUp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selisih tunai tidak boleh kosong';
    }
    final amount = int.tryParse(value.trim());
    if (amount == null) {
      return 'Hanya boleh berisi angka';
    }
    if (amount < 0) {
      return 'Tidak boleh bernilai negatif';
    }
    // BR-16: Rp0–5.000.000, kelipatan Rp1.000.
    if (amount > 5000000) {
      return 'Maksimal Rp5.000.000';
    }
    if (amount % 1000 != 0) {
      return 'Harus kelipatan Rp1.000';
    }
    return null;
  }

  BarterDeal? dealById(String id) {
    for (final deal in _deals) {
      if (deal.id == id) return deal;
    }
    return null;
  }

  /// Konfirmasi hanya dapat diberikan sekali dan selama tawaran masih berjalan.
  bool canConfirm(BarterDeal deal) {
    // Server mengirim `can_confirm`; data contoh memakai aturan bawaan.
    return deal.canConfirm ??
        (!deal.myConfirmed &&
            (deal.status == 'Menunggu' || deal.status == 'Negosiasi'));
  }

  void _replaceDeal(BarterDeal updated) {
    _deals = [for (final d in _deals) d.id == updated.id ? updated : d];
  }

  /// Penerima menolak tawaran (FR-12).
  Future<bool> rejectDeal(String dealId, {String? reason}) async {
    final deal = dealById(dealId);
    if (deal == null) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _replaceDeal(await _service.rejectDeal(deal, reason: reason));
      return true;
    } catch (e) {
      _errorMessage = errorMessageOf(e, fallback: 'Gagal menolak tawaran, coba lagi');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Membatalkan / menarik tawaran (BR-20).
  Future<bool> cancelDeal(String dealId, {String? reason}) async {
    final deal = dealById(dealId);
    if (deal == null) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _service.cancelDeal(deal, reason: reason);
      if (updated == null) {
        _deals = _deals.where((d) => d.id != dealId).toList();
      } else {
        _replaceDeal(updated);
      }
      return true;
    } catch (e) {
      _errorMessage = errorMessageOf(e, fallback: 'Gagal membatalkan tawaran, coba lagi');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Dual-confirmation (FR-13). Mengembalikan true bila konfirmasi tercatat.
  Future<bool> confirmDeal(String dealId) async {
    final deal = dealById(dealId);
    if (deal == null || !canConfirm(deal)) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _service.confirmDeal(deal);
      _replaceDeal(updated);
      return true;
    } catch (e) {
      _errorMessage = errorMessageOf(e, fallback: 'Gagal mengonfirmasi kesepakatan, coba lagi');
      // Status mungkin berubah di server (mis. penguncian gagal): muat ulang.
      try {
        _deals = await _service.getMyDeals();
      } catch (_) {}
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Mengirim tawaran. Mengembalikan true bila berhasil.
  Future<bool> submitProposal(String topUpText) async {
    final offered = selectedItem;
    final target = _targetItem;
    if (offered == null || target == null || validateTopUp(topUpText) != null) {
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.submitProposal(
        offeredItem: offered,
        targetItem: target,
        cashTopUp: int.parse(topUpText.trim()),
      );
      try {
        _deals = await _service.getMyDeals();
      } catch (_) {}
      return true;
    } catch (e) {
      _errorMessage = errorMessageOf(e, fallback: 'Gagal mengirim penawaran, coba lagi');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
