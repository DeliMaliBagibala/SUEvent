import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundDark = Color(0xFF68717D);
  static const Color backgroundHeader = Color(0xFF223B61);
  static const Color cardBackground = Color(0xFF355C97);
  static const Color accentLight = Color(0xFF1B2E4B);

  static const Color textBlack = Colors.white70;
  static const Color textWhite = Colors.black54;
  static const Color iconBlack = Colors.white70;

  // Category Colors
  static const Map<String, Color> categoryColors = {
    "Food": Color(0xffb14d0f),
    "Movies": Color(0xffb10f83),
    "Clubs": Color(0xffb10f0f),
    "Games": Color(0xff0fb12a),
    "Hanging Out": Color(0xff0f12b1),
    "Sports": Color(0xFF6d0fb1),
    "Music": Color(0xff5e595b),
    "Other": Color(0xffb1b10f),
  };
}

class AppTextStyles {
  static TextStyle get headerLarge => TextStyle(
    color: AppColors.textBlack.withOpacity(0.8),
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headerMedium = TextStyle(
    color: AppColors.textBlack,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headerMediumThin = TextStyle(
    color: AppColors.textBlack,
    fontSize: 24,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyBold = TextStyle(
    color: AppColors.textBlack,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle labelLarge = TextStyle(
    color: AppColors.textBlack,
    fontSize: 20,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle dateHeader = TextStyle(
    color: AppColors.textBlack,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardSubtitle = TextStyle(
    color: AppColors.textBlack,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
  );

  static const TextStyle buttonSmall = TextStyle(
    color: AppColors.textBlack,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    height: 1,
  );

  static const TextStyle hintText = TextStyle(
    color: Colors.black54,
  );
}

class AppDimens {
  static const double pagePadding = 20.0;
  static const double cardRadius = 16.0;
  static const double smallRadius = 8.0;
  static const double buttonRadius = 20.0;

  static const double iconSmall = 20.0;
  static const double iconMedium = 32.0;
  static const double iconLarge = 40.0;
}
