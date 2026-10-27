import 'package:flutter/material.dart';
import '../models/grant_claim.dart';
import '../models/social_grant.dart';
import '../viewmodels/grant_claim_viewmodel.dart';

class AjukanKlaimScreen extends StatefulWidget {
  final SocialGrant? grant;
  final GrantClaim? existingClaim;
  final GrantClaimViewModel? viewModel;

  const AjukanKlaimScreen({
    super.key,
    this.grant,
    this.existingClaim,
    this.viewModel,
  });

  @override
  State<AjukanKlaimScreen> createState() => _AjukanKlaimScreenState();
}

class _AjukanKlaimScreenState extends State<AjukanKlaimScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _justificationController;
  late final GrantClaimViewModel _vm;
  String _selectedUrgency = 'Mendesak';
  bool _isSubmitting = false;

  static const List<Map<String, dynamic>> _urgencyOptions = [
    {
      'value': 'Mendesak',
      'label': 'Mendesak',
      'desc': 'Dibutuhkan segera untuk kuliah/praktikum minggu ini',
      'color': Color(0xFFDC2626),
      'icon': Icons.priority_high_rounded,
    },
    {
      'value': 'Sedang',
      'label': 'Sedang',
      'desc': 'Dibutuhkan untuk menunjang perkuliahan semester ini',
      'color': Color(0xFFD97706),
      'icon': Icons.schedule_rounded,
    },
    {
      'value': 'Rendah',
      'label': 'Rendah',
      'desc': 'Bermanfaat sebagai perlengkapan belajar tambahan',
      'color': Color(0xFF0D9488),
      'icon': Icons.low_priority_rounded,
    },
  ];

  bool get _isEditMode => widget.existingClaim != null;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel ?? GrantClaimViewModel();
    _selectedUrgency = widget.existingClaim?.urgency ?? 'Mendesak';
    _justificationController = TextEditingController(
      text: widget.existingClaim?.justification ?? '',
    );
    _justificationController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  int get _charCount => _justificationController.text.trim().length;
  bool get _isJustificationValid => _charCount >= 100 && _charCount <= 1000;

  Future<void> _handleSubmit() async {
    if (!_isJustificationValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Justifikasi kebutuhan wajib minimal 100 karakter dan maksimal 1.000 karakter (BR-27).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    if (_isEditMode) {
      final claim = widget.existingClaim!;
      if (claim.status != 'Pending') {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Klaim berstatus ${claim.status} tidak dapat disunting (AC-30).'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final ok = await _vm.updateClaim(
        claimId: claim.id,
        urgency: _selectedUrgency,
        justification: _justificationController.text.trim(),
      );
      setState(() => _isSubmitting = false);

      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan klaim berhasil disimpan.'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_vm.errorMessage ?? 'Gagal memperbarui klaim.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final itemTitle = widget.grant?.title ?? 'Buku Kalkulus Purcell Edisi 9';
    final itemId = widget.grant?.id ?? 'item-hibah-001';
    final donorId = widget.grant?.ownerUserId ?? 'user-raka-001';
    final donorName = widget.grant?.ownerName ?? 'Raka Pratama (Teknik 22)';

    final created = await _vm.submitClaim(
      itemId: itemId,
      itemTitle: itemTitle,
      donorUserId: donorId,
      donorName: donorName,
      urgency: _selectedUrgency,
      justification: _justificationController.text.trim(),
    );

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Klaim hibah berhasil diajukan! Menunggu persetujuan donatur.'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
      Navigator.pop(context, created);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_vm.errorMessage ?? 'Gagal mengajukan klaim.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemTitle = _isEditMode
        ? widget.existingClaim!.itemTitle
        : (widget.grant?.title ?? 'Barang Hibah Kampus');
    final itemCategory = _isEditMode
        ? widget.existingClaim!.itemCategory
        : (widget.grant?.category ?? 'Buku & Referensi');
    final itemCondition = _isEditMode
        ? widget.existingClaim!.itemCondition
        : (widget.grant?.condition ?? 'Sangat Baik');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Sunting Klaim Hibah' : 'Form Klaim Hibah'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  color: const Color(0xFFF0FDFA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF99F6E4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.volunteer_activism_rounded,
                            color: Color(0xFF0D9488),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$itemCategory • Kondisi: $itemCondition • Gratis (Rp0)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber.shade900),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aturan Klaim (FR-23 & BR-28): Maksimal 1 klaim per barang dan maksimal 3 klaim aktif (Pending/Approved) sekaligus.',
                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '1. Pilih Tingkat Urgensi Kebutuhan *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ..._urgencyOptions.map((opt) {
                  final String value = opt['value'] as String;
                  final bool isSelected = _selectedUrgency == value;
                  final Color color = opt['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _selectedUrgency = value),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey.shade300,
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(opt['icon'] as IconData, color: color),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['label'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  Text(
                                    opt['desc'] as String,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected ? color : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        '2. Justifikasi Kebutuhan (100–1.000 karakter) *',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isJustificationValid
                            ? const Color(0xFF0D9488).withValues(alpha: 0.12)
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$_charCount / 1000',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isJustificationValid ? const Color(0xFF0D9488) : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _justificationController,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText:
                        'Jelaskan secara jujur dan spesifik mengapa Anda membutuhkan barang hibah ini untuk kegiatan perkuliahan Anda di Universitas Andalas (minimal 100 karakter)...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                    ),
                    helperText: _charCount < 100
                        ? 'Minimal 100 karakter (kurang ${100 - _charCount} karakter lagi)'
                        : 'Panjang justifikasi sudah memenuhi syarat (BR-27).',
                    helperStyle: TextStyle(
                      color: _charCount < 100 ? Colors.red.shade700 : const Color(0xFF0D9488),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.length < 100) {
                      return 'Minimal 100 karakter diperlukan (AC-27).';
                    }
                    if (text.length > 1000) {
                      return 'Maksimal 1.000 karakter (BR-27).';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: (_isSubmitting || !_isJustificationValid) ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(_isEditMode ? Icons.save_rounded : Icons.send_rounded),
                    label: Text(
                      _isEditMode ? 'Simpan Perubahan Klaim' : 'Kirim Klaim Hibah',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
