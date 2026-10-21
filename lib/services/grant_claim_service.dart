import '../models/grant_claim.dart';
import 'api_client.dart';

class GrantClaimService {
  GrantClaimService(this._client);
  final ApiClient _client;

  /// FR-22. `voiceNoteFilePath` opsional, sesuai mockup "Rekam Voice Note
  /// (Opsional)" — kalau diisi, dikirim multipart seperti foto di
  /// SocialGrantService. Catatan: applicant_user_id SENGAJA tidak dikirim
  /// di body — backend mengambilnya dari JWT di header, bukan dari client,
  /// supaya tidak bisa dipalsukan.
  Future<GrantClaim> submitClaim({
    required String grantId,
    required ClaimUrgency urgency,
    required String justificationText,
    String? voiceNoteFilePath,
  }) async {
    final fields = {
      'grant_id': grantId,
      'urgency_category': urgency.name,
      'justification_text': justificationText,
    };
    final json = voiceNoteFilePath == null
        ? await _client.post('/grant-claims', body: fields)
        : await _client.postMultipart(
            '/grant-claims',
            fields: fields,
            fileField: 'voice_note',
            filePath: voiceNoteFilePath,
          );
    return GrantClaim.fromJson(json as Map<String, dynamic>);
  }

  /// FR-23: antrean untuk donatur, urut urgensi lalu tanggal pengajuan.
  /// Sorting dilakukan di backend (query param) agar tetap konsisten
  /// walau datanya besar — bukan di-sort manual di sisi client.
  Future<List<GrantClaim>> fetchClaimQueue(String grantId) async {
    final json = await _client
        .get('/grants/$grantId/claims', query: {'sort': 'urgency_then_date'});
    return (json as List)
        .map((e) => GrantClaim.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// FR-24: approve → backend yang generate Digital Claim Pass Code.
  Future<GrantClaim> approveClaim(String claimId) async {
    final json = await _client.put('/grant-claims/$claimId/approve');
    return GrantClaim.fromJson(json as Map<String, dynamic>);
  }

  Future<GrantClaim> rejectClaim(String claimId) async {
    final json = await _client.put('/grant-claims/$claimId/reject');
    return GrantClaim.fromJson(json as Map<String, dynamic>);
  }
}
