import 'dart:convert';

/// Represents a class section with metadata
class ClassSection {
  final String id;
  final String name;
  final String teacherName;
  final String branch;
  final String session;
  final List<String> subjectNames;

  const ClassSection({
    required this.id,
    required this.name,
    required this.teacherName,
    required this.branch,
    required this.session,
    this.subjectNames = const [],
  });

  ClassSection copyWith({
    String? id,
    String? name,
    String? teacherName,
    String? branch,
    String? session,
    List<String>? subjectNames,
  }) {
    return ClassSection(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherName: teacherName ?? this.teacherName,
      branch: branch ?? this.branch,
      session: session ?? this.session,
      subjectNames: subjectNames ?? this.subjectNames,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teacherName': teacherName,
      'branch': branch,
      'session': session,
      'subjectNames': subjectNames,
    };
  }

  factory ClassSection.fromMap(Map<String, dynamic> map) {
    return ClassSection(
      id: map['id'] as String,
      name: map['name'] as String,
      teacherName: map['teacherName'] as String,
      branch: map['branch'] as String,
      session: map['session'] as String,
      subjectNames: List<String>.from(
        (map['subjectNames'] as List<dynamic>?) ?? [],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ClassSection.fromJson(String source) =>
      ClassSection.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ClassSection(id: $id, name: $name, teacherName: $teacherName, branch: $branch, session: $session)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClassSection &&
        other.id == id &&
        other.name == name &&
        other.teacherName == teacherName &&
        other.branch == branch &&
        other.session == session &&
        other.subjectNames == subjectNames;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        teacherName.hashCode ^
        branch.hashCode ^
        session.hashCode ^
        subjectNames.hashCode;
  }
}
