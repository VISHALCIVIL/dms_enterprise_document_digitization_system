import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'stitch_colors.dart';

/// Inter Typography System based on Google Stitch Design Guidelines.
abstract class StitchTypography {
  static TextStyle displayLg = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: -0.72,
    color: StitchColors.onSurface,
  );

  static TextStyle headlineLg = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    letterSpacing: -0.28,
    color: StitchColors.onSurface,
  );

  static TextStyle headlineLgMobile = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    color: StitchColors.onSurface,
  );

  static TextStyle headlineMd = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    color: StitchColors.onSurface,
  );

  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: StitchColors.onSurface,
  );

  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: StitchColors.onSurface,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: StitchColors.onSurfaceVariant,
  );

  static TextStyle labelMd = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    color: StitchColors.onSurface,
  );

  static TextStyle labelSm = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
    color: StitchColors.onSurfaceVariant,
  );
}
