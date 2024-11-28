import 'module.dart';

class PharMeTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        error: errorColor,
        onError: errorColor.highEmphasisOnColor,
        onPrimary: primaryColor.highEmphasisOnColor,
        onSecondary: secondaryColor.highEmphasisOnColor,
        onSurface: surfaceColor.highEmphasisOnColor,
        onSurfaceVariant: onSurfaceColor,
        primary: primaryColor,
        primaryContainer: primaryContainer,
        secondary: secondaryColor,
        secondaryContainer: secondaryContainer,
        surface: surfaceColor,
        surfaceContainerHighest: surfaceColor,
      ),
      textTheme: textTheme,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        dragHandleColor: onSurfaceColor,
      )
    );
  }

  // small wrapper for removing some of the boilerplate when defining the
  // textTheme below
  static TextStyle themeFont(double size,
      [FontWeight weight = FontWeight.w400,
      double spacing = 0,
      double lineHeight = 1.2,
      Color color = PharMeTheme.onSurfaceText]) {
    return TextStyle(
        fontFamily: 'Helvetica',
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        height: lineHeight,
        color: color);
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

  static const sinaiCyanCode = 0xff01aeef;
  static const sinaiMagentaCode = 0xffd80b8c;
  static const sinaiPurpleCode = 0xff221f73;

  static final sinaiCyan = Color(sinaiCyanCode);
  static final sinaiMagenta = Color(sinaiMagentaCode);
  static final sinaiPurple = Color(sinaiPurpleCode);

  static final primaryColor =
    MaterialColorAutoShades.fromPrimary(sinaiCyanCode);
  static final primaryContainer = primaryColor.shade200;

  static final secondaryColor =
    MaterialColorAutoShades.fromPrimary(sinaiMagentaCode);
  static final secondaryContainer = secondaryColor.shade200;

  static const surfaceColor = Colors.white;
  static const onSurfaceColor = Color(0xffe5e5e5);
  static const onSurfaceText = Color(0xff444648);
  static const backgroundColor = Colors.white;
  static const errorColor = Color(0xccf52a2a);
  static final borderColor = Colors.black.withOpacity(.2);
  static final iconColor = darkenColor(PharMeTheme.onSurfaceText, -0.1);
  static final subheaderColor = Colors.grey[600];

  static const smallSpace = 8.0;
  static const defaultPagePadding = smallSpace;
  static const smallToMediumSpace = 12.0;
  static const mediumSpace = 16.0;
  static const mediumToLargeSpace = 24.0;
  static const largeSpace = 32.0;

  static const outerCardRadius = mediumSpace;
  static const innerCardRadius = smallToMediumSpace;

  static final appBarTheme = AppBarTheme(
    backgroundColor: surfaceColor,
    foregroundColor: onSurfaceText,
    leadingWidth: largeSpace + mediumToLargeSpace,
  );
}

class AppBarTheme {
  AppBarTheme({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.leadingWidth
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final double leadingWidth;
  final elevation = 0.0;
  final centerTitle = false;
}
