import 'package:campusshift/models/item_model.dart';
import 'package:campusshift/models/public_profile.dart';
import 'package:campusshift/models/user.dart';
import 'package:campusshift/shared/widgets/user_link.dart';
import 'package:campusshift/services/user_profile_service.dart';
import 'package:campusshift/viewmodels/item_viewmodel.dart';
import 'package:campusshift/viewmodels/public_profile_view_model.dart';
import 'package:campusshift/views/public_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Map<String, dynamic> _profileJson() => {
  'id': 7,
  'full_name': 'Naufal Baihaqi',
  'nim': '2411522025',
  'bio': 'Suka jual buku bekas.',
  'profile_photo_url': null,
  'joined_at': '2026-09-01T03:00:00.000Z',
  'completed_deals': 4,
  'reputation': {'average': 4.5, 'count': 2, 'label': '4.5 (2 ulasan)'},
  'reviews': [
    {
      'id': 1,
      'meetup_id': 10,
      'reviewer_id': 3,
      'reviewer_name': 'Bayu',
      'reviewee_id': 7,
      'rating': 5,
      'comment': 'Barang sesuai foto.',
      'is_edited': false,
      'created_at': '2026-10-10T03:00:00.000Z',
    },
    {
      'id': 2,
      'meetup_id': 11,
      'reviewer_id': 4,
      'reviewer_name': 'Fadel',
      'reviewee_id': 7,
      'rating': 4,
      'comment': '',
      'is_edited': true,
      'created_at': '2026-10-12T03:00:00.000Z',
    },
  ],
};

ItemModel _item(String id, String ownerId, {String status = 'Available'}) =>
    ItemModel(
      id: id,
      ownerId: ownerId,
      title: 'Barang $id',
      description: 'Deskripsi barang $id yang cukup panjang',
      category: 'Elektronik',
      listingType: 'Jual',
      price: 50000,
      isBarterOpen: false,
      condition: 'Baik',
      photoUrls: const [],
      status: status,
    );

void main() {
  setUpAll(() => initializeDateFormatting('id_ID', null));

  test('PublicProfile.fromJson membaca reputasi dan ulasan', () {
    final p = PublicProfile.fromJson(_profileJson());
    expect(p.fullName, 'Naufal Baihaqi');
    expect(p.averageRating, 4.5);
    expect(p.reviewCount, 2);
    expect(p.completedDeals, 4);
    expect(p.bio, 'Suka jual buku bekas.');
    expect(p.reviews.length, 2);
    expect(p.ratingDistribution[5], 1);
    expect(p.ratingDistribution[4], 1);
  });

  test('profil tanpa ulasan: skor null', () {
    final json = _profileJson()
      ..['reputation'] = {'average': null, 'count': 0}
      ..['reviews'] = [];
    final p = PublicProfile.fromJson(json);
    expect(p.averageRating, isNull);
    expect(p.reviewCount, 0);
  });

  test('barang tersedia hanya milik pengguna tsb dan berstatus Available', () async {
    final service = UserProfileService(
      fetchProfile: (_) async => PublicProfile.fromJson(_profileJson()),
      fetchCatalog: () async => [
        _item('1', '7'),
        _item('2', '8'),
        _item('3', '7', status: 'Reserved'),
      ],
    );
    final vm = PublicProfileViewModel(userId: 7, service: service);
    await vm.load();
    expect(vm.profile, isNotNull);
    expect(vm.listings.map((i) => i.id), ['1']);
  });

  test('gagal memuat profil menghasilkan pesan error', () async {
    final vm = PublicProfileViewModel(
      userId: 7,
      service: UserProfileService(
        fetchProfile: (_) async => throw Exception('Pengguna tidak ditemukan'),
        fetchCatalog: () async => [],
      ),
    );
    await vm.load();
    expect(vm.profile, isNull);
    expect(vm.errorMessage, 'Pengguna tidak ditemukan');
  });

  testWidgets('layar profil publik menampilkan skor, barang, dan ulasan', (
    tester,
  ) async {
    final vm = PublicProfileViewModel(
      userId: 7,
      service: UserProfileService(
        fetchProfile: (_) async => PublicProfile.fromJson(_profileJson()),
        fetchCatalog: () async => [_item('1', '7')],
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: PublicProfileScreen(userId: 7, viewModel: vm)),
    );
    await tester.pumpAndSettle();

    expect(find.text('4,5'), findsOneWidget);
    expect(find.text('Transaksi selesai'), findsOneWidget);
    expect(find.text('Barang tersedia (1)'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Barang sesuai foto.'),
      200,
      // Halaman punya dua area gulir; pakai yang vertikal (halaman).
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    expect(find.text('Barang sesuai foto.'), findsOneWidget);
  });

  test('resetFilter dengan kategori dipakai kartu Kategori Populer', () {
    final vm = ItemViewModel();
    vm.resetFilter(category: 'Alat Perkuliahan');
    expect(vm.selectedCategory, 'Alat Perkuliahan');
    expect(vm.searchQuery, '');
  });

  test('User.fromJson membaca bio dan foto profil', () {
    final u = User.fromJson({
      'id': 5,
      'full_name': 'Habib',
      'nim': '2411522024',
      'email': 'habib@student.unand.ac.id',
      'bio': 'Halo',
      'profile_photo_url': 'https://contoh/foto.jpg',
    });
    expect(u.bio, 'Halo');
    expect(u.photoUrl, 'https://contoh/foto.jpg');
    final kosong = User.fromJson({'id': 5, 'profile_photo_url': ''});
    expect(kosong.bio, '');
    expect(kosong.photoUrl, isNull);
  });

  testWidgets('UserLink membuka profil publik saat diketuk', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserLink(userId: 7, name: 'Naufal', prefix: 'Mitra: '),
        ),
      ),
    );
    await tester.tap(find.byType(UserLink));
    // Hanya cek navigasi; data profil tidak dimuat (tanpa login).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PublicProfileScreen), findsOneWidget);
  });

  testWidgets('UserLink tanpa ID valid tidak bisa diketuk', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UserLink(userId: 0, name: 'Contoh')),
      ),
    );
    expect(find.byType(InkWell), findsNothing);
    expect(find.text('Contoh'), findsOneWidget);
  });
}
