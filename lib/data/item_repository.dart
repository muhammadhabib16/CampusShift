import '../models/item.dart';

class ItemRepository {
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    // Simulasi proses mengambil data
    await Future.delayed(const Duration(seconds: 2));

    if (simulateError) {
      throw Exception('Gagal mengambil data barang.');
    }

    return const [
      Item(
        id: '1',
        title: 'Buku Kalkulus',
        subtitle: 'Buku & Referensi',
        description:
            'Buku referensi Kalkulus yang masih layak digunakan untuk perkuliahan.',
      ),
      Item(
        id: '2',
        title: 'Laptop Stand',
        subtitle: 'Elektronik',
        description:
            'Laptop stand yang dapat digunakan untuk menunjang kegiatan belajar mahasiswa.',
      ),
      Item(
        id: '3',
        title: 'Kursi Lipat',
        subtitle: 'Furnitur Kos',
        description:
            'Kursi lipat bekas yang masih dalam kondisi baik dan dapat digunakan untuk belajar.',
      ),
      Item(
        id: '4',
        title: 'Headphone',
        subtitle: 'Elektronik',
        description:
            'Headphone bekas yang masih berfungsi dengan baik untuk kebutuhan belajar.',
      ),
      Item(
        id: '5',
        title: 'Kamus Bahasa Inggris',
        subtitle: 'Buku & Referensi',
        description:
            'Kamus Bahasa Inggris untuk membantu kebutuhan akademik mahasiswa.',
      ),
    ];
  }
}