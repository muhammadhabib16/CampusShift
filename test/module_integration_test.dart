import 'package:campusshift/models/barter_item.dart';
import 'package:campusshift/models/handover_token_model.dart';
import 'package:campusshift/models/item_model.dart';
import 'package:campusshift/services/barter_service.dart';
import 'package:campusshift/services/home_service.dart';
import 'package:campusshift/services/meetup_repository.dart';
import 'package:campusshift/viewmodels/barter_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

ItemModel _item(String id, {String status = 'Available'}) {
  return ItemModel(
    id: id,
    ownerId: '9',
    ownerName: 'Dinda Lestari',
    title: 'Barang $id',
    description: '',
    category: 'Elektronik',
    listingType: 'Jual',
    price: 100000,
    isBarterOpen: true,
    condition: 'Baik',
    photoUrls: const [],
    status: status,
  );
}

void main() {
  group('Beranda memakai listing Modul 1', () {
    test('hanya listing Available yang tampil, maksimal 5', () async {
      final service = HomeService(
        fetchItems: () async => [
          _item('1'),
          _item('2', status: 'Reserved'),
          for (var i = 3; i <= 8; i++) _item('$i'),
        ],
      );
      final listings = await service.getLatestListings();

      expect(listings.length, 5);
      expect(listings.map((l) => l.id), ['1', '3', '4', '5', '6']);
      expect(listings.first.ownerId, 9);
      expect(listings.first.ownerName, 'Dinda Lestari');
      expect(listings.first.condition, 'Baik');
    });

    test('memakai data contoh bila API listing gagal', () async {
      final service = HomeService(fetchItems: () async => throw Exception('offline'));
      final listings = await service.getLatestListings();
      expect(listings.first.title, 'Buku Kalkulus Purcell Ed. 9');
    });
  });

  test('barang target barter mengikuti barang yang dilihat', () async {
    final viewModel = BarterViewModel(BarterService());
    await viewModel.loadInitialData();

    viewModel.setTargetItem(const BarterItem(
      id: '7',
      name: 'Kursi Lipat Kos',
      price: 75000,
      category: 'Furnitur Kos',
      condition: 'Baik',
    ));

    expect(viewModel.targetItem?.name, 'Kursi Lipat Kos');
    // Kalkulator (Rp 195.000) lebih mahal dari target, jadi tidak perlu top-up.
    expect(viewModel.priceDifference, 75000 - 195000);
    expect(viewModel.suggestedTopUp, 0);
  });

  group('Pertemuan Modul 2 ke serah terima Modul 4', () {
    setUpAll(() => initializeDateFormatting('id_ID', null));

    test('data QR berasal dari pertemuan, mitra adalah pihak lain', () {
      final meetup = MeetupRepository().getNextConfirmedMeetup()!;
      final detail = MeetupDetailModel.fromMeetup(
        meetup,
        viewerId: MeetupRepository.currentUserId,
      );

      expect(detail.meetupId, meetup.id.toString());
      expect(detail.itemName, meetup.itemTitle);
      expect(detail.locationTitle, meetup.safeMeetPoint.name);
      // Pengguna adalah peminat pada data contoh, jadi mitranya pemilik barang.
      expect(detail.partnerName, meetup.ownerName);
    });

    test('pengguna tidak dapat mengajukan pertemuan untuk barang sendiri', () {
      final repository = MeetupRepository();
      expect(
        () => repository.createMeetup(
          itemId: 500,
          itemTitle: 'Barang Sendiri',
          ownerId: MeetupRepository.currentUserId,
          ownerName: MeetupRepository.currentUserName,
          safeMeetPoint: repository.getPointById(1),
          scheduledTime: DateTime.now().add(const Duration(hours: 3)),
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
