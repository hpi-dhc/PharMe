import '../module.dart';

class Hyperlink extends StatelessWidget {
  const Hyperlink({ required this.text, required this.onTap, this.style });
  final String text;
  final void Function() onTap;
  final TextStyle? style;
  
  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: PharMeTheme.secondaryColor,
      decoration: TextDecoration.underline,
      decorationColor: PharMeTheme.secondaryColor,
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
