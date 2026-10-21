import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/meetup.dart';
import '../../models/safe_meet_point.dart';
import '../../services/meetup_repository.dart';
import 'my_meetups_screen.dart';
import 'safe_meet_directory_screen.dart';

class MeetupFormScreen extends StatefulWidget {
  final Meetup? existingMeetup; // Null jika Create, terisi jika Update (FR-07.3)
  final SafeMeetPoint? initialSafeMeetPoint;
  final int itemId;
  final String itemTitle;
  final String itemPrice;
  final String itemType;
  final int ownerId;
  final String ownerName;

  const MeetupFormScreen({
    super.key,
    this.existingMeetup,
    this.initialSafeMeetPoint,
    this.itemId = 1,
    this.itemTitle = 'Buku Kalkulus Purcell Edisi 9',
    this.itemPrice = 'Rp 85.000',
    this.itemType = 'Jual',
    this.ownerId = 2,
    this.ownerName = 'Muhammad Racha',
  });

  bool get isEditMode => existingMeetup != null;

  @override
  State<MeetupFormScreen> createState() => _MeetupFormScreenState();
}

class _MeetupFormScreenState extends State<MeetupFormScreen> {
  final MeetupRepository _repository = MeetupRepository();
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  late SafeMeetPoint _selectedPoint;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool _isSubmitting = false;
  String? _validationErrorMessage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    if (widget.isEditMode) {
      final m = widget.existingMeetup!;
      _selectedPoint = m.safeMeetPoint;
      _selectedDate = m.scheduledTime;
      _selectedTime = TimeOfDay.fromDateTime(m.scheduledTime);
      _notesController.text = m.notes;
    } else {
      // Default: 2 jam dari sekarang (agar valid BR-07)
      final defaultTime = now.add(const Duration(hours: 2));
      _selectedPoint = widget.initialSafeMeetPoint ??
          _repository.getSafeMeetPoints().first;
      _selectedDate = defaultTime;
      _selectedTime = TimeOfDay.fromDateTime(defaultTime);
    }

    _runLiveValidation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  DateTime get _combinedScheduledDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  // Validasi Realtime Aturan Bisnis BR-07 (AC-09)
  void _runLiveValidation() {
    final scheduled = _combinedScheduledDateTime;
    final validation = _repository.validateMeetupTime(scheduled);
    setState(() {
      _validationErrorMessage = validation.isValid ? null : validation.message;
    });
  }

