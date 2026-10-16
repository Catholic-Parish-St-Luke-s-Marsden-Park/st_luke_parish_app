import 'dart:typed_data';

/// The notice currently shown in the parish home page's pop-up, e.g. the
/// "Save the Date" events poster. It is an image, not text.
class ParishNotice {
  const ParishNotice({required this.imageUrl, required this.imageBytes});

  final String imageUrl;

  /// The image, already downloaded, so it shows instantly when opened.
  final Uint8List imageBytes;
}
