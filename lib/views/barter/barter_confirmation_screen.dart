import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/barter_deal.dart';
import '../../utils/formatters.dart';
import '../../viewmodels/barter_view_model.dart';
import '../handover/serah_terima_qr_screen.dart';
import 'widgets/barter_visuals.dart';

/// Detail Tawaran & Konfirmasi Kesepakatan (FR-13 Dual-Confirmation).
class BarterConfirmationScreen extends StatelessWidget {
  final String dealId;
  const BarterConfirmationScreen({super.key, required this.dealId});

  Future<void> _confirm(BuildContext context, BarterDeal deal) async {
    final viewModel = context.read<BarterViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await viewModel.confirmDeal(deal.id);
    final updated = viewModel.dealById(deal.id);

    messenger.showSnackBar(
      SnackBar(
        content: Text(!success
            ? viewModel.errorMessage ?? 'Gagal mengonfirmasi kesepakatan'
            : updated?.status == 'Terkunci'
                ? 'Kesepakatan Berhasil Dikunci!'
                : 'Konfirmasi tercatat, menunggu ${deal.partnerName}'),
        backgroundColor: success ? const Color(0xFF0D9488) : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BarterViewModel>();
    final deal = viewModel.dealById(dealId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Konfirmasi Barter',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: deal == null
          ? const Center(child: Text('Tawaran tidak ditemukan'))
          : _buildContent(context, viewModel, deal),
    );
  }

  Widget _buildContent(BuildContext context, BarterViewModel viewModel, BarterDeal deal) {
    final isLocked = deal.status == 'Terkunci';
    final canConfirm = viewModel.canConfirm(deal);
    final topUpPayer = deal.topUpPaidByMe ? 'Kamu' : deal.partnerName;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Barang yang ditukar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLocked ? const Color(0xFF0D9488) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLocked ? 'Asset Terkunci' : 'Status: ${deal.status}',
                      style: TextStyle(
                        color: BarterVisuals.colorForDealStatus(deal.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
                      color: BarterVisuals.colorForDealStatus(deal.status),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildAssetItem(
                      deal.myItem.name,
                      BarterVisuals.iconForCategory(deal.myItem.category),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.swap_horiz, color: Colors.grey.shade400, size: 24),
                    ),
                    _buildAssetItem(
                      deal.partnerItem.name,
                      BarterVisuals.iconForCategory(deal.partnerItem.category),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Rincian Kesepakatan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rincian Kesepakatan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Mitra Barter', deal.partnerName),
                const Divider(height: 24, color: Color(0xFFEEEEEE)),
                _buildDetailRow(
                  'Tambahan Tunai',
                  formatRupiah(deal.cashTopUp),
                  valueColor: const Color(0xFF0D9488),
                ),
                if (deal.cashTopUp > 0) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow('Dibayar oleh', topUpPayer),
                ],
                const Divider(height: 24, color: Color(0xFFEEEEEE)),
                _buildDetailRow('Konfirmasi Kamu', deal.myConfirmed ? 'Sudah' : 'Belum'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Konfirmasi ${deal.partnerName}',
                  deal.partnerConfirmed ? 'Sudah' : 'Belum',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Titik temu dan jadwal COD dibuat di Modul 2 setelah kesepakatan Locked.
          Text(
            isLocked
                ? 'Kesepakatan terkunci. Ajukan titik temu dan jadwal COD dari menu Pertemuan.'
                : 'Titik temu dan jadwal COD diajukan setelah kedua pihak mengonfirmasi.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          if (canConfirm)
            ElevatedButton(
              onPressed: viewModel.isSubmitting ? null : () => _confirm(context, deal),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                disabledBackgroundColor: Colors.grey.shade300,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: viewModel.isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Setuju & Kunci Kesepakatan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            )
          else if (isLocked)
            // Lanjut ke serah terima (Modul 4) setelah kesepakatan terkunci
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SerahTerimaQrScreen()),
              ),
              icon: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF0D9488)),
              label: const Text(
                'Buka Serah Terima QR',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFF0D9488)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          else if (deal.myConfirmed && deal.status != 'Selesai')
            // BR-18: setelah satu pihak mengonfirmasi
            Text(
              'Menunggu konfirmasi ${deal.partnerName}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssetItem(String name, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.grey.shade500, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color valueColor = Colors.black87}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}
