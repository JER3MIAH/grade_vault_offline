import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/features/home/data/models/app_state.dart';
import 'package:grade_vault_offline/src/features/home/data/models/subject_perf.dart';
import 'package:grade_vault_offline/src/features/home/data/models/term_result.dart';

mixin TermResultManagementMixin on StateNotifier<AppState> {
  Future<void> saveState();

  Future<void> updateTermResults({
    required String studentId,
    required TermResult termResult,
  }) async {
    final recordIndex = state.studentRecords.indexWhere(
      (s) => s.student.id == studentId,
    );
    if (recordIndex < 0) return;

    final record = state.studentRecords[recordIndex];
    final updatedRecord = record.withTermResult(termResult);

    final updatedRecords = [...state.studentRecords];
    updatedRecords[recordIndex] = updatedRecord;

    state = state.copyWith(studentRecords: updatedRecords);
    await saveState();
  }

  Future<void> updateSubjectScore({
    required String studentId,
    required String termName,
    required String subjectName,
    required double caScore,
    required double examScore,
  }) async {
    final record = state.studentRecords.firstWhere(
      (s) => s.student.id == studentId,
    );
    final termResult = record.getTermResult(termName);

    if (termResult == null) return;

    final updatedSubjects = termResult.subjects.map((s) {
      if (s.subjectName == subjectName) {
        return s.copyWith(caScore: caScore, examScore: examScore);
      }
      return s;
    }).toList();

    final updatedTerm = termResult.copyWith(subjects: updatedSubjects);
    await updateTermResults(studentId: studentId, termResult: updatedTerm);
  }

  Future<void> updateSubjectScores({
    required String studentId,
    required String termName,
    required List<SubjectPerformance> subjectPerformances,
  }) async {
    final recordIndex = state.studentRecords.indexWhere(
      (s) => s.student.id == studentId,
    );
    if (recordIndex < 0) return;

    final record = state.studentRecords[recordIndex];
    final termResult = record.getTermResult(termName);

    if (termResult == null) return;

    final updatedTerm = termResult.copyWith(subjects: subjectPerformances);

    final updatedRecord = record.withTermResult(updatedTerm);
    final updatedRecords = [...state.studentRecords];
    updatedRecords[recordIndex] = updatedRecord;

    state = state.copyWith(studentRecords: updatedRecords);
    await saveState();
  }

  Future<void> updateStudentComments({
    required String studentId,
    required String termName,
    required String teacherComment,
    required String principalComment,
  }) async {
    final recordIndex = state.studentRecords.indexWhere(
      (s) => s.student.id == studentId,
    );
    if (recordIndex < 0) return;

    final record = state.studentRecords[recordIndex];
    final termResult = record.getTermResult(termName);

    if (termResult == null) return;

    final updatedTerm = termResult.copyWith(
      teacherComment: teacherComment,
      principalComment: principalComment,
    );

    final updatedRecord = record.withTermResult(updatedTerm);
    final updatedRecords = [...state.studentRecords];
    updatedRecords[recordIndex] = updatedRecord;

    state = state.copyWith(studentRecords: updatedRecords);
    await saveState();
  }

  Future<void> setCurrentTerm(String termName) async {
    state = state.copyWith(currentTerm: termName);
    await saveState();
  }
}
