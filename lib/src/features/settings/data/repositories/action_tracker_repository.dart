import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grade_vault_offline/src/features/settings/data/datasources/action_tracker_local_datasource.dart';

class ActionTrackerRepository {
  final ActionTrackerLocalDatasource localDatasource;
  static const int maxLimit = 5;

  ActionTrackerRepository({required this.localDatasource});

  Future<int> getSaveCount() async {
    return await localDatasource.getSaveCount();
  }

  Future<void> incrementCount(int currentCount) async {
    await localDatasource.setSaveCount(currentCount + 1);
  }

  Future<void> resetCount() async {
    await localDatasource.setSaveCount(0);
  }
}

final actionTrackerRepositoryProvider = Provider<ActionTrackerRepository>((
  ref,
) {
  final datasource = ref.watch(actionTrackerLocalDatasourceProvider);
  return ActionTrackerRepository(localDatasource: datasource);
});
