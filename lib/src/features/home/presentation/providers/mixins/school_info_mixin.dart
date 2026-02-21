import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';

mixin SchoolInfoMixin on StateNotifier<AppState> {
  Future<void> saveState();

  Future<void> updateSchoolInfo({
    String? name,
    String? motto,
    String? address,
    String? logoPath,
    List<String>? branches,
    ContactInfo? contactInfo,
    String? website,
    String? establishedYear,
    GradingSystem? gradingSystem,
    bool? showFinalPosition,
  }) async {
    final updatedSchoolInfo = state.schoolInfo.copyWith(
      name: name,
      motto: motto,
      address: address,
      logoPath: logoPath,
      branches: branches,
      contactInfo: contactInfo,
      website: website,
      establishedYear: establishedYear,
      gradingSystem: gradingSystem,
      showFinalPosition: showFinalPosition,
    );

    state = state.copyWith(schoolInfo: updatedSchoolInfo);
    await saveState();
  }

  Future<void> updateSchoolInfoFromData({
    required SchoolInfo schoolData,
  }) async {
    state = state.copyWith(schoolInfo: schoolData);
    await saveState();
  }

  Future<void> replaceAppState(AppState newState) async {
    state = newState;
    await saveState();
  }
}
