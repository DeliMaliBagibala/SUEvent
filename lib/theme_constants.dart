import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundDark = Color(0xFF141E61);
  static const Color backgroundHeader = Color(0xFF0F044C);
  static const Color cardBackground = Color(0xFF234C6A);
  static const Color accentLight = Color(0xFF234C6A);

  static const Color textBlack = Colors.white70;
  static const Color textWhite = Colors.black54;
  static const Color iconBlack = Colors.white70;

  // Category Colors
  static const Map<String, Color> categoryColors = {
    "Food": Color(0xff84004B),
    "Movies": Color(0xff69003B),
    "Clubs": Color(0xff820300),
    "Games": Color(0xff006707),
    "Hanging Out": Color(0xff2B0670),
    "Sports": Color(0xFF360357),
    "Music": Color(0xff024251),
    "Other": Color(0xff828100),
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
