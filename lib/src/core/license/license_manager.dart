import 'dart:convert';
import 'dart:typed_data'; // Required for Uint8List
import 'package:encrypt/encrypt.dart';
import 'package:toolkit_core/toolkit_core.dart' show KitLogger;

class LicenseManager {
  // Split key for mild obfuscation
  static final _k1 = 'my_secure_';
  static final _k2 = '32_char_key_';
  static final _k3 = 'part_3_123';

  static final _key = Key.fromUtf8('$_k1$_k2$_k3');

  // Corrected IV initialization: 16 bytes of zeros
  static final _iv = IV(Uint8List(16));

  static String encrypt(Map<String, dynamic> data) {
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(jsonEncode(data), iv: _iv);
    return encrypted.base64;
  }

  static Map<String, dynamic>? decrypt(String base64Cipher) {
    try {
      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt64(base64Cipher, iv: _iv);
      return jsonDecode(decrypted);
    } catch (e) {
      KitLogger.error('Decryption failed: $e');
      return null;
    }
  }
}
