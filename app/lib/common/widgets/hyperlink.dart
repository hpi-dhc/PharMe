import '../module.dart';

class Hyperlink extends StatelessWidget {
  const Hyperlink({ required this.text, required this.onTap });
  final String text;
  final void Function() onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: PharMeTheme.secondaryColor,
          decoration: TextDecoration.underline,
          decorationColor: PharMeTheme.secondaryColor,
        ),
      ),
    );
  }
} 
