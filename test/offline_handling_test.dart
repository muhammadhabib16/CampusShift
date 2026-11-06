import 'dart:async';
import 'dart:io';

import 'package:campusshift/services/api_client.dart';
import 'package:campusshift/services/connectivity_service.dart';
import 'package:campusshift/shared/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  final status = ConnectivityService.instance;

  setUp(() => status.reportOnline());

  group('ApiClient.guardNetwork', () {
    test('SocketException menjadi NetworkException dengan pesan ramah', () async {
      await expectLater(
        ApiClient.guardNetwork<void>(
          () => Future.error(const SocketException('Failed host lookup')),
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.toString(),
            'pesan',
            NetworkException.offlineMessage,
          ),
        ),
      );
      expect(status.isOffline, isTrue);
    });

    test('ClientException dan Timeout juga dipetakan', () async {
      await expectLater(
        ApiClient.guardNetwork<void>(
          () => Future.error(http.ClientException('Connection closed')),
        ),
        throwsA(isA<NetworkException>()),
      );
      await expectLater(
        ApiClient.guardNetwork<void>(
          () => Future.error(TimeoutException('lama')),
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'pesan',
            NetworkException.timeoutMessage,
          ),
        ),
      );
    });

    test('respons berhasil menandai online dan memicu onReconnect', () async {
      var reconnects = 0;
      status
        ..reportNetworkFailure()
        ..onReconnect = () => reconnects++;

      final result = await ApiClient.guardNetwork(() async => 42);

      expect(result, 42);
      expect(status.isOffline, isFalse);
      expect(status.justReconnected, isTrue);
      expect(reconnects, 1);
      status.onReconnect = null;
    });

    test('NetworkException tetap ApiException agar penanganan lama berlaku', () {
      expect(NetworkException.offline(), isA<ApiException>());
    });
  });

  testWidgets('OfflineBanner tampil saat offline dan hilang saat online', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: status,
        child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
      ),
    );
    expect(find.textContaining('sedang offline'), findsNothing);

    status.reportNetworkFailure();
    await tester.pumpAndSettle();
    expect(find.textContaining('sedang offline'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    status.reportOnline();
    await tester.pumpAndSettle();
    expect(find.textContaining('Koneksi kembali'), findsOneWidget);

    // Strip hijau hilang sendiri setelah ±3 detik.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.textContaining('Koneksi kembali'), findsNothing);
  });
}