  // Input / Event: Memilih Tanggal Pertemuan
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)), // Maksimal 14 hari (BR-07)
      helpText: 'Pilih Tanggal Pertemuan (Maks 14 Hari)',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _runLiveValidation();
    }
  }

  // Input / Event: Memilih Jam Pertemuan
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Pilih Jam Pertemuan (Min 1 Jam dari Sekarang)',
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      _runLiveValidation();
    }
  }

  // Input / Event: Memilih Titik Temu dari Direktori Resmi (Data Passing & Result Return)
  Future<void> _changeSafeMeetPoint() async {
    final result = await Navigator.of(context).push<SafeMeetPoint>(
      MaterialPageRoute(
        builder: (_) => const SafeMeetDirectoryScreen(isPickerMode: true),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedPoint = result;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Titik temu diubah ke: ${result.name}'),
            backgroundColor: const Color(0xFF0D9488),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Input / Event: Tombol Uji Validasi AC-09 (Set waktu ke 30 menit lagi untuk demo dosen)
  void _setTestScenarioAC09() {
    final invalidTime = DateTime.now().add(const Duration(minutes: 30));
    setState(() {
      _selectedDate = invalidTime;
      _selectedTime = TimeOfDay.fromDateTime(invalidTime);
    });
    _runLiveValidation();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Uji AC-09: Waktu diatur 30 menit dari sekarang. Sistem wajib menolak.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // ==========================================
  // WORKFLOW UTAMA: SUBMIT AJAKAN PERTEMUAN
  // Input/Event -> State -> Validation -> Feedback -> Navigation/Result
  // ==========================================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final scheduled = _combinedScheduledDateTime;

    // Tahap Validasi (BR-07 & AC-09)
    final validation = _repository.validateMeetupTime(scheduled);
    if (!validation.isValid) {
      setState(() {
        _validationErrorMessage = validation.message;
      });

      // Feedback Gagal
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Validasi Gagal (BR-07)'),
            ],
          ),
          content: Text(
            validation.message ?? 'Waktu pertemuan tidak memenuhi batas minimal 1 jam.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Perbaiki Jadwal'),
            ),
          ],
        ),
      );
      return;
    }

    // Tahap State: Mengubah state menjadi loading
    setState(() {
      _isSubmitting = true;
    });

    try {
      Meetup resultMeetup;

      if (widget.isEditMode) {
        // Alur Update (FR-07.3)
        resultMeetup = await _repository.updateMeetup(
          id: widget.existingMeetup!.id,
          newPoint: _selectedPoint,
          newScheduledTime: scheduled,
          newNotes: _notesController.text.trim(),
        );
      } else {
        // Alur Create (FR-07.1)
        resultMeetup = await _repository.createMeetup(
          itemId: widget.itemId,
          itemTitle: widget.itemTitle,
          itemPrice: widget.itemPrice,
          itemType: widget.itemType,
          ownerId: widget.ownerId,
          ownerName: widget.ownerName,
          safeMeetPoint: _selectedPoint,
          scheduledTime: scheduled,
          notes: _notesController.text.trim(),
        );
      }

      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;

      // Tahap Feedback: SnackBar & Dialog Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditMode
              ? 'Jadwal pertemuan berhasil diperbarui!'
              : 'Ajakan pertemuan berhasil diajukan ke penjual!'),
          backgroundColor: const Color(0xFF0D9488),
        ),
      );

      // Tahap Navigation / Result:
      // Kembalikan objek Meetup ke caller, atau pindah ke layar Pertemuan Saya
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(resultMeetup);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MyMeetupsScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDateText = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);
    final formattedTimeText = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} WIB';
    final isValidTime = _validationErrorMessage == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isEditMode ? 'Ubah Jadwal Pertemuan' : 'Ajukan Pertemuan COD',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          // Tombol Praktis Demo Dosen untuk Uji Skenario AC-09
          TextButton(
            onPressed: _setTestScenarioAC09,
            child: const Text(
              'Uji AC-09',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan Barang yang Diajukan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0D9488)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.itemTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.itemPrice} • Jalur ${widget.itemType}',
                            style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                          Text(
                            'Penjual: ${widget.ownerName}',
                            style: const TextStyle(color: Colors.black45, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Pilihan Safe-Meet Point Resmi (Lokasi Wajib Resmi - BR-07)
              const Text(
                'Lokasi Titik Temu Aman (Safe-Meet Point)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: Color(0xFF0D9488), size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedPoint.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '${_selectedPoint.category} • Jarak: ${_selectedPoint.formattedDistance}',
                                style: TextStyle(color: Colors.teal.shade800, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedPoint.description,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _changeSafeMeetPoint,
                        icon: const Icon(Icons.map_rounded, size: 16),
                        label: const Text('Ganti Titik Temu dari Direktori'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D9488),
                          side: const BorderSide(color: Color(0xFF0D9488)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Pemilihan Jadwal (Tanggal & Jam)
              const Text(
                'Jadwal Pertemuan COD',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal', style: TextStyle(fontSize: 11, color: Colors.black54)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF0D9488)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formattedDateText,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Jam', style: TextStyle(fontSize: 11, color: Colors.black54)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF0D9488)),
                                const SizedBox(width: 8),
                                Text(
                                  formattedTimeText,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Indikator Validasi Realtime Aturan BR-07
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isValidTime ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isValidTime ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isValidTime ? Icons.check_circle_rounded : Icons.warning_rounded,
                      size: 16,
                      color: isValidTime ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isValidTime
                            ? 'Waktu valid memenuhi aturan BR-07 (minimal 1 jam dan maksimal 14 hari ke depan).'
                            : (_validationErrorMessage ?? 'Waktu tidak memenuhi aturan BR-07.'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isValidTime ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Catatan Tambahan (Opsional)
              const Text(
                'Catatan untuk Penjual (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Saya pakai kemeja kotak-kotak, tunggu di depan meja resepsionis...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          widget.isEditMode ? 'Simpan Perubahan Jadwal' : 'Kirim Ajakan Pertemuan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
