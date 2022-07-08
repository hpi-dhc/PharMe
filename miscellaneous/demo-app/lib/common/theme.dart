import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PharmeTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme(
        background: backgroundColor,
        brightness: Brightness.light,
        error: errorColor,
        onBackground: backgroundColor.highEmphasisOnColor,
        onError: errorColor.highEmphasisOnColor,
        onPrimary: primaryColor.highEmphasisOnColor,
        onSecondary: secondaryColor.highEmphasisOnColor,
        onSurface: surfaceColor.highEmphasisOnColor,
        onSurfaceVariant: onSurfaceColor,
        primary: primaryColor,
        primaryContainer: primaryContainer,
        secondary: secondaryColor,
        secondaryContainer: secondaryContainer,
        surface: onSurfaceColor,
        surfaceVariant: surfaceColor,
      ),
      textTheme: textTheme,
    );
  }

  // small wrapper for removing some of the boilerplate when defining the textTheme below
  static TextStyle themeFont(double size,
      [FontWeight? weight, double? spacing, Color? color]) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w400,
      letterSpacing: spacing ?? 0,
      color: color ?? Color(0xFF444648),
    );
  }

  static final textTheme = TextTheme(
    displayLarge: themeFont(57),
    displayMedium: themeFont(45),
    displaySmall: themeFont(36),
    headlineLarge: themeFont(32, FontWeight.w600),
    headlineMedium: themeFont(28, FontWeight.w600),
    headlineSmall: themeFont(24),
    titleLarge: themeFont(22),
    titleMedium: themeFont(16, FontWeight.w500),
    titleSmall: themeFont(14, FontWeight.w500),
    labelLarge: themeFont(14, FontWeight.w500),
    labelMedium: themeFont(12, FontWeight.w500),
    labelSmall: themeFont(11, FontWeight.w500),
    bodyLarge: themeFont(16),
    // default if no text-style specified
    bodyMedium: themeFont(14),
    bodySmall: themeFont(12),
  );

  static const primaryColor = MaterialColor(0xFF267DBA, {
    50: Color(0xFFF5F9FC),
    100: Color(0xFFEAF2F9),
    200: Color(0xFFC9DFEE),
    300: Color(0xFFA7CAE3),
    400: Color(0xFF68A4CF),
    500: Color(0xFF267DBA),
    600: Color(0xFF2270A6),
    700: Color(0xFF174B70),
    800: Color(0xFF123954),
    900: Color(0xFF0C2536),
  });
  static const primaryContainer = Color(0xFF225DE6);

  static const secondaryColor = MaterialColor(0xFF87A9FF, {
    50: Color(0xFFF9FBFF),
    100: Color(0xFFF3F7FF),
    200: Color(0xFFE1EAFF),
    300: Color(0xFFCEDCFF),
    400: Color(0xFFABC3FF),
    500: Color(0xFF87A9FF),
    600: Color(0xFF7997E3),
    700: Color(0xFF516699),
    800: Color(0xFF3D4D73),
    900: Color(0xFF28324A),
  });
  static const secondaryContainer = Color(0xFF7759C0);

  static const surfaceColor = Colors.white;
  static const onSurfaceColor = Color(0xFFE5E5E5);
  static const backgroundColor = Colors.white;
  static const errorColor = Color(0xCCF52A2A);
}
