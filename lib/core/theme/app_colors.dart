import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // Light Theme Colors
  static const Color lightPrimary = Colors.indigo;
  static const Color lightSecondary = Color(0xFF7E57C2); // Light Purple
  static const Color lightAccent = Color(0xFFBA68C8);

  static const Color lightBackground = Color(0xFFF7F7FB);
  static const Color lightCard = Colors.white;

  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFFBB86FC); // Lighter Purple for Dark Theme
  static const Color darkSecondary = Color(0xFF7E57C2); // Lighter Purple for Dark Theme
  static const Color darkAccent = Color(0xFF3700B3);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);

  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF757575);

  // Common Colors
  static const Color border = Color(0xFFEEEEEE);

  // Method to get the correct primary color depending on the theme
  static Color getPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkPrimary : lightPrimary;
  }

  static Color getSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkSecondary : lightSecondary;
  }

  static Color getAccent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkAccent : lightAccent;
  }

  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  }
}
