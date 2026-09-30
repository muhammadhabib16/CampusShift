import 'package:flutter/material.dart';
import '../barter_negotiation_screen.dart';

class BarterItemSelectionSheet extends StatefulWidget {
  const BarterItemSelectionSheet({super.key});

  @override
  State<BarterItemSelectionSheet> createState() => _BarterItemSelectionSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BarterItemSelectionSheet(),
    );
  }
}

class _BarterItemSelectionSheetState extends State<BarterItemSelectionSheet> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _myItems = [
    {
      'name': 'Kalkulator Casio FX-991EX',
      'price': 'Rp 195.000',
      'condition': 'Baik',
      'conditionColor': Colors.green,
      'icon': Icons.calculate,
    },
    {
      'name': 'iPad Air 4 Case Navy Blue',
      'price': 'Rp 45.000',
      'condition': 'Cukup',
      'conditionColor': Colors.orange,
      'icon': Icons.tablet_mac,
    },
    {
      'name': 'Meja Lipat Belajar Minimalis',
      'price': 'Rp 120.000',
      'condition': 'Baik',
      'conditionColor': Colors.green,
      'icon': Icons.desk,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pilih Barang untuk Ditukar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih salah satu aset aktifmu untuk mengajukan barter.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _myItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _myItems[index];
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0D9488) : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item['icon'], color: Colors.grey.shade400, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  item['price'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item['condition'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: item['conditionColor'],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Radio<int>(
                        value: index,
                        groupValue: _selectedIndex,
                        onChanged: (value) {
                          setState(() {
                            _selectedIndex = value!;
                          });
                        },
                        activeColor: const Color(0xFF0D9488),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close sheet
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BarterNegotiationScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Konfirmasi Pilihan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
