import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';
import 'package:grade_vault_offline/src/features/home/data/models/app_state.dart';
import 'package:grade_vault_offline/src/features/home/data/models/subject_perf.dart';
import 'package:grade_vault_offline/src/features/home/data/models/term_result.dart';

mixin SubjectManagementMixin on StateNotifier<AppState> {
  Future<void> saveState();

  /// Sync subjects across all students in a class for all terms
  void _syncSubjectsForStudents(String classId, List<String> subjectNames) {
    final updatedRecords = state.studentRecords.map((record) {
      if (record.classId != classId) return record;

      // Ensure all 3 terms exist
      final terms = TERM_LIST;
      final updatedTermResults = <TermResult>[];

      for (final termName in terms) {
        final existingTerm = record.getTermResult(termName);

        // Create new subject performances based on class subjects
        final newSubjects = subjectNames.map((subjectName) {
          // Try to find existing performance to preserve scores
          final existingPerf = existingTerm?.subjects.firstWhere(
            (s) => s.subjectName == subjectName,
            orElse: () => SubjectPerformance(subjectName: subjectName),
          );
          return existingPerf ?? SubjectPerformance(subjectName: subjectName);
        }).toList();

        updatedTermResults.add(
          existingTerm?.copyWith(subjects: newSubjects) ??
              TermResult(termName: termName, subjects: newSubjects),
        );
      }

      return record.copyWith(termResults: updatedTermResults);
    }).toList();

    state = state.copyWith(studentRecords: updatedRecords);
  }

  Future<void> setSubjectsForClass({
    required String classId,
    required List<String> subjectNames,
  }) async {
    final uniqueSubjectNames = subjectNames.toSet().toList();

    final updatedClasses = state.classSections.map((classSection) {
      if (classSection.id == classId) {
        return classSection.copyWith(subjectNames: uniqueSubjectNames);
      }
      return classSection;
    }).toList();

    state = state.copyWith(classSections: updatedClasses);

    // Sync subjects for all students in this class
    _syncSubjectsForStudents(classId, uniqueSubjectNames);

    await saveState();
  }

  Future<void> deleteSubjectFromClass({
    required String classId,
    required String subjectName,
  }) async {
    final updatedClasses = state.classSections.map((classSection) {
      if (classSection.id == classId) {
        final updatedSubjects = classSection.subjectNames
            .where((subject) => subject != subjectName)
            .toList();
        return classSection.copyWith(subjectNames: updatedSubjects);
      }
      return classSection;
    }).toList();

    state = state.copyWith(classSections: updatedClasses);

    // Find the updated class and sync subjects
    final updatedClass = updatedClasses.firstWhere((c) => c.id == classId);
    _syncSubjectsForStudents(classId, updatedClass.subjectNames);

    await saveState();
  }
}
