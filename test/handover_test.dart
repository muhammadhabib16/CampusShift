import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusshift/models/handover_token_model.dart';
import 'package:campusshift/services/handover_service.dart';
import 'package:campusshift/views/handover/serah_terima_qr_screen.dart';

void main() {
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

    test('FR-17.1 Create: HandoverService creates a one-time token valid for 5 minutes', () async {
      final res = await HandoverService.createQrSession(meetupId: 'MEET-TEST-01');

      expect(res['success'], isTrue);
      final token = res['token'] as HandoverTokenModel;
      expect(token.token, startsWith('TKN-CS-'));
      expect(token.status, equals('active'));
      expect(token.expiresAt.difference(token.issuedAt).inMinutes, equals(5));
    });

    test('FR-17.2 Delete: HandoverService cancels active QR session', () async {
      final createRes = await HandoverService.createQrSession(meetupId: 'MEET-TEST-02');
      final token = createRes['token'] as HandoverTokenModel;

      final cancelRes = await HandoverService.cancelQrSession(
        meetupId: 'MEET-TEST-02',
        tokenId: token.tokenId,
      );

      expect(cancelRes['success'], isTrue);
      final status = await HandoverService.checkTokenStatus(
        meetupId: 'MEET-TEST-02',
        tokenId: token.tokenId,
      );
      expect(status['status'], equals('cancelled'));
    });

    test('FR-21 Status check returns used when scanned', () async {
      final createRes = await HandoverService.createQrSession(meetupId: 'MEET-TEST-03');
      final token = createRes['token'] as HandoverTokenModel;

      HandoverService.simulateScanSuccess('MEET-TEST-03');
      final status = await HandoverService.checkTokenStatus(
        meetupId: 'MEET-TEST-03',
        tokenId: token.tokenId,
      );
      expect(status['status'], equals('used'));
    });
  });

  group('SerahTerimaQrScreen Widget Tests', () {
    testWidgets('Renders SerahTerimaQrScreen with all Figma elements', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: SerahTerimaQrScreen(),
        ),
      );

      // Wait for async _initSession to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Top title
      expect(find.text('Serah Terima Qr'), findsOneWidget);

      // Simulation banner
      expect(find.text('SIMULASI SKENARIO HANDOVER'), findsOneWidget);
      expect(find.text('1. Aktif (3s)'), findsOneWidget);
      expect(find.text('2. Kedaluwarsa'), findsOneWidget);
      expect(find.text('3. Sukses Selesai'), findsOneWidget);

      // Verified safe-meet point
      expect(find.text('TITIK TEMU KAMPUS TERVERIFIKASI'), findsOneWidget);
      expect(find.text('Pos Satpam Gedung A (Lobby Utama)'), findsOneWidget);

      // Item & Partner
      expect(find.text('Kalkulator Saintifik Casio fx-991EX'), findsOneWidget);
      expect(find.text('Dimas FTI'), findsOneWidget);

      // Action buttons
      expect(find.text('Perbarui QR'), findsOneWidget);
      expect(find.text('Batalkan Sesi QR'), findsOneWidget);

      // Protocol card
      expect(find.text('Protokol Serah Terima Aman'), findsOneWidget);
    });
  });
}
