import 'dart:convert';

/// Represents a student in the system
class Student {
  final String id;
  final String name;
  final String gender;
  final int? age;

  const Student({
    required this.id,
    required this.name,
    required this.gender,
    this.age,
  });

  Student copyWith({String? id, String? name, String? gender, int? age}) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'gender': gender, 'age': age};
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as String,
      name: map['name'] as String,
      gender: map['gender'] as String,
      age: map['age'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Student.fromJson(String source) =>
      Student.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Student(id: $id, name: $name, gender: $gender, age: $age)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Student &&
        other.id == id &&
        other.name == name &&
        other.gender == gender &&
        other.age == age;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ gender.hashCode ^ age.hashCode;
  }
}
