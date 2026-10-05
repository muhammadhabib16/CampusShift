import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grant_claim.dart';
import '../models/social_grant.dart';
import '../viewmodels/grant_claim_viewmodel.dart';

/// Layar "daftar-detail-klaim" — sisi donatur: FR-23 (antrean klaim,
/// terurut urgensi+tanggal dari backend) & FR-24 (approve/reject).
class DaftarDetailKlaimScreen extends StatefulWidget {
  const DaftarDetailKlaimScreen({super.key, required this.grant});
  final SocialGrant grant;

  @override
  State<DaftarDetailKlaimScreen> createState() => _DaftarDetailKlaimScreenState();
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
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pemohon Klaim',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: Column(
        children: [
          _Header(grant: widget.grant, total: vm.claimQueue.length),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.claimQueue.isEmpty
                    ? const Center(child: Text('Belum ada pengajuan klaim.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: vm.claimQueue.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, i) => _ClaimCard(
                          claim: vm.claimQueue[i],
                          // Urutan #0 dari backend = paling prioritas
                          // (sudah di-sort urgensi+tanggal, lihat FR-23).
                          highlighted: i == 0,
                          itemName: widget.grant.itemName,
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
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 48,
              height: 48,
              child: grant.photoUrl.isEmpty
                  ? Container(color: Colors.grey.shade200)
                  : Image.network(grant.photoUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(grant.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    children: [
                      const TextSpan(text: 'Total pengajuan masuk: '),
                      TextSpan(
                        text: '$total Pemohon',
                        style:
                            const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
                      ),
                    ],
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

class _ClaimCard extends StatelessWidget {
  const _ClaimCard({required this.claim, required this.highlighted, required this.itemName});
  final GrantClaim claim;
  final bool highlighted;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    final applicant = claim.applicant; // ApplicantSummary? — lihat models/grant_claim.dart
    final initial = (applicant != null && applicant.name.isNotEmpty)
        ? applicant.name.substring(0, 1)
        : '?';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted ? const Color(0xFF0D9488) : Colors.grey.shade200,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    applicant?.photoUrl != null ? NetworkImage(applicant!.photoUrl!) : null,
                child: applicant?.photoUrl == null ? Text(initial) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(applicant?.name ?? 'Pemohon',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('NIM: ${applicant?.nim ?? '-'}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  ],
                ),
              ),
              Text(_timeAgo(claim.createdAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration:
                BoxDecoration(color: const Color(0xFFF5F4F1), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alasan Kebutuhan',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(claim.justificationText, maxLines: 3, overflow: TextOverflow.ellipsis),
                if (claim.voiceNoteUrl != null) ...[
                  const SizedBox(height: 8),
                  const _VoiceNotePlayer(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: claim.approval == ClaimApproval.pending
                        ? () => context
                            .read<GrantClaimViewModel>()
                            .approveClaim(claim, itemName: itemName)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    child: Text(
                      claim.approval == ClaimApproval.approved ? 'Disetujui' : 'Setujui Penerima',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              if (claim.approval == ClaimApproval.pending) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.read<GrantClaimViewModel>().rejectClaim(claim),
                  child: const Text('Tolak', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
  }
}

/// TODO: hubungkan ke package `audioplayers`/`just_audio` untuk play/pause
/// sungguhan terhadap claim.voiceNoteUrl.
class _VoiceNotePlayer extends StatelessWidget {
  const _VoiceNotePlayer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.play_circle_fill, color: Color(0xFF0D9488), size: 20),
        SizedBox(width: 6),
        Text('Dengar Voice Note',
            style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }
}
