class AppVersion {
  const AppVersion._();

  static const String currentVersion = '1.1.1';
  static const String buildNumber = '4';

  static String get version => '$currentVersion+$buildNumber';
}
