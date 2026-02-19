import 'dart:convert';
import 'package:grade_vault_offline/src/core/config/app_config.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';
import 'package:grade_vault_offline/src/features/home/data/models/grading_system.dart';
import 'package:grade_vault_offline/src/features/home/data/models/subject_perf.dart';

/// Represents academic results for a single term
class TermResult {
  final String termName;
  final List<SubjectPerformance> subjects;
  final String teacherComment;
  final String principalComment;

  const TermResult({
    required this.termName,
    required this.subjects,
    this.teacherComment = '',
    this.principalComment = '',
  });

  // =============================
  //           GETTERS
  // =============================

  /// Total score for this term
  double get totalScore => subjects.fold(0.0, (sum, subj) => sum + subj.total);

  /// Number of subjects
  int get numberOfSubjects => subjects.length;

  /// Average score for this term
  double get average =>
      numberOfSubjects == 0 ? 0 : totalScore / numberOfSubjects;

  /// Grade based on term average
  String get grade =>
      AppConfig.instance.schoolInfo.gradingSystem.gradeForScore(average);

  /// Grade range for this term
  GradeRange get gradeRange =>
      AppConfig.instance.schoolInfo.gradingSystem.rangeForScore(average);

  /// Get teacher comment (custom or from config)
  String get displayTeacherComment => teacherComment.trim().isNotEmpty
      ? teacherComment
      : (gradeRange.teacherRemark.trim().isNotEmpty
            ? gradeRange.teacherRemark
            : EMPTY);

  /// Get principal comment (custom or from config)
  String get displayPrincipalComment => principalComment.trim().isNotEmpty
      ? principalComment
      : (gradeRange.principalRemark.trim().isNotEmpty
            ? gradeRange.principalRemark
            : EMPTY);

  /// Get the final position as ordinal (1st, 2nd, 3rd, etc.)
  /// This requires access to all students' averages, so it should be calculated at a higher level
  /// This getter is a helper to format a position number
  static String getOrdinalPosition(int position) {
    if (position <= 0) return '';
    if (position % 100 >= 11 && position % 100 <= 13) {
      return '${position}th';
    }
    switch (position % 10) {
      case 1:
        return '${position}st';
      case 2:
        return '${position}nd';
      case 3:
        return '${position}rd';
      default:
        return '${position}th';
    }
  }

  TermResult copyWith({
    String? termName,
    List<SubjectPerformance>? subjects,
    String? teacherComment,
    String? principalComment,
  }) {
    return TermResult(
      termName: termName ?? this.termName,
      subjects: subjects ?? this.subjects,
      teacherComment: teacherComment ?? this.teacherComment,
      principalComment: principalComment ?? this.principalComment,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'termName': termName,
      'subjects': subjects.map((s) => s.toMap()).toList(),
      'teacherComment': teacherComment,
      'principalComment': principalComment,
    };
  }

  factory TermResult.fromMap(Map<String, dynamic> map) {
    return TermResult(
      termName: map['termName'] as String,
      subjects: List<SubjectPerformance>.from(
        (map['subjects'] as List<dynamic>).map(
          (x) => SubjectPerformance.fromMap(x as Map<String, dynamic>),
        ),
      ),
      teacherComment: map['teacherComment'] as String? ?? '',
      principalComment: map['principalComment'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TermResult.fromJson(String source) =>
      TermResult.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TermResult(termName: $termName, numberOfSubjects: $numberOfSubjects, average: $average, grade: $grade)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TermResult &&
        other.termName == termName &&
        other.subjects == subjects &&
        other.teacherComment == teacherComment &&
        other.principalComment == principalComment;
  }

  @override
  int get hashCode {
    return termName.hashCode ^
        subjects.hashCode ^
        teacherComment.hashCode ^
        principalComment.hashCode;
  }
}
