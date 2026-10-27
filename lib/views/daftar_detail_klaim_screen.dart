import 'package:flutter/material.dart';
import '../models/grant_claim.dart';
import '../viewmodels/grant_claim_viewmodel.dart';
import 'ajukan_klaim_screen.dart';

class DaftarDetailKlaimScreen extends StatefulWidget {
  final GrantClaimViewModel? viewModel;
  final int initialTabIndex;

  const DaftarDetailKlaimScreen({
    super.key,
    this.viewModel,
    this.initialTabIndex = 0,
  });

  @override
  State<DaftarDetailKlaimScreen> createState() =>
      _DaftarDetailKlaimScreenState();
}

class _DaftarDetailKlaimScreenState extends State<DaftarDetailKlaimScreen>
    with SingleTickerProviderStateMixin {
  late final GrantClaimViewModel _vm;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel ?? GrantClaimViewModel();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _vm.addListener(_onVmChanged);
    _vm.syncClaims();
  }

  void _onVmChanged() {
    if (!mounted) return;
    final alerts = _vm.consumeNotifications();
    for (final msg in alerts) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: const Color(0xFF0D9488),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF16A34A);
      case 'Pending':
        return const Color(0xFFD97706);
      case 'Rejected':
        return const Color(0xFFDC2626);
      case 'Cancelled':
        return Colors.grey.shade700;
      case 'Completed':
        return const Color(0xFF0D9488);
      default:
        return Colors.blueGrey;
    }
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'Mendesak':
        return const Color(0xFFDC2626);
      case 'Sedang':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF0D9488);
    }
  }

  Future<void> _confirmDeletePending(GrantClaim claim) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Klaim Permanen?'),
        content: Text(
          'Klaim untuk "${claim.itemTitle}" masih berstatus Pending. '
          'Jika dihapus, data klaim akan hilang permanen dari basis data dan antrean donatur, serta kuota klaim aktif Anda akan berkurang (BR-32).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await _vm.deletePendingClaim(claim.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Klaim Pending berhasil dihapus permanen (AC-31).'
                : (_vm.errorMessage ?? 'Gagal menghapus klaim.'),
          ),
          backgroundColor: ok ? const Color(0xFF0D9488) : Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _confirmCancelApproved(GrantClaim claim) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Klaim yang Disetujui?'),
        content: Text(
          'Klaim "${claim.itemTitle}" akan diubah menjadi Cancelled dan status barang dikembalikan menjadi Available (BR-31).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan Klaim'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await _vm.cancelApprovedClaim(claim.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Klaim dibatalkan (Cancelled) dan barang kembali Available (BR-31).'
                : (_vm.errorMessage ?? 'Gagal membatalkan klaim.'),
          ),
          backgroundColor: ok ? const Color(0xFF0D9488) : Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _showRejectDialog(GrantClaim claim) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tolak Klaim ${claim.applicantName}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anda dapat menyertakan alasan penolakan singkat (opsional) yang akan terlihat oleh pemohon (BR-30):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Contoh: Barang diprioritaskan untuk mahasiswa semester 1',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tolak Klaim'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _vm.rejectClaimByDonor(claim.id, reason: reasonCtrl.text);
    }
  }

  void _openClaimDetailSheet(GrantClaim claim, {required bool isDonorView}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _urgencyColor(claim.urgency).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Urgensi: ${claim.urgency}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _urgencyColor(claim.urgency),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(claim.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Status: ${claim.status}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _statusColor(claim.status),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  claim.itemTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pemohon: ${claim.applicantName} • Reputasi: ${claim.reputationLabel}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const Divider(height: 24),
                const Text(
                  'Justifikasi Kebutuhan (FR-23):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    claim.justification,
                    style: const TextStyle(fontSize: 13.5, height: 1.45),
                  ),
                ),
                if (claim.rejectionReason != null && claim.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'Alasan Penolakan: ${claim.rejectionReason}',
                      style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (!isDonorView && claim.status == 'Pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AjukanKlaimScreen(
                                  existingClaim: claim,
                                  viewModel: _vm,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Sunting Klaim'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _confirmDeletePending(claim);
                          },
                          icon: const Icon(Icons.delete_forever_rounded),
                          label: const Text('Hapus Permanen'),
                        ),
                      ),
                    ],
                  ),
                ] else if (!isDonorView && claim.status == 'Approved') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Mengarahkan ke Modul 2 (Jadwal Pertemuan Safe-Meet Point) dengan claim_id=${claim.id} & item_id=${claim.itemId}',
                            ),
                            backgroundColor: const Color(0xFF0D9488),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_on_rounded),
                      label: const Text('Jadwalkan Pengambilan di Safe-Meet Point (Modul 2)'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmCancelApproved(claim);
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Batalkan Klaim (BR-31)'),
                    ),
                  ),
                ] else if (isDonorView && claim.status == 'Pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showRejectDialog(claim);
                          },
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _vm.approveClaimByDonor(claim.id);
                          },
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text('Setujui Pemohon'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Klaim & Antrean Hibah'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Sinkronisasi Server (FR-27)',
            onPressed: () => _vm.syncClaims(),
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.assignment_ind_rounded), text: 'Klaim Saya (Pemohon)'),
            Tab(icon: Icon(Icons.queue_play_next_rounded), text: 'Antrean Klaim (Donatur)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyClaimsTab(),
          _buildDonorQueueTab(),
        ],
      ),
    );
  }

  Widget _buildMyClaimsTab() {
    if (_vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = _vm.myClaims;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                'Belum ada klaim hibah. Cari barang gratis di Katalog Hibah.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _vm.syncClaims(),
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final claim = list[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openClaimDetailSheet(claim, isDonorView: false),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _urgencyColor(claim.urgency).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            claim.urgency,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: _urgencyColor(claim.urgency),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(claim.status).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            claim.status,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: _statusColor(claim.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      claim.itemTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      claim.justification,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (claim.canEditOrDelete) ...[
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AjukanKlaimScreen(
                                    existingClaim: claim,
                                    viewModel: _vm,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                            onPressed: () => _confirmDeletePending(claim),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Hapus'),
                          ),
                        ] else if (claim.canCancelApproved) ...[
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.orange.shade800),
                            onPressed: () => _confirmCancelApproved(claim),
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: const Text('Batalkan'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDonorQueueTab() {
    if (_vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final queue = _vm.donorQueue;
    return RefreshIndicator(
      onRefresh: () => _vm.syncClaims(),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF99F6E4)),
            ),
            child: const Text(
              'Antrean Prioritas Donatur (FR-25 & BR-29): Diurutkan otomatis berdasarkan Urgensi (Mendesak → Sedang → Rendah), lalu waktu pengajuan terlama. Menyetujui 1 pemohon otomatis mengubah barang menjadi Reserved dan menolak klaim lainnya (AC-29).',
              style: TextStyle(fontSize: 12, color: Color(0xFF115E59)),
            ),
          ),
          ...queue.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final claim = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openClaimDetailSheet(claim, isDonorView: true),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
                            child: Text(
                              '#$idx',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D9488),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  claim.applicantName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  'Reputasi: ${claim.reputationLabel}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _urgencyColor(claim.urgency).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              claim.urgency,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _urgencyColor(claim.urgency),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Barang: ${claim.itemTitle}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        claim.justification,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status: ${claim.status}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _statusColor(claim.status),
                            ),
                          ),
                          if (claim.status == 'Pending')
                            Row(
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => _showRejectDialog(claim),
                                  child: const Text('Tolak'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    foregroundColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => _vm.approveClaimByDonor(claim.id),
                                  child: const Text('Setujui'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
