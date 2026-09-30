class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _nimRegex = RegExp(r'^\d{8,12}$');

  /// Kolom "Email Kampus / NIM": boleh email valid atau NIM (8-12 digit).
  static String? emailOrNim(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email atau NIM tidak boleh kosong';
    if (text.contains('@')) {
      if (!_emailRegex.hasMatch(text)) return 'Format email tidak valid';
      return null;
    }
    if (!_nimRegex.hasMatch(text)) {
      return 'NIM harus 8-12 digit angka';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (text.length < 8) return 'Kata sandi minimal 8 karakter';
    return null;
  }

  static String? note(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Catatan tidak boleh kosong';
    if (text.length < 3) return 'Catatan minimal 3 karakter';
    if (text.length > 200) return 'Catatan maksimal 200 karakter';
    return null;
  }
}
