import '../models/listing_summary.dart';

/// Sumber data Beranda.
///
/// SEMENTARA masih memakai data contoh sampai API listing Modul 1 tersedia.
/// Saat backend siap, isi method cukup diganti pemanggilan REST API tanpa
/// mengubah ViewModel maupun View.
class HomeService {
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
  Future<List<ListingSummary>> getLatestListings() async => List.of(_latestListings);
}
