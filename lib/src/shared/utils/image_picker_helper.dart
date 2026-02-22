import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageBase64Picker {
  final ImagePicker _picker = ImagePicker();

  /// Picks image from gallery and returns Base64 string
  /// Returns null if user cancels
  Future<String?> pickImageAsBase64({
    int maxWidth = 300,
    int quality = 70,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return null;

      final File file = File(pickedFile.path);

      final List<int> imageBytes = await file.readAsBytes();
      img.Image? originalImage = img.decodeImage(
        Uint8List.fromList(imageBytes),
      );

      if (originalImage == null) return null;

      // Resize image (to reduce license string size)
      img.Image resizedImage = img.copyResize(originalImage, width: maxWidth);

      // Compress to JPEG
      List<int> compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      // Convert to Base64
      String base64String = base64Encode(compressedBytes);

      return base64String;
    } catch (e) {
      KitLogger.error('Error picking image: $e');
      return null;
    }
  }
}
