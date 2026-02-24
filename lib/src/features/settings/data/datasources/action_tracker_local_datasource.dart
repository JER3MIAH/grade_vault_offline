import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/datasources/result_local_datasource.dart'; // Assuming hiveBoxProvider is here
import 'package:hive/hive.dart' show Box;

class ActionTrackerLocalDatasource {
  final Box hiveBox;

  ActionTrackerLocalDatasource({required this.hiveBox});

  static const _countKey = 'save_action_count';

  Future<int> getSaveCount() async {
    try {
      return hiveBox.get(_countKey, defaultValue: 0) as int;
    } catch (e, stack) {
      log('Error getting save count: $e at $stack');
      return 0;
    }
  }

  Future<void> setSaveCount(int count) async {
    try {
      await hiveBox.put(_countKey, count);
    } catch (e, stack) {
      log('Error setting save count: $e at $stack');
    }
  }
}

final actionTrackerLocalDatasourceProvider =
    Provider<ActionTrackerLocalDatasource>((ref) {
      final hiveBox = ref.watch(hiveBoxProvider);
      return ActionTrackerLocalDatasource(hiveBox: hiveBox);
    });
