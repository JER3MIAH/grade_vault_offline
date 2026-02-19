import 'package:grade_vault_offline/src/core/config/config.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart'
    show SchoolInfo;

class AppConfig {
  final SchoolInfo schoolInfo;

  AppConfig({required this.schoolInfo});

  /// Singleton instance
  static late AppConfig instance;

  /// Load the config data
  static Future<void> load() async {
    final Map<String, dynamic> data = configData;

    instance = AppConfig.fromMap(data);
  }

  factory AppConfig.fromMap(Map<String, dynamic> json) {
    return AppConfig(schoolInfo: SchoolInfo.fromMap(json['schoolInfo']));
  }
}
