import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/app_strings.dart';
import '../../models/meetup.dart';
import '../../services/maps_launcher_service.dart';
import '../../services/meetup_repository.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../handover/qr_scanner_screen.dart';
import '../handover/riwayat_transaksi_screen.dart';
import '../handover/serah_terima_qr_screen.dart';
import 'meetup_form_screen.dart';
import '../../utils/error_message.dart';

class MeetupDetailScreen extends StatefulWidget {
  final int meetupId;

  const MeetupDetailScreen({super.key, required this.meetupId});

  @override
  State<MeetupDetailScreen> createState() => _MeetupDetailScreenState();
}

class _MeetupDetailScreenState extends State<MeetupDetailScreen> {
  final MeetupRepository _repository = MeetupRepository();

  Meetup? _meetup;

  @override
  void initState() {
    super.initState();
    _loadMeetup();
    _repository.addListener(_loadMeetup);
    _repository.refresh();
  }

  @override
  void dispose() {
    _repository.removeListener(_loadMeetup);
    super.dispose();
  }

  void _loadMeetup() {
    if (!mounted) return;
    setState(() {
      _meetup = _repository.getMeetupById(widget.meetupId);
    });
  }

  /// BR-10 / AC-10: status barang hanya berubah pada jalur Jual.
  bool get _isJualPath => (_meetup?.itemType ?? 'Jual') == 'Jual';

