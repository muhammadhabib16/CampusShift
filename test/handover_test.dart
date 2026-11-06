import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusshift/models/handover_token_model.dart';
import 'package:campusshift/services/handover_service.dart';
import 'package:campusshift/viewmodels/handover_view_model.dart';
import 'package:campusshift/views/handover/serah_terima_qr_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FR-17 Handover Token Model & Service Tests', () {
    test('HandoverTokenModel calculates 5-minute expiry correctly', () {
      final now = DateTime.now();
      final token = HandoverTokenModel(
        tokenId: 'TOK-1',
        meetupId: 'MEET-1',
        token: 'TKN-CS-1234-AB',
        issuedAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
        status: 'active',
      );

      expect(token.isActive, isTrue);
      expect(token.isExpired, isFalse);
      expect(token.remainingSeconds, inInclusiveRange(298, 300));
      expect(token.formattedRemainingTime, matches(r'04:5[0-9]|05:00'));
    });

    test(
      'FR-17.1 Create: HandoverService creates a one-time token valid for 5 minutes',
      () async {
        final service = HandoverService();
        final token = await service.createQrSession(meetupId: 101);

        expect(token.token, startsWith('TKN-CS-'));
        expect(token.status, equals('active'));
        expect(token.expiresAt.difference(token.issuedAt).inMinutes, equals(5));
      },
    );

    test(
      'FR-17.2 Delete: HandoverService cancels active QR session',
      () async {
        final service = HandoverService();
        final token = await service.createQrSession(meetupId: 102);

        final cancelled = await service.cancelQrSession(
          meetupId: 102,
          tokenId: token.tokenId,
        );

        expect(cancelled, isTrue);
        final status = await service.checkTokenStatus(
          meetupId: 102,
          tokenId: token.tokenId,
        );
        expect(status['status'], equals('cancelled'));
      },
    );

    test('FR-21 Status check returns used when scanned', () async {
      final service = HandoverService();
      final token = await service.createQrSession(meetupId: 103);

      service.simulateScanSuccess(103);
      final status = await service.checkTokenStatus(
        meetupId: 103,
        tokenId: token.tokenId,
      );
      expect(status['status'], equals('used'));
    });
  });

  group('SerahTerimaQrScreen Widget Tests', () {
    testWidgets('Renders SerahTerimaQrScreen with active QR session', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => HandoverViewModel(),
          child: const MaterialApp(home: SerahTerimaQrScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Serah Terima QR'), findsOneWidget);
      expect(find.text('TITIK TEMU RESMI UNAND'), findsOneWidget);
      expect(
        find.text('SESI QR AKTIF (SATU KALI PAKAI)'),
        findsOneWidget,
      );
      expect(
        find.text('Batalkan Sesi QR'),
        findsOneWidget,
      );
      expect(find.text('Protokol Serah Terima Aman Kampus:'), findsOneWidget);
    });
  });
}
