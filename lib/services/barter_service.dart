import '../models/barter_deal.dart';
import '../models/barter_item.dart';
import 'backend.dart';
import 'item_service.dart';

/// Sumber data Modul 3 (Barter) — `be-campusshift/src/routes/barter.routes.js`.
///
/// Saat pengguna login, semua data dibaca/ditulis ke `/api/barters`.
/// Data contoh di bawah hanya dipakai pada mode tanpa login (demo & widget test).
class BarterService {
  static const BarterItem _calculator = BarterItem(
    id: 'item-1',
    name: 'Kalkulator Casio FX-991EX',
    price: 195000,
    category: 'Alat Perkuliahan',
    condition: 'Baik',
  );

  static const BarterItem _ipadCase = BarterItem(
    id: 'item-2',
    name: 'iPad Air 4 Case Navy Blue',
    price: 45000,
    category: 'Elektronik',
    condition: 'Cukup',
  );

  static const BarterItem _foldingDesk = BarterItem(
    id: 'item-3',
    name: 'Meja Lipat Belajar Minimalis',
    price: 120000,
    category: 'Furnitur Kos',
    condition: 'Baik',
  );

  static const List<BarterItem> _myActiveItems = [
    _calculator,
    _ipadCase,
    _foldingDesk,
  ];

  static const BarterItem _targetItem = BarterItem(
    id: 'item-9',
    name: 'Buku Fisika Dasar',
    price: 250000,
    category: 'Buku & Referensi',
    condition: 'Baik',
  );

  static const List<BarterDeal> _deals = [
    BarterDeal(
      id: 'deal-1',
      partnerName: 'Farhan Wijaya',
      myItem: _calculator,
      partnerItem: _targetItem,
      cashTopUp: 55000,
      topUpPaidByMe: true,
      isSentByMe: true,
      status: 'Menunggu',
      myConfirmed: true,
      partnerConfirmed: false,
      dateLabel: 'Hari ini, 10:15 WIB',
    ),
    BarterDeal(
      id: 'deal-2',
      partnerName: 'Sarah Amanda',
      myItem: _foldingDesk,
      partnerItem: BarterItem(
        id: 'item-14',
        name: 'Rice Cooker Mini 0.8L',
        price: 150000,
        category: 'Elektronik',
        condition: 'Sangat Baik',
      ),
      cashTopUp: 30000,
      topUpPaidByMe: true,
      isSentByMe: false,
      status: 'Menunggu',
      myConfirmed: false,
      partnerConfirmed: true,
      dateLabel: 'Kemarin, 14:30 WIB',
    ),
    BarterDeal(
      id: 'deal-3',
      partnerName: 'Rian Hidayat',
      myItem: BarterItem(
        id: 'item-5',
        name: 'Modul Praktikum Kimia',
        price: 40000,
        category: 'Buku & Referensi',
        condition: 'Baik',
      ),
      partnerItem: BarterItem(
        id: 'item-17',
        name: 'Jas Lab Ukuran M',
        price: 60000,
        category: 'Alat Perkuliahan',
        condition: 'Baik',
      ),
      cashTopUp: 20000,
      topUpPaidByMe: true,
      isSentByMe: true,
      status: 'Selesai',
      myConfirmed: true,
      partnerConfirmed: true,
      dateLabel: '12 Okt 2026',
    ),
  ];

  /// Barang milik pengguna yang berstatus Available (BR-14).
  /// Mode server: listing Jual milik sendiri yang Available (`GET /items/me`).
  Future<List<BarterItem>> getMyActiveItems() async {
    if (await Backend.isOnline()) {
      final items = await ItemService.getMyItems();
      return items
          .where((i) => i.status == 'Available' && i.listingType == 'Jual')
          .map(
            (i) => BarterItem(
              id: i.id,
              name: i.title,
              price: i.price,
              category: i.category,
              condition: i.condition,
              photoUrl: i.photoUrls.isNotEmpty ? i.photoUrls.first : null,
            ),
          )
          .toList();
    }
    return List.of(_myActiveItems);
  }

  /// Barang milik orang lain yang sedang ditawar. Mode server: null — barang
  /// target ditetapkan dari layar detail barang lewat `setTargetItem`.
  Future<BarterItem?> getTargetItem() async {
    if (await Backend.isOnline()) return null;
    return _targetItem;
  }

  /// Daftar tawaran barter pengguna (dikirim maupun diterima).
  Future<List<BarterDeal>> getMyDeals() async {
    if (await Backend.isOnline()) {
      return Backend.list(await Backend.client.get('/barters/me'))
          .map(BarterDeal.fromJson)
          .toList();
    }
    return List.of(_deals);
  }

  /// Mengirim tawaran barter (status awal Pending).
  ///
  /// BR-16: top-up dibayar Pengaju (Sender) bila barang target lebih mahal,
  /// selain itu dibayar Penerima (Receiver).
  Future<void> submitProposal({
    required BarterItem offeredItem,
    required BarterItem targetItem,
    required int cashTopUp,
  }) async {
    if (await Backend.isOnline()) {
      final senderId = int.tryParse(offeredItem.id);
      final receiverId = int.tryParse(targetItem.id);
      if (senderId == null || receiverId == null) {
        throw Exception('Data barang tidak valid. Muat ulang halaman barang.');
      }
      await Backend.client.post(
        '/barters',
        body: {
          'sender_item_id': senderId,
          'receiver_item_id': receiverId,
          'cash_top_up': cashTopUp,
          if (cashTopUp > 0)
            'top_up_payer': targetItem.price >= offeredItem.price
                ? 'Sender'
                : 'Receiver',
        },
      );
      return;
    }
    // Mode demo: simulasi waktu tunggu server.
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Menekan "Setuju & Kunci Kesepakatan" dari sisi pengguna (dual-confirmation).
  /// Server mengunci kesepakatan bila mitra juga sudah mengonfirmasi.
  Future<BarterDeal> confirmDeal(BarterDeal deal) async {
    if (await Backend.isOnline()) {
      return BarterDeal.fromJson(
        Backend.map(await Backend.client.post('/barters/${deal.id}/confirm')),
      );
    }
    // Mode demo: simulasi waktu tunggu server.
    await Future.delayed(const Duration(seconds: 1));
    return deal.copyWith(
      myConfirmed: true,
      status: deal.partnerConfirmed ? 'Terkunci' : deal.status,
    );
  }

  /// Penerima menolak tawaran (FR-12).
  Future<BarterDeal> rejectDeal(BarterDeal deal, {String? reason}) async {
    if (await Backend.isOnline()) {
      return BarterDeal.fromJson(
        Backend.map(
          await Backend.client.put(
            '/barters/${deal.id}/reject',
            body: {'reason': ?reason},
          ),
        ),
      );
    }
    return deal.copyWith(status: 'Ditolak');
  }

  /// Membatalkan tawaran yang sudah ditanggapi / kesepakatan Terkunci.
  /// Tawaran Pending yang belum ditanggapi ditarik (dihapus) sesuai BR-20.
  /// Mengembalikan null bila tawaran dihapus.
  Future<BarterDeal?> cancelDeal(BarterDeal deal, {String? reason}) async {
    if (await Backend.isOnline()) {
      if (deal.canDelete == true) {
        await Backend.client.delete('/barters/${deal.id}');
        return null;
      }
      return BarterDeal.fromJson(
        Backend.map(
          await Backend.client.put(
            '/barters/${deal.id}/cancel',
            body: {'reason': ?reason},
          ),
        ),
      );
    }
    return deal.copyWith(status: 'Dibatalkan');
  }
}
