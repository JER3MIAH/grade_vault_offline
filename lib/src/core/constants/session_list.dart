// ignore: non_constant_identifier_names
List<String> get SESSION_LIST {
  final now = DateTime.now();
  int startYear;

  if (now.month >= 9) {
    startYear = now.year;
  } else {
    startYear = now.year - 1;
  }

  final List<String> sessions = [];

  for (int i = -5; i <= 5; i++) {
    final year = startYear + i;
    sessions.add('$year/${year + 1}');
  }

  return sessions;
}

// ignore: non_constant_identifier_names
String get CURRENT_SESSION {
  final now = DateTime.now();
  int startYear;

  if (now.month >= 9) {
    startYear = now.year;
  } else {
    startYear = now.year - 1;
  }

  return '$startYear/${startYear + 1}';
}
