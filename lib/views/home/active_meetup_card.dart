import 'package:flutter/material.dart';

import '../../models/handover_token_model.dart';
import '../../models/meetup.dart';
import '../../services/meetup_repository.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../theme/app_tokens.dart';
import '../handover/serah_terima_qr_screen.dart';
import '../safe_meet/my_meetups_screen.dart';

/// Kartu pertemuan terkonfirmasi terdekat dengan pintasan ke sesi QR
/// serah terima; menampilkan ajakan melihat jadwal bila belum ada.
class ActiveMeetupCard extends StatelessWidget {
  const ActiveMeetupCard({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MeetupRepository();
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final meetup = repository.getNextConfirmedMeetup();
        return _buildMeetupCardContent(context, meetup);
      },
    );
  }

  Widget _buildMeetupCardContent(BuildContext context, Meetup? meetup) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.onPrimaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.large,
        boxShadow: AppElevation.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: AppRadius.small,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'SERAH TERIMA QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (meetup != null)
                const StatusBadge(status: 'Dikonfirmasi', compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            meetup?.itemTitle ?? 'Belum ada pertemuan terkonfirmasi',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                meetup == null
                    ? Icons.info_outline_rounded
                    : Icons.location_on_outlined,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  meetup == null
                      ? 'Sesi QR tersedia setelah pemilik mengonfirmasi pertemuan.'
                      : '${meetup.safeMeetPoint.name} • ${meetup.formattedShortDateTime}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => meetup == null
                        ? const MyMeetupsScreen()
                        : SerahTerimaQrScreen(
                            meetupDetail: MeetupDetailModel.fromMeetup(
                              meetup,
                              viewerId: MeetupRepository.currentUserId,
                            ),
                          ),
                  ),
                );
              },
              icon: Icon(
                meetup == null
                    ? Icons.event_note_rounded
                    : Icons.qr_code_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                meetup == null
                    ? 'Lihat Jadwal Pertemuan Saya'
                    : 'Buka Sesi QR Serah Terima',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.medium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
