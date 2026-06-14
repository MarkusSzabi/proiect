import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );
}