/*
import 'dart:developer';
import 'package:flutter_riverpod/legacy.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:grade_vault_offline/src/core/config/app_config.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';
import 'package:grade_vault_offline/src/features/home/data/models/result_model.dart';
import 'package:grade_vault_offline/src/features/home/data/models/class_info.dart';
import 'package:grade_vault_offline/src/features/home/data/models/student_info.dart';
import 'package:grade_vault_offline/src/features/home/data/models/subject_perf.dart';
import 'package:grade_vault_offline/src/features/home/data/models/term_performance.dart';
import 'package:grade_vault_offline/src/features/home/data/repositories/result_repository.dart';

class ResultNotifier extends StateNotifier<ResultModel> {
  final ResultRepository repository;
  ResultNotifier({required this.repository})
    : super(
        ResultModel(
          schoolInfo: AppConfig.instance.schoolInfo,
          term: 'First Term',
          classes: [],
          selectedClassId: '', // Will be set to first class ID after creation
        ),
      ) {
    // Set selectedClassId to the first (and only) class
    if (state.classes.isNotEmpty && state.selectedClassId.isEmpty) {
      state = state.copyWith(selectedClassId: state.classes[0].id);
    }
  }

  void getDetails() async {
    final details = await repository.getResult();
    if (details != null) {
      state = details;
    }
  }

  // =============================
  //     CLASS MANAGEMENT
  // =============================

  /// Add a new class to the system
  void addClass({
    String? className,
    String? teacherName,
    String? branch,
    String? session,
  }) {
    final newClass = ClassInfo(
      id: getUniqueId(),
      className: className ?? EMPTY,
      teacherName: teacherName ?? EMPTY,
      branch: branch ?? EMPTY,
      session: session ?? EMPTY,
      studentList: [],
      subjectList: [],
    );

    final updatedClasses = [...state.classes, newClass];
    final updatedState = state.copyWith(
      classes: updatedClasses,
      selectedClassId: newClass.id, // Auto-select the new class
    );
    state = updatedState;
    repository.setResult(updatedState);
  }

  /// Remove a class by ID
  void removeClass(String classId) {
    final updatedClasses = state.classes.where((c) => c.id != classId).toList();
    if (updatedClasses.isEmpty) {
      // If no classes remain, reset selectedClassId
      final updatedState = state.copyWith(
        classes: updatedClasses,
        selectedClassId: '',
      );
      state = updatedState;
      repository.setResult(updatedState);
      return;
    }
    // If the deleted class was selected, select the first remaining class
    String newSelectedId = state.selectedClassId;
    if (state.selectedClassId == classId) {
      newSelectedId = updatedClasses[0].id;
    }

    final updatedState = state.copyWith(
      classes: updatedClasses,
      selectedClassId: newSelectedId,
    );
    state = updatedState;
    repository.setResult(updatedState);
  }

  /// Select a class by ID
  void selectClass(String classId) {
    if (state.classes.any((c) => c.id == classId)) {
      final updatedState = state.copyWith(selectedClassId: classId);
      state = updatedState;
      repository.setResult(updatedState);
    }
  }

  // =============================
  //     SCHOOL INFO
  // =============================

  void updateSchoolInfo([
    String? orgName,
    String? motto,
    String? address,
    String? logoPath,
  ]) {
    final currentInfo = state.schoolInfo;
    final updatedSchoolInfo = currentInfo.copyWith(
      name: orgName,
      motto: motto,
      address: address,
      logoPath: logoPath,
    );
    final updatedState = state.copyWith(schoolInfo: updatedSchoolInfo);
    state = updatedState;
    repository.setResult(updatedState);
  }

  // =============================
  //     CLASS-SPECIFIC UPDATES
  // =============================

  void updateClassName(String className) {
    _updateCurrentClass((cls) => cls.copyWith(className: className));
  }

  void updateTeacherName(String teacherName) {
    _updateCurrentClass((cls) => cls.copyWith(teacherName: teacherName));
  }

  void updateBranch(String branch) {
    _updateCurrentClass((cls) => cls.copyWith(branch: branch));
  }

  // =============================
  //     GLOBAL UPDATES
  // =============================

  void updateTerm(String term) {
    final updatedState = state.copyWith(term: term);
    state = updatedState;
    repository.setResult(updatedState);
  }

  // =============================
  //     SUBJECT MANAGEMENT
  // =============================

  void setSubjects(List<String> subjects) {
    _updateCurrentClass((cls) {
      final newStudentList = cls.studentList.map((student) {
        // Update the latest term's subject list, or create a default term if none exist
        final updatedTerms = student.termPerformances.isEmpty
            ? [
                TermPerformance(
                  termName: state.term,
                  subjectPerformances: subjects.map((subjectName) {
                    return SubjectPerformance(
                      subjectName: subjectName,
                      caScore: 0,
                      examScore: 0,
                    );
                  }).toList(),
                )
              ]
            : student.termPerformances.map((term) {
                // For the latest term, update the subjects
                if (term.termName == state.term) {
                  final oldSubjects = {
                    for (var sp in term.subjectPerformances) sp.subjectName: sp,
                  };

                  final newPerformances = subjects.map((subjectName) {
                    if (oldSubjects.containsKey(subjectName)) {
                      return oldSubjects[subjectName]!;
                    }
                    return SubjectPerformance(
                      subjectName: subjectName,
                      caScore: 0,
                      examScore: 0,
                    );
                  }).toList();

                  return term.copyWith(subjectPerformances: newPerformances);
                }
                return term;
              }).toList();

        return student.copyWith(termPerformances: updatedTerms);
      }).toList();

      log(newStudentList.toString());
      return cls.copyWith(subjectList: subjects, studentList: newStudentList);
    });
  }

  // =============================
  //     STUDENT MANAGEMENT
  // =============================

  void addStudent(StudentInfo student) {
    _updateCurrentClass((cls) {
      // Initialize the new student's term performances based on current subjectList
      final initialTermPerformance = TermPerformance(
        termName: state.term,
        subjectPerformances: cls.subjectList.map((subjectName) {
          return SubjectPerformance(
            subjectName: subjectName,
            caScore: 0,
            examScore: 0,
          );
        }).toList(),
      );

      final initializedStudent = student.copyWith(
        termPerformances: [initialTermPerformance],
      );

      // Add the new student at the beginning of the list
      return cls.copyWith(
        studentList: [initializedStudent, ...cls.studentList],
      );
    });
  }

  void editStudentScores(StudentInfo updatedStudent) {
    _updateCurrentClass((cls) {
      final updatedStudentList = cls.studentList.map((student) {
        if (student.id == updatedStudent.id) {
          return updatedStudent;
        }
        return student;
      }).toList();
      return cls.copyWith(studentList: updatedStudentList);
    });
  }

  void editStudent(StudentInfoMin studentMin) {
    _updateCurrentClass((cls) {
      final updatedStudentList = cls.studentList.map((student) {
        if (student.id == studentMin.id) {
          // Only update the fields you want, keep subjectPerformances
          return student.copyWith(
            name: studentMin.name,
            gender: studentMin.gender,
            age: studentMin.age,
          );
        }
        return student;
      }).toList();
      return cls.copyWith(studentList: updatedStudentList);
    });
  }

  void removeStudent(String studentId) {
    _updateCurrentClass((cls) {
      final updatedStudentList = cls.studentList
          .where((student) => student.id != studentId)
          .toList();
      return cls.copyWith(studentList: updatedStudentList);
    });
  }

  // =============================
  //     HELPER METHODS
  // =============================

  /// Helper to update the currently selected class
  void _updateCurrentClass(ClassInfo Function(ClassInfo) updater) {
    final currentClass = state.currentClass;
    if (currentClass == null) return;

    final updatedClass = updater(currentClass);
    final updatedClasses = state.classes.map((cls) {
      return cls.id == currentClass.id ? updatedClass : cls;
    }).toList();

    final updatedState = state.copyWith(classes: updatedClasses);
    state = updatedState;
    repository.setResult(updatedState);
  }
}

final resultProvider = StateNotifierProvider<ResultNotifier, ResultModel>((
  ref,
) {
  return ResultNotifier(repository: ref.watch(resultRepositoryProvider));
});
*/
