import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grade_vault_offline/src/features/settings/data/datasources/user_local_datasource.dart';

class UserRepository {
  final UserLocalDatasource localDatasource;

  UserRepository({required this.localDatasource});

  Future<bool> getFirstTime() async {
    return await localDatasource.getFirstTime();
  }

  Future<void> setFirstTime(bool isFirstTime) async {
    return await localDatasource.setFirstTime(isFirstTime);
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final datasource = ref.watch(userLocalDatasourceProvider);
  return UserRepository(localDatasource: datasource);
});
