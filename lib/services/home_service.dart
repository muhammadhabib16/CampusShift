import '../models/item_model.dart';
import '../models/listing_summary.dart';
import 'item_service.dart';

/// Sumber data Beranda: listing Available terbaru dari API Modul 1
/// (`GET /api/items`).
///
/// SEMENTARA, bila API listing belum bisa dihubungi atau belum berisi data,
/// Beranda memakai data contoh di bawah agar demo tetap berjalan.
class HomeService {
  /// [fetchItems] dapat diganti pada pengujian agar tidak memanggil server.
  HomeService({Future<List<ItemModel>> Function()? fetchItems})
    : _fetchItems = fetchItems ?? (() => ItemService.getCatalog());

  final Future<List<ItemModel>> Function() _fetchItems;

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
