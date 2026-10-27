import 'package:intl/intl.dart';

/// Mengubah angka menjadi format Rupiah konsisten, contoh: 55000 -> "Rp55.000".
String formatRupiah(int amount) {
  final isNegative = amount < 0;
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return '${isNegative ? '-' : ''}Rp$buffer';
}

/// Menampilkan jarak sesuai BR-11:
/// Di bawah 1.000 m tampil dalam meter (misal: "450 m"),
/// Di atas 1.000 m tampil dalam km dengan 1 desimal (misal: "1,2 km"),
/// Jika null/invalid tampil "—".
String formatJarak(double? meter) {
  if (meter == null || meter.isNaN || meter.isInfinite || meter < 0) {
    return '—';
  }
  if (meter < 1000) {
    return '${meter.round()} m';
  }
  final km = (meter / 1000).toStringAsFixed(1).replaceAll('.', ',');
  return '$km km';
}

/// Format tanggal absolut berbahasa Indonesia dalam zona tampilan WIB (e.g., "12 Nov 2026, 13.00 WIB").
String formatTanggalWib(DateTime value) {
  final local = value.toLocal();
  final formatted = DateFormat("dd MMM yyyy, HH.mm", 'id_ID').format(local);
  return '$formatted WIB';
}

/// Alias pendek formatTanggal
String formatTanggal(DateTime value) => formatTanggalWib(value);

/// Format waktu relatif ramah Indonesia ("5 menit lalu", "Besok, 13.00", dll).
String formatWaktuRelatif(DateTime value) {
  final now = DateTime.now();
  final local = value.toLocal();
  final diff = now.difference(local);

  if (diff.isNegative) {
    // Tanggal di masa depan
    final futureDiff = local.difference(now);
    if (futureDiff.inDays == 0 && local.day == now.day) {
      return 'Hari ini, ${DateFormat('HH.mm', 'id_ID').format(local)} WIB';
    } else if (futureDiff.inDays <= 1 && local.day == now.day + 1) {
      return 'Besok, ${DateFormat('HH.mm', 'id_ID').format(local)} WIB';
    } else {
      return formatTanggalWib(local);
    }
  }

  if (diff.inSeconds < 60) {
    return 'Baru saja';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} menit lalu';
  } else if (diff.inHours < 24) {
    return '${diff.inHours} jam lalu';
  } else if (diff.inDays < 7) {
    return '${diff.inDays} hari lalu';
  } else {
    return DateFormat('dd MMM yyyy', 'id_ID').format(local);
  }
}

/// Format skor reputasi & ulasan, contoh: "4,5 (12 ulasan)" atau "Belum ada ulasan" jika kosong.
String formatSkor(double? rating, [int? reviewCount]) {
  if (rating == null || rating <= 0) {
    return 'Belum ada ulasan';
  }
  final scoreStr = rating.toStringAsFixed(1).replaceAll('.', ',');
  if (reviewCount == null || reviewCount <= 0) {
    return scoreStr;
  }
  return '$scoreStr ($reviewCount ulasan)';
}

/// Kompatibilitas mundur
String formatRating(double rating, {int? reviewCount}) {
  return formatSkor(rating, reviewCount);
}
