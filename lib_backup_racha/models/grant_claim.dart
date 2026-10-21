enum ClaimUrgency { mendesak, sedang, rendah }

enum ClaimApproval { pending, approved, rejected }

ClaimUrgency urgencyFromString(String v) => ClaimUrgency.values.firstWhere(
      (e) => e.name == v.toLowerCase(),
      orElse: () => ClaimUrgency.rendah,
    );

ClaimApproval approvalFromString(String v) => ClaimApproval.values.firstWhere(
      (e) => e.name == v.toLowerCase(),
      orElse: () => ClaimApproval.pending,
    );

/// Data tampilan pemohon untuk kartu di layar "daftar-detail-klaim"
/// (nama, NIM, foto). Ini BUKAN pelanggaran aturan low-coupling di
/// TEAM_GUIDELINES.md #3 — aturan itu soal kode Flutter antar modul yang
/// tidak boleh saling panggil/pakai objek satu sama lain. Di sini backend
/// (endpoint milik Modul 5 sendiri) yang men-join data ringkas pemohon ke
/// dalam satu response, jadi kode Flutter Modul 5 tidak perlu
/// mengimpor/bergantung ke kelas User milik Modul Pendukung sama sekali.
class ApplicantSummary {
  ApplicantSummary({required this.id, required this.name, required this.nim, this.photoUrl});

  final String id;
  final String name;
  final String nim;
  final String? photoUrl;

  factory ApplicantSummary.fromJson(Map<String, dynamic> json) => ApplicantSummary(
        id: json['id'].toString(),
        name: json['name'] as String,
        nim: json['nim'] as String,
        photoUrl: json['photo_url'] as String?,
      );
}

/// Model untuk pengajuan klaim hibah (FR-22 s/d FR-24).
class GrantClaim {
  GrantClaim({
    required this.id,
    required this.grantId, // ID saja, bukan objek SocialGrant utuh
    required this.applicantUserId,
    required this.urgency,
    required this.justificationText,
    required this.approval,
    this.digitalClaimPassCode,
    this.voiceNoteUrl,
    this.applicant,
    required this.createdAt,
  });

  final String id;
  final String grantId;
  final String applicantUserId;
  final ClaimUrgency urgency;
  final String justificationText;
  final ClaimApproval approval;
  final String? digitalClaimPassCode;
  final String? voiceNoteUrl; // mockup "ajukan-klaim": Rekam Voice Note (Opsional)
  final ApplicantSummary? applicant; // hanya terisi saat fetch via antrean donatur
  final DateTime createdAt;

  factory GrantClaim.fromJson(Map<String, dynamic> json) => GrantClaim(
        id: json['id'].toString(),
        grantId: json['grant_id'].toString(),
        applicantUserId: json['applicant_user_id'].toString(),
        urgency: urgencyFromString(json['urgency_category'] as String),
        justificationText: json['justification_text'] as String,
        approval: approvalFromString(json['approval_status'] as String),
        digitalClaimPassCode: json['digital_claim_pass_code'] as String?,
        voiceNoteUrl: json['voice_note_url'] as String?,
        applicant: json['applicant'] == null
            ? null
            : ApplicantSummary.fromJson(json['applicant'] as Map<String, dynamic>),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'grant_id': grantId,
        'urgency_category': urgency.name,
        'justification_text': justificationText,
      };
}
