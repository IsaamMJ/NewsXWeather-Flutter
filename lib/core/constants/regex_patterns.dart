class RegexPatterns {
  // Regex for Email validation
  static final RegExp emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  // Regex for Password validation (example: at least 8 characters, 1 uppercase, 1 number, 1 special character)
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );
}
