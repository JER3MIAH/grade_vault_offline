import 'dart:developer';
import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/core/config/app_config.dart';
import 'package:grade_vault_offline/src/features/home/data/models/app_state.dart';
import 'package:grade_vault_offline/src/features/home/data/repositories/result_repository.dart';

mixin AppInitializationMixin on StateNotifier<AppState> {
  ResultRepository get repository;

  Future<void> initializeState() async {
    // Load from repository if exists
    try {
      final savedState = await repository.getResult();
      if (savedState != null) {
        // Always prefer config-sourced school info over what was persisted
        state = savedState;
        _selectFirstClassIfNeeded();
      }
    } catch (e) {
      log('Error loading state: $e');
    }
  }

  void _selectFirstClassIfNeeded() {
    if (state.selectedClassId.isEmpty && state.classSections.isNotEmpty) {
      state = state.copyWith(selectedClassId: state.classSections[0].id);
    }
  }

  Future<void> saveState() async {
    await repository.setResult(state);
  }

  Future<void> clearAllData() async {
    await repository.clearAllData();
    state = AppState(
      schoolInfo: AppConfig.instance.schoolInfo,
      currentTerm: 'First Term',
      classSections: [],
      studentRecords: [],
      selectedClassId: '',
      selectedStudentId: '',
    );
  }
}
