import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

class PharmeTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme(
        primary: primaryColor,
        primaryVariant: primaryVariantColor,
        secondary: secondaryColor,
        secondaryVariant: secondaryVariantColor,
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
    );
  }

  static const primaryColor = MaterialColor(0xFF58A6DD, {
    50: Color(0xFFEBF4FB),
    100: Color(0xFFCDE4F5),
    200: Color(0xFFACD3EE),
    300: Color(0xFF8AC1E7),
    400: Color(0xFF71B3E2),
    500: Color(0xFF58A6DD),
    600: Color(0xFF509ED9),
    700: Color(0xFF4795D4),
    800: Color(0xFF3D8BCF),
    900: Color(0xFF2D7BC7),
  });
  static const primaryVariantColor = Color(0xFF225DE6);
  static const secondaryColor = MaterialColor(0xFFA364FD, {
    50: Color(0xFFF4ECFF),
    100: Color(0xFFE3D1FE),
    200: Color(0xFFD1B2FE),
    300: Color(0xFFBF93FE),
    400: Color(0xFFB17BFD),
    500: Color(0xFFA364FD),
    600: Color(0xFF9B5CFD),
    700: Color(0xFF9152FC),
    800: Color(0xFF8848FC),
    900: Color(0xFF7736FC),
  });
  static const secondaryVariantColor = Color(0xFF7759C0);
  static const surfaceColor = Colors.white;
  static const backgroundColor = Colors.white;
  static const errorColor = Color(0xFFB00020);
}
