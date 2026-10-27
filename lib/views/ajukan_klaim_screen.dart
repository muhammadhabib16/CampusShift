import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../models/grant_claim.dart';
import '../models/social_grant.dart';
import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../viewmodels/grant_claim_viewmodel.dart';

/// Layar Pengajuan Klaim Hibah — FR-22 (pemohon mengajukan klaim dengan
/// justifikasi akademik minimal 100–1.000 karakter dan tingkat urgensi).
class AjukanKlaimScreen extends StatefulWidget {
  const AjukanKlaimScreen({
    super.key,
    required this.grant,
    required this.currentUserNim,
  });

  final SocialGrant grant;
  final String currentUserNim;

  @override
  State<AjukanKlaimScreen> createState() => _AjukanKlaimScreenState();
}

class _AjukanKlaimScreenState extends State<AjukanKlaimScreen> {
  final _justificationCtrl = TextEditingController();
  ClaimUrgency _urgency = ClaimUrgency.sedang;
  String? _voiceNotePath;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _justificationCtrl.addListener(() {
      final len = _justificationCtrl.text.trim().length;
      if (len != _charCount) {
        setState(() {
          _charCount = len;
        });
      }
    });
  }

  @override
  void dispose() {
    _justificationCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid => _charCount >= 100 && _charCount <= 1000;

  Future<void> _submit() async {
    if (!_isFormValid) return;

    final vm = context.read<GrantClaimViewModel>();
    final ok = await vm.submitClaim(
      grantId: widget.grant.id,
      urgency: _urgency,
      justificationText: _justificationCtrl.text,
      voiceNoteFilePath: _voiceNotePath,
    );

    if (!mounted) return;

    if (ok) {
      AppSnackBar.showSuccess(
        context,
        'Pengajuan klaim berhasil dikirim. Menunggu kurasi donatur.',
      );
      Navigator.pop(context);
    } else if (vm.errorMessage != null) {
      AppSnackBar.showError(context, vm.errorMessage!);
    }
  }

  String _urgencyLabel(ClaimUrgency u) => switch (u) {
    ClaimUrgency.mendesak => 'Mendesak',
    ClaimUrgency.sedang => 'Sedang',
    ClaimUrgency.rendah => 'Rendah',
  };

  Color _urgencyColor(ClaimUrgency u) => switch (u) {
    ClaimUrgency.mendesak => AppColors.error,
    ClaimUrgency.sedang => AppColors.accent,
    ClaimUrgency.rendah => AppColors.primary,
  };

  Color _urgencyBgColor(ClaimUrgency u) => switch (u) {
    ClaimUrgency.mendesak => const Color(0xFFFEE2E2),
    ClaimUrgency.sedang => const Color(0xFFFEF3C7),
    ClaimUrgency.rendah => AppColors.primaryContainer,
  };

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GrantClaimViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ajukan Klaim Hibah'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Banner
            const StepBanner(
              title: 'Langkah 1 dari 2: Verifikasi Kebutuhan',
              description: 'Berikan justifikasi yang jujur dan objektif agar donatur dapat memprioritaskan penerima yang paling membutuhkan (AC-27).',
              stepNumber: 1,
            ),
            const SizedBox(height: AppSpacing.md),

            // Ringkasan Barang Hibah
            _GrantSummaryCard(grant: widget.grant),
            const SizedBox(height: AppSpacing.lg),

            // Tingkat Urgensi
            const Text(
              'Tingkat Urgensi Kebutuhan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Pilih tingkat urgensi untuk membantu donatur mengurutkan antrean prioritas.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: ClaimUrgency.values.map((u) {
                final selected = _urgency == u;
                final color = _urgencyColor(u);
                final bgColor = _urgencyBgColor(u);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _urgency = u),
                      borderRadius: AppRadius.medium,
                      child: AnimatedContainer(
                        duration: AppDurations.quick,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? bgColor : AppColors.surface,
                          borderRadius: AppRadius.medium,
                          border: Border.all(
                            color: selected ? color : AppColors.outline,
                            width: selected ? 1.5 : 1,
                          ),
                          boxShadow: selected ? AppElevation.softShadow : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              u == ClaimUrgency.mendesak
                                  ? Icons.priority_high_rounded
                                  : u == ClaimUrgency.sedang
                                  ? Icons.schedule_rounded
                                  : Icons.low_priority_rounded,
                              size: 18,
                              color: selected ? color : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _urgencyLabel(u),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? color
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Input Alasan Kebutuhan
            AppTextField(
              label: 'Alasan Kebutuhan & Justifikasi Akademik',
              hintText: 'Jelaskan mengapa kamu membutuhkan barang ini untuk menunjang perkuliahan...',
              controller: _justificationCtrl,
              maxLines: 4,
              maxLength: 1000,
              showCounter: true,
              helperText: _charCount < 100
                  ? 'Minimal 100 karakter (saat ini: $_charCount/100)'
                  : 'Syarat minimal 100 karakter terpenuhi',
            ),
            const SizedBox(height: AppSpacing.md),

            // Verifikasi Mahasiswa (NIM)
            const Text(
              'Identitas Mahasiswa Pengaju',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.school_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'NIM: ${widget.currentUserNim} (Mahasiswa Aktif)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Rekam Voice Note Opsional
            _VoiceNoteRecorder(
              onRecorded: (path) => setState(() => _voiceNotePath = path),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Tombol Kirim Klaim
            AppPrimaryButton(
              label: 'Kirim Pengajuan Klaim',
              icon: Icons.send_rounded,
              isLoading: vm.isLoading,
              onPressed: _isFormValid && !vm.isLoading ? _submit : null,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _GrantSummaryCard extends StatelessWidget {
  const _GrantSummaryCard({required this.grant});
  final SocialGrant grant;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.small,
            child: SizedBox(
              width: 58,
              height: 58,
              child: grant.photoUrl.isEmpty
                  ? Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.volunteer_activism_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    )
                  : Image.network(
                      grant.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PriceTag(price: 0, isGrant: true),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.small,
                      ),
                      child: Text(
                        grant.academicCategory,
                        style: const TextStyle(
                          color: AppColors.onPrimaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  grant.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Donatur: ${grant.donorName}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Perekam voice note opsional dengan package `record`.
class _VoiceNoteRecorder extends StatefulWidget {
  const _VoiceNoteRecorder({required this.onRecorded});
  final ValueChanged<String?> onRecorded;

  @override
  State<_VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<_VoiceNoteRecorder> {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _filePath;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _filePath = path;
      });
      widget.onRecorded(path);
      return;
    }
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/claim_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      setState(() => _isRecording = true);
    } else if (mounted) {
      AppSnackBar.showError(
        context,
        'Izin mikrofon diperlukan untuk merekam voice note.',
      );
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isRecording
                  ? const Color(0xFFFEE2E2)
                  : AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: _isRecording ? AppColors.error : AppColors.primary,
                size: 24,
              ),
              onPressed: _toggleRecording,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isRecording
                      ? 'Sedang Merekam…'
                      : _filePath != null
                      ? 'Voice Note Tersimpan'
                      : 'Rekam Voice Note (Opsional)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isRecording
                      ? 'Ketuk tombol stop jika selesai berbicara'
                      : _filePath != null
                      ? 'Pesan suara siap dikirim bersama justifikasi'
                      : 'Dapat menambahkan penjelasan lisan untuk donatur',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_filePath != null && !_isRecording)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              onPressed: () {
                setState(() => _filePath = null);
                widget.onRecorded(null);
              },
              tooltip: 'Hapus Rekaman',
            ),
        ],
      ),
    );
  }
}
