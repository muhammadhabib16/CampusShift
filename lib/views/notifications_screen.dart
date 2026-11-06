import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/notification_center.dart';
import '../shared/widgets/shared_widgets.dart';
import '../theme/app_tokens.dart';
import '../utils/formatters.dart';
import 'safe_meet/meetup_detail_screen.dart';
import '../core/app_tabs.dart';

/// Kotak masuk notifikasi: pertemuan, barter, dan klaim hibah.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationCenter>().refresh();
    });
  }

  void _open(NotificationCenter center, AppNotification n) {
    center.markRead(n);
    final nav = Navigator.of(context);
    switch (n.type) {
      case AppNotificationType.meetup:
        nav.push(
          MaterialPageRoute(
            builder: (_) => MeetupDetailScreen(meetupId: n.refId),
          ),
        );
      case AppNotificationType.barter:
        nav.pop();
        center.onSelectTab?.call(AppTabs.barter);
      case AppNotificationType.claim:
      case AppNotificationType.incomingClaim:
        nav.pushNamed('/kelola-klaim');
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = context.watch<NotificationCenter>();
    final items = center.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (center.unreadCount > 0)
            TextButton(
              onPressed: center.markAllRead,
              child: const Text('Tandai dibaca'),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: center.refresh,
        child: items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  if (center.isLoading)
                    const LoadingState(label: 'Memuat notifikasi…')
                  else
                    EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: center.error != null
                          ? 'Notifikasi belum dapat dimuat'
                          : 'Belum ada notifikasi',
                      description: center.error ??
                          'Ajakan pertemuan, tawaran barter, dan status klaim '
                              'hibah akan muncul di sini.',
                    ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (context, i) => _NotificationTile(
                  notification: items[i],
                  onTap: () => _open(center, items[i]),
                ),
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  static (IconData, Color, Color) _style(AppNotificationType type) =>
      switch (type) {
        AppNotificationType.meetup => (
          Icons.event_available_rounded,
          AppColors.primary,
          AppColors.primaryContainer,
        ),
        AppNotificationType.barter => (
          Icons.swap_horiz_rounded,
          AppColors.warning,
          AppColors.warningContainer,
        ),
        AppNotificationType.claim ||
        AppNotificationType.incomingClaim => (
          Icons.volunteer_activism_rounded,
          AppColors.success,
          AppColors.successContainer,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final (icon, fg, bg) = _style(n.type);
    return Material(
      color: n.isRead ? AppColors.surface : const Color(0xFFF0FDFA),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: bg,
                child: Icon(icon, color: fg, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      n.body,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatWaktuRelatif(n.time),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!n.isRead)
                Container(
                  margin: const EdgeInsets.only(left: AppSpacing.sm, top: 6),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
