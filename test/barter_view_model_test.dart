import 'package:campusshift/models/user.dart';
import 'package:campusshift/services/barter_service.dart';
import 'package:campusshift/services/home_service.dart';
import 'package:campusshift/utils/formatters.dart';
import 'package:campusshift/viewmodels/auth_view_model.dart';
import 'package:campusshift/viewmodels/barter_view_model.dart';
import 'package:campusshift/viewmodels/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatRupiah', () {
    test('memformat ribuan dengan titik', () {
      expect(formatRupiah(195000), 'Rp 195.000');
      expect(formatRupiah(45000), 'Rp 45.000');
      expect(formatRupiah(1250000), 'Rp 1.250.000');
      expect(formatRupiah(0), 'Rp 0');
    });
  });

  group('BarterViewModel', () {
    late BarterViewModel viewModel;

    setUp(() async {
      viewModel = BarterViewModel(BarterService());
      await viewModel.loadInitialData();
    });

    test('memuat barang sendiri, barang target, dan daftar tawaran', () {
      expect(viewModel.myItems.length, 3);
      expect(viewModel.targetItem?.name, 'Buku Fisika Dasar');
      expect(viewModel.deals.length, 3);
      expect(viewModel.isLoading, isFalse);
    });

    test('selisih harga dan saran top-up mengikuti barang yang dipilih', () {
      // Default: Kalkulator (195.000) vs Buku (250.000)
      expect(viewModel.priceDifference, 55000);
      expect(viewModel.suggestedTopUp, 55000);

      viewModel.selectItem(1); // iPad Case 45.000
      expect(viewModel.selectedItem?.name, 'iPad Air 4 Case Navy Blue');
      expect(viewModel.priceDifference, 205000);
    });

    test('selectItem mengabaikan indeks di luar jangkauan', () {
      viewModel.selectItem(99);
      expect(viewModel.selectedIndex, 0);
    });

    test('validasi top-up sesuai aturan', () {
      expect(viewModel.validateTopUp(''), 'Selisih tunai tidak boleh kosong');
      expect(viewModel.validateTopUp('abc'), 'Hanya boleh berisi angka');
      expect(viewModel.validateTopUp('-5000'), 'Tidak boleh bernilai negatif');
      expect(viewModel.validateTopUp('55000'), isNull);
    });

    test('submitProposal mengubah state isSubmitting lalu berhasil', () async {
      final future = viewModel.submitProposal('55000');
      expect(viewModel.isSubmitting, isTrue);
      expect(await future, isTrue);
      expect(viewModel.isSubmitting, isFalse);
    });

    test('submitProposal menolak input tidak valid tanpa memanggil service', () async {
      expect(await viewModel.submitProposal('-1'), isFalse);
      expect(viewModel.isSubmitting, isFalse);
    });

    test('tawaran dipisah menjadi tab Dikirim dan Diterima', () {
      expect(viewModel.sentDeals.map((d) => d.id), ['deal-1', 'deal-3']);
      expect(viewModel.receivedDeals.map((d) => d.id), ['deal-2']);
    });

    test('konfirmasi kedua mengunci kesepakatan (dual-confirmation)', () async {
      // deal-2: mitra sudah konfirmasi, pengguna belum
      expect(viewModel.canConfirm(viewModel.dealById('deal-2')!), isTrue);
      expect(await viewModel.confirmDeal('deal-2'), isTrue);

      final deal = viewModel.dealById('deal-2')!;
      expect(deal.myConfirmed, isTrue);
      expect(deal.status, 'Terkunci');
      expect(viewModel.canConfirm(deal), isFalse);
    });

    test('konfirmasi tidak dapat diberikan dua kali atau pada tawaran selesai', () async {
      expect(await viewModel.confirmDeal('deal-1'), isFalse); // sudah konfirmasi
      expect(await viewModel.confirmDeal('deal-3'), isFalse); // Selesai
      expect(await viewModel.confirmDeal('tidak-ada'), isFalse);
    });
  });

  group('HomeViewModel', () {
    test('memuat barang terbaru dari service', () async {
      final viewModel = HomeViewModel(HomeService(fetchItems: () async => []));
      await viewModel.loadLatestListings();
      expect(viewModel.latestListings.length, 5);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });
  });

  group('User', () {
    test('membaca data pengguna dari respons login', () {
      final user = User.fromJson({
        'user_id': 7,
        'full_name': 'Dinda Lestari',
        'nim': '2411522099',
        'email': 'dinda@student.unand.ac.id',
      });
      expect(user.id, '7');
      expect(user.fullName, 'Dinda Lestari');
      expect(user.nim, '2411522099');
    });
  });

  group('AuthViewModel', () {
    test('login dengan kolom kosong ditolak tanpa memanggil server', () async {
      final viewModel = AuthViewModel();
      expect(await viewModel.login(email: '', password: ''), isFalse);
      expect(viewModel.message, 'Email dan Password tidak boleh kosong');
      expect(viewModel.isLoading, isFalse);
    });

    test('registrasi dengan kolom kosong ditolak tanpa memanggil server', () async {
      final viewModel = AuthViewModel();
      final success = await viewModel.register(fullName: '', nim: '', email: '', password: '');
      expect(success, isFalse);
      expect(viewModel.message, 'Semua kolom wajib diisi');
    });

    test('nama tampilan memakai label umum bila belum login', () {
      expect(AuthViewModel().displayName, 'Mahasiswa');
    });
  });
}