  Future<void> _handleCancel() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Batalkan Pertemuan?',
      message: _isJualPath
          ? 'Membatalkan pertemuan Dikonfirmasi pada jalur Jual akan mengembalikan status barang menjadi "Available".'
          : 'Pertemuan dibatalkan dan QR serah terima tidak berlaku lagi. Kesepakatan ${_meetup?.itemType} tetap berlaku, kamu dapat mengajukan jadwal baru.',
      confirmLabel: 'Batalkan',
      cancelLabel: 'Tutup',
      destructive: true,
      confirmIcon: Icons.cancel_outlined,
    );
    if (!confirmed) return;

    try {
      await _repository.cancelMeetup(
        widget.meetupId,
        reason: 'Dibatalkan oleh pihak terkait',
      );
      if (!mounted) return;
      AppSnackBar.showInfo(
        context,
        _isJualPath
            ? 'Pertemuan dibatalkan. Status barang kembali "Available".'
            : 'Pertemuan dibatalkan.',
      );
      _loadMeetup();
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, errorMessageOf(e));
    }
  }

  /// BR-13: hanya Peminat pembuat ajakan yang dapat menghapus ajakan Diajukan.
  Future<void> _handleDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Ajakan Pertemuan?',
      message:
          'Ajakan yang berstatus Diajukan akan dihapus permanen.',
      confirmLabel: 'Hapus Permanen',
      cancelLabel: AppStrings.cancel,
      destructive: true,
      confirmIcon: Icons.delete_outline,
    );
    if (!confirmed) return;

    try {
      final success = await _repository.deleteMeetup(widget.meetupId);
      if (!mounted || !success) return;
      AppSnackBar.showSuccess(
        context,
        'Ajakan pertemuan berhasil dihapus.',
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, errorMessageOf(e));
    }
  }

  /// FR-08: Pemilik menolak ajakan (status Ditolak, bukan dihapus).
  Future<void> _handleReject() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Tolak Ajakan Pertemuan?',
      message:
          'Ajakan dari ${_meetup?.requesterName ?? 'peminat'} akan ditolak. Peminat dapat mengajukan jadwal lain.',
      confirmLabel: 'Tolak Ajakan',
      cancelLabel: AppStrings.cancel,
      destructive: true,
      confirmIcon: Icons.block,
    );
    if (!confirmed) return;

    try {
      await _repository.rejectMeetup(widget.meetupId);
      if (!mounted) return;
      AppSnackBar.showInfo(context, 'Ajakan pertemuan ditolak.');
      _loadMeetup();
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, errorMessageOf(e));
    }
  }

  Future<void> _handleConfirm() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Konfirmasi Jadwal Pertemuan?',
      message: _isJualPath
          ? 'Menyetujui jadwal pertemuan. Barang akan menjadi Reserved dan ajakan lain otomatis dibatalkan.'
          : 'Menyetujui jadwal pertemuan untuk serah terima ${_meetup?.itemType}.',
      confirmLabel: 'Konfirmasi',
      cancelLabel: 'Kembali',
      confirmIcon: Icons.check_circle_outline,
    );
    if (!confirmed) return;

    try {
      await _repository.confirmMeetup(widget.meetupId);
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Pertemuan berhasil Dikonfirmasi!');
      _loadMeetup();
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, errorMessageOf(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_meetup == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pertemuan')),
        body: const Center(
          child: Text('Pertemuan tidak ditemukan atau telah dihapus.'),
        ),
      );
    }

    final meetup = _meetup!;
    final isOwner = meetup.ownerId == MeetupRepository.currentUserId;
    final partnerName = isOwner ? meetup.requesterName : meetup.ownerName;
    final partnerRole = isOwner ? 'Peminat Barang' : 'Pemilik Barang';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Pertemuan COD',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Banner Status Utama
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: meetup.status),
                    Text(
                      'ID #${meetup.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  meetup.itemTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nominal: ${meetup.itemPrice} • Jalur: ${meetup.itemType}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const Divider(height: 24, color: AppColors.outline),
                InkWell(
                  onTap: () => openUserProfile(
                    context,
                    userId: isOwner ? meetup.requesterId : meetup.ownerId,
                    name: partnerName,
                  ),
                  borderRadius: AppRadius.medium,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryContainer,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partnerName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '$partnerRole · Lihat profil',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Detail Waktu & Lokasi Safe-Meet Point
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi & Waktu Pertemuan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        formatTanggalWib(meetup.scheduledTime),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meetup.safeMeetPoint.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Kategori: ${meetup.safeMeetPoint.category} • Jarak: ${formatJarak(meetup.safeMeetPoint.distanceInMeters)}',
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
                const SizedBox(height: AppSpacing.md),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.medium,
                    border: Border.all(color: AppColors.outline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        meetup.safeMeetPoint.latitude,
                        meetup.safeMeetPoint.longitude,
                      ),
                      initialZoom: 16.5,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.campusshift',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              meetup.safeMeetPoint.latitude,
                              meetup.safeMeetPoint.longitude,
                            ),
                            width: 36,
                            height: 36,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppSecondaryButton(
                  label: 'Buka Rute Navigasi Google Maps',
                  icon: Icons.directions_rounded,
                  onPressed: () async {
                    await MapsLauncherService.openNavigation(
                      latitude: meetup.safeMeetPoint.latitude,
                      longitude: meetup.safeMeetPoint.longitude,
                      destinationTitle: meetup.safeMeetPoint.name,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Banner Sesi QR Serah Terima (Jika Dikonfirmasi)
          if (meetup.isDikonfirmasi) ...[
            StepBanner(
              title: 'Pertemuan Siap Dilaksanakan',
              description:
                  'Gunakan kode QR serah terima saat bertemu di titik Safe-Meet Point untuk verifikasi transaksi.',
              stepNumber: 3,
              actionLabel: isOwner
                  ? 'Tampilkan QR Serah Terima'
                  : 'Pindai QR Serah Terima',
              onAction: () {
                if (isOwner) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SerahTerimaQrScreen(meetup: meetup),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QrScannerScreen(targetMeetup: meetup),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          if (meetup.isSelesai) ...[
            AppPrimaryButton(
              label: 'Lihat Bukti Digital & Ulasan',
              icon: Icons.receipt_long_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RiwayatTransaksiScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Tombol Aksi Konfirmasi / Batalkan
          if (meetup.isDiajukan && isOwner) ...[
            AppPrimaryButton(
              label: 'Konfirmasi Jadwal Pertemuan',
              icon: Icons.check_circle_outline,
              onPressed: _handleConfirm,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSecondaryButton(
              label: 'Tolak Ajakan Pertemuan',
              icon: Icons.block,
              isDestructive: true,
              onPressed: _handleReject,
            ),
          ] else if (meetup.isDiajukan && !isOwner) ...[
            AppPrimaryButton(
              label: 'Ubah Jadwal Pertemuan',
              icon: Icons.edit_calendar_rounded,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MeetupFormScreen(
                      existingMeetup: meetup,
                      itemId: meetup.itemId,
                      itemTitle: meetup.itemTitle,
                      itemPrice: meetup.itemPrice,
                      itemType: meetup.itemType,
                      ownerId: meetup.ownerId,
                      ownerName: meetup.ownerName,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSecondaryButton(
              label: 'Tarik & Hapus Pengajuan',
              icon: Icons.delete_outline,
              isDestructive: true,
              onPressed: _handleDelete,
            ),
          ] else if (meetup.isDikonfirmasi) ...[
            AppSecondaryButton(
              label: 'Batalkan Pertemuan Dikonfirmasi',
              icon: Icons.cancel_outlined,
              isDestructive: true,
              onPressed: _handleCancel,
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
