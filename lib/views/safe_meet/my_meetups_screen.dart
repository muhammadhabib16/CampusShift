import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../models/meetup.dart';
import '../../services/maps_launcher_service.dart';
import '../../services/meetup_repository.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import 'meetup_detail_screen.dart';
import 'meetup_form_screen.dart';

class MyMeetupsScreen extends StatefulWidget {
  const MyMeetupsScreen({super.key});

  @override
  State<MyMeetupsScreen> createState() => _MyMeetupsScreenState();
}

class _MyMeetupsScreenState extends State<MyMeetupsScreen>
    with SingleTickerProviderStateMixin {
  final MeetupRepository _repository = MeetupRepository();
  late TabController _tabController;

  bool _isViewingAsRequester = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  Future<void> _handleDelete(Meetup meetup) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Ajakan Pertemuan?',
      message: 'Ajakan yang masih Diajukan akan dihapus secara permanen dan hilang dari daftar kedua pihak (Aturan BR-13 & AC-11).',
      confirmLabel: 'Hapus Permanen',
      cancelLabel: AppStrings.cancel,
      destructive: true,
      confirmIcon: Icons.delete_outline,
    );

    if (confirmed) {
      final success = await _repository.deleteMeetup(meetup.id);
      if (mounted) {
        if (success) {
          AppSnackBar.showSuccess(
            context,
            'Ajakan pertemuan berhasil dihapus permanen (AC-11).',
          );
          _refresh();
        }
      }
    }
  }

  Future<void> _handleConfirm(Meetup meetup) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Konfirmasi Jadwal Pertemuan?',
      message:
          'Menyetujui pertemuan di ${meetup.safeMeetPoint.name} pada ${meetup.formattedShortDateTime}.\n\n'
          'Sesuai aturan FR-08 & AC-10, barang akan berstatus "Reserved" dan ajakan pertemuan lain untuk barang ini otomatis Dibatalkan.',
      confirmLabel: 'Konfirmasi',
      cancelLabel: 'Kembali',
      confirmIcon: Icons.check_circle_outline,
    );

    if (confirmed) {
      await _repository.confirmMeetup(meetup.id);
      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          'Pertemuan Dikonfirmasi! Status barang menjadi Reserved (AC-10).',
        );
        _refresh();
      }
    }
  }

  Future<void> _handleCancel(Meetup meetup) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Batalkan Pertemuan?',
      message: 'Membatalkan pertemuan yang telah dikonfirmasi akan mengembalikan status barang menjadi "Available" (Aturan BR-10).',
      confirmLabel: 'Batalkan Pertemuan',
      cancelLabel: 'Tutup',
      destructive: true,
      confirmIcon: Icons.cancel_outlined,
    );

    if (confirmed) {
      await _repository.cancelMeetup(
        meetup.id,
        reason: 'Dibatalkan oleh pengguna dari daftar pertemuan',
      );
      if (mounted) {
        AppSnackBar.showInfo(
          context,
          'Pertemuan dibatalkan. Status barang kembali "Available" (BR-10).',
        );
        _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Jadwal Pertemuan Saya',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Ganti Peran Uji (Peminat / Pemilik)',
            icon: Icon(
              _isViewingAsRequester
                  ? Icons.person_pin_circle_rounded
                  : Icons.store_mall_directory_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _isViewingAsRequester = !_isViewingAsRequester;
              });
              AppSnackBar.showInfo(
                context,
                _isViewingAsRequester
                    ? 'Beralih ke sudut pandang: Peminat (Pengaju)'
                    : 'Beralih ke sudut pandang: Pemilik Barang (Penerima)',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Diajukan'),
            Tab(text: 'Dikonfirmasi'),
            Tab(text: 'Selesai/Batal'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMeetupList(null),
              _buildMeetupList('Diajukan'),
              _buildMeetupList('Dikonfirmasi'),
              _buildMeetupList('Selesai', includeCancelled: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMeetupList(
    String? filterStatus, {
    bool includeCancelled = false,
  }) {
    List<Meetup> list = _isViewingAsRequester
        ? _repository.getMeetupsAsRequester()
        : _repository.getMeetupsAsOwner();

    if (filterStatus != null) {
      if (includeCancelled) {
        list = list
            .where((m) => m.status == 'Selesai' || m.status == 'Dibatalkan')
            .toList();
      } else {
        list = list.where((m) => m.status == filterStatus).toList();
      }
    }

    if (list.isEmpty) {
      return const EmptyState(
        title: AppStrings.emptyMeetupTitle,
        description: AppStrings.emptyMeetupDesc,
        icon: Icons.event_busy_rounded,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final meetup = list[index];
        return _buildMeetupCard(meetup);
      },
    );
  }

  Widget _buildMeetupCard(Meetup meetup) {
    final isOwner = meetup.ownerId == MeetupRepository.currentUserId;
    final partnerName = isOwner ? meetup.requesterName : meetup.ownerName;
    final partnerRole = isOwner ? 'Peminat' : 'Pemilik';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MeetupDetailScreen(meetupId: meetup.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(status: meetup.status),
              Text(
                meetup.itemPrice,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            meetup.itemTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Partner ($partnerRole): $partnerName',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(height: 20, color: AppColors.outline),

          // Waktu dan Lokasi
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  formatTanggalWib(meetup.scheduledTime),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${meetup.safeMeetPoint.name} (${formatJarak(meetup.safeMeetPoint.distanceInMeters)})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Baris Aksi
          Row(
            children: [
              Expanded(
                child: AppSecondaryButton(
                  label: 'Buka Rute',
                  icon: Icons.directions_rounded,
                  onPressed: () async {
                    await MapsLauncherService.openNavigation(
                      latitude: meetup.safeMeetPoint.latitude,
                      longitude: meetup.safeMeetPoint.longitude,
                      destinationTitle: meetup.safeMeetPoint.name,
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (meetup.isDiajukan && isOwner) ...[
                Expanded(
                  child: AppPrimaryButton(
                    label: 'Konfirmasi',
                    icon: Icons.check_circle_outline,
                    onPressed: () => _handleConfirm(meetup),
                  ),
                ),
              ] else if (meetup.isDiajukan && !isOwner) ...[
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Ubah Jadwal',
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
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  tooltip: 'Hapus Ajakan',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: () => _handleDelete(meetup),
                ),
              ] else if (meetup.isDikonfirmasi) ...[
                IconButton(
                  tooltip: 'Batalkan Pertemuan',
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: AppColors.error,
                  ),
                  onPressed: () => _handleCancel(meetup),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
