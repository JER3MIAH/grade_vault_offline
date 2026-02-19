import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/features/home/data/repositories/theme_repository.dart';

class ThemeNotifier extends StateNotifier<bool> {
  final ThemeRepository repository;

  ThemeNotifier(this.repository) : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await repository.getTheme();
    state = isDark;
  }

  Future<void> toggle() async {
    final newState = !state;
    state = newState;
    await repository.setTheme(newState);
  }

  Future<void> setTheme(bool isDark) async {
    state = isDark;
    await repository.setTheme(isDark);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final repo = ref.watch(themeRepositoryProvider);
  return ThemeNotifier(repo);
});
