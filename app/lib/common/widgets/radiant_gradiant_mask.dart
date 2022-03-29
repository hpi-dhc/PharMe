import 'package:flutter/widgets.dart';

class RadiantGradientMask extends StatelessWidget {
  const RadiantGradientMask({
    required this.child,
    required this.colors,
  });
  final Widget child;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(bounds),
      child: child,
    );
  }
}
