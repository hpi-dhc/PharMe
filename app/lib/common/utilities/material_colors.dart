import '../module.dart';

extension MaterialColorAutoShades on MaterialColor {
  static MaterialColor fromPrimary(int primary) {
    final color = Color(primary);
    final r = color.red, g = color.green, b = color.blue;
    final shades = <double>[.05] + List.generate(9, (i) => (i + 1) * 0.1);

    final swatch = shades.fold<Map<int, Color>>({}, (swatch, shade) {
      final rs = 0.5 - shade;
      swatch[(shade * 1000).round()] = Color.fromRGBO(
        r + ((rs < 0 ? r : (255 - r)) * rs).round(),
        g + ((rs < 0 ? g : (255 - g)) * rs).round(),
        b + ((rs < 0 ? b : (255 - b)) * rs).round(),
        1,
      );
      return swatch;
    });

    return MaterialColor(color.value, swatch);
  }
}
