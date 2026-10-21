import 'dart:io';

import '../models/item_model.dart';

class ItemService {
  // 1. MOCK DATA KATALOG (Aman dari error Platform._operatingSystem di Web)
  static Future<List<ItemModel>> getCatalog({
    String? search,
    String? category,
    String? type,
  }) async {
    // Simulasi loading jeda waktu 1 detik
    await Future.delayed(const Duration(seconds: 1));

    return [
      ItemModel(
        id: '1',
        ownerId: '2',
        title: 'Kalkulator Saintifik Casio fx-991EX Classwiz Asli',
        description:
            'Pembelian resmi semester 1. Fungsi normal 100%. LCD bening.',
        category: 'Elektronik & Gadget',
        listingType: 'Jual',
        price: 180000,
        isBarterOpen: true,
        condition: 'Sangat Baik (Grade A)',
        photoUrls: [
          'https://via.placeholder.com/300/0D9488/FFFFFF?text=Kalkulator',
        ],
        status: 'Available',
      ),
      ItemModel(
        id: '2',
        ownerId: '3',
        title: 'Buku Fisika Dasar Halliday Resnick Vol 1',
        description: 'Buku wajib TPB, kondisi ada coretan rapi di bab 1-3.',
        category: 'Buku & Referensi',
        listingType: 'Jual',
        price: 120000,
        isBarterOpen: true,
        condition: 'Sangat Baik (Grade A)',
        photoUrls: [
          'https://via.placeholder.com/300/0D9488/FFFFFF?text=Buku+Fisika',
        ],
        status: 'Available',
      ),
      ItemModel(
        id: '3',
        ownerId: '4',
        title: 'Meja Lipat Belajar Kayu Kokoh Praktis',
        description: 'Bisa dipakai untuk di atas kasur kos.',
        category: 'Furnitur Kos',
        listingType: 'Hibah',
        price: 0,
        isBarterOpen: false,
        condition: 'Baru (Segel / Belum Terpakai)',
        photoUrls: [
          'https://via.placeholder.com/300/0D9488/FFFFFF?text=Meja+Lipat',
        ],
        status: 'Available',
      ),
      ItemModel(
        id: '4',
        ownerId: '5',
        title: 'Lampu Belajar Arsitek',
        description: 'Bisa dijepit di meja. Kondisi normal.',
        category: 'Furnitur Kos',
        listingType: 'Jual',
        price: 45000,
        isBarterOpen: true,
        condition: 'Baik (Grade B)',
        photoUrls: [
          'https://via.placeholder.com/300/0D9488/FFFFFF?text=Lampu+Belajar',
        ],
        status: 'Available',
      ),
    ];
  }

  // 2. MOCK DATA CREATE LISTING (Pura-pura sukses)
  static Future<bool> createListing(
    Map<String, dynamic> data,
    List<File> imageFiles,
  ) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi upload
    return true;
  }
}
