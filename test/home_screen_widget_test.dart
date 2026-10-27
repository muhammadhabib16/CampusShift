import 'package:campusshift/services/home_service.dart';
import 'package:campusshift/viewmodels/auth_view_model.dart';
import 'package:campusshift/viewmodels/home_view_model.dart';
import 'package:campusshift/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Beranda menampilkan barang terbaru dari HomeViewModel', (tester) async {
    final homeViewModel = HomeViewModel(HomeService(fetchItems: () async => []));
    await homeViewModel.loadLatestListings();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider.value(value: homeViewModel),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Halo, Mahasiswa Unand!'), findsOneWidget);
    expect(find.text('Mahasiswa'), findsOneWidget);

    // Banner Modul 2 & 4 mendorong daftar barang ke bawah layar uji.
    await tester.scrollUntilVisible(
      find.text('Buku Kalkulus Purcell Ed. 9'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Buku Kalkulus Purcell Ed. 9'), findsOneWidget);
    expect(find.text('Rp 85.000'), findsOneWidget);
    expect(find.text('Unand • FMIPA'), findsOneWidget);
  });
}
