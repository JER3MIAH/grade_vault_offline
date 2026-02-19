import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:grade_vault_offline/src/shared/utils/share_helper.dart';

/// Centralized helper to deliver generated PDFs across platforms.
class PdfDeliveryService {
  const PdfDeliveryService();

  /// Handles sharing/downloading feedback for a generated PDF file.
  ///
  /// - On web: file is downloaded in-browser; we just show success feedback.
  /// - On Android/iOS: shares the file.
  /// - On desktop: shows the path where the file was saved.
  Future<void> deliver({
    required BuildContext context,
    required File? file,
    required String successMessage,
    String errorMessage = 'An error occurred while generating pdf',
  }) async {
    if (kIsWeb) {
      context.showSuccessSnackBar(successMessage);
      return;
    }

    if (file == null) {
      context.showErrorSnackBar(errorMessage);
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      await ShareHelper.shareFile(file.path);
      return;
    }

    context.showSuccessSnackBar('$successMessage at ${file.path}');
  }
}
