import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class VoidButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color borderColor;

  const VoidButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor = AppColors.fgMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.3 : 1.0,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.fgPrimary,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: borderColor, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
            color: AppColors.fgPrimary,
          ),
        ),
      ),
    );
  }
}
