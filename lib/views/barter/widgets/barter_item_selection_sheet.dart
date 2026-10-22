import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/barter_item.dart';
import '../../../utils/formatters.dart';
import '../../../viewmodels/barter_view_model.dart';
import '../barter_negotiation_screen.dart';
import 'barter_visuals.dart';

class BarterItemSelectionSheet extends StatelessWidget {
  const BarterItemSelectionSheet({super.key});

  /// [target] adalah barang yang sedang dilihat pengguna. Bila kosong,
  /// barang target terakhir di BarterViewModel tetap dipakai.
  static void show(BuildContext context, {BarterItem? target}) {
    if (target != null) context.read<BarterViewModel>().setTargetItem(target);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BarterItemSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BarterViewModel>();
    final myItems = viewModel.myItems;
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
          RadioGroup<int>(
            groupValue: viewModel.selectedIndex,
            onChanged: (value) => viewModel.selectItem(value!),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = myItems[index];
                final isSelected = viewModel.selectedIndex == index;
                return GestureDetector(
                  onTap: () => viewModel.selectItem(index),
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
                          child: Icon(BarterVisuals.iconForCategory(item.category), color: Colors.grey.shade400, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
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
                                    formatRupiah(item.price),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.condition,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: BarterVisuals.colorForCondition(item.condition),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Radio<int>(
                          value: index,
                          activeColor: const Color(0xFF0D9488),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.selectedItem == null
                ? null
                : () {
                    // Ambil Navigator sebelum sheet ditutup, karena context sheet tidak lagi aktif setelah pop
                    final navigator = Navigator.of(context);
                    navigator.pop(); // Close sheet
                    navigator.push(
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
