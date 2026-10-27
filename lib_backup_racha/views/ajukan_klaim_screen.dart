import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import '../models/grant_claim.dart';
import '../models/social_grant.dart';
import '../viewmodels/grant_claim_viewmodel.dart';

/// Layar "ajukan-klaim" — FR-22 (pemohon mengajukan klaim dengan
/// justifikasi akademik).
class AjukanKlaimScreen extends StatefulWidget {
  const AjukanKlaimScreen({super.key, required this.grant, required this.currentUserNim});

  final SocialGrant grant;

  /// Dioper dari luar modul (hasil AuthViewModel milik Modul Pendukung),
  /// bukan diimpor langsung — menjaga low coupling antar modul, sesuai
  /// TEAM_GUIDELINES.md #3.
  final String currentUserNim;

  @override
  State<AjukanKlaimScreen> createState() => _AjukanKlaimScreenState();
}

class _AjukanKlaimScreenState extends State<AjukanKlaimScreen> {
  final _justificationCtrl = TextEditingController();
  ClaimUrgency _urgency = ClaimUrgency.sedang;
  String? _voiceNotePath;

  @override
  void dispose() {
    _justificationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vm = context.read<GrantClaimViewModel>();
    final ok = await vm.submitClaim(
      grantId: widget.grant.id,
      urgency: _urgency,
      justificationText: _justificationCtrl.text,
      voiceNoteFilePath: _voiceNotePath,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Klaim berhasil diajukan.')));
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  String _urgencyLabel(ClaimUrgency u) => switch (u) {
        ClaimUrgency.mendesak => 'Mendesak',
        ClaimUrgency.sedang => 'Sedang',
        ClaimUrgency.rendah => 'Rendah',
      };

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GrantClaimViewModel>();
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Ajukan Klaim',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GrantSummaryCard(grant: widget.grant),
          const SizedBox(height: 20),
          const Text('Alasan Kebutuhan', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _justificationCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Jelaskan mengapa kamu membutuhkan barang ini untuk menunjang perkuliahan...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          // Tambahan di luar mockup Figma: "Aturan_Project_Mobile_2026.md"
          // (FR-22) mewajibkan kategori urgensi untuk menentukan urutan di
          // layar daftar-detail-klaim, tapi field ini belum ada di desain.
          // Dibuat ringkas (chip) biar tidak mengganggu layout aslinya —
          // koordinasikan dgn tim kalau mau diposisikan ulang.
          const Text('Tingkat Urgensi', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ClaimUrgency.values.map((u) {
              final selected = _urgency == u;
              return ChoiceChip(
                label: Text(_urgencyLabel(u)),
                selected: selected,
                onSelected: (_) => setState(() => _urgency = u),
                selectedColor: const Color(0xFF0D9488),
                labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Nomor Induk Mahasiswa (NIM) Verifikasi',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration:
                BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Expanded(
                  child: Text('${widget.currentUserNim} (Terverifikasi)',
                      style: const TextStyle(color: Colors.black54)),
                ),
                const Icon(Icons.check_circle, color: Color(0xFF0D9488)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _VoiceNoteRecorder(onRecorded: (path) => setState(() => _voiceNotePath = path)),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: vm.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: vm.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kirim Klaim',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrantSummaryCard extends StatelessWidget {
  const _GrantSummaryCard({required this.grant});
  final SocialGrant grant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: grant.photoUrl.isEmpty
                  ? Container(color: Colors.grey.shade200)
                  : Image.network(grant.photoUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F5F2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('DONASI AKTIF',
                      style: TextStyle(
                          color: Color(0xFF0D9488), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Text(grant.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Donatur: ${grant.donorName}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Perekam voice note opsional. Pakai package `record` (tambahkan ke
/// pubspec.yaml). Flutter tidak punya border putus-putus bawaan, jadi
/// dipakai border solid teal — tinggal ganti ke package `dotted_border`
/// kalau mau persis seperti mockup.
class _VoiceNoteRecorder extends StatefulWidget {
  const _VoiceNoteRecorder({required this.onRecorded});
  final ValueChanged<String?> onRecorded;

  @override
  State<_VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<_VoiceNoteRecorder> {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _filePath;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _filePath = path;
      });
      widget.onRecorded(path);
      return;
    }
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/claim_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      setState(() => _isRecording = true);
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Izin mikrofon diperlukan.')));
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleRecording,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FBF9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0D9488)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF0D9488),
              child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _filePath != null ? 'Voice note tersimpan' : 'Rekam Voice Note (Opsional)',
                    style:
                        const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isRecording
                        ? 'Merekam... ketuk untuk berhenti'
                        : 'Berikan penjelasan lisan untuk memperkuat pengajuanmu.',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
