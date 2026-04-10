import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get monoUI => GoogleFonts.jetBrainsMono(
        color: AppColors.fgPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.2,
      );

  static TextStyle get monoUISecondary => GoogleFonts.jetBrainsMono(
        color: AppColors.fgSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.2,
      );

  static TextStyle get monoDisplay => GoogleFonts.spaceMono(
        color: AppColors.fgPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 4,
      );

  static TextStyle get monoDisplayLarge => GoogleFonts.spaceMono(
        color: AppColors.fgPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 4,
      );

  static TextStyle get body => GoogleFonts.inter(
        color: AppColors.fgPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        height: 1.6,
      );

  static TextStyle get timestamp => GoogleFonts.jetBrainsMono(
        color: AppColors.fgSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get label => GoogleFonts.jetBrainsMono(
        color: AppColors.fgSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
      );
}
