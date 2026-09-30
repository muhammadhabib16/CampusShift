import '../models/item.dart';

class ItemRepository {
  static const List<Item> _items = [
    Item(
      id: '1',
      title: 'Judul Item 1',
      subtitle: 'Keterangan singkat item 1',
      description: 'Deskripsi lengkap item 1.',
    ),
    Item(
      id: '2',
      title: 'Judul Item 2',
      subtitle: 'Keterangan singkat item 2',
      description: 'Deskripsi lengkap item 2.',
    ),
    Item(
      id: '3',
      title: 'Judul Item 3',
      subtitle: 'Keterangan singkat item 3',
      description: 'Deskripsi lengkap item 3.',
    ),
  ];

  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}
