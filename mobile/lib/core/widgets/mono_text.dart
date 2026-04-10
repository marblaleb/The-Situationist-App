import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class MonoText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final FontWeight weight;
  final double? letterSpacing;

  const MonoText(
    this.text, {
    super.key,
    this.size = 13,
    this.color = AppColors.fgPrimary,
    this.weight = FontWeight.w400,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
