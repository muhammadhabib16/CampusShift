import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/meetup.dart';
import '../../models/safe_meet_point.dart';
import '../../services/meetup_repository.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import 'my_meetups_screen.dart';
import 'safe_meet_directory_screen.dart';

class MeetupFormScreen extends StatefulWidget {
  final Meetup? existingMeetup;
  final SafeMeetPoint? initialSafeMeetPoint;
  final int itemId;
  final String itemTitle;
  final String itemPrice;
  final String itemType;
  final int ownerId;
  final String ownerName;

  const MeetupFormScreen({
    super.key,
    this.existingMeetup,
    this.initialSafeMeetPoint,
    this.itemId = 1,
    this.itemTitle = 'Buku Kalkulus Purcell Edisi 9',
    this.itemPrice = 'Rp 85.000',
    this.itemType = 'Jual',
    this.ownerId = 2,
    this.ownerName = 'Muhammad Racha',
  });

  bool get isEditMode => existingMeetup != null;

  @override
  State<MeetupFormScreen> createState() => _MeetupFormScreenState();
}

class _MeetupFormScreenState extends State<MeetupFormScreen> {
  final MeetupRepository _repository = MeetupRepository();
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  late SafeMeetPoint _selectedPoint;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool _isSubmitting = false;
  String? _validationErrorMessage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    if (widget.isEditMode) {
      final m = widget.existingMeetup!;
      _selectedPoint = m.safeMeetPoint;
      _selectedDate = m.scheduledTime;
      _selectedTime = TimeOfDay.fromDateTime(m.scheduledTime);
      _notesController.text = m.notes;
    } else {
      final defaultTime = now.add(const Duration(hours: 2));
      _selectedPoint =
          widget.initialSafeMeetPoint ?? _repository.getSafeMeetPoints().first;
      _selectedDate = defaultTime;
      _selectedTime = TimeOfDay.fromDateTime(defaultTime);
    }

    _runLiveValidation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  DateTime get _combinedScheduledDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  void _runLiveValidation() {
    final scheduled = _combinedScheduledDateTime;
    final validation = _repository.validateMeetupTime(scheduled);
    setState(() {
      _validationErrorMessage = validation.isValid ? null : validation.message;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)),
      helpText: 'Pilih Tanggal Pertemuan (Maks 14 Hari)',
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _runLiveValidation();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Pilih Jam Pertemuan (Min 1 Jam dari Sekarang)',
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
      _runLiveValidation();
    }
  }

  Future<void> _changeSafeMeetPoint() async {
    final result = await Navigator.of(context).push<SafeMeetPoint>(
      MaterialPageRoute(
        builder: (_) => const SafeMeetDirectoryScreen(isPickerMode: true),
      ),
    );

    if (result != null) {
      setState(() => _selectedPoint = result);
      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          'Titik temu diubah ke: ${result.name}',
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final scheduled = _combinedScheduledDateTime;

    final validation = _repository.validateMeetupTime(scheduled);
    if (!validation.isValid) {
      setState(() {
        _validationErrorMessage = validation.message;
      });
      AppSnackBar.showError(
        context,
        validation.message ??
            'Waktu pertemuan tidak memenuhi syarat minimal 1 jam (BR-07).',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.isEditMode) {
        await _repository.updateMeetup(
          id: widget.existingMeetup!.id,
          newPoint: _selectedPoint,
          newScheduledTime: scheduled,
          newNotes: _notesController.text.trim(),
        );
      } else {
        await _repository.createMeetup(
          itemId: widget.itemId,
          itemTitle: widget.itemTitle,
          itemPrice: widget.itemPrice,
          itemType: widget.itemType,
          ownerId: widget.ownerId,
          ownerName: widget.ownerName,
          safeMeetPoint: _selectedPoint,
          scheduledTime: scheduled,
          notes: _notesController.text.trim(),
        );
      }

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      AppSnackBar.showSuccess(
        context,
        widget.isEditMode
            ? 'Jadwal pertemuan berhasil diperbarui.'
            : 'Ajukan pertemuan berhasil dikirim ke pemilik barang.',
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyMeetupsScreen()),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      AppSnackBar.showError(context, 'Gagal menyimpan jadwal pertemuan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(_selectedDate);
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}.${_selectedTime.minute.toString().padLeft(2, '0')} WIB';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Ubah Jadwal Pertemuan' : 'Ajukan Pertemuan COD',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Banner Langkah Berikutnya (Section 4.3)
            const StepBanner(
              title: 'Kesepakatan Pertemuan COD',
              description: 'Pilih lokasi Safe-Meet Point resmi kampus Unand dan tentukan jadwal yang disepakati kedua belah pihak.',
              stepNumber: 2,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Ringkasan Barang
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Barang Transaksi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.itemTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.itemPrice,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Pemilik: ${widget.ownerName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Pemilihan Titik Temu Resmi
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Titik Temu Resmi Unand',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      AppTextButton(
                        label: 'Ganti Titik',
                        icon: Icons.edit_location_alt_rounded,
                        onPressed: _changeSafeMeetPoint,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: AppRadius.medium,
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedPoint.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '📍 Jarak: ${formatJarak(_selectedPoint.distanceInMeters)} • ${_selectedPoint.category}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Pemilihan Tanggal & Waktu
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Waktu & Jadwal Pertemuan (WIB)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Batas minimal 1 jam dari sekarang & maksimal 14 hari ke depan (BR-07).',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: AppRadius.medium,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outline),
                        borderRadius: AppRadius.medium,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    onTap: _pickTime,
                    borderRadius: AppRadius.medium,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outline),
                        borderRadius: AppRadius.medium,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Indikator Error Validasi BR-07
                  if (_validationErrorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: AppRadius.medium,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _validationErrorMessage!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Catatan Pertemuan
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _notesController,
                    label: 'Catatan Tambahan (Opsional)',
                    hintText: 'Contoh: Saya memakai jaket biru dan menunggu dekat pintu masuk satpam…',
                    maxLines: 3,
                    maxLength: 200,
                    showCounter: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tombol Kirim Pengajuan
            AppPrimaryButton(
              label: widget.isEditMode
                  ? 'Simpan Perubahan Jadwal'
                  : 'Kirim Ajakan Pertemuan',
              icon: Icons.check_circle_outline,
              isLoading: _isSubmitting,
              onPressed: _validationErrorMessage != null ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
