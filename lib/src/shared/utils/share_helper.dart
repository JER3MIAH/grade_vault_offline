import 'package:share_plus/share_plus.dart';

class ShareHelper {
  /// Shares plain text content
  static Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }

  /// Shares multiple files
  static Future<void> shareFiles(
    List<String> filePaths, {
    String? text,
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: filePaths.map((e) => XFile(e)).toList(),
        text: text,
        subject: subject,
      ),
    );
  }

  /// Shares a single file
  static Future<void> shareFile(
    String filePath, {
    String? text,
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: text, subject: subject),
    );
  }
}
