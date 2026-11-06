import '../models/item_model.dart';
import '../models/listing_summary.dart';
import 'backend.dart';
import 'item_service.dart';

/// Sumber data Beranda: listing Available terbaru dari API Modul 1
/// (`GET /api/items`).
///
/// Pengguna login: data server apa adanya (kosong berarti belum ada listing;
/// gagal dimuat dilaporkan sebagai error). Data contoh di bawah hanya untuk
/// mode demo tanpa login, agar barang fiktif tidak bisa diajukan ke server.
class HomeService {
  /// [fetchItems] dan [isOnline] dapat diganti pada pengujian.
  HomeService({
    Future<List<ItemModel>> Function()? fetchItems,
    Future<bool> Function()? isOnline,
  }) : _fetchItems = fetchItems ?? (() => ItemService.getCatalog()),
       _isOnline = isOnline ?? Backend.isOnline;

  final Future<List<ItemModel>> Function() _fetchItems;
  final Future<bool> Function() _isOnline;

  static const int _latestLimit = 5;
  static const Duration _timeout = Duration(seconds: 8);

  static const List<ListingSummary> _latestListings = [
    ListingSummary(
      id: '1',
      title: 'Buku Kalkulus Purcell Ed. 9',
      category: 'Buku & Referensi',
      faculty: 'Unand • FMIPA',
      price: 85000,
      ownerId: 2,
      ownerName: 'Muhammad Racha',
    ),
    ListingSummary(
      id: '2',
      title: 'Laptop Stand Adjustable',
      category: 'Elektronik',
      faculty: 'Unand • Teknik Mesin',
      price: 120000,
      ownerId: 3,
      ownerName: 'Fadel Muhammad',
    ),
    ListingSummary(
      id: '3',
      title: 'Kursi Lipat Kos',
      category: 'Furnitur Kos',
      faculty: 'Unand • FISIP',
      price: 75000,
      ownerId: 4,
      ownerName: 'Muhammad Habib',
    ),
    ListingSummary(
      id: '4',
      title: 'Headphone Sony WH-1000',
      category: 'Elektronik',
      faculty: 'Unand • Teknik Elektro',
      price: 350000,
      ownerId: 5,
      ownerName: 'Ahmad Zaky',
    ),
    ListingSummary(
      id: '5',
      title: 'Jangka Sorong Digital',
      category: 'Alat Perkuliahan',
      faculty: 'Unand • Teknik Sipil',
      price: 45000,
      ownerId: 6,
      ownerName: 'Rafi Pratama',
    ),
  ];

  /// Listing Available terbaru untuk ditampilkan di Beranda.
  Future<List<ListingSummary>> getLatestListings() async {
    if (await _isOnline()) {
      final items = await _fetchItems().timeout(_timeout);
      return items
          .where((item) => item.status == 'Available')
          .take(_latestLimit)
          .map(ListingSummary.fromItem)
          .toList();
    }

    try {
      final items = await _fetchItems().timeout(_timeout);
      final available = items
          .where((item) => item.status == 'Available')
          .take(_latestLimit)
          .map(ListingSummary.fromItem)
          .toList();
      if (available.isNotEmpty) return available;
    } catch (_) {
      // API listing belum tersedia; lanjut ke data contoh.
    }
    return List.of(_latestListings);
  }
}
