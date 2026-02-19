import 'dart:convert';
import 'package:grade_vault_offline/src/features/home/data/models/student.dart';
import 'package:grade_vault_offline/src/features/home/data/models/term_result.dart';

/// Represents a student's complete academic record across multiple terms
class StudentRecord {
  final Student student;
  final String classId;
  final List<TermResult> termResults;

  const StudentRecord({
    required this.student,
    required this.classId,
    required this.termResults,
  });

  // =============================
  //           GETTERS
  // =============================

  /// Get term result by term name
  TermResult? getTermResult(String termName) {
    try {
      return termResults.firstWhere((t) => t.termName == termName);
    } catch (e) {
      return null;
    }
  }

  /// Get the latest term result
  TermResult? get latestTermResult =>
      termResults.isNotEmpty ? termResults.last : null;

  /// Overall average across all terms
  double get overallAverage {
    if (termResults.isEmpty) return 0;
    final totalAverage = termResults.fold<double>(
      0,
      (sum, term) => sum + term.average,
    );
    return totalAverage / termResults.length;
  }

  StudentRecord copyWith({
    Student? student,
    String? classId,
    List<TermResult>? termResults,
  }) {
    return StudentRecord(
      student: student ?? this.student,
      classId: classId ?? this.classId,
      termResults: termResults ?? this.termResults,
    );
  }

  /// Update or add a term result
  StudentRecord withTermResult(TermResult termResult) {
    final updatedTerms = [...termResults];
    final existingIndex = updatedTerms.indexWhere(
      (t) => t.termName == termResult.termName,
    );

    if (existingIndex >= 0) {
      updatedTerms[existingIndex] = termResult;
    } else {
      updatedTerms.add(termResult);
    }

    return copyWith(termResults: updatedTerms);
  }

  Map<String, dynamic> toMap() {
    return {
      'student': student.toMap(),
      'classId': classId,
      'termResults': termResults.map((t) => t.toMap()).toList(),
    };
  }

  factory StudentRecord.fromMap(Map<String, dynamic> map) {
    return StudentRecord(
      student: Student.fromMap(map['student'] as Map<String, dynamic>),
      classId: map['classId'] as String,
      termResults: List<TermResult>.from(
        (map['termResults'] as List<dynamic>).map(
          (x) => TermResult.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory StudentRecord.fromJson(String source) =>
      StudentRecord.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StudentRecord(student: ${student.name}, classId: $classId, termResults: ${termResults.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StudentRecord &&
        other.student == student &&
        other.classId == classId &&
        other.termResults == termResults;
  }

  @override
  int get hashCode {
    return student.hashCode ^ classId.hashCode ^ termResults.hashCode;
  }
}
