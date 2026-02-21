class ValidationRule {
  final String? Function() validate;

  ValidationRule(this.validate);
}

class ValidationRunner {
  static String? run(List<ValidationRule> rules) {
    for (final rule in rules) {
      final error = rule.validate();
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}
