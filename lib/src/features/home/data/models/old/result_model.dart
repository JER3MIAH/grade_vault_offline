import 'dart:convert';
import 'package:grade_vault_offline/src/features/home/data/models/old/student_info.dart';
import 'package:grade_vault_offline/src/features/home/data/models/school_info.dart';

class ResultModel {
  final SchoolInfo schoolInfo;
  final String term;
  final String session;
  final String teacherName;
  final String className;
  final List<StudentInfo> studentList;
  final List<String> subjectList;
  final String branch;

  List<double> get classAverageList =>
      studentList.map((e) => e.finalAverage).toList();

  double get classAverage {
    if (classAverageList.isEmpty) return 0.0;
    return classAverageList.reduce((a, b) => a + b) / classAverageList.length;
  }

  double get highestInClass {
    if (classAverageList.isEmpty) return 0.0;
    return classAverageList.reduce((a, b) => a > b ? a : b);
  }

  double get lowestInClass {
    if (classAverageList.isEmpty) return 0.0;
    return classAverageList.reduce((a, b) => a < b ? a : b);
  }

  int get numberOfStudents => classAverageList.length;

  ResultModel({
    required this.schoolInfo,
    required this.term,
    required this.session,
    required this.teacherName,
    required this.className,
    required this.studentList,
    required this.subjectList,
    this.branch = '',
  });

  // ---------------------------
  // toMap
  // ---------------------------
  Map<String, dynamic> toMap() {
    return {
      'schoolInfo': schoolInfo.toMap(),
      'classAverageList': classAverageList,
      'term': term,
      'session': session,
      'className': className,
      'teacherName': teacherName,
      'studentList': studentList.map((s) => s.toMap()).toList(),
      'subjectList': subjectList,
      'branch': branch,
    };
  }

  factory ResultModel.fromMap(Map<String, dynamic> map) {
    return ResultModel(
      schoolInfo: SchoolInfo.fromMap(map['schoolInfo']),
      term: map['term'] ?? '',
      session: map['session'] ?? '',
      className: map['className'] ?? '',
      teacherName: map['teacherName'] ?? '',
      studentList: map['studentList'] != null
          ? List<StudentInfo>.from(
              map['studentList'].map((x) => StudentInfo.fromMap(x)),
            )
          : [],
      subjectList: map['subjectList'] != null
          ? List<String>.from(map['subjectList'])
          : map['subjectList'] ?? [],
      branch: map['branch'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ResultModel.fromJson(String source) =>
      ResultModel.fromMap(json.decode(source));

  ResultModel copyWith({
    SchoolInfo? schoolInfo,
    List<double>? classAverageList,
    String? term,
    String? session,
    String? className,
    String? teacherName,
    List<StudentInfo>? studentList,
    List<String>? subjectList,
    String? branch,
  }) {
    return ResultModel(
      schoolInfo: schoolInfo ?? this.schoolInfo,
      term: term ?? this.term,
      session: session ?? this.session,
      className: className ?? this.className,
      teacherName: teacherName ?? this.teacherName,
      studentList: studentList ?? this.studentList,
      subjectList: subjectList ?? this.subjectList,
      branch: branch ?? this.branch,
    );
  }
}
