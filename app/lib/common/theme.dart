import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PharmeTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme(
        primary: primaryColor,
        primaryContainer: primaryVariantColor,
        secondary: secondaryColor,
        secondaryContainer: secondaryVariantColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: primaryColor.highEmphasisOnColor,
        onSecondary: secondaryColor.highEmphasisOnColor,
        onSurface: surfaceColor.highEmphasisOnColor,
        onBackground: backgroundColor.highEmphasisOnColor,
        onError: errorColor.highEmphasisOnColor,
        brightness: Brightness.light,
      ),
      textTheme: textTheme,
    );
  }

  static final textTheme = TextTheme(
    titleLarge: GoogleFonts.inter(
      fontSize: 72,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.25,
      color: Color(0xFF444648),
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 56,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.25,
      color: Color(0xFF444648),
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 42,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.25,
      color: Color(0xFF444648),
    ),
    headline1: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: Color(0xFF444648),
    ),
    headline2: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Color(0xFF444648),
    ),
    headline3: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF444648),
    ),
    headline4: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFF444648),
    ),
    headline5: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Color(0xFF444648),
    ),
    headline6: GoogleFonts.inter(
      fontSize: 8,
      fontWeight: FontWeight.w500,
      color: Color(0xFF444648),
    ),
    bodyText1: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xFF444648),
    ),
    bodyText2: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.15,
      color: Color(0xFF444648),
    ),
    button: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xFF444648),
    ),
    caption: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: Color(0xFF444648),
    ),
    overline: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Color(0xFF444648),
    ),
    subtitle1: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.50,
      color: Color(0xFF444648),
    ),
    subtitle2: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.50,
      color: Color(0xFF444648),
    ),
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
  static const primaryVariantColor = Color(0xFF225DE6);

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
  static const secondaryVariantColor = Color(0xFF7759C0);

  static const surfaceColor = Colors.white;
  static const backgroundColor = Colors.white;
  static const errorColor = Color(0xFFB00020);
}
