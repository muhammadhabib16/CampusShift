import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/formatters.dart';
import '../../viewmodels/barter_view_model.dart';
import 'widgets/barter_visuals.dart';

class BarterNegotiationScreen extends StatefulWidget {
  const BarterNegotiationScreen({super.key});

  @override
  State<BarterNegotiationScreen> createState() => _BarterNegotiationScreenState();
}

class _BarterNegotiationScreenState extends State<BarterNegotiationScreen> {
  late final TextEditingController _cashAdditionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Nilai awal top-up diambil dari ViewModel (menutup selisih harga).
    _cashAdditionController = TextEditingController(
      text: context.read<BarterViewModel>().suggestedTopUp.toString(),
    );
  }

  @override
  void dispose() {
    _cashAdditionController.dispose();
    super.dispose();
  }

  Future<void> _submitProposal() async {
    // 1. Validasi form memakai aturan dari ViewModel
    if (!_formKey.currentState!.validate()) return;

    // 2. Kirim lewat ViewModel; state loading dikelola ViewModel
    final viewModel = context.read<BarterViewModel>();
    final success = await viewModel.submitProposal(_cashAdditionController.text);
    if (!mounted) return;

    // 3. Feedback & navigasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Penawaran Barter Berhasil Dikirim!'
            : viewModel.errorMessage ?? 'Gagal mengirim penawaran'),
        backgroundColor: success ? const Color(0xFF0D9488) : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BarterViewModel>();
    final offeredItem = viewModel.selectedItem;
    final targetItem = viewModel.targetItem;
    final difference = viewModel.priceDifference;
    final isSubmitting = viewModel.isSubmitting;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Negosiasi Barter',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Exchange Card
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildItemColumn(
                      'Barang Kamu',
                      offeredItem?.name ?? '-',
                      offeredItem == null ? '-' : formatRupiah(offeredItem.price),
                      BarterVisuals.iconForCategory(offeredItem?.category ?? ''),
                      const Color(0xFF0D9488),
                    ),
                    const Icon(Icons.swap_horiz, color: Color(0xFF0D9488), size: 28),
                    _buildItemColumn(
                      'Barang Mereka',
                      targetItem?.name ?? '-',
                      targetItem == null ? '-' : formatRupiah(targetItem.price),
                      BarterVisuals.iconForCategory(targetItem?.category ?? ''),
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Price Difference
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selisih Harga:',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    difference > 0
                        ? '- ${formatRupiah(difference)}'
                        : '+ ${formatRupiah(-difference)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: difference > 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Tambah Selisih Tunai (Rp)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cashAdditionController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(color: Colors.black87, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF0D9488)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: viewModel.validateTopUp,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submitProposal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              disabledBackgroundColor: Colors.grey.shade300,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Kirim Penawaran Barter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemColumn(String label, String name, String price, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey.shade400, size: 40),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
