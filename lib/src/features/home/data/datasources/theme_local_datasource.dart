import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/datasources/result_local_datasource.dart';
import 'package:hive/hive.dart' show Box;

class BoolThemeLocalDatasource {
  final Box hiveBox;

  BoolThemeLocalDatasource({required this.hiveBox});

  static const _key = 'is_dark_theme';

  Future<bool> getTheme() async {
    try {
      return hiveBox.get(_key, defaultValue: false) as bool? ?? false;
    } catch (e, stack) {
      log('error getting theme: $e at $stack');
      return false;
    }
  }

  Future<void> setTheme(bool isDark) async {
    try {
      await hiveBox.put(_key, isDark);
    } catch (e, stack) {
      log('error setting theme: $e at $stack');
    }
  }
}

final boolThemeLocalDatasourceProvider = Provider<BoolThemeLocalDatasource>((
  ref,
) {
  final hiveBox = ref.watch(hiveBoxProvider);
  return BoolThemeLocalDatasource(hiveBox: hiveBox);
});
