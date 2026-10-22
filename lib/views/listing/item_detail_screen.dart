import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/barter_item.dart';
import '../../models/item_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../barter/widgets/barter_item_selection_sheet.dart';
import '../katalog_hibah_screen.dart';
import '../safe_meet/meetup_form_screen.dart';

class ItemDetailScreen extends StatelessWidget {
  final ItemModel item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Barang',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Barang Full Width
            Image.network(
              item.photoUrls.isNotEmpty
                  ? item.photoUrls.first
                  : 'https://via.placeholder.com/400',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges (Status & Kondisi)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '• ${item.status}',
                          style: const TextStyle(
                            color: Color(0xFF0D9488),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.condition,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title & Price
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        item.listingType == 'Hibah'
                            ? 'Hibah Gratis'
                            : currencyFormatter.format(item.price),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                      if (item.isBarterOpen) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '⇌ Terbuka Barter',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Zona Safe-Meet Card (Berdasarkan Figma)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.security, color: Color(0xFF0D9488)),
                            SizedBox(width: 8),
                            Text(
                              'Zona Safe-Meet Kampus',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildLocationRow(
                          'Pos Satpam Utama Gedung Baru',
                          '~150m dari posisi Anda',
                        ),
                        const SizedBox(height: 12),
                        _buildLocationRow(
                          'Lobi Perpustakaan Pusat (Lantai 1)',
                          '~320m • Buka s/d 20.00 WIB',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Deskripsi
                  const Text(
                    'Deskripsi & Kondisi Fisik',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(height: 1.5, color: Colors.black87),
                  ),

                  const SizedBox(
                    height: 100,
                  ), // Spacing untuk bottom navigation bar
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            if (item.isBarterOpen)
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF0D9488)),
                  ),
                  icon: const Icon(Icons.swap_horiz, color: Color(0xFF0D9488)),
                  label: const Text(
                    'Tukar (Barter)',
                    style: TextStyle(color: Color(0xFF0D9488)),
                  ),
                  onPressed: () {
                    BarterItemSelectionSheet.show(
                      context,
                      target: BarterItem(
                        id: item.id,
                        name: item.title,
                        price: item.price,
                        category: item.category,
                        condition: item.condition,
                      ),
                    );
                  },
                ),
              ),
            if (item.isBarterOpen) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.handshake, color: Colors.white),
                label: Text(
                  item.listingType == 'Hibah'
                      ? 'Ajukan Klaim'
                      : 'Ajukan COD Temu',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (item.listingType == 'Hibah') {
                    // Klaim hibah diajukan dari katalog hibah (Modul 5)
                    final nim = context.read<AuthViewModel>().currentUser?.nim ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KatalogHibahScreen(currentUserNim: nim),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MeetupFormScreen(
                        itemId: int.tryParse(item.id) ?? 0,
                        itemTitle: item.title,
                        itemPrice: currencyFormatter.format(item.price),
                        itemType: 'Jual',
                        ownerId: int.tryParse(item.ownerId) ?? 0,
                        ownerName: item.ownerName.isEmpty ? 'Pemilik Barang' : item.ownerName,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String title, String subtitle) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(Icons.send, color: Colors.grey, size: 16),
      ],
    );
  }
}
