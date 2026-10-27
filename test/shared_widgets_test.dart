import 'package:campusshift/shared/widgets/shared_widgets.dart';
import 'package:campusshift/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('Shared Widgets Unit & Widget Tests', () {
    testWidgets('AppPrimaryButton renders label and handles tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestApp(
          AppPrimaryButton(
            label: 'Lanjutkan',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Lanjutkan'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

      await tester.tap(find.byType(AppPrimaryButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('AppPrimaryButton displays loading spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          AppPrimaryButton(
            label: 'Proses',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Proses'), findsNothing);
    });

    testWidgets('StatusBadge renders correct label and icon for Available', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const StatusBadge(status: 'Available'),
        ),
      );

      expect(find.text('Tersedia'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('StatusBadge renders correct label and icon for Reserved', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const StatusBadge(status: 'Reserved'),
        ),
      );

      expect(find.text('Dalam Kesepakatan'), findsOneWidget);
      expect(find.byIcon(Icons.handshake_outlined), findsOneWidget);
    });

    testWidgets('AppCard renders child and triggers onTap callback', (tester) async {
      bool clicked = false;
      await tester.pumpWidget(
        buildTestApp(
          AppCard(
            onTap: () => clicked = true,
            child: const Text('Konten Kartu'),
          ),
        ),
      );

      expect(find.text('Konten Kartu'), findsOneWidget);
      await tester.tap(find.text('Konten Kartu'));
      await tester.pump();
      expect(clicked, isTrue);
    });

    testWidgets('RatingStars renders score and review count text', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const RatingStars(
            rating: 4.8,
            reviewCount: 15,
          ),
        ),
      );

      expect(find.text('4,8 (15 ulasan)'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
    });

    testWidgets('PriceTag renders formatted Rupiah and Hibah / Gratis badge', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Column(
            children: [
              PriceTag(price: 75000),
              PriceTag(price: 0, isGrant: true),
            ],
          ),
        ),
      );

      expect(find.text('Rp75.000'), findsOneWidget);
      expect(find.text('Gratis (Hibah)'), findsOneWidget);
    });
  });
}
