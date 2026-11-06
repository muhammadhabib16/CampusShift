import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/review_model.dart';
import '../../viewmodels/handover_view_model.dart';
import '../../services/meetup_repository.dart';
import '../../theme/app_tokens.dart';

/// FR-20 [W]: Memberi dan menyunting ulasan reputasi mitra transaksi.
/// Create: Rating 1-5 bintang wajib, komentar maks 500 karakter (BR-25).
/// Update: Hanya 1 kali dalam 7 hari setelah dibuat, diberi tanda "Diedit" (BR-26, AC-24).
/// Ulasan TIDAK DAPAT DIHAPUS oleh siapa pun (BR-26, AC-25).
class ReviewFormScreen extends StatefulWidget {
  final int meetupId;
  final String proofNumber;
  final int targetUserId;
  final String targetUserName;
  final ReviewModel? existingReview;

  const ReviewFormScreen({
    super.key,
    required this.meetupId,
    required this.proofNumber,
    required this.targetUserId,
    required this.targetUserName,
    this.existingReview,
  });

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _commentController = TextEditingController();
  int _selectedRating = 5;
  bool _isEditMode = false;
  ReviewModel? _activeReview;

  @override
  void initState() {
    super.initState();
    _checkExistingReview();
  }

  void _checkExistingReview() {
    final vm = context.read<HandoverViewModel>();
    final matches = vm.myReviews.where(
      (r) => r.meetupId == widget.meetupId && r.targetUserId == widget.targetUserId,
    );

    if (widget.existingReview != null) {
      _activeReview = widget.existingReview;
      _isEditMode = true;
    } else if (matches.isNotEmpty) {
      _activeReview = matches.first;
      _isEditMode = true;
    }

    if (_isEditMode && _activeReview != null) {
      _selectedRating = _activeReview!.rating;
      _commentController.text = _activeReview!.comment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final vm = context.read<HandoverViewModel>();
    final currentUserId = MeetupRepository.currentUserId;
    final currentUserName = MeetupRepository.currentUserName;
    final currentUserNim = MeetupRepository.currentUserNim;

    if (_selectedRating < 1 || _selectedRating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating 1-5 bintang wajib dipilih.')),
      );
      return;
    }

    if (_commentController.text.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar maksimal 500 karakter.')),
      );
      return;
    }

    if (_isEditMode) {
      // Validasi BR-26 & AC-24 sebelum update
      if (_activeReview != null && !_activeReview!.canEdit) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Penyuntingan Ditolak'),
            content: Text(
              _activeReview!.isEdited
                  ? 'Ulasan hanya dapat disunting satu kali.'
                  : 'Batas waktu penyuntingan 7 hari telah lewat.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
        return;
      }

      final res = await vm.updateReview(
        reviewId: _activeReview!.id,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
        currentUserId: currentUserId,
      );

      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ulasan berhasil diperbarui dan ditandai "Diedit".'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal memperbarui ulasan.')),
        );
      }
    } else {
      // Create Review baru (FR-20.1)
      final res = await vm.submitReview(
        meetupId: widget.meetupId,
        proofNumber: widget.proofNumber,
        reviewerId: currentUserId,
        reviewerName: currentUserName,
        reviewerNim: currentUserNim,
        targetUserId: widget.targetUserId,
        targetUserName: widget.targetUserName,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terima kasih! Ulasan reputasi berhasil disimpan.'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal menyimpan ulasan.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HandoverViewModel>();
    final canEdit = !_isEditMode || (_activeReview?.canEdit ?? true);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          _isEditMode ? 'Sunting Ulasan' : 'Beri Ulasan Reputasi',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Mitra
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mitra Transaksi:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text(widget.targetUserName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('Bukti: ${widget.proofNumber}', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rating Stars Picker
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  const Text('Berapa bintang untuk mitra ini?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        iconSize: 36,
                        onPressed: canEdit ? () => setState(() => _selectedRating = starValue) : null,
                        icon: Icon(
                          starValue <= _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  Text(
                    _selectedRating == 5
                        ? 'Sangat Baik (5/5)'
                        : _selectedRating == 4
                            ? 'Baik (4/5)'
                            : _selectedRating == 3
                                ? 'Cukup (3/5)'
                                : _selectedRating == 2
                                    ? 'Kurang (2/5)'
                                    : 'Sangat Buruk (1/5)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Komentar Ulasan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Komentar Ulasan (Opsional):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('${_commentController.text.length}/500', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    enabled: canEdit,
                    maxLines: 4,
                    maxLength: 500,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Tuliskan pengalaman bertransaksi di titik temu kampus Unand...',
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Catatan Aturan Bisnis Ulasan (BR-26 & AC-25)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.shield_outlined, size: 18, color: Color(0xFFB45309)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Penting: Ulasan bersifat permanen dan tidak dapat dihapus oleh siapa pun. Penyuntingan hanya dapat dilakukan 1 kali dalam 7 hari setelah transaksi selesai.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Simpan
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: canEdit && !vm.isSubmitting ? _handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: vm.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditMode ? 'Simpan Perubahan Ulasan' : 'Kirim Ulasan Reputasi',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}