import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/review_model.dart';
import '../../viewmodels/handover_view_model.dart';
import '../../services/meetup_repository.dart';
import 'review_form_screen.dart';

/// FR-20.2 [W]: Melihat profil publik pengguna yang menampilkan rata-rata rating dan daftar ulasan (BR-25).
/// Menampilkan ulasan diterima & ulasan diberikan. Opsi sunting tersedia jika masih dalam 7 hari (AC-24).
/// Ulasan TIDAK BISA DIHAPUS oleh siapa pun (BR-26, AC-25).
class ProfilReputasiScreen extends StatefulWidget {
  final int? targetUserId;
  final String? targetUserName;

  const ProfilReputasiScreen({
    super.key,
    this.targetUserId,
    this.targetUserName,
  });

  @override
  State<ProfilReputasiScreen> createState() => _ProfilReputasiScreenState();
}

class _ProfilReputasiScreenState extends State<ProfilReputasiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _userId;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userId = widget.targetUserId ?? MeetupRepository.currentUserId;
    _userName = widget.targetUserName ?? MeetupRepository.currentUserName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HandoverViewModel>().refreshProofsAndReviews(_userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HandoverViewModel>();
    final received = vm.receivedReviews;
    final given = vm.myReviews;
    final avgRating = vm.averageRating;
    final totalCount = received.length;
    final dist = vm.ratingDistribution;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Profil Reputasi & Ulasan',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          // Header Ringkasan Reputasi (BR-25)
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Skor Angka Besar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          totalCount == 0 ? '-' : avgRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.1),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < avgRating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 18,
                            );
                          }),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          totalCount == 0 ? 'Belum ada ulasan' : '($totalCount ulasan)',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),

                    // Progress Bar Distribusi Bintang (5 s/d 1)
                    Expanded(
                      child: Column(
                        children: [5, 4, 3, 2, 1].map((star) {
                          final count = dist[star] ?? 0;
                          final ratio = totalCount > 0 ? (count / totalCount) : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text('$star', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                const SizedBox(width: 4),
                                const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      minHeight: 5,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 18,
                                  child: Text('$count', style: const TextStyle(fontSize: 11, color: Colors.black45), textAlign: TextAlign.right),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Rekam jejak transaksi terpercaya mahasiswa Unand: $_userName',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0D9488),
              unselectedLabelColor: Colors.black45,
              indicatorColor: const Color(0xFF0D9488),
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Ulasan Diterima (${received.length})'),
                Tab(text: 'Ulasan Diberikan (${given.length})'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReviewList(received, isReceivedTab: true),
                _buildReviewList(given, isReceivedTab: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList(List<ReviewModel> list, {required bool isReceivedTab}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_outline_rounded, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              isReceivedTab ? 'Belum Ada Ulasan Diterima' : 'Belum Pernah Memberi Ulasan',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              isReceivedTab
                  ? 'Selesaikan serah terima barang untuk mulai membangun reputasi.'
                  : 'Beri ulasan kepada mitra setelah transaksi selesai di titik temu.',
              style: const TextStyle(fontSize: 12, color: Colors.black38),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final review = list[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
                        child: const Icon(Icons.person, color: Color(0xFF0D9488), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isReceivedTab ? review.reviewerName : 'Untuk: ${review.targetUserName}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('d MMM yyyy').format(review.createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Row(
                    children: List.generate(5, (starIdx) {
                      return Icon(
                        starIdx < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(width: 6),
                  if (review.isEdited)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Text('Diedit (BR-26)', style: TextStyle(fontSize: 10, color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              if (review.comment.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  review.comment,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.35),
                ),
              ],
              if (!isReceivedTab && review.canEdit) ...[
                const Divider(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewFormScreen(
                            meetupId: review.meetupId,
                            proofNumber: review.proofNumber,
                            targetUserId: review.targetUserId,
                            targetUserName: review.targetUserName,
                            existingReview: review,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF0D9488)),
                    label: const Text('Sunting Ulasan (AC-24)', style: TextStyle(fontSize: 12, color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}