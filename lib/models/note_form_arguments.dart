/// Argumen yang dikirim dari ProductDetailScreen ke NoteFormScreen.
class NoteFormArguments {
  final String productName;
  final String? initialNote;

  const NoteFormArguments({required this.productName, this.initialNote});
}
