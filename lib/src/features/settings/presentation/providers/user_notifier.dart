import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/features/settings/data/repositories/user_repository.dart';

class UserNotifier extends StateNotifier<bool> {
  final UserRepository repository;

  UserNotifier(this.repository) : super(true);

  Future<bool> checkFirstTime() async {
    final isFirstTime = await repository.getFirstTime();
    state = isFirstTime;
    return isFirstTime;
  }

  Future<void> setFirstTime(bool isFirstTime) async {
    state = isFirstTime;
    await repository.setFirstTime(isFirstTime);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, bool>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UserNotifier(repo);
});
