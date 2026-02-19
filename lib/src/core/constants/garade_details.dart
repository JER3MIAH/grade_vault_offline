import 'package:grade_vault_offline/src/core/config/app_config.dart';

// ignore: non_constant_identifier_names
final GRADE_LIST = AppConfig.instance.schoolInfo.gradingSystem.ranges
    .map((r) => r.grade)
    .toList();

const principalComment = 'principalComment';
const teacherComment = 'teacherComment';
