import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/datasources/theme_local_datasource.dart';

class ThemeRepository {
  final BoolThemeLocalDatasource localDatasource;

  ThemeRepository({required this.localDatasource});

  Future<bool> getTheme() async {
    return await localDatasource.getTheme();
  }

  Future<void> setTheme(bool isDark) async {
    return await localDatasource.setTheme(isDark);
  }
}

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  final datasource = ref.watch(boolThemeLocalDatasourceProvider);
  return ThemeRepository(localDatasource: datasource);
});
