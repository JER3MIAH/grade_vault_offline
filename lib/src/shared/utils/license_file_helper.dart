import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class LicenseFileHelper {
  /// Picks a .txt file and returns its name and content
  static Future<({String name, String content})?> pickAndReadLicense() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        final content = utf8.decode(file.bytes!);

        return (name: file.name, content: content);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
