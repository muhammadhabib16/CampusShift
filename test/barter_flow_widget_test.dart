import 'package:campusshift/services/barter_service.dart';
import 'package:campusshift/viewmodels/barter_view_model.dart';
import 'package:campusshift/views/barter/barter_confirmation_screen.dart';
import 'package:campusshift/views/barter/barter_list_screen.dart';
import 'package:campusshift/views/barter/barter_negotiation_screen.dart';
import 'package:campusshift/views/barter/widgets/barter_item_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Memastikan alur barter di layar tetap berjalan setelah dipindah ke MVVM.
void main() {
  Future<BarterViewModel> pumpWithViewModel(WidgetTester tester, Widget home) async {
    final viewModel = BarterViewModel(BarterService());
    await viewModel.loadInitialData();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: viewModel,
        child: MaterialApp(home: home),
      ),
    );
    return viewModel;
  }

  testWidgets('layar negosiasi menampilkan data dari ViewModel', (tester) async {
    await pumpWithViewModel(tester, const BarterNegotiationScreen());

    expect(find.text('Kalkulator Casio FX-991EX'), findsOneWidget);
    expect(find.text('Rp 195.000'), findsOneWidget);
    expect(find.text('Buku Fisika Dasar'), findsOneWidget);
    expect(find.text('- Rp 55.000'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '55000'), findsOneWidget);
  });

  testWidgets('validasi top-up kosong & negatif tampil di layar', (tester) async {
    await pumpWithViewModel(tester, const BarterNegotiationScreen());

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.text('Kirim Penawaran Barter'));
    await tester.pump();
    expect(find.text('Selisih tunai tidak boleh kosong'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '-5000');
    await tester.tap(find.text('Kirim Penawaran Barter'));
    await tester.pump();
    expect(find.text('Tidak boleh bernilai negatif'), findsOneWidget);
  });

  testWidgets('kirim penawaran: loading lalu SnackBar sukses', (tester) async {
    await pumpWithViewModel(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BarterNegotiationScreen()),
            ),
            child: const Text('buka'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kirim Penawaran Barter'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Penawaran Barter Berhasil Dikirim!'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(BarterNegotiationScreen), findsNothing);
  });

  testWidgets('memilih barang lain di sheet mengubah layar negosiasi', (tester) async {
    await pumpWithViewModel(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => BarterItemSelectionSheet.show(context),
            child: const Text('tukar'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('tukar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('iPad Air 4 Case Navy Blue'));
    await tester.pump();
    await tester.tap(find.text('Konfirmasi Pilihan'));
    await tester.pumpAndSettle();

    expect(find.byType(BarterNegotiationScreen), findsOneWidget);
    expect(find.text('Rp 45.000'), findsOneWidget);
    expect(find.text('- Rp 205.000'), findsOneWidget);
  });

  testWidgets('daftar barter memisahkan tab Dikirim dan Diterima', (tester) async {
    await pumpWithViewModel(tester, const BarterListScreen());

    expect(find.text('Farhan Wijaya'), findsOneWidget);
    expect(find.text('Sarah Amanda'), findsNothing);

    await tester.tap(find.text('Diterima'));
    await tester.pumpAndSettle();
    expect(find.text('Sarah Amanda'), findsOneWidget);
    expect(find.text('Rice Cooker Mini 0.8L'), findsOneWidget);
  });

  testWidgets('konfirmasi kesepakatan mengunci barter', (tester) async {
    await pumpWithViewModel(tester, const BarterConfirmationScreen(dealId: 'deal-2'));

    expect(find.text('Meja Lipat Belajar Minimalis'), findsOneWidget);
    expect(find.text('Rp 30.000'), findsOneWidget);
    expect(find.textContaining('Biometrik'), findsNothing);

    await tester.tap(find.text('Setuju & Kunci Kesepakatan'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('Kesepakatan Berhasil Dikunci!'), findsOneWidget);
    expect(find.text('Asset Terkunci'), findsOneWidget);
    expect(find.text('Setuju & Kunci Kesepakatan'), findsNothing);
  });

  testWidgets('setelah konfirmasi sendiri tampil menunggu mitra (BR-18)', (tester) async {
    await pumpWithViewModel(tester, const BarterConfirmationScreen(dealId: 'deal-1'));

    expect(find.text('Menunggu konfirmasi Farhan Wijaya'), findsOneWidget);
    expect(find.text('Setuju & Kunci Kesepakatan'), findsNothing);
  });
}
