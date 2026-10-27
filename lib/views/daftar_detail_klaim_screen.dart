import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_strings.dart';
import '../models/grant_claim.dart';
import '../models/social_grant.dart';
import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../utils/formatters.dart';
import '../viewmodels/grant_claim_viewmodel.dart';
import 'digital_claim_pass_screen.dart';

/// Layar Antrean Klaim Hibah (Sisi Donatur) — FR-23 (antrean klaim terurut urgensi+tanggal)
/// dan FR-24 (persetujuan/penolakan pemohon klaim).
class DaftarDetailKlaimScreen extends StatefulWidget {
  const DaftarDetailKlaimScreen({super.key, required this.grant});
  final SocialGrant grant;

  @override
  State<DaftarDetailKlaimScreen> createState() =>
      _DaftarDetailKlaimScreenState();
}

class _DaftarDetailKlaimScreenState extends State<DaftarDetailKlaimScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GrantClaimViewModel>().loadClaimQueue(widget.grant.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GrantClaimViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Antrean Pemohon Klaim'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Barang Donasi
          _Header(grant: widget.grant, total: vm.claimQueue.length),

          // Daftar Antrean atau State (PRD 2.10)
          Expanded(
            child: vm.isLoading
                ? const LoadingState(label: 'Memuat antrean pengajuan klaim…')
                : vm.errorMessage != null
                ? ErrorState(
                    title: 'Gagal Memuat Antrean',
                    message: vm.errorMessage!,
                    onRetry: () => context
                        .read<GrantClaimViewModel>()
                        .loadClaimQueue(widget.grant.id),
                  )
                : vm.claimQueue.isEmpty
                ? const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Belum Ada Pengajuan Klaim',
                    description: 'Belum ada mahasiswa yang mengajukan klaim untuk barang hibah ini.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: vm.claimQueue.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) => _ClaimCard(
                      queueNumber: i + 1,
                      claim: vm.claimQueue[i],
                      grant: widget.grant,
                      isHighestPriority: i == 0,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.grant, required this.total});
  final SocialGrant grant;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.small,
            child: SizedBox(
              width: 52,
              height: 52,
              child: grant.photoUrl.isEmpty
                  ? Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.volunteer_activism_outlined,
                        color: AppColors.primary,
                        size: 26,
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
                Row(
                  children: [
                    const Text(
                      'Total Antrean: ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$total Pemohon',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  const _ClaimCard({
    required this.queueNumber,
    required this.claim,
    required this.grant,
    required this.isHighestPriority,
  });

  final int queueNumber;
  final GrantClaim claim;
  final SocialGrant grant;
  final bool isHighestPriority;

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
    final applicant = claim.applicant;
    final applicantName = applicant?.name ?? 'Pemohon #$queueNumber';
    final applicantNim = applicant?.nim ?? '-';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris Pemohon & Nomor Antrean
          Row(
            children: [
              // Badge Nomor Urut
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isHighestPriority
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$queueNumber',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isHighestPriority
                          ? AppColors.onPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Avatar & Identitas
              Expanded(
                child: AvatarWithName(
                  name: applicantName,
                  subtitle: 'NIM: $applicantNim',
                  radius: 18,
                ),
              ),

              // Badge Urgensi
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _urgencyBgColor(claim.urgency),
                  borderRadius: AppRadius.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      claim.urgency == ClaimUrgency.mendesak
                          ? Icons.priority_high_rounded
                          : Icons.schedule_rounded,
                      size: 12,
                      color: _urgencyColor(claim.urgency),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _urgencyLabel(claim.urgency),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _urgencyColor(claim.urgency),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Kotak Alasan Kebutuhan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadius.medium,
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Justifikasi Akademik:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      formatWaktuRelatif(claim.createdAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  claim.justificationText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                if (claim.voiceNoteUrl != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const _VoiceNotePlayer(),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Tombol Aksi: Setujui & Tolak
          if (claim.approval == ClaimApproval.pending) ...[
            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    label: 'Setujui Pemohon',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: () => _confirmApproval(context, applicantName),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Tolak',
                    icon: Icons.close_rounded,
                    isDestructive: true,
                    onPressed: () => _confirmRejection(context, applicantName),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: claim.approval == ClaimApproval.approved
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEE2E2),
                borderRadius: AppRadius.medium,
              ),
              child: Center(
                child: Text(
                  claim.approval == ClaimApproval.approved
                      ? '✓ Disetujui sebagai Penerima'
                      : '✕ Pengajuan Ditolak',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: claim.approval == ClaimApproval.approved
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ),
            ),
            if (claim.approval == ClaimApproval.approved &&
                claim.digitalClaimPassCode != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppSecondaryButton(
                label: 'Lihat Pass Pengambilan Digital',
                icon: Icons.qr_code_2_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DigitalClaimPassScreen(
                        claim: claim,
                        grant: grant,
                        recipientName: applicantName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _confirmApproval(
    BuildContext context,
    String applicantName,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Setujui Penerima Hibah?',
      message:
          'Apakah Anda yakin menyetujui $applicantName sebagai penerima barang "${grant.itemName}"? Tiket Digital Claim Pass akan otomatis diterbitkan.',
      confirmLabel: 'Ya, Setujui',
      cancelLabel: AppStrings.cancel,
      confirmIcon: Icons.check_circle_outline_rounded,
    );

    if (confirmed == true && context.mounted) {
      await context.read<GrantClaimViewModel>().approveClaim(
        claim,
        itemName: grant.itemName,
      );
      if (context.mounted) {
        AppSnackBar.showSuccess(
          context,
          '$applicantName berhasil disetujui sebagai penerima.',
        );
      }
    }
  }

  Future<void> _confirmRejection(
    BuildContext context,
    String applicantName,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Tolak Pengajuan Klaim?',
      message:
          'Apakah Anda yakin menolak pengajuan dari $applicantName? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Ya, Tolak',
      cancelLabel: AppStrings.cancel,
      destructive: true,
      confirmIcon: Icons.block_rounded,
    );

    if (confirmed == true && context.mounted) {
      await context.read<GrantClaimViewModel>().rejectClaim(claim);
      if (context.mounted) {
        AppSnackBar.showInfo(
          context,
          'Pengajuan $applicantName telah ditolak.',
        );
      }
    }
  }
}

class _VoiceNotePlayer extends StatelessWidget {
  const _VoiceNotePlayer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.pill,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_fill_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          SizedBox(width: 4),
          Text(
            'Dengarkan Penjelasan Suara',
            style: TextStyle(
              color: AppColors.onPrimaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
