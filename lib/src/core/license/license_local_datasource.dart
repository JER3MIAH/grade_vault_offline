import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toolkit_core/toolkit_core.dart' show KitLogger;

class LicenseLocalDatasource {
  static const _boxName = 'license_box';
  static const _licenseKey = 'encrypted_license';
  final Box<String> _box;

  LicenseLocalDatasource(this._box);

  static Future<Box<String>> initializeHive() async {
    return await Hive.openBox<String>(_boxName);
  }

  Future<void> saveLicense(String encryptedLicense) async {
    try {
      await _box.put(_licenseKey, encryptedLicense);
    } catch (e) {
      KitLogger.error('Failed to save license: \$e');
      rethrow;
    }
  }

  String? getLicense() {
    try {
      return _box.get(_licenseKey);
    } catch (e) {
      KitLogger.error('Failed to get license: \$e');
      return null;
    }
  }

  Future<void> clearAllData() async {
    try {
      await _box.clear();
      KitLogger.info('License storage cleared successfully');
    } catch (e) {
      KitLogger.error('Failed to clear license storage: \$e');
      rethrow;
    }
  }
}

final licenseBoxProvider = Provider<Box<String>>((ref) {
  throw UnimplementedError('licenseBoxProvider needs to be overridden');
});

final licenseLocalDatasourceProvider = Provider<LicenseLocalDatasource>((ref) {
  final box = ref.watch(licenseBoxProvider);
  return LicenseLocalDatasource(box);
});
