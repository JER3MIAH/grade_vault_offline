import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/core/config/app_config.dart';
import 'package:grade_vault_offline/src/features/home/data/models/app_state.dart';
import 'package:grade_vault_offline/src/features/home/data/repositories/result_repository.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/mixins/mixins.dart';

class AppStateNotifier extends StateNotifier<AppState>
    with
        AppInitializationMixin,
        ClassManagementMixin,
        SubjectManagementMixin,
        StudentManagementMixin,
        TermResultManagementMixin,
        SchoolInfoMixin {
  @override
  final ResultRepository repository;

  AppStateNotifier({required this.repository})
    : super(
        AppState(
          schoolInfo: AppConfig.instance.schoolInfo,
          currentTerm: 'First Term',
          classSections: [],
          studentRecords: [],
          selectedClassId: '',
          selectedStudentId: '',
        ),
      ) {
    initializeState();
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier(repository: ref.watch(resultRepositoryProvider));
});
