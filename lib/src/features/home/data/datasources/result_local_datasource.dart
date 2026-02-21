import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:grade_vault_offline/src/features/home/data/models/app_state.dart';

class ResultLocalDatasource {
  final Box hiveBox;

  static const String _appStateKey = 'app_state';
  static const String _hiveBoxName = 'grade_vault_offline_storage';

  ResultLocalDatasource({required this.hiveBox});

  static Future<Box> initializeHive() async {
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(AppStateAdapter());
      }
      final box = await Hive.openBox(_hiveBoxName);
      return box;
    } catch (e) {
      log('Error initializing Hive: $e');
      rethrow;
    }
  }

  Future<AppState?> getAppState() async {
    try {
      final String? json = hiveBox.get(_appStateKey);
      if (json != null) return AppState.fromJson(json);
      return null;
    } catch (e, stack) {
      log('error getting app state: $e at $stack');
      return null;
    }
  }

  Future<void> setAppState(AppState state) async {
    try {
      String json = state.toJson();

      await hiveBox.put(_appStateKey, json);
    } catch (e, stack) {
      log('error saving app state: $e at $stack');
    }
  }

  Future<void> clearAllData() async {
    try {
      await hiveBox.clear();
      log('Local app state storage cleared successfully');
    } catch (e, stack) {
      log('error clearing app state: $e at $stack');
    }
  }
}

class AppStateAdapter extends TypeAdapter<AppState> {
  @override
  final int typeId = 0;

  @override
  AppState read(BinaryReader reader) {
    final jsonString = reader.read() as String;
    return AppState.fromJson(jsonString);
  }

  @override
  void write(BinaryWriter writer, AppState obj) {
    writer.write(obj.toJson());
  }
}

final hiveBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError();
});

final resultLocalDatasourceProvider = Provider<ResultLocalDatasource>((ref) {
  final hiveBox = ref.watch(hiveBoxProvider);
  return ResultLocalDatasource(hiveBox: hiveBox);
});
