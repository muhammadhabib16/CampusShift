import '../models/listing_summary.dart';

/// Sumber data Beranda.
///
/// SEMENTARA masih memakai data contoh sampai API listing Modul 1 tersedia.
/// Saat backend siap, isi method cukup diganti pemanggilan REST API tanpa
/// mengubah ViewModel maupun View.
class HomeService {
  static const List<ListingSummary> _latestListings = [
    ListingSummary(
      id: 'item-21',
      title: 'Buku Kalkulus Purcell Ed. 9',
      category: 'Buku & Referensi',
      faculty: 'Unand • FMIPA',
      price: 85000,
    ),
    ListingSummary(
      id: 'item-22',
      title: 'Laptop Stand Adjustable',
      category: 'Elektronik',
      faculty: 'Unand • Teknik Mesin',
      price: 120000,
    ),
    ListingSummary(
      id: 'item-23',
      title: 'Kursi Lipat Kos',
      category: 'Furnitur Kos',
      faculty: 'Unand • FISIP',
      price: 75000,
    ),
    ListingSummary(
      id: 'item-24',
      title: 'Headphone Sony WH-1000',
      category: 'Elektronik',
      faculty: 'Unand • Teknik Elektro',
      price: 350000,
    ),
    ListingSummary(
      id: 'item-25',
      title: 'Jangka Sorong Digital',
      category: 'Alat Perkuliahan',
      faculty: 'Unand • Teknik Sipil',
      price: 45000,
    ),
  ];

  /// Listing Available terbaru untuk ditampilkan di Beranda.
  Future<List<ListingSummary>> getLatestListings() async => List.of(_latestListings);
}
