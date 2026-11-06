import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/notification_center.dart';
import '../../theme/app_tokens.dart';
import '../../views/notifications_screen.dart';

/// Ikon lonceng di app bar dengan badge jumlah notifikasi belum dibaca.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key, this.color = AppColors.textSecondary});

  final Color color;

  @override
  Widget build(BuildContext context) {
    // Aman bila provider belum dipasang (mis. widget test layar tunggal).
    final unread = context.select<NotificationCenter?, int>(
      (c) => c?.unreadCount ?? 0,
    );

    return IconButton(
      tooltip: unread > 0 ? 'Notifikasi ($unread belum dibaca)' : 'Notifikasi',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      ),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        backgroundColor: AppColors.error,
        child: Icon(
          unread > 0
              ? Icons.notifications_rounded
              : Icons.notifications_none_rounded,
          color: unread > 0 ? AppColors.primary : color,
        ),
      ),
    );
  }
}
