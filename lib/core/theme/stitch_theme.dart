import 'package:flutter/material.dart';
import 'stitch_colors.dart';
import 'stitch_typography.dart';

/// Material 3 Theme data configured for ScanDigitize using Google Stitch Design System.
abstract class StitchTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: StitchColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: StitchColors.primary,
        onPrimary: StitchColors.onPrimary,
        primaryContainer: StitchColors.primaryContainer,
        onPrimaryContainer: StitchColors.onPrimaryContainer,
        secondary: StitchColors.secondary,
        onSecondary: StitchColors.onSecondary,
        secondaryContainer: StitchColors.secondaryContainer,
        onSecondaryContainer: StitchColors.onSecondaryContainer,
        tertiary: StitchColors.tertiary,
        onTertiary: StitchColors.onTertiary,
        tertiaryContainer: StitchColors.tertiaryContainer,
        onTertiaryContainer: StitchColors.onTertiaryContainer,
        error: StitchColors.error,
        onError: StitchColors.onError,
        errorContainer: StitchColors.errorContainer,
        onErrorContainer: StitchColors.onErrorContainer,
        surface: StitchColors.surface,
        onSurface: StitchColors.onSurface,
        onSurfaceVariant: StitchColors.onSurfaceVariant,
        outline: StitchColors.outline,
        outlineVariant: StitchColors.outlineVariant,
      ),
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: StitchTypography.displayLg,
        headlineLarge: StitchTypography.headlineLg,
        headlineMedium: StitchTypography.headlineMd,
        bodyLarge: StitchTypography.bodyLg,
        bodyMedium: StitchTypography.bodyMd,
        bodySmall: StitchTypography.bodySm,
        labelMedium: StitchTypography.labelMd,
        labelSmall: StitchTypography.labelSm,
      ),
      cardTheme: CardThemeData(
        color: StitchColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: StitchColors.outlineVariant, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: StitchColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
