import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/features/settings/data/repositories/action_tracker_repository.dart';

class SaveLimitNotifier extends StateNotifier<int> {
  final ActionTrackerRepository repository;

  SaveLimitNotifier(this.repository) : super(0) {
    _loadCount();
  }

  Future<void> _loadCount() async {
    state = await repository.getSaveCount();
  }

  /// Returns [true] if the action is allowed, [false] if limit is reached.
  Future<bool> attemptAction() async {
    if (state < ActionTrackerRepository.maxLimit) {
      final newCount = state + 1;
      state = newCount;
      await repository.incrementCount(state - 1); // persists the change
      return true;
    }
    return false;
  }

  Future<void> reset() async {
    state = 0;
    await repository.resetCount();
  }
}

final saveLimitProvider = StateNotifierProvider<SaveLimitNotifier, int>((ref) {
  final repo = ref.watch(actionTrackerRepositoryProvider);
  return SaveLimitNotifier(repo);
});
