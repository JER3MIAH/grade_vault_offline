import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/datasources/result_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoolThemeLocalDatasource {
  final SharedPreferences prefs;

  BoolThemeLocalDatasource({required this.prefs});

  static const _key = 'is_dark_theme';

  Future<bool> getTheme() async {
    try {
      return prefs.getBool(_key) ?? false;
    } catch (e, stack) {
      log('error getting theme: $e at $stack');
      return false;
    }
  }

  Future<void> setTheme(bool isDark) async {
    try {
      await prefs.setBool(_key, isDark);
    } catch (e, stack) {
      log('error setting theme: $e at $stack');
    }
  }
}

final boolThemeLocalDatasourceProvider = Provider<BoolThemeLocalDatasource>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BoolThemeLocalDatasource(prefs: prefs);
});
