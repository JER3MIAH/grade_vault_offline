import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/core/config/app_config.dart';
import 'package:grade_vault_offline/src/core/config/config.dart';
import 'package:grade_vault_offline/src/core/license/license_local_datasource.dart';
import 'package:grade_vault_offline/src/core/license/license_manager.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:toolkit_core/toolkit_core.dart' show KitLogger;

class LicenseNotifier extends Notifier<SchoolInfo> {
  @override
  SchoolInfo build() {
    _loadInitialLicense();
    return AppConfig.instance.schoolInfo;
  }

  void _loadInitialLicense() {
    final localDataSource = ref.read(licenseLocalDatasourceProvider);
    final encryptedLicense = localDataSource.getLicense();

    if (encryptedLicense != null) {
      final decryptedData = LicenseManager.decrypt(encryptedLicense);
      if (decryptedData != null) {
        try {
          // Verify it matches the shape of SchoolInfo
          if (decryptedData.containsKey('name')) {
            final fetchedSchoolInfo = SchoolInfo.fromMap(decryptedData);
            _updateAppConfig(fetchedSchoolInfo);
            return;
          }
        } catch (e) {
          KitLogger.error('Failed to parse saved license: \$e');
        }
      }
    }

    // Fallback to demo config
    _updateAppConfig(
      SchoolInfo.fromMap(configData['schoolInfo'] as Map<String, dynamic>),
    );
  }

  void _updateAppConfig(SchoolInfo newInfo) {
    AppConfig.instance = AppConfig(schoolInfo: newInfo);
  }

  Future<bool> saveLicense(String encryptedLicense) async {
    try {
      final decryptedData = LicenseManager.decrypt(encryptedLicense);
      if (decryptedData == null || !decryptedData.containsKey('name')) {
        KitLogger.error('Invalid license format');
        return false;
      }

      final localDataSource = ref.read(licenseLocalDatasourceProvider);
      await localDataSource.saveLicense(encryptedLicense);

      final newSchoolInfo = SchoolInfo.fromMap(decryptedData);
      state = newSchoolInfo;
      _updateAppConfig(newSchoolInfo);

      return true;
    } catch (e) {
      KitLogger.error('Error saving license: \$e');
      return false;
    }
  }

  Future<void> resetToDemo() async {
    try {
      // Clear local storage by sending an empty/null string or clearing box depending on implementation
      final localDataSource = ref.read(licenseLocalDatasourceProvider);
      // We'll write an empty string to invalidate it. Decrypt will fail, fallback to demo on restart.
      // Even better, modify LicenseLocalDatasource to have a delete/clear method if possible,
      // but for now saving empty string works since decrypt will catch it.
      await localDataSource.saveLicense('');

      final demoInfo = SchoolInfo.fromMap(
        configData['schoolInfo'] as Map<String, dynamic>,
      );
      state = demoInfo;
      _updateAppConfig(demoInfo);
    } catch (e) {
      KitLogger.error('Error resetting license: \$e');
    }
  }
}

final licenseProvider = NotifierProvider<LicenseNotifier, SchoolInfo>(() {
  return LicenseNotifier();
});
