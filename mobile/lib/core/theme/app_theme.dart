import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.spaceMono(
        color: AppColors.fgPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 4,
      ),
      bodyMedium: GoogleFonts.inter(
        color: AppColors.fgPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        height: 1.6,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
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
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgElevated,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.fgMuted),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.fgMuted),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.phosphor),
      ),
      hintStyle: GoogleFonts.jetBrainsMono(
        color: AppColors.fgMuted,
        fontSize: 13,
      ),
    ),
  );
}
