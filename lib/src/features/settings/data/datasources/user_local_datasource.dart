import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/datasources/result_local_datasource.dart'; // Assuming hiveBoxProvider is here
import 'package:hive/hive.dart' show Box;

class UserLocalDatasource {
  final Box hiveBox;

  UserLocalDatasource({required this.hiveBox});

  static const _key = 'is_first_time';
  static const _supportLaunchCountKey = 'support_launch_count';
  static const _supportNeverShowKey = 'support_never_show';

  Future<bool> getFirstTime() async {
    try {
      // Default to true because if the key doesn't exist, it IS their first time.
      return hiveBox.get(_key, defaultValue: true) as bool? ?? true;
    } catch (e, stack) {
      log('error getting first time flag: $e at $stack');
      return true;
    }
  }

  Future<void> setFirstTime(bool isFirstTime) async {
    try {
      await hiveBox.put(_key, isFirstTime);
    } catch (e, stack) {
      log('error setting first time flag: $e at $stack');
    }
  }

  Future<void> clearAllData() async {
    try {
      await hiveBox.clear();
      log('User preference storage cleared successfully');
    } catch (e, stack) {
      log('error clearing first time user storage: $e at $stack');
    }
  }

  /// Increments the launch count and returns true if the support prompt
  /// should be shown this session. Shows at launch 5, 15, 25, ...
  Future<bool> checkAndIncrementForSupportPrompt() async {
    try {
      final neverShow =
          hiveBox.get(_supportNeverShowKey, defaultValue: false) as bool? ??
          false;
      if (neverShow) return false;

      final count =
          (hiveBox.get(_supportLaunchCountKey, defaultValue: 0) as int? ?? 0) +
          1;
      await hiveBox.put(_supportLaunchCountKey, count);

      return count >= 5 && (count - 5) % 10 == 0;
    } catch (e, stack) {
      log('error checking support prompt: $e at $stack');
      return false;
    }
  }

  Future<void> setSupportNeverShow(bool value) async {
    try {
      await hiveBox.put(_supportNeverShowKey, value);
    } catch (e, stack) {
      log('error setting support never show: $e at $stack');
    }
  }
}

final userLocalDatasourceProvider = Provider<UserLocalDatasource>((ref) {
  final hiveBox = ref.watch(hiveBoxProvider);
  return UserLocalDatasource(hiveBox: hiveBox);
});
