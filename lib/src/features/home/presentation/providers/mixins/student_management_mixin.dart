import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';
import 'package:grade_vault_offline/src/features/home/data/models/app_state.dart';
import 'package:grade_vault_offline/src/features/home/data/models/student.dart';
import 'package:grade_vault_offline/src/features/home/data/models/student_record.dart';
import 'package:grade_vault_offline/src/features/home/data/models/subject_perf.dart';
import 'package:grade_vault_offline/src/features/home/data/models/term_result.dart';

mixin StudentManagementMixin on StateNotifier<AppState> {
  Future<void> saveState();

  Future<void> addStudent({
    required String classId,
    required String name,
    required String gender,
    int? age,
  }) async {
    final classSection = state.classSections.firstWhere(
      (c) => c.id == classId,
      orElse: () => throw Exception('Class not found'),
    );

    final student = Student(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      gender: gender,
      age: age,
    );

    // Initialize all 3 term results with class subjects
    final terms = TERM_LIST;
    final termResults = terms.map((termName) {
      return TermResult(
        termName: termName,
        subjects: classSection.subjectNames
            .map((subject) => SubjectPerformance(subjectName: subject))
            .toList(),
      );
    }).toList();

    final studentRecord = StudentRecord(
      student: student,
      classId: classSection.id,
      termResults: termResults,
    );

    final updatedRecords = [studentRecord, ...state.studentRecords];
    state = state.copyWith(studentRecords: updatedRecords);

    await saveState();
  }

  Future<void> updateStudent({
    required String studentId,
    String? name,
    String? gender,
    int? age,
  }) async {
    final recordIndex = state.studentRecords.indexWhere(
      (s) => s.student.id == studentId,
    );
    if (recordIndex < 0) return;

    final record = state.studentRecords[recordIndex];
    final updatedStudent = record.student.copyWith(
      name: name,
      gender: gender,
      age: age,
    );

    final updatedRecord = record.copyWith(student: updatedStudent);
    final updatedRecords = [...state.studentRecords];
    updatedRecords[recordIndex] = updatedRecord;

    state = state.copyWith(studentRecords: updatedRecords);
    await saveState();
  }

  Future<void> deleteStudent(String studentId) async {
    final updatedRecords = state.studentRecords
        .where((s) => s.student.id != studentId)
        .toList();
    state = state.copyWith(studentRecords: updatedRecords);
    await saveState();
  }

  void selectStudent(String studentId) {
    if (state.studentRecords.any((s) => s.student.id == studentId)) {
      state = state.copyWith(selectedStudentId: studentId);
    }
  }
}
