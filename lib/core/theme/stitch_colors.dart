import 'package:flutter/material.dart';

/// Google Stitch Design System Color Palette for ScanDigitize.
/// Enterprise Blue, Corporate Slate, and Material 3 Tonal Surfaces.
abstract class StitchColors {
  // Primary Palette (Enterprise Blue)
  static const Color primary = Color(0xFF00288E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1E40AF);
  static const Color onPrimaryContainer = Color(0xFFA8B8FF);
  static const Color primaryFixed = Color(0xFFDDE1FF);
  static const Color onPrimaryFixed = Color(0xFF001453);

  // Secondary Palette (Corporate Slate)
  static const Color secondary = Color(0xFF505F76);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD0E1FB);
  static const Color onSecondaryContainer = Color(0xFF54647A);

  // Tertiary Palette
  static const Color tertiary = Color(0xFF611E00);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF872D00);
  static const Color onTertiaryContainer = Color(0xFFFFA583);

  // Surface & Canvas Tonal Levels
  static const Color background = Color(0xFFF7F9FB);
  static const Color onBackground = Color(0xFF191C1E);
  static const Color surface = Color(0xFFF7F9FB);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF444653);
  static const Color surfaceDim = Color(0xFFD8DADC);
  static const Color surfaceBright = Color(0xFFF7F9FB);
  static const Color surfaceVariant = Color(0xFFE0E3E5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);

  // Borders & Outlines
  static const Color outline = Color(0xFF757684);
  static const Color outlineVariant = Color(0xFFC4C5D5);

  // Semantic Status Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldContainer = Color(0xFFD1FAE5);
  static const Color emeraldText = Color(0xFF065F46);

  static const Color amber = Color(0xFFF59E0B);
  static const Color amberContainer = Color(0xFFFEF3C7);
  static const Color amberText = Color(0xFF92400E);
}
