import 'package:flutter/material.dart';

enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

PasswordStrength checkPasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.empty;

  final hasUppercase = password.contains(RegExp(r'[A-Z]'));
  final hasLowercase = password.contains(RegExp(r'[a-z]'));
  final hasDigits = password.contains(RegExp(r'[0-9]'));
  final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  final length = password.length;

  int score = 0;
  if (length >= 8) score++;
  if (length >= 12) score++;
  if (hasUppercase) score++;
  if (hasLowercase) score++;
  if (hasDigits) score++;
  if (hasSpecial) score++;

  if (score < 2) return PasswordStrength.weak;
  if (score < 4) return PasswordStrength.medium;
  return PasswordStrength.strong;
}

Color getPasswordStrengthColor(PasswordStrength strength) {
  switch (strength) {
    case PasswordStrength.empty:
      return Colors.grey.shade300;
    case PasswordStrength.weak:
      return Colors.red;
    case PasswordStrength.medium:
      return Colors.orange;
    case PasswordStrength.strong:
      return Colors.green;
  }
}
