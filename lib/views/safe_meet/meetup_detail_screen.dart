import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/app_strings.dart';
import '../../models/handover_token_model.dart';
import '../../models/meetup.dart';
import '../../services/maps_launcher_service.dart';
import '../../services/meetup_repository.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../handover/serah_terima_qr_screen.dart';
import 'meetup_form_screen.dart';

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
  }

  void _loadMeetup() {
    setState(() {
      _meetup = _repository.getMeetupById(widget.meetupId);
    });
  }

  Future<void> _handleCancel() async {
    final reasonController = TextEditingController();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Batalkan Pertemuan?',
      message: 'Sesuai aturan BR-10, membatalkan pertemuan Dikonfirmasi pada jalur Jual akan mengembalikan status barang menjadi "Available".',
      confirmLabel: 'Batalkan',
      cancelLabel: 'Tutup',
      destructive: true,
      confirmIcon: Icons.cancel_outlined,
    );

    if (confirmed) {
      await _repository.cancelMeetup(
        widget.meetupId,
        reason: reasonController.text.trim().isNotEmpty
            ? reasonController.text.trim()
            : 'Dibatalkan oleh pihak terkait',
      );
      if (mounted) {
        AppSnackBar.showInfo(
          context,
          'Pertemuan dibatalkan. Status barang kembali "Available" (BR-10).',
        );
        _loadMeetup();
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Ajakan Pertemuan?',
      message: 'Ajakan yang berstatus Diajukan akan dihapus permanen (Aturan BR-13 & AC-11).',
      confirmLabel: 'Hapus Permanen',
      cancelLabel: AppStrings.cancel,
      destructive: true,
      confirmIcon: Icons.delete_outline,
    );

    if (confirmed) {
      final success = await _repository.deleteMeetup(widget.meetupId);
      if (mounted) {
        if (success) {
          AppSnackBar.showSuccess(
            context,
            'Ajakan pertemuan berhasil dihapus (AC-11).',
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _handleConfirm() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Konfirmasi Jadwal Pertemuan?',
      message: 'Menyetujui jadwal pertemuan. Barang akan menjadi Reserved dan ajakan lain otomatis dibatalkan (FR-08 & AC-10).',
      confirmLabel: 'Konfirmasi',
      cancelLabel: 'Kembali',
      confirmIcon: Icons.check_circle_outline,
    );

    if (confirmed) {
      await _repository.confirmMeetup(widget.meetupId);
      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          'Pertemuan berhasil Dikonfirmasi! (AC-10)',
        );
        _loadMeetup();
      }
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
                Row(
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
                            partnerRole,
                            style: const TextStyle(
                              fontSize: 11,
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
              description: 'Gunakan kode QR serah terima saat bertemu di titik Safe-Meet Point untuk verifikasi transaksi.',
              stepNumber: 3,
              actionLabel: 'Buka Sesi QR Serah Terima',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SerahTerimaQrScreen(
                      meetupDetail: MeetupDetailModel.fromMeetup(
                        meetup,
                        viewerId: MeetupRepository.currentUserId,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
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
              label: 'Tolak & Hapus Pertemuan',
              icon: Icons.delete_outline,
              isDestructive: true,
              onPressed: _handleDelete,
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
