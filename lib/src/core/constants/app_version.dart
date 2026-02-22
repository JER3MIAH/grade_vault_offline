class AppVersion {
  const AppVersion._();

  static const String currentVersion = '1.0.0';
  static const String buildNumber = '1';

  static String get version => '$currentVersion+$buildNumber';
}
