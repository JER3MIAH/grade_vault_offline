import 'dart:convert';
import 'package:grade_vault_offline/src/core/config/app_config.dart';
import 'package:grade_vault_offline/src/features/home/data/models/grading_system.dart';
import 'package:grade_vault_offline/src/features/home/data/models/subject_perf.dart';

class StudentInfoMin {
  final String id;
  final String name;
  final int? age;
  final String gender;
  StudentInfoMin({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
  });
}

class StudentInfo {
  final String id;
  final String name;
  final String gender;
  final String studentClass;
  final int? age;
  final List<SubjectPerformance> subjectPerformances;
  final String teacherComment;
  final String principalComment;

  // ------------------------------
  //           GETTERS
  // ------------------------------

  /// Total score = sum of all subjects' total
  double get totalScore =>
      subjectPerformances.fold(0.0, (sum, subj) => sum + subj.total);

  /// Number of subjects
  int get numberOfSubjects => subjectPerformances.length;

  /// Final average = totalScore ÷ numberOfSubjects
  double get finalAverage =>
      numberOfSubjects == 0 ? 0 : totalScore / numberOfSubjects;

  /// Final grade based on average
  String get finalGrade =>
      AppConfig.instance.schoolInfo.gradingSystem.gradeForScore(finalAverage);

  /// The GradeRange that applies to this student's average
  GradeRange get finalRange =>
      AppConfig.instance.schoolInfo.gradingSystem.rangeForScore(finalAverage);

  /// Teacher comment (from config)
  String get defaultTeacherComment => finalRange.teacherRemark.trim().isNotEmpty
      ? finalRange.teacherRemark
      : 'Performance requires evaluation.';

  /// Principal comment (from config)
  String get defaultPrincipalComment =>
      finalRange.principalRemark.trim().isNotEmpty
      ? finalRange.principalRemark
      : 'Performance requires evaluation.';

  // ------------------------------
  //           MAPPING
  // ------------------------------

  StudentInfo({
    required this.id,
    required this.name,
    required this.gender,
    required this.studentClass,
    this.age,
    this.subjectPerformances = const [],
    this.teacherComment = '',
    this.principalComment = '',
  });

  StudentInfo copyWith({
    String? id,
    String? name,
    String? gender,
    String? studentClass,
    int? age,
    List<SubjectPerformance>? subjectPerformances,
    String? teacherComment,
    String? principalComment,
  }) {
    return StudentInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      studentClass: studentClass ?? this.studentClass,
      age: age ?? this.age,
      subjectPerformances: subjectPerformances ?? this.subjectPerformances,
      teacherComment: teacherComment ?? this.teacherComment,
      principalComment: principalComment ?? this.principalComment,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'gender': gender,
      'studentClass': studentClass,
      'age': age,
      'subjectPerformances': subjectPerformances.map((x) => x.toMap()).toList(),
      'teacherComment': teacherComment,
    };
  }

  factory StudentInfo.fromMap(Map<String, dynamic> map) {
    return StudentInfo(
      id: map['id'] as String,
      name: map['name'] as String,
      gender: map['gender'] as String,
      studentClass: map['studentClass'] as String,
      age: map['age'] != null ? map['age'] as int : null,
      subjectPerformances: map['subjectPerformances'] != null
          ? List<SubjectPerformance>.from(
              (map['subjectPerformances'] as List<dynamic>)
                  .map<SubjectPerformance>(
                    (x) =>
                        SubjectPerformance.fromMap(x as Map<String, dynamic>),
                  ),
            )
          : [],
      teacherComment: map['teacherComment'] ?? '',
      principalComment: map['principalComment'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory StudentInfo.fromJson(String source) =>
      StudentInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StudentInfo(id: $id, name: $name, gender: $gender, studentClass: $studentClass, age: $age, subjectPerformances: $subjectPerformances, teacherComment: $teacherComment, principalComment: $principalComment, numberOfSubjects: $numberOfSubjects)';
  }
}
