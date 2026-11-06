import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../services/api_client.dart';

/// Pesan bawaan bila error tidak membawa keterangan yang layak ditampilkan.
const String defaultErrorMessage = 'Terjadi kesalahan. Silakan coba lagi.';

/// Mengubah error apa pun menjadi pesan yang aman ditampilkan ke pengguna.
///
/// Satu-satunya tempat pemetaan error → teks di aplikasi, dipakai oleh semua
/// ViewModel, repository, dan layar:
/// - [ApiException] / [NetworkException]: pesan dari server atau pesan jaringan.
/// - Kegagalan jaringan mentah (socket, timeout, `ClientException`): pesan
///   jaringan yang ramah.
/// - `Exception('…')` buatan sendiri (mis. validasi): teksnya tanpa awalan
///   "Exception: ".
/// - Bug pemrograman (`Error`, `FormatException`): [fallback], agar detail
///   teknis tidak bocor ke layar.
String errorMessageOf(Object error, {String fallback = defaultErrorMessage}) {
  if (error is ApiException) {
    return error.message.trim().isEmpty ? fallback : error.message;
  }
  if (error is TimeoutException) return NetworkException.timeoutMessage;
  if (error is SocketException || error is http.ClientException) {
    return NetworkException.offlineMessage;
  }
  if (error is Error || error is FormatException) return fallback;

  final text = error
      .toString()
      .replaceFirst(RegExp(r'^Exception:\s*'), '')
      .trim();
  if (text.contains('SocketException') || text.contains('ClientException')) {
    return NetworkException.offlineMessage;
  }
  if (text.contains('TimeoutException')) return NetworkException.timeoutMessage;
  return text.isEmpty ? fallback : text;
}
