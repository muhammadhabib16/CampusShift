/// Nilai kategori & kondisi listing (Modul 1).
///
/// HARUS sama persis dengan `ITEM_CATEGORIES` dan `ITEM_CONDITIONS` di
/// `be-campusshift/src/config/constants.js` — backend menolak nilai lain
/// ("Kategori tidak valid" / "Kondisi harus Baru, Sangat Baik, Baik, atau Cukup").
/// Teks yang lebih deskriptif hanya untuk tampilan lewat [conditionLabel].
abstract final class ListingOptions {
  static const List<String> categories = [
    'Buku & Referensi',
    'Furnitur Kos',
    'Elektronik',
    'Alat Perkuliahan',
  ];

  static const List<String> conditions = [
    'Baru',
    'Sangat Baik',
    'Baik',
    'Cukup',
  ];

  static const String defaultCondition = 'Sangat Baik';

  static const Map<String, String> _conditionLabels = {
    'Baru': 'Baru (Segel / Belum Terpakai)',
    'Sangat Baik': 'Sangat Baik (Grade A)',
    'Baik': 'Baik (Grade B)',
    'Cukup': 'Cukup (Grade C)',
  };

  /// Label tampilan untuk nilai kondisi resmi.
  static String conditionLabel(String value) =>
      _conditionLabels[value] ?? value;

  /// Mengubah nilai lama/label (mis. "Sangat Baik (Grade A)",
  /// "Elektronik & Gadget") menjadi nilai resmi backend.
  static String normalizeCondition(String value) {
    for (final c in conditions) {
      if (value == c || value.startsWith('$c ')) return c;
    }
    return defaultCondition;
  }

  static String normalizeCategory(String value) {
    if (categories.contains(value)) return value;
    if (value.startsWith('Elektronik')) return 'Elektronik';
    return categories.first;
  }
}
