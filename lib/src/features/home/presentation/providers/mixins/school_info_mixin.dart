import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/features/home/data/models/app_state.dart';

mixin SchoolInfoMixin on StateNotifier<AppState> {
  Future<void> saveState();

  Future<void> updateSchoolInfo({
    String? name,
    String? motto,
    String? address,
    String? logoPath,
  }) async {
    final updatedSchoolInfo = state.schoolInfo.copyWith(
      name: name,
      motto: motto,
      address: address,
      logoPath: logoPath,
    );

    state = state.copyWith(schoolInfo: updatedSchoolInfo);
    await saveState();
  }

  Future<void> replaceAppState(AppState newState) async {
    state = newState;
    await saveState();
  }
}
