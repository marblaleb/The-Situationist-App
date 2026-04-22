import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.bgVoid,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.bgSurface,
      primary: AppColors.phosphor,
      secondary: AppColors.amber,
      error: AppColors.danger,
    ),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'SpaceMono',
        color: AppColors.fgPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 4,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        color: AppColors.fgPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        height: 1.6,
      ),
      labelSmall: TextStyle(
        fontFamily: 'JetBrainsMono',
        color: AppColors.fgSecondary,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.fgMuted,
      thickness: 1,
      space: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.fgMuted),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.fgMuted),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.phosphor),
      ),
      hintStyle: TextStyle(
        fontFamily: 'JetBrainsMono',
        color: AppColors.fgMuted,
        fontSize: 13,
      ),
    ),
  );
}
