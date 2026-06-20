import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryOrange,
      primary: AppColors.primaryOrange,
      secondary: AppColors.secondaryBlue,
      surface: AppColors.card,
    ),

    scaffoldBackgroundColor: AppColors.background,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryOrange,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
  color: AppColors.card,
  elevation: 3,

  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),

  shadowColor: Colors.black12,

  margin: const EdgeInsets.all(8),
),

    elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryOrange,
    foregroundColor: Colors.white,

    elevation: 4,

    padding: const EdgeInsets.symmetric(
      vertical: 16,
      horizontal: 20,
    ),

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
),

    inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: Colors.white,

  contentPadding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  ),

  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(
      color: AppColors.border,
    ),
  ),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(
      color: AppColors.border,
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(
      color: AppColors.primaryOrange,
      width: 2,
    ),
  ),
),
  );





static ThemeData darkTheme = ThemeData(
  useMaterial3: true,

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFF7A00),
    secondary: Color(0xFF1E5EFF),
  ),

  scaffoldBackgroundColor: const Color(
    0xFF121212,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    centerTitle: true,
  ),

  cardTheme: const CardThemeData(
    color: Color(0xFF1E1E1E),
    elevation: 3,
  ),

  elevatedButtonTheme:
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor:
          AppColors.primaryOrange,
      foregroundColor: Colors.white,
    ),
  ),
);

}