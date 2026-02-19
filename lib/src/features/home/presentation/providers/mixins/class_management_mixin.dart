import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/features/home/data/models/app_state.dart';
import 'package:grade_vault_offline/src/features/home/data/models/class_section.dart';

mixin ClassManagementMixin on StateNotifier<AppState> {
  Future<void> saveState();

  Future<void> createClass({
    required String name,
    required String teacherName,
    required String branch,
    required String session,
  }) async {
    final newClass = ClassSection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      teacherName: teacherName,
      branch: branch,
      session: session,
    );

    final updatedClasses = [...state.classSections, newClass];
    state = state.copyWith(
      classSections: updatedClasses,
      selectedClassId: newClass.id,
    );

    await saveState();
  }

  Future<void> updateClass(ClassSection updatedClass) async {
    final updatedClasses = state.classSections.map((c) {
      return c.id == updatedClass.id ? updatedClass : c;
    }).toList();

    state = state.copyWith(classSections: updatedClasses);
    await saveState();
  }

  Future<void> updateClassProperties({
    required String classId,
    String? className,
    String? teacherName,
    String? branch,
    String? session,
  }) async {
    final updatedClasses = state.classSections.map((c) {
      if (c.id == classId) {
        return c.copyWith(
          name: className ?? c.name,
          teacherName: teacherName ?? c.teacherName,
          branch: branch ?? c.branch,
          session: session ?? c.session,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(classSections: updatedClasses);
    await saveState();
  }

  Future<void> deleteClass(String classId) async {
    final updatedClasses = state.classSections
        .where((c) => c.id != classId)
        .toList();

    String newSelectedId = state.selectedClassId;
    if (state.selectedClassId == classId) {
      newSelectedId = updatedClasses.isNotEmpty ? updatedClasses[0].id : '';
    }

    state = state.copyWith(
      classSections: updatedClasses,
      selectedClassId: newSelectedId,
    );

    // Also remove students from this class
    final updatedStudents = state.studentRecords
        .where((s) => s.classId != classId)
        .toList();
    state = state.copyWith(studentRecords: updatedStudents);

    await saveState();
  }

  void selectClass(String classId) {
    if (state.classSections.any((c) => c.id == classId)) {
      state = state.copyWith(selectedClassId: classId);
    }
  }
}
