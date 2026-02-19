// import 'dart:convert';
// import 'package:grade_vault_offline/src/features/home/data/models/old/student_info.dart';

// /// Represents a single class with its own students, subjects, teacher, and branch.
// class ClassInfo {
//   final String id; // Unique identifier for this class
//   final String className;
//   final String teacherName;
//   final String branch;
//   final List<StudentInfo> studentList;
//   final List<String> subjectList;

//   // =============================
//   //        GETTERS
//   // =============================

//   /// List of final averages for all students in this class
//   List<double> get classAverageList =>
//       studentList.map((e) => e.finalAverage).toList();

//   /// Average score across all students in the class
//   double get classAverage {
//     if (classAverageList.isEmpty) return 0.0;
//     return classAverageList.reduce((a, b) => a + b) / classAverageList.length;
//   }

//   /// Highest average in the class
//   double get highestInClass {
//     if (classAverageList.isEmpty) return 0.0;
//     return classAverageList.reduce((a, b) => a > b ? a : b);
//   }

//   /// Lowest average in the class
//   double get lowestInClass {
//     if (classAverageList.isEmpty) return 0.0;
//     return classAverageList.reduce((a, b) => a < b ? a : b);
//   }

//   /// Number of students in this class
//   int get numberOfStudents => classAverageList.length;

//   // =============================
//   //        CONSTRUCTOR
//   // =============================

//   ClassInfo({
//     required this.id,
//     required this.className,
//     required this.teacherName,
//     required this.branch,
//     required this.studentList,
//     required this.subjectList,
//   });

//   // =============================
//   //        SERIALIZATION
//   // =============================

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'className': className,
//       'teacherName': teacherName,
//       'branch': branch,
//       'studentList': studentList.map((s) => s.toMap()).toList(),
//       'subjectList': subjectList,
//     };
//   }

//   factory ClassInfo.fromMap(Map<String, dynamic> map) {
//     return ClassInfo(
//       id: map['id'] ?? '',
//       className: map['className'] ?? '',
//       teacherName: map['teacherName'] ?? '',
//       branch: map['branch'] ?? '',
//       studentList: map['studentList'] != null
//           ? List<StudentInfo>.from(
//               map['studentList'].map((x) => StudentInfo.fromMap(x)),
//             )
//           : [],
//       subjectList: map['subjectList'] != null
//           ? List<String>.from(map['subjectList'])
//           : [],
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory ClassInfo.fromJson(String source) =>
//       ClassInfo.fromMap(json.decode(source));

//   ClassInfo copyWith({
//     String? id,
//     String? className,
//     String? teacherName,
//     String? branch,
//     List<StudentInfo>? studentList,
//     List<String>? subjectList,
//   }) {
//     return ClassInfo(
//       id: id ?? this.id,
//       className: className ?? this.className,
//       teacherName: teacherName ?? this.teacherName,
//       branch: branch ?? this.branch,
//       studentList: studentList ?? this.studentList,
//       subjectList: subjectList ?? this.subjectList,
//     );
//   }

//   @override
//   String toString() {
//     return 'ClassInfo(id: $id, className: $className, teacherName: $teacherName, branch: $branch, studentList: $studentList, subjectList: $subjectList)';
//   }
// }
