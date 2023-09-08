import 'module.dart';

class PharMeTheme {
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

  static final primaryColor = MaterialColorAutoShades.fromPrimary(0xff01aeef);
  static final primaryContainer = primaryColor.shade200;

  static final secondaryColor = MaterialColorAutoShades.fromPrimary(0xffd80b8c);
  static final secondaryContainer = secondaryColor.shade200;

  static const surfaceColor = Colors.white;
  static const onSurfaceColor = Color(0xffe5e5e5);
  static const onSurfaceText = Color(0xff444648);
  static const backgroundColor = Colors.white;
  static const errorColor = Color(0xccf52a2a);
  static final borderColor = Colors.black.withOpacity(.2);

  static const smallSpace = 8.0;
  static const smallToMediumSpace = 12.0;
  static const mediumSpace = 16.0;
  static const largeSpace = 32.0;

  static final appBarTheme = AppBarTheme(
    backgroundColor: surfaceColor,
    foregroundColor: onSurfaceText,
    leadingWidth: smallSpace + mediumSpace
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

extension WarningLevelColor on WarningLevel {
  static final _colorMap = {
    WarningLevel.red.name: Color(0xffffafaf),
    WarningLevel.yellow.name: Color(0xffffebcc),
    WarningLevel.green.name: Color(0xffcfe8cf),
    WarningLevel.none.name: Color(0xffcfe8cf),
  };

  Color get color => WarningLevelColor._colorMap[name]!;
}
