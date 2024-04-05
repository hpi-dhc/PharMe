import 'dart:async';

import '../module.dart';

enum ButtonDirection { forward, backward }

class DirectionButton extends StatelessWidget {
  const DirectionButton({
    super.key,
    required this.direction,
    required this.text,
    required this.onPressed,
    this.emphasize = false,
    this.onDarkBackground = false,
  });

  final ButtonDirection direction;
  final String text;
  final FutureOr<void> Function() onPressed;
  final bool emphasize;
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    const lightColor = Colors.white;
    const darkColor = PharMeTheme.onSurfaceText;
    final buttonStyle = emphasize
      ? ElevatedButton.styleFrom(
        backgroundColor: onDarkBackground ? lightColor : darkColor,
      )
      : null;
    final textColor = emphasize == onDarkBackground
      ? PharMeTheme.onSurfaceText
      : Colors.white;
    final separator = SizedBox(width: 8);
    final iconData = direction == ButtonDirection.forward
      ? Icons.arrow_forward_rounded
      : Icons.arrow_back_rounded;
    final icon = Icon(
      iconData,
      color: textColor,
      size: 32,
    );
    final buttonText = Text(
      text,
      style: PharMeTheme.textTheme.titleLarge!.copyWith(color: textColor),
    );
    final buttonContent = direction == ButtonDirection.forward
      ? [ separator, buttonText, separator, icon ]
      : [ icon, separator, buttonText, separator ];
    return TextButton(
      style: buttonStyle,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: buttonContent,
      ),
    );
  }

}