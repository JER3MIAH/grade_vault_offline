class GradeRange {
  final String grade;
  final int min;
  final int max;
  final String color; // hex e.g. "#4CAF50"
  final String remark; // general remark (optional fallback)
  final String teacherRemark;
  final String principalRemark;

  GradeRange({
    this.grade = '',
    this.min = 0,
    this.max = 0,
    this.color = '#000000',
    this.remark = '',
    this.teacherRemark = '',
    this.principalRemark = '',
  });

  GradeRange copyWith({
    String? grade,
    int? min,
    int? max,
    String? color,
    String? remark,
    String? teacherRemark,
    String? principalRemark,
  }) {
    return GradeRange(
      grade: grade ?? this.grade,
      min: min ?? this.min,
      max: max ?? this.max,
      color: color ?? this.color,
      remark: remark ?? this.remark,
      teacherRemark: teacherRemark ?? this.teacherRemark,
      principalRemark: principalRemark ?? this.principalRemark,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'min': min,
      'max': max,
      'color': color,
      'remark': remark,
      'teacherRemark': teacherRemark,
      'principalRemark': principalRemark,
    };
  }

  factory GradeRange.fromMap(Map<String, dynamic> map) {
    return GradeRange(
      grade: map['grade'] ?? '',
      min: map['min'] ?? 0,
      max: map['max'] ?? 0,
      color: map['color'] ?? '#000000',
      remark: map['remark'] ?? '',
      teacherRemark: map['teacherRemark'] ?? '',
      principalRemark: map['principalRemark'] ?? '',
    );
  }
}

class GradingSystem {
  /// List of ranges e.g. A (70–100), B (60–69)
  final List<GradeRange> ranges;

  GradingSystem({this.ranges = const []});

  GradingSystem copyWith({List<GradeRange>? ranges}) {
    return GradingSystem(ranges: ranges ?? this.ranges);
  }

  Map<String, dynamic> toMap() {
    return {'ranges': ranges.map((x) => x.toMap()).toList()};
  }

  factory GradingSystem.fromMap(Map<String, dynamic> map) {
    return GradingSystem(
      ranges: map['ranges'] != null
          ? List<GradeRange>.from(
              (map['ranges'] as List<dynamic>).map(
                (x) => GradeRange.fromMap(x),
              ),
            )
          : [],
    );
  }

  /// Human-readable string representation
  String get prettyPrint {
    if (ranges.isEmpty) return '';

    return ranges.map((r) => '${r.grade} = ${r.min}-${r.max}').join(', ');
  }

  /// Determine grade from numeric score
  String gradeForScore(double score) {
    for (final r in ranges) {
      final lower = r.min.toDouble();
      final upper = (r.max + 1).toDouble();
      if (score >= lower && score < upper) {
        return r.grade;
      }
    }
    return '';
  }

  /// Get the range corresponding to a numeric score
  GradeRange rangeForScore(double score) {
    return ranges.firstWhere(
      (r) => score >= r.min.toDouble() && score <= r.max.toDouble(),
      orElse: () => GradeRange(),
    );
  }

  /// List of grades (from config)
  List<String> get gradeList => ranges.map((r) => r.grade).toList();
}
