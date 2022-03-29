import 'package:flutter/widgets.dart';

class RadiantGradientMask extends StatelessWidget {
  const RadiantGradientMask({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(255, 88, 166, 221),
          Color.fromARGB(255, 135, 169, 255)
        ],
      ).createShader(bounds),
      child: child,
    );
  }
}
