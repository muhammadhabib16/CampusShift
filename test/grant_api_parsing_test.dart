import 'package:campusshift/models/grant_claim.dart';
import 'package:campusshift/models/social_grant.dart';
import 'package:campusshift/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bentuk JSON mengikuti `be-campusshift/src/utils/serializers.js`
/// (serializeItem & serializeClaim) dan `claim.controller.js#getItemClaims`.
void main() {
  test('ApiClient.unwrap mengambil isi data dari envelope backend', () {
    expect(ApiClient.unwrap({'success': true, 'data': [1, 2]}), [1, 2]);
    expect(ApiClient.unwrap([3]), [3]);
  });

  test('SocialGrant.fromJson membaca serializeItem', () {
    final grant = SocialGrant.fromJson({
      'item_id': 12,
      'owner_user_id': 4,
      'owner_name': 'Raka',
      'judul': 'Buku Kalkulus',
      'deskripsi': 'Masih rapi',
      'kategori': 'Buku & Referensi',
      'tipe_listing': 'Hibah',
      'kondisi': 'Baik',
      'url_foto': ['https://x/1.jpg'],
      'status': 'Available',
    });
    expect(grant.id, '12');
    expect(grant.ownerUserId, '4');
    expect(grant.title, 'Buku Kalkulus');
    expect(grant.photoUrls, ['https://x/1.jpg']);
    expect(grant.listingType, 'Hibah');
  });

  test('GrantClaim.fromJson membaca antrean klaim donatur', () {
    final claim = GrantClaim.fromJson({
      'id': 7,
      'item_id': 12,
      'item_title': 'Buku Kalkulus',
      'donor_user_id': 4,
      'donor_name': 'Raka',
      'applicant_user_id': 9,
      'urgency_category': 'Mendesak',
      'justification_text': 'Butuh untuk kuliah',
      'status': 'Rejected',
      'reason': 'Sudah diberikan ke pemohon lain',
      'created_at': '2026-11-01T10:00:00.000Z',
      'applicant': {
        'id': 9,
        'name': 'Sinta',
        'nim': '2411522011',
        'photo_url': null,
        'reputation': {'average': 4.7, 'count': 3, 'label': '4.7 (3 ulasan)'},
      },
    });
    expect(claim.id, '7');
    expect(claim.applicantUserId, '9');
    expect(claim.applicantName, 'Sinta');
    expect(claim.applicantNim, '2411522011');
    expect(claim.applicantReputation, 4.7);
    expect(claim.applicantReviewCount, 3);
    expect(claim.urgency, 'Mendesak');
    expect(claim.justification, 'Butuh untuk kuliah');
    expect(claim.rejectionReason, 'Sudah diberikan ke pemohon lain');
  });
}
