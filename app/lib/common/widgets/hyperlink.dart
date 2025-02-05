import '../module.dart';

class Hyperlink extends StatelessWidget {
  const Hyperlink({
    required this.text,
    required this.onTap,
    this.style,
    this.color,
  });
  final String text;
  final void Function() onTap;
  final TextStyle? style;
  final Color? color;
  
  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: color ?? PharMeTheme.secondaryColor,
      decoration: TextDecoration.underline,
      decorationColor: color ?? PharMeTheme.secondaryColor,
    );
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: style != null ? style!.merge(linkStyle) : linkStyle,
      ),
    );
  }
} 
