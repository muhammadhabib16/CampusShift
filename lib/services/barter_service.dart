import '../models/barter_deal.dart';
import '../models/barter_item.dart';

/// Sumber data Modul 3 (Barter).
///
/// SEMENTARA masih memakai data contoh karena API Barter Deals belum tersedia.
/// Saat backend siap, isi method di bawah cukup diganti dengan pemanggilan
/// REST API (header `Authorization: Bearer <token>`), tanpa mengubah
/// ViewModel maupun View.
class BarterService {
  static const BarterItem _calculator = BarterItem(
    id: 'item-1',
    name: 'Kalkulator Casio FX-991EX',
    price: 195000,
    category: 'Alat Perkuliahan',
    condition: 'Baik',
  );

  static const BarterItem _ipadCase = BarterItem(
    id: 'item-2',
    name: 'iPad Air 4 Case Navy Blue',
    price: 45000,
    category: 'Elektronik',
    condition: 'Cukup',
  );

  static const BarterItem _foldingDesk = BarterItem(
    id: 'item-3',
    name: 'Meja Lipat Belajar Minimalis',
    price: 120000,
    category: 'Furnitur Kos',
    condition: 'Baik',
  );

  static const List<BarterItem> _myActiveItems = [
    _calculator,
    _ipadCase,
    _foldingDesk,
  ];

  static const BarterItem _targetItem = BarterItem(
    id: 'item-9',
    name: 'Buku Fisika Dasar',
    price: 250000,
    category: 'Buku & Referensi',
    condition: 'Baik',
  );

  static const List<BarterDeal> _deals = [
    BarterDeal(
      id: 'deal-1',
      partnerName: 'Farhan Wijaya',
      myItem: _calculator,
      partnerItem: _targetItem,
      cashTopUp: 55000,
      topUpPaidByMe: true,
      isSentByMe: true,
      status: 'Menunggu',
      myConfirmed: true,
      partnerConfirmed: false,
      dateLabel: 'Hari ini, 10:15 WIB',
    ),
    BarterDeal(
      id: 'deal-2',
      partnerName: 'Sarah Amanda',
      myItem: _foldingDesk,
      partnerItem: BarterItem(
        id: 'item-14',
        name: 'Rice Cooker Mini 0.8L',
        price: 150000,
        category: 'Elektronik',
        condition: 'Sangat Baik',
      ),
      cashTopUp: 30000,
      topUpPaidByMe: true,
      isSentByMe: false,
      status: 'Menunggu',
      myConfirmed: false,
      partnerConfirmed: true,
      dateLabel: 'Kemarin, 14:30 WIB',
    ),
    BarterDeal(
      id: 'deal-3',
      partnerName: 'Rian Hidayat',
      myItem: BarterItem(
        id: 'item-5',
        name: 'Modul Praktikum Kimia',
        price: 40000,
        category: 'Buku & Referensi',
        condition: 'Baik',
      ),
      partnerItem: BarterItem(
        id: 'item-17',
        name: 'Jas Lab Ukuran M',
        price: 60000,
        category: 'Alat Perkuliahan',
        condition: 'Baik',
      ),
      cashTopUp: 20000,
      topUpPaidByMe: true,
      isSentByMe: true,
      status: 'Selesai',
      myConfirmed: true,
      partnerConfirmed: true,
      dateLabel: '12 Okt 2026',
    ),
  ];

  /// Barang milik pengguna yang berstatus Available (BR-14).
  Future<List<BarterItem>> getMyActiveItems() async => List.of(_myActiveItems);

  /// Barang milik orang lain yang sedang ditawar.
  Future<BarterItem> getTargetItem() async => _targetItem;

  /// Daftar tawaran barter pengguna (dikirim maupun diterima).
  Future<List<BarterDeal>> getMyDeals() async => List.of(_deals);

  /// Mengirim tawaran barter (status awal Pending).
  Future<void> submitProposal({
    required BarterItem offeredItem,
    required BarterItem targetItem,
    required int cashTopUp,
  }) async {
    // Simulasi waktu tunggu server.
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Menekan "Setuju & Kunci Kesepakatan" dari sisi pengguna (dual-confirmation).
  /// Server mengunci kesepakatan bila mitra juga sudah mengonfirmasi.
  Future<BarterDeal> confirmDeal(BarterDeal deal) async {
    // Simulasi waktu tunggu server.
    await Future.delayed(const Duration(seconds: 1));
    return deal.copyWith(
      myConfirmed: true,
      status: deal.partnerConfirmed ? 'Terkunci' : deal.status,
    );
  }
}
