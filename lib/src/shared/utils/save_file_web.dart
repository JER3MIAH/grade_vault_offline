import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

void saveFileWeb(
  Uint8List bytes,
  String filename, {
  String mimeType = 'application/pdf',
}) {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);

  // Detect iOS (iPhone/iPad/iPod) to open in a new tab
  final ua = web.window.navigator.userAgent.toLowerCase();
  final isIOS =
      ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod');

  if (isIOS) {
    // Opening in a new tab shows Safari's PDF viewer with the share button
    web.window.open(url, '_blank');
    // Do not immediately revoke the object URL to avoid race conditions
    // (iOS Safari may still be loading the blob). Let the browser handle cleanup.
    return;
  }

  // Other platforms: trigger download via anchor
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = filename
    ..target = '_self';
  anchor.click();

  web.URL.revokeObjectURL(url);
}
