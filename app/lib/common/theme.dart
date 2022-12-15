import 'package:google_fonts/google_fonts.dart';

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

  // small wrapper for removing some of the boilerplate when defining the textTheme below
  static TextStyle themeFont(double size,
      [FontWeight? weight, double? spacing, Color? color]) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w400,
      letterSpacing: spacing ?? 0,
      color: color ?? PharMeTheme.onSurfaceText,
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

  static Icon starIcon({required bool isStarred, double? size}) {
    return Icon(isStarred ? Icons.star_rounded : Icons.star_border_rounded,
        size: size, color: primaryColor);
  }
}

extension WarningLevelColor on WarningLevel {
  static final _colorMap = {
    WarningLevel.danger.name: Color(0xffffafaf),
    WarningLevel.warning.name: Color(0xffffebcc),
    WarningLevel.ok.name: Color(0xffcfe8cf),
  };

  Color get color => WarningLevelColor._colorMap[name]!;
}
