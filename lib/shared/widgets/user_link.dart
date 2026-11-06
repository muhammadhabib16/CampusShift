import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import '../../views/public_profile_screen.dart';

/// Membuka profil publik pengguna. Tidak melakukan apa pun bila [userId]
/// tidak valid (mis. data contoh tanpa ID).
void openUserProfile(
  BuildContext context, {
  required Object? userId,
  String name = '',
}) {
  final id = int.tryParse('${userId ?? ''}');
  if (id == null || id <= 0) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PublicProfileScreen(
        userId: id,
        fallbackName: name.isEmpty ? 'Mahasiswa Unand' : name,
      ),
    ),
  );
}

/// Nama pengguna yang dapat diketuk untuk membuka profil publiknya.
///
/// Dipakai di semua tempat yang menampilkan pengguna lain (mitra barter,
/// pemohon klaim, pemilik barang, pemberi ulasan, dan sebagainya) agar
/// perilakunya seragam di seluruh aplikasi.
class UserLink extends StatelessWidget {
  const UserLink({
    super.key,
    required this.userId,
    required this.name,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
  });

  final Object? userId;
  final String name;

  /// Teks biasa sebelum nama, mis. "Mitra: ".
  final String prefix;

  /// Teks biasa setelah nama, mis. " (2411522023)".
  final String suffix;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;

  bool get _tappable {
    final id = int.tryParse('${userId ?? ''}');
    return id != null && id > 0;
  }

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(style);
    final display = name.isEmpty ? 'Mahasiswa Unand' : name;
    final text = Text.rich(
      TextSpan(
        children: [
          if (prefix.isNotEmpty) TextSpan(text: prefix),
          TextSpan(
            text: display,
            style: _tappable
                ? const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  )
                : null,
          ),
          if (suffix.isNotEmpty) TextSpan(text: suffix),
        ],
      ),
      style: base,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
    if (!_tappable) return text;

    return Semantics(
      button: true,
      label: 'Lihat profil $display',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => openUserProfile(context, userId: userId, name: name),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: text,
        ),
      ),
    );
  }
}
