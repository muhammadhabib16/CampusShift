import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/backend.dart';
import '../../services/connectivity_service.dart';
import '../../theme/app_tokens.dart';

/// Strip status koneksi di atas navigasi bawah.
///
/// - Offline: strip gelap "Kamu sedang offline" + tombol Coba Lagi.
/// - Baru kembali online: strip hijau selama ±3 detik.
/// - Online normal: tidak tampil (tinggi 0).
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _checking = false;

  Future<void> _retry() async {
    setState(() => _checking = true);
    try {
      // Respons apa pun dari server menandakan online (lihat guardNetwork).
      await Backend.client.get('/health');
    } catch (_) {
      // Status offline/online sudah diperbarui oleh ApiClient.guardNetwork.
    }
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<ConnectivityService?>();
    final offline = status?.isOffline ?? false;
    final reconnected = status?.justReconnected ?? false;

    Widget child = const SizedBox(width: double.infinity);
    if (offline) {
      child = _Strip(
        key: const ValueKey('offline'),
        color: const Color(0xFF334155),
        icon: Icons.wifi_off_rounded,
        text: 'Kamu sedang offline. Data mungkin belum terbaru.',
        action: _checking
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : TextButton(
                onPressed: _retry,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
      );
    } else if (reconnected) {
      child = const _Strip(
        key: ValueKey('online'),
        color: AppColors.success,
        icon: Icons.wifi_rounded,
        text: 'Koneksi kembali. Memuat data terbaru…',
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: child,
      ),
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip({
    super.key,
    required this.color,
    required this.icon,
    required this.text,
    this.action,
  });

  final Color color;
  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: color,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: AppSpacing.sm),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
