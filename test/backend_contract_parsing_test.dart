import 'package:campusshift/core/listing_options.dart';
import 'package:campusshift/models/barter_deal.dart';
import 'package:campusshift/models/handover_proof_model.dart';
import 'package:campusshift/models/handover_token_model.dart';
import 'package:campusshift/models/meetup.dart';
import 'package:campusshift/models/review_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bentuk JSON mengikuti `be-campusshift/src/utils/serializers.js` dan
/// `handover.controller.js#serializeProof`. Bila backend mengubah format,
/// test ini yang pertama gagal.
void main() {
  test('Kategori & kondisi listing sama dengan constants.js backend', () {
    expect(ListingOptions.categories, [
      'Buku & Referensi',
      'Furnitur Kos',
      'Elektronik',
      'Alat Perkuliahan',
    ]);
    expect(ListingOptions.conditions, ['Baru', 'Sangat Baik', 'Baik', 'Cukup']);
    // Data lama berlabel deskriptif dinormalisasi ke nilai resmi.
    expect(ListingOptions.normalizeCondition('Sangat Baik (Grade A)'), 'Sangat Baik');
    expect(ListingOptions.normalizeCondition('Baik (Grade B)'), 'Baik');
    expect(ListingOptions.normalizeCategory('Elektronik & Gadget'), 'Elektronik');
  });

  const point = {
    'id': 2,
    'name': 'Perpustakaan Pusat',
    'category': 'Perpustakaan',
    'latitude': -0.9148,
    'longitude': 100.4612,
    'description': '',
    'type': 'Official',
    'operational_hours': null,
    'landmark': 'Lobby',
    'safety_features': ['CCTV'],
  };

  test('Meetup.fromJson membaca serializeMeetup (harga angka, waktu UTC)', () {
    final meetup = Meetup.fromJson({
      'id': 5,
      'item_id': 12,
      'item_title': 'Kalkulator',
      'item_category': 'Elektronik',
      'item_price': 85000,
      'item_type': 'Barter',
      'item_status': 'Reserved',
      'deal_id': 3,
      'claim_id': null,
      'requester_id': 1,
      'requester_name': 'Bayu',
      'requester_nim': '2411522023',
      'owner_id': 2,
      'owner_name': 'Racha',
      'owner_nim': '2411522020',
      'safe_meet_point': point,
      'scheduled_time': '2026-11-06T07:00:00.000Z',
      'notes': '',
      'status': 'Ditolak',
      'cancelled_by': null,
      'cancellation_reason': 'Tidak jadi',
      'created_at': '2026-11-05T07:00:00.000Z',
    });
    expect(meetup.itemPrice, 'Rp85.000');
    expect(meetup.dealId, 3);
    expect(meetup.claimId, isNull);
    expect(meetup.isDitolak, isTrue);
    expect(meetup.safeMeetPoint.operationalHours, isNotEmpty);
    expect(meetup.scheduledTime.isUtc, isFalse); // dikonversi ke waktu lokal
  });

  test('BarterDeal.fromJson memakai status_label dan flag can_*', () {
    final deal = BarterDeal.fromJson({
      'id': 9,
      'status': 'Pending',
      'status_label': 'Menunggu',
      'is_sent_by_me': false,
      'partner_user_id': 4,
      'partner_name': 'Farhan',
      'my_item': {'id': 1, 'name': 'Meja', 'price': 120000, 'category': 'Furnitur Kos', 'condition': 'Baik', 'status': 'Available', 'photo_url': null},
      'partner_item': {'id': 2, 'name': 'Rice Cooker', 'price': 150000, 'category': 'Elektronik', 'condition': 'Baik', 'status': 'Available', 'photo_url': 'http://x/p.jpg'},
      'cash_top_up': 30000,
      'top_up_payer': 'Receiver',
      'top_up_paid_by_me': true,
      'my_confirmed': false,
      'partner_confirmed': true,
      'can_confirm': true,
      'can_reject': true,
      'can_delete': false,
      'can_cancel': false,
      'created_at': '2026-11-05T07:00:00.000Z',
      'updated_at': '2026-11-05T08:00:00.000Z',
    });
    expect(deal.status, 'Menunggu');
    expect(deal.partnerUserId, 4);
    expect(deal.canConfirm, isTrue);
    expect(deal.partnerItem.photoUrl, 'http://x/p.jpg');
    expect(deal.dateLabel, contains('2026'));
  });

  test('HandoverTokenModel.fromJson membaca serializeToken', () {
    final token = HandoverTokenModel.fromJson({
      'token_id': '15',
      'meetup_id': '5',
      'token': 'abc_DEF-123',
      'issued_at': '2026-11-05T07:00:00.000Z',
      'expires_at': '2026-11-05T07:05:00.000Z',
      'used_at': null,
      'status': 'active',
      'proof_number': null,
    });
    expect(token.tokenId, '15');
    expect(token.status, 'active');
  });

  test('HandoverProofModel.fromServer membaca riwayat serah terima', () {
    final proof = HandoverProofModel.fromServer({
      'meetup_id': 5,
      'proof_number': 'PRF-20261105-000015',
      'validated_at': '2026-11-05T07:03:00.000Z',
      'item_type': 'Barter',
      'items': [
        {'id': 1, 'title': 'Meja'},
        {'id': 2, 'title': 'Rice Cooker'},
      ],
      'item_price': null,
      'cash_top_up': 30000,
      'owner': {'id': 2, 'full_name': 'Racha', 'nim': '2411522020'},
      'requester': {'id': 1, 'full_name': 'Bayu', 'nim': '2411522023'},
      'partner': {'id': 2, 'full_name': 'Racha', 'nim': '2411522020'},
      'safe_meet_point': point,
      'my_review': {
        'id': 7,
        'meetup_id': 5,
        'reviewer_id': 1,
        'reviewer_name': 'Bayu',
        'reviewee_id': 2,
        'rating': 5,
        'comment': 'Mantap',
        'is_edited': false,
        'can_edit': true,
        'created_at': '2026-11-05T08:00:00.000Z',
      },
      'partner_review': null,
    });
    expect(proof.proofNumber, 'PRF-20261105-000015');
    expect(proof.itemTitle, 'Meja ⇄ Rice Cooker');
    expect(proof.itemPrice, 'Top-up Rp30.000');
    expect(proof.ownerName, 'Racha');
    expect(proof.safeMeetPointName, 'Perpustakaan Pusat');
    expect(proof.myReview?.rating, 5);
    expect(proof.myReview?.canEdit, isTrue);
    expect(proof.partnerReview, isNull);
  });

  test('ReviewModel.fromServer memakai can_edit dari server (BR-26)', () {
    final review = ReviewModel.fromServer({
      'id': 8,
      'meetup_id': 5,
      'reviewer_id': 2,
      'reviewer_name': 'Racha',
      'reviewee_id': 1,
      'rating': 4,
      'comment': null,
      'is_edited': false,
      'can_edit': false,
      'created_at': '2026-11-05T08:00:00.000Z',
    });
    expect(review.id, '8');
    expect(review.targetUserId, 1);
    expect(review.comment, '');
    expect(review.canEdit, isFalse);
  });
}
