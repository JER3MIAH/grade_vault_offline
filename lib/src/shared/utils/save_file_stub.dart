import 'dart:typed_data';

// Stub implementation for non-web platforms
void saveFileWeb(
  Uint8List bytes,
  String filename, {
  String mimeType = 'application/pdf',
}) {
  throw UnsupportedError('saveFileWeb is only supported on web platform');
}
