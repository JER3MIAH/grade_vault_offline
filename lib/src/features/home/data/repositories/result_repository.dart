import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/datasources/result_local_datasource.dart';
import 'package:grade_vault_offline/src/features/home/data/models/app_state.dart';

class ResultRepository {
  final ResultLocalDatasource localDatasource;
  ResultRepository({required this.localDatasource});

  Future<AppState?> getResult() async {
    return await localDatasource.getAppState();
  }

  Future<void> setResult(AppState state) async {
    return await localDatasource.setAppState(state);
  }
}

final resultRepositoryProvider = Provider<ResultRepository>((ref) {
  final resultLocalDatasource = ref.watch(resultLocalDatasourceProvider);
  return ResultRepository(localDatasource: resultLocalDatasource);
});
