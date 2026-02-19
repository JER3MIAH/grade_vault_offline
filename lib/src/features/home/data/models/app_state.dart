import 'dart:convert';
import 'package:grade_vault_offline/src/features/home/data/models/school_info.dart';
import 'package:grade_vault_offline/src/features/home/data/models/class_section.dart';
import 'package:grade_vault_offline/src/features/home/data/models/student_record.dart';

/// Main application state model
class AppState {
  final SchoolInfo schoolInfo;
  final String currentTerm;
  final List<ClassSection> classSections;
  final List<StudentRecord> studentRecords;
  final String selectedClassId;
  final String selectedStudentId;

  const AppState({
    required this.schoolInfo,
    required this.currentTerm,
    this.classSections = const [],
    this.studentRecords = const [],
    this.selectedClassId = '',
    this.selectedStudentId = '',
  });

  // =============================
  //           GETTERS
  // =============================

  /// Get current class section
  ClassSection? get currentClass {
    try {
      return classSections.firstWhere((c) => c.id == selectedClassId);
    } catch (e) {
      return null;
    }
  }

  /// Get current student record
  StudentRecord? get currentStudent {
    try {
      return studentRecords.firstWhere(
        (s) => s.student.id == selectedStudentId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all students in current class
  List<StudentRecord> get studentsInCurrentClass {
    return studentRecords.where((s) => s.classId == selectedClassId).toList();
  }

  /// Get current term result for all students in class
  List<StudentRecord> get studentsWithCurrentTermResults {
    return studentsInCurrentClass
        .where((s) => s.getTermResult(currentTerm) != null)
        .toList();
  }

  AppState copyWith({
    SchoolInfo? schoolInfo,
    String? currentTerm,
    List<ClassSection>? classSections,
    List<StudentRecord>? studentRecords,
    String? selectedClassId,
    String? selectedStudentId,
  }) {
    return AppState(
      schoolInfo: schoolInfo ?? this.schoolInfo,
      currentTerm: currentTerm ?? this.currentTerm,
      classSections: classSections ?? this.classSections,
      studentRecords: studentRecords ?? this.studentRecords,
      selectedClassId: selectedClassId ?? this.selectedClassId,
      selectedStudentId: selectedStudentId ?? this.selectedStudentId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolInfo': schoolInfo.toMap(),
      'currentTerm': currentTerm,
      'classSections': classSections.map((c) => c.toMap()).toList(),
      'studentRecords': studentRecords.map((s) => s.toMap()).toList(),
      'selectedClassId': selectedClassId,
      'selectedStudentId': selectedStudentId,
    };
  }

  factory AppState.fromMap(Map<String, dynamic> map) {
    return AppState(
      schoolInfo: SchoolInfo.fromMap(map['schoolInfo'] as Map<String, dynamic>),
      currentTerm: map['currentTerm'] as String,
      classSections: List<ClassSection>.from(
        (map['classSections'] as List<dynamic>?)?.map(
              (x) => ClassSection.fromMap(x as Map<String, dynamic>),
            ) ??
            [],
      ),
      studentRecords: List<StudentRecord>.from(
        (map['studentRecords'] as List<dynamic>?)?.map(
              (x) => StudentRecord.fromMap(x as Map<String, dynamic>),
            ) ??
            [],
      ),
      selectedClassId: map['selectedClassId'] as String? ?? '',
      selectedStudentId: map['selectedStudentId'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AppState.fromJson(String source) =>
      AppState.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AppState(schoolInfo: ${schoolInfo.name}, currentTerm: $currentTerm, classes: ${classSections.length}, students: ${studentRecords.length})';
  }
}
