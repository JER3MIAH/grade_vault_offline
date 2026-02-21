import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/datasources/result_local_datasource.dart'; // Assuming hiveBoxProvider is here
import 'package:hive/hive.dart' show Box;

class UserLocalDatasource {
  final Box hiveBox;

  UserLocalDatasource({required this.hiveBox});

  static const _key = 'is_first_time';

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
}

final userLocalDatasourceProvider = Provider<UserLocalDatasource>((ref) {
  final hiveBox = ref.watch(hiveBoxProvider);
  return UserLocalDatasource(hiveBox: hiveBox);
});
