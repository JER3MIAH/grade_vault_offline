import 'dart:convert';
import 'package:grade_vault_offline/src/core/config/app_config.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';
import 'package:grade_vault_offline/src/features/home/data/models/grading_system.dart';
import 'package:grade_vault_offline/src/shared/shared.dart'
    show StringExtensions;

class SubjectPerformance {
  final String subjectName;
  final double caScore;
  final double examScore;

  /// Combined CA + Exam score
  double get total => caScore + examScore;

  /// Grade based on total score
  String get grade =>
      AppConfig.instance.schoolInfo.gradingSystem.gradeForScore(total);

  /// Remark for each grade
  String get remark {
    final grading = AppConfig.instance.schoolInfo.gradingSystem;

    final matching = grading.ranges.firstWhere(
      (r) => total >= r.min && total <= r.max,
      orElse: () => GradeRange(),
    );

    return matching.remark;
  }

  /// Color associated with each grade
  int get remarkColor {
    final grading = AppConfig.instance.schoolInfo.gradingSystem;

    // Find the grade range that matches this student's finalAverage
    final matching = grading.ranges.firstWhere(
      (r) => total >= r.min && total <= r.max,
      orElse: () => GradeRange(), // default empty
    );

    // Return its color if valid
    if (matching.color.isNotNullOrEmpty) {
      return matching.color.asInt;
    }

    // Fallback: red
    return 0xFFF44336;
  }

  /// Converts an integer like 1 → '1st', 2 → '2nd', 3 → '3rd'
  /// Handles exceptions like 11th, 12th, 13th correctly.
  String _ordinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  /// Returns a string position ('1st', '2nd', '3rd')
  String getPosition(List<double> allTotals) {
    final sorted = [...allTotals]..sort((a, b) => b.compareTo(a));

    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i] == total) {
        int numericPos = i + 1;
        return _ordinal(numericPos);
      }
    }

    return EMPTY;
  }

  SubjectPerformance({
    required this.subjectName,
    this.caScore = 0,
    this.examScore = 0,
  });

  SubjectPerformance copyWith({
    String? subjectName,
    double? caScore,
    double? examScore,
  }) {
    return SubjectPerformance(
      subjectName: subjectName ?? this.subjectName,
      caScore: caScore ?? this.caScore,
      examScore: examScore ?? this.examScore,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'subjectName': subjectName,
      'caScore': caScore,
      'examScore': examScore,
    };
  }

  factory SubjectPerformance.fromMap(Map<String, dynamic> map) {
    return SubjectPerformance(
      subjectName: map['subjectName'] as String,
      caScore: map['caScore'] as double,
      examScore: map['examScore'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory SubjectPerformance.fromJson(String source) =>
      SubjectPerformance.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SubjectPerformance(subjectName: $subjectName, caScore: $caScore, examScore: $examScore)';

  @override
  bool operator ==(covariant SubjectPerformance other) {
    if (identical(this, other)) return true;

    return other.subjectName == subjectName &&
        other.caScore == caScore &&
        other.examScore == examScore;
  }

  @override
  int get hashCode =>
      subjectName.hashCode ^ caScore.hashCode ^ examScore.hashCode;
}
